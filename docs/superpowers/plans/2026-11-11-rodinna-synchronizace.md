# Rodinná synchronizace profilů – implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Jeden profil každého člena rodiny – body, odměny, odznaky, vzhled, historie a žebříčky – stejný na všech rodinných zařízeních, synchronizovaný jen přes domácí Wi-Fi.

**Architecture:** Každá změna dat profilů a historie se zapíše jako **operace** do deníku `sync_ops` (globální id, hybridní logické hodiny). Čistá funkce `foldFamily(ops)` z celého deníku (seřazeného deterministicky) spočítá stav rodiny podle pravidel zadání (kap. 6) a **materializer** ho promítne do stávajících tabulek, které dál čtou obrazovky. Zařízení si přes WebSocket (ověřeno HMAC klíčem rodiny) vymění chybějící operace podle vektoru verzí; po sloučení se stav přepočítá.

**Tech Stack:** Flutter 3.47.8, Drift (schéma v6), Riverpod 3, `crypto` (HMAC-SHA256, už v projektu), `mobile_scanner` + `qr_flutter` (už v projektu), síťová vrstva `lib/core/multiplayer` (UDP oznámení, `NetServer`, `SocketChannel`).

**Spec:** `docs/superpowers/specs/2026-11-11-rodinna-synchronizace-design.md`

## Global Constraints
- Jen domácí Wi-Fi, žádný internet, účty ani cloud; žádné nové balíčky.
- Body se nikdy neztratí ani nezdvojí; smazaný profil se nevrátí; stav nezávisí na pořadí doručení.
- Bez rodiny se aplikace chová přesně jako dnes (všechny stávající testy zůstanou zelené beze změny očekávání).
- Nesdílí se: nastavení zařízení, aktivní hráč, rozehrané partie (`saved_sessions`), poslední nastavení her (`game_settings_last`).
- Synchronizace neběží během rozehrané partie; síťová hra má přednost.
- Texty CS/EN/ES; 360 dp při 130 % bez přetečení.
- Výkon: první synchronizace stovek partií ≤ ~10 s; přepočet stavu po výměně ≤ 300 ms pro 1000 partií (test).

## Review Focus
1. **Spojení profilů na jednom zařízení, zatímco jiné offline dál zapisuje body „starému“ profilu** → body skončí u spojeného profilu, nic se neztratí (Task 1, test `alias ops arriving later still land on the merged profile`).
2. **Zdvojená nebo přeházená výměna** (stejná dávka operací 2×, opačné pořadí) → stejný stav (Task 1 test permutací, Task 4 test zdvojení dávky).
3. **Aktualizace ze v0.6.1 s reálnými daty** → žádná změna zůstatků, úrovní, odznaků, historie ani aktivního hráče (Task 2 test migrace s naplněnou v5).
4. **Telefon kamaráda ve stejné Wi-Fi** → nespojí se, nic nedostane, nic nepošle (Task 4 test `a stranger without the family key gets nothing`).
5. **Síťová partie rodiny** → v historii jednou se všemi hráči, body každému jen jednou (Task 7 test).

---

### Task 1: Operace, hodiny a čistý výpočet stavu rodiny

**Files:**
- Create: `lib/core/family/hlc.dart`, `lib/core/family/family_op.dart`, `lib/core/family/family_state.dart`, `lib/core/family/fold.dart`
- Test: `test/core/family/fold_test.dart`, `test/core/family/hlc_test.dart`

**Interfaces – Produces:**
- `class Hlc { final int millis; final int counter; final String deviceId; Hlc tick(int nowMillis); Hlc receive(Hlc remote, int nowMillis); int compareTo(Hlc o); String pack(); static Hlc unpack(String) }` – pořadí: millis, counter, deviceId.
- `class FamilyOp { final String origin; final int seq; final Hlc clock; final OpBody body; Map<String,Object?> toJson(); static FamilyOp? fromJson(Object?) }` – identita `(origin, seq)`.
- `sealed class OpBody` s variantami (všechny id jsou UUID řetězce):
  - `ProfileCreated(uid, name, avatar json, favoriteSeat?)`, `ProfileUpdated(uid, name?, avatar?, favoriteSeat?)`, `ProfileDeleted(uid)`, `ProfilesMerged(fromUid, intoUid)`
  - `MatchRecorded(matchUid, gameId, playedAtMs, durationMs, difficulty?, participants: [ {seat, playerUid?, robot, place, score, stars} ], points: [ {entryUid, playerUid, amount, reason, detail?} ], counters: [ {playerUid, key, delta} ])`
  - `PointsGift(entryUid, playerUid, amount)`, `ItemBought(itemUid, playerUid, itemId, price)`, `BadgeAwarded(playerUid, badgeId, rewardPoints)`, `PointsReset(resetUid, playerUid, amount, itemIds)`
  - `DeviceJoined(deviceId, name)`, `DeviceRemoved(deviceId)`
- `class FamilyState` (neměnná): `Map<String, ProfileView> profiles` (uid → name, nameKey, avatar json, favoriteSeat, createdClock, `pairCandidate` uid?), `List<MatchView> matches`, `Map<String, List<LedgerView>> ledger` (uid → zápisy s `entryUid, amount, reason, detail, matchUid?, atMs`), `Map<String, Map<String,int>> counters`, `Map<String, Map<String,int>> badges` (badgeId → earnedAtMs), `Map<String, Set<String>> items`, `Map<String, List<RefundNotice>> refunds`, `Map<String, DeviceView> devices`, `Set<String> deleted`, `Map<String,String> aliases`.
- `FamilyState foldFamily(Iterable<FamilyOp> ops)` – seřadí podle `clock`, pak `(origin, seq)`; čistá funkce.

- [ ] **Step 1: Napsat testy** v `fold_test.dart` (každý s konkrétními čísly):
  - `points are the sum of ledger entries; the same op twice counts once`
  - `same result for every order of the same ops` (100 náhodných permutací ze `SeededRandom`, porovnat `FamilyState` přes JSON)
  - `the same item bought on two devices: one item, refund "duplicate" of its price, exactly once`
  - `overspend offline: balance 100, hat 100 at t=10, glasses 100 at t=20 → glasses refunded ("notEnough"), balance 0, a RefundNotice for glasses`
  - `badge reward paid once when the badge is awarded on two devices`
  - `reset clears only the amount and items it lists; a later gift from another device stays`
  - `a deleted profile never comes back, even with points or a match recorded for it later` (smazání má přednost)
  - `merging B into A: sums ledger, unions items (duplicates refunded), badges with the earliest date, counters summed, B's matches show A`
  - `alias ops arriving later still land on the merged profile`
  - `name and avatar: the last update wins (by clock, then device id)`
  - `two profiles with the same name not merged: the later-created one is "Babička 2" with pairCandidate = the other`
  - `a network match recorded by two devices merges into one match by matchUid, participants by seat (playerUid wins over null), points from both devices kept once each`
  - `a removed device stays in devices with removed = true`
- [ ] **Step 2: Spustit** `flutter test test/core/family` → FAIL (chybí `lib/core/family`).
- [ ] **Step 3: Implementovat** `hlc.dart`, `family_op.dart` (JSON s klíčem `t` pro typ, neznámý typ → `fromJson` vrátí null a fold ho přeskočí), `family_state.dart`, `fold.dart`. Pořadí kroků foldu: (1) odstranit operace smazaných uid (po rozlišení aliasů, aliasy rekurzivně, cyklus → menší uid vyhrává); (2) profily a LWW; (3) partie sloučit podle matchUid; (4) zápisy bodů, dárky, odměny odznaků s identitou `badge:<uid>:<badgeId>`; (5) nákupy v pořadí hodin: duplicita → refund `duplicate`, zůstatek by klesl pod 0 → refund `notEnough`, identita refundu = `refund:<itemUid>`; (6) reset: zápis `-amount`, odebrat jeho `itemIds`; (7) kolize jmen: pozdější podle `createdClock` dostane příponu ` 2`, ` 3`…
- [ ] **Step 4: Spustit** `flutter test test/core/family` → PASS.
- [ ] **Step 5: Commit** `feat(family): operations, hybrid clock and a pure fold of the family state`.

### Task 2: Schéma v6, převod dat a materializer

**Files:**
- Modify: `lib/core/db/tables.dart` (sloupce `uid` TEXT UNIQUE NULL u `Players`, `Matches`, `PointsLedger`), `lib/core/db/app_database.dart` (`schemaVersion => 6`, krok `from < 6`)
- Create: tabulka `SyncOps` (origin TEXT, seq INT, clock TEXT, json TEXT, PK origin+seq) a `FamilyDevices` (deviceId PK, name, lastSeenMs, removed BOOL) v `tables.dart`; `lib/core/family/family_store.dart`, `lib/core/family/materializer.dart`, `lib/core/family/legacy_import.dart`
- Run: `MSYS_NO_PATHCONV=1 dart run drift_dev make-migrations` (snapshot v6, viz CLAUDE.md)
- Test: `test/core/db/migration_test.dart` (rozšířit), `test/core/family/materializer_test.dart`

**Interfaces – Produces:**
- `class FamilyStore { FamilyStore(AppDatabase db); Future<String> deviceId(); Future<Hlc> nextClock(); Future<void> append(OpBody body); Future<int> insertRemote(Iterable<FamilyOp> ops) /* vrací počet nových */; Future<Map<String,int>> versionVector(); Future<List<FamilyOp>> opsAfter(Map<String,int> theirs); Future<List<FamilyOp>> all(); Future<void> rebuild() /* fold + materialize v jedné transakci */; Stream<void> changes }`. Id zařízení a stav hodin v `app_settings` (`deviceId`, `hlc`).
- `Future<void> materialize(AppDatabase db, FamilyState state)` – projde stav a **zachová celočíselná id** existujících řádků podle `uid` (aktivní hráč, uložené partie a poslední nastavení dál odkazují na stejná čísla): upsert hráčů, smazání smazaných, přepis partií, účastníků, zápisů bodů, počítadel, odznaků a věcí jen tam, kde se liší.
- `Future<void> importLegacy(AppDatabase db, FamilyStore store)` – jednorázově při migraci: každému existujícímu řádku přidělí uid a zapíše ekvivalentní operace (ProfileCreated, MatchRecorded s body a bez počítadel, PointsGift/ItemBought/PointsReset jako „importované“ zápisy se zachovanými částkami, BadgeAwarded s `rewardPoints: 0` – odměny jsou už v importovaných bodech, počítadla jako jedna MatchRecorded-like operace `counters`).
- [ ] **Step 1: Testy:** migrace naplněné v5 databáze (2 hráči, 3 partie, dárek, nákup, reset, odznak, počítadla, aktivní hráč, uložená partie s `HumanSeat(id)`) → po v6 stejné zůstatky, celkem získané, úrovně, věci, odznaky, počítadla, historie, aktivní hráč a uložená partie; `rebuild()` po importu nic nezmění; materializer zachová int id při přejmenování a po spojení profilů smaže řádek B a přepíše jeho partie na A.
- [ ] **Step 2: Spustit** `flutter test test/core/db test/core/family` → FAIL.
- [ ] **Step 3: Implementovat** tabulky, krok migrace (`from < 6`: přidat sloupce a tabulky, pak `importLegacy` v `beforeOpen` jen když chybí `deviceId`), `FamilyStore`, `materializer.dart`, `legacy_import.dart`; vygenerovat drift kód a snapshot.
- [ ] **Step 4: Spustit** `flutter test test/core/db test/core/family` → PASS.
- [ ] **Step 5: Commit** `feat(family): schema v6 with the operation log, legacy import and materializer`.

### Task 3: Všechny zápisy přes deník

**Files:**
- Modify: `lib/core/players/player_repository.dart` (create/update/delete), `lib/core/points/points_repository.dart` (gift, addGameLines, spend, addReset), `lib/core/shop/shop_repository.dart` (buy, reset, equip/unequip přes update), `lib/core/stats/stats_repository.dart` (recordMatch, awardBadge), `lib/app/stats_service.dart` (jedna operace `MatchRecorded` na partii včetně bodů a počítadel; `matchUid` parametr, výchozí nové UUID), `lib/app/providers.dart` (`familyStoreProvider`)
- Test: celá stávající sada + `test/core/family/write_through_test.dart`

**Interfaces – Consumes:** `FamilyStore.append`, `FamilyStore.rebuild`. **Produces:** `StatsService.recordFinished({..., String? matchUid})`; `Future<List<String>> StatsService.checkBadges(int playerId)` (vyhodnotí odznaky nad aktuálními počítadly a historií, zapíše `BadgeAwarded` pro nové a vrátí jejich id – volá se po synchronizaci); `ShopRepository.buy` dál vrací `BuyResult` (kontrola zůstatku na zařízení zůstává; refund `notEnough` nastává jen po synchronizaci).
- [ ] **Step 1: Test** `write_through_test.dart`: po create/gift/buy/match/reset/delete je v deníku odpovídající operace a `rebuild()` dá stejné tabulky jako přímý zápis (porovnat zůstatky, věci, odznaky, historii).
- [ ] **Step 2: Spustit** → FAIL.
- [ ] **Step 3: Implementovat:** repozitáře zapisují operaci a pak inkrementálně aplikují (nebo zavolají `rebuild()`; volba podle výkonu – cíl ≤ 300 ms, test v Task 1/2 hlídá). Unikátnost jména dál kontroluje `PlayerRepository` lokálně.
- [ ] **Step 4: Spustit** `flutter test --timeout 90s` (celá sada, na pozadí) → PASS beze změny stávajících očekávání.
- [ ] **Step 5: Commit** `refactor(family): profiles, points, shop and matches write through the operation log`.

### Task 4: Rodina a výměna operací (bez UI)

**Files:**
- Create: `lib/core/family/family_identity.dart` (id rodiny, klíč 32 B, `FamilyTicket` = `deskovky://family?id=…&key=…&ip=…&port=…`, parse/toUri jako `JoinTicket`), `lib/core/family/sync_protocol.dart` (zprávy JSON: `fHello{v, family, device, nonce}`, `fProof{hmac}`, `fHave{vector}`, `fOps{ops}`, `fDone`, `fBye{reason}`, `fInvite{...}` – rezervováno pro Task 7), `lib/core/family/family_sync.dart` (`FamilySession` nad `MessageChannel`)
- Test: `test/core/family/family_sync_test.dart` (loopback)

**Interfaces – Produces:**
- `class FamilyIdentity { familyId; key; static FamilyIdentity create(Random); }` uložená v `app_settings` (`familyId`, `familyKey`).
- `Future<SyncOutcome> syncOver(MessageChannel ch, {required FamilyStore store, required FamilyIdentity family, required bool initiator})` – vzájemné ověření (HMAC-SHA256 klíčem nad nonce obou stran a id zařízení; klíč se neposílá), výměna vektorů, poslání chybějících operací po dávkách ≤ 500, `insertRemote` + `rebuild`; odmítnutí odebraného zařízení (`DeviceRemoved` ve stavu) a jiné verze protokolu (`familyProtocolVersion = 1`).
- [ ] **Step 1: Testy:** `two devices converge after offline changes on both`; `three devices converge in any meeting order`; `the same batch delivered twice changes nothing`; `a stranger without the family key gets nothing and sends nothing`; `a removed device is refused`; `a different protocol version is refused with a reason`; `first sync of 500 matches finishes in time` (≤ 10 s na loopbacku).
- [ ] **Step 2–4:** FAIL → implementace → PASS.
- [ ] **Step 5: Commit** `feat(family): family identity and authenticated operation exchange`.

### Task 5: Rodina v aplikaci – QR, vyhledání, automatická synchronizace

**Files:**
- Create: `lib/core/family/family_beacon.dart` (UDP oznámení na portu 47124 s otiskem `sha256(familyId)`, id zařízení a uid aktivního hráče každých 10 s; naslouchání; seznam viděných rodinných zařízení pro pozvánky), `lib/app/family_controller.dart` (Riverpod: stav rodiny, spuštění serveru, spojení s viděnými rodinnými zařízeními, spouštěče: start, návrat do popředí, po partii/nákupu/úpravě; pauza během obrazovky hry), `lib/features/family/family_screen.dart` (sekce „Rodina“: založit, QR, seznam zařízení s „naposledy“, Odebrat), `lib/features/family/join_family_screen.dart` (skener; varování při jiné rodině)
- Modify: `lib/features/settings/parents_screen.dart` (vstup do „Rodina“ a „Připojit se k rodině“ za rodičovskou otázkou), skener „Připojit se ke hře“ rozpozná `deskovky://family` a nabídne připojení k rodině, ARB texty, router
- Test: `test/features/family/family_screen_test.dart`, `test/app/family_controller_test.dart` (falešná síť jako `FakeNetworkEnv`)
- [ ] **Step 1: Testy:** zařízení s jinou verzí protokolu → Rodina ukáže „Aktualizujte aplikaci na všech zařízeních“; po synchronizaci se udělí odznak, jehož podmínku splnil až součet ze dvou zařízení (`StatsService.checkBadges(playerId)` z Task 3), oslava jen na zařízení, kde je dítě aktivní; založení rodiny ukáže QR s platným `FamilyTicket`; připojení naskenováním stáhne profily a ukáže „Hotovo – jsi v rodině“; odebrání zařízení ho přestane synchronizovat; během hry se nesynchronizuje, po návratu na výsledky ano; drobná ikona synchronizace se ukáže na 2 s; texty se vejdou (cs/en/es, 360 dp, 130 %).
- [ ] **Step 2–4:** FAIL → implementace → PASS.
- [ ] **Step 5: Commit** `feat(family): family QR, discovery and automatic sync over Wi-Fi`.

### Task 6: Spárování profilů a vysvětlení vrácených nákupů

**Files:**
- Create: `lib/features/family/pair_profiles_screen.dart` (dvojice podle `pairCandidate` a stejného jména, ruční výběr, náhled součtu, volba jména a vzhledu – výchozí novější), `lib/features/family/refund_notice.dart` (jednorázová hláška u aktivního hráče: „Brýle se vrátily – na obě věci nebylo dost bodů.“; přečtení uložené v `app_settings`)
- Modify: `family_screen.dart` (odkaz „Možné dvojice (n)“), po připojení k rodině automaticky otevřít spárování, je-li co párovat
- Test: `test/features/family/pair_profiles_test.dart`
- [ ] **Step 1: Testy:** dvojice Viky + Viky nabídnuta a po potvrzení jeden profil se součtem bodů a duplicitním kloboukem vráceným; odmítnutí ponechá „Viky 2“; hláška o vrácení se ukáže jednou a jen správnému dítěti.
- [ ] **Step 2–4:** FAIL → implementace → PASS.
- [ ] **Step 5: Commit** `feat(family): pairing duplicate profiles and refund notices`.

### Task 7: Síťová hra v rodině – jedna partie a pozvánky

**Files:**
- Modify: `lib/core/multiplayer/protocol.dart` (`Start` + `matchUid`, `seatProfiles: Map<int,String>` globální uid rodinných profilů), `host_room.dart` (přidělí `matchUid` = `<roomCode>-<seed>`), `lib/features/game_play/game_screen.dart` (předá `matchUid` do `recordFinished`; účastník z jiného zařízení s rodinným uid se zapíše s tím uid, bez bodů), `lib/features/multiplayer/host_room_screen.dart` („Pozvat z rodiny“), `family_controller.dart` (`fInvite` přes rodinné spojení na zařízení, jehož oznámení uvádí vybraný profil jako aktivního hráče, jinak všem viděným rodinným zařízením; dialog „Táta tě zve do Pexesa – hrát?“, 60 s, přijetí = `NetworkRooms.join` s profilem, `setReady(true)`)
- Test: `test/features/multiplayer/family_network_test.dart`
- [ ] **Step 1: Testy:** síťová partie dvou rodinných zařízení → po synchronizaci jedna partie se dvěma hráči a body každému jednou; pozvánka dorazí, „Hrát“ připojí se správným profilem a připraveným stavem, „Teď ne“ / 60 s / start hry ji zruší; cizí host zůstane hostem.
- [ ] **Step 2–4:** FAIL → implementace → PASS.
- [ ] **Step 5: Commit** `feat(family): one record per family network game and invitations to family devices`.

### Task 8: Ověření a vydání
- [ ] Celá sada, `flutter analyze --fatal-infos`, emulátor (dvě instance nebo emulátor + PC přes `adb forward`: založení rodiny, připojení, synchronizace).
- [ ] Nezávislá revize celé větve (opus) s Review Focus výše; opravy Critical/Important s testy, které nejdřív selžou.
- [ ] Docs: `docs/ARCHITECTURE.md` (rodinná synchronizace), `CLAUDE.md` (jak testovat), CHANGELOG 0.7.0 (cs/en/es), verze `0.7.0+700`.
- [ ] **Ruční test u Miloše** (tablet + 2 mobily): založení a přidání přes QR, spárování Viky, hraní offline na dvou zařízeních a setkání, nákupy offline (vrácení), pozvánka do síťové hry. Push, PR, sloučení a tag jen s Milošovým výslovným souhlasem.
