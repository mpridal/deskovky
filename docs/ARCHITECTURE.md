# Architektura – Deskovky

## Volba technologie: Flutter (Dart)

Kritéria z kap. 2 zadání a jak je Flutter splňuje:

| Kritérium | Řešení |
|---|---|
| Jeden kód pro telefon i tablet | Flutter vykresluje vlastní UI; rozložení řídí třídy šířky okna (`lib/ui_kit/layout/window_size.dart`). |
| Plynulé 60 fps animace | Vlastní renderovací engine (Impeller), animace bez mostu do nativních view. |
| Zvuk – smyčka hudby + víc efektů současně | Balíčky `just_audio` / `audioplayers` (milník 5). |
| Vektorová grafika kreslená kódem | `CustomPainter` (avatary, ikony her, herní prvky). |
| Lokální perzistence | SQLite přes Drift s verzovanými migracemi (milník 3). |
| Podepsaný APK v GitHub Actions | `flutter build apk --release` + keystore z GitHub Secrets (milník 8). |

Alternativa Capacitor + TypeScript by přinesla OTA aktualizace web-bundle. Nepotřebujeme je: aplikace se aktualizuje celým APK z GitHub Releases (kap. 4), a Flutter má lepší výkon animací a kreslení.

## Struktura

Dart kód musí ležet v `lib/`, proto adresáře z kap. 8 zadání žijí pod ním:

| Zadání | Repozitář |
|---|---|
| `/app` | `lib/app` – vstupní bod, routing (`go_router`), shell s navigací |
| `/core` | `lib/core` – modely, perzistence, služby, lokalizace |
| `/ui_kit` | `lib/ui_kit` – design tokeny, komponenty, layout |
| `/features/*` | `lib/features/*` – obrazovky frameworku |
| `/games/<id>` | `lib/games/<id>` – herní moduly |
| `/assets/...` | `assets/...` |

Pravidla rozsahu pro paralelní vývoj her (kap. 13.2) proto znamenají `lib/games/<id>/**`, `assets/games/<id>/**`, `test/games/<id>/**`, `assets/audio/music/<id>.ogg`.

## Klíčová rozhodnutí

- **Routing:** `go_router` se `StatefulShellRoute.indexedStack` – 4 záložky (Hry, Hráči, Žebříčky, Nastavení), každá si drží vlastní stav.
- **Lokalizace:** `flutter_localizations` + `gen-l10n`, ARB soubory v `lib/l10n`, šablona `app_en.arb` (klíče anglicky). Výchozí jazyk podle systému: `cs` → čeština, `es` → španělština, jinak angličtina.
- **Fonty:** Baloo 2 a Nunito jako variabilní TTF přibalené v `assets/fonts` (offline). Každý `TextStyle` nastavuje `fontWeight` i `FontVariation.weight`, aby se váha správně projevila.
- **Responzivita:** compact < 600 dp (spodní lišta, 2 sloupce), medium 600–839 (rail, 3 sloupce), expanded ≥ 840 (rail, 3–4 sloupce, pravý panel).

## Data a stav (milník 3)

- **Drift (SQLite)** – `lib/core/db/`. Typované dotazy, sledování změn jako `Stream`, verzované schéma se snapshoty v `drift_schemas/` a generovaným ověřovačem migrací (`test/core/db/generated/`). Soubor DB leží v adresáři aplikace (`drift_flutter`), aktualizace APK ho nemaže.
- **Repozitáře** – `PlayerRepository` (pravidla profilů z kap. 5.2), `SettingsRepository` (aktivní hráč, jazyk). UI k databázi nikdy nepřistupuje přímo.
- **Riverpod** – `lib/app/providers.dart`. Jediné místo, kde se skládají závislosti; v testech se `databaseProvider` přepíše paměťovou DB (`test/helpers/test_database.dart`). Proč Riverpod: testovatelné přepisování závislostí bez globálních singletonů a přímá podpora `Stream` → `AsyncValue`.

## Herní API (milník 4)

```
GameModule<S>  ── manifest hry: rozsah hráčů, volby, obtížnosti, rules, ai, board, icon
  rules: GameRules<S>   initialState(config, seed) → apply(state, Move) … isOver / result
  ai:    AiPlayer<S>    chooseMove(state, seat, difficulty, SeededRandom) – čistá funkce

Framework (lib/features/game_play):
  GameSession<S>  stav + log tahů + seed  →  toSave() = SavedGame (config, seed, moves)
  LocalTransport  ověří a aplikuje Move   (fáze 3: NetworkTransport, hry beze změny)
  TurnController  pořadí, roboti s prodlevou (RobotSpeed), AI přes AiRunner (izolát)
  GameScreen      HUD, pauza, ukládání při každém tahu a při odchodu z aplikace
```

- **Tok tahu:** deska → `GameBoardView.submit(Move)` → `TurnController.submitHuman` → `LocalTransport.submit` → `GameSession.apply` → listener uloží partii a překreslí HUD. Roboti posílají tahy stejnou cestou.
- **Náhoda** jen přes `SeededRandom` (vlastní xorshift32 se zamrzlou referenční posloupností), nikdy `dart:math Random` – uložená partie se musí přehrát stejně na každém zařízení i verzi.
- **Obnovení** = `GameSession.restore(rules, save)` přehraje tahy; neplatný tah nebo chybějící profil → partie se zahodí a otevře se nastavení.
- **Typ stavu:** framework zná jen `GameModule<Object?>`; `module.withType(<T>(m) => …)` vrátí typovaný kontext pro `GameSession<T>` a desku.
- **Registr:** `lib/games/registry.dart`. Texty her zatím ve sdílených ARB s prefixem hry (`sample…`), milník 9 je přesune do složek her.

## Statistiky, žebříčky a odznaky (m6)

- Schéma v3: `matches` (hra, čas v ms, délka, obtížnost robotů nebo NULL), `match_participants` (místo, skóre, hvězdy; robot/smazaný hráč), `player_counters` (součty událostí z `reportEvent`), `earned_badges`.
- `StatsService` (vrstva `app`, zná registr her) po konci partie zapíše záznam, spočítá statistiky každého člověka a vyhodnotí odznaky (rámcové `frameworkBadges` + `GameModule.badges`). Nové odznaky jdou do `GameOutcomeView.newBadges` → výsledky (vyjetí zespodu, fanfára `achievement`).
- Statistiky (`computePlayerStats`) a žebříčky (`leaderboard`) se počítají v paměti ze všech partií (`allMatchesProvider`) – rodinné zařízení jich má nejvýš tisíce; kdyby to zpomalilo, přejít na SQL agregace.
- Žebříček řadí podle výher (pak % výher); body z m7 ho doplní.

## Body a úrovně (m7a)

- Schéma v4: `points_ledger` (hráč, částka ±, důvod, detail = odznak/položka/počet, odkaz na partii, čas). Smazání hráče smaže jeho knihu; smazání partie jen odpojí odkaz.
- `RewardsConfig` (`assets/config/rewards.json`) → `computeMatchPoints` → řádky rozpisu (`PointsLine`) → `PointsRepository.addGameLines`. Úroveň `levelFor(celkem)` podle 50·n·(n+1)/2, max 30.
- Výsledky dostávají `MatchRewards` (odznaky + body na hráče) a ukazují rozpis; horní pruh domovské obrazovky ukazuje zůstatek a úroveň; statistiky hráče úroveň s progress barem a historii bodů.
- Milník 7b (katalog vylepšení, obchod, šatník) bude utrácet přes `PointsRepository.spend` (důvod `purchase`).

## Příprava na paralelní vývoj her (m9)
- **Texty her** jsou v Dart mapách ve složce hry (`GameTexts`), ne ve sdílených ARB – `gen-l10n` neumí slučovat více složek. `gameText`/`badgeText` hledají nejdřív v textech her.
- **Zvuky her** deklaruje manifest (`GameModule.sfx`) a `AudioCatalog.withSfx` je přidá při startu; cesty `games/<id>/…` načítá backend z `assets/`. Licence her v `assets/games/<id>/CREDITS.json`, Autoři a licence je sloučí.
- **Game kit** (`lib/core/game_kit/`): `BoardGrid`, `PieceToken`, `HoppingPiece`, `FlipCard`, `Dice` a čisté `GameSearch` (alpha-beta s iterativním prohlubováním a časovým limitem; běží v izolátu AI).
- **Herní čas** bez pauz se ukládá se partií (`SavedGame.elapsedMs`) a deska ho dostává v `GameBoardView.elapsed`.
- **Kontrakt** `test/games/contract.dart` musí projít každá hra; **`tool/check_scope.dart`** v CI drží větve `game/<id>` v jejich složce. Návod: `docs/GAME_MODULE_GUIDE.md`.

## Síťová hra (fáze 3a)

- **Hostitel je jediný zdroj pravdy** (`lib/core/multiplayer/host_room.dart`). Každý tah klienta (`MoveRequest` se `basedOn` = poslední seq) ověří: místo patří tomu zařízení, je na tahu, stav není starý, hra neběží v pauze a tah je legální. Pak ho aplikuje a všem rozešle `MoveApplied(seq, move, hash)`.
- **Klient** (`client_room.dart`) drží vlastní kopii hry a aplikuje tahy v pořadí. Mezera v seq, nelegální tah nebo jiný hash → `SnapshotRequest` → `StateSnapshot` → `GameSession.replaceWith` (obnova na místě, obrazovka drží stejnou session).
- **Sdílená konfigurace** má každého člověka jako `RemoteSeat` (hostitelovi lidé mají `clientId 'host'`); hry se ptají jen na `is RobotSeat`, takže stav je na všech zařízeních stejný. Každé zařízení si ji převede přes `GameConfig.forDevice` – své lidi na `HumanSeat`, ostatní zůstanou hosté. Statistiky a body tak každé zařízení zapíše jen svým profilům.
- **Spojení:** zprávy JSON (`protocol.dart`, `protocolVersion`), `MessageChannel` = WebSocket (`socket_channel.dart`, `net_server.dart`, ping 3 s, ztráta po 8 s) nebo `LoopbackChannel` v testech (zpoždění, přerušení).
- **Hledání:** hostitel posílá každé 2 s UDP oznámení (port 47123) na 255.255.255.255 a /24 broadcast; `RoomFinder` místnost zahodí po 6 s ticha. Android potřebuje `MulticastLock` (Kotlin kanál `deskovky/multicast`, drží ho jen obrazovka Připojit se). QR obsahuje `deskovky://join?ip&port&code`.
- **Výpadky:** odpojený klient → pauza u všech a odpočet 30 s (`reconnectGrace`), pak hostitel volí Čekat dál / Nahradit robotem / Ukončit hru. Robot hraje přes `TurnController.setStandIn` (sdílená konfigurace se nemění). Návrat se stejným tokenem (`NetworkRooms.rejoin`) vrátí místa.
- **Vrstvy:** `NetworkEnv` (skutečná síť / falešná v testech) → `NetworkRooms` (jediná místnost zařízení, přežije obrazovky) → obrazovky `lib/features/multiplayer/` a síťový režim `GameScreen` (`/play/<id>/net`).
- Po síti jde každá hotová hra pro 2+ hráče (`GameModule.playableOnNetwork`; hra se může vyřadit `supportsNetwork => false`), stále jako „Zkušební“. Kontrakt her (`test/games/contract.dart`) u každé takové hry odehraje síťovou partii přes loopback. Síťová partie se neukládá pro pozdější pokračování.
