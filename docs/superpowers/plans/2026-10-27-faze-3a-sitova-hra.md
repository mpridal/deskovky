# Fáze 3a – Hra přes domácí Wi-Fi (do v0.4.0, Pexeso): implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Každý hráč může táhnout na svém zařízení ve stejné Wi-Fi.
- Hostitel otevře místnost (seznam v síti, 4místný kód, QR), ostatní se připojí se svým profilem, hostitel spustí hru.
- Ve v0.4.0 to funguje pro **Pexeso** jako zkušební volba; ostatní hry přibudou ve fázi 3b.
- Místní hra se nemění.

**Architecture:**
- **Hostitel je jediný zdroj pravdy.** Drží `GameSession`, ověřuje tahy (`isLegal`), hraje za roboty (`TurnController`) a rozesílá `move_applied` s pořadovým číslem a `stateHash`.
- **Klient** tahy jen posílá (`move_request`) a aplikuje, co přijde. Při nesouladu hashe si vyžádá `state_snapshot`.
- Vše síťové je v `lib/core/multiplayer/`:
  - protokol (JSON zprávy s `protocolVersion`);
  - kanál (`MessageChannel`: WebSocket přes `dart:io`, v testech `LoopbackChannel`);
  - `HostRoom` / `ClientRoom`;
  - `NetworkTransport implements MoveTransport`;
  - `RoomAnnouncer` / `RoomFinder` (UDP).
- **Místa:** nový `RemoteSeat(clientId, name, avatar)` v `GameConfig`. Každé zařízení si z konfigurace hostitele udělá vlastní pohled: svá místa jako `HumanSeat(profileId)`, cizí jako `RemoteSeat`.
- **Statistiky:** body, odznaky a statistiky ukládá každé zařízení jen svým profilům. Hráči z jiných zařízení se v historii zapíšou jako hosté (spec 14.5).

**Tech Stack:**
- Flutter 3.47.8, Riverpod 3, go_router, Drift (schéma beze změny);
- `dart:io` (`HttpServer` + `WebSocketTransformer`, `WebSocket.connect`, `RawDatagramSocket`);
- nový balíček **`qr_flutter`** (schválen Milošem 2026-10-27);
- Kotlin kanál pro `WifiManager.MulticastLock`.

**Spec:** `docs/ZADANI-deskovky.md` kap. 14 (14.1–14.9), kap. 8 („Tahy jako přenositelné zprávy“), 5.6 (body), 5.7 (nastavení hry).

## Global Constraints
- **Rozhodnutí Miloše (2026-10-27):**
  - hledání přes **UDP oznámení** místo mDNS;
  - QR kód **jen zobrazit** (bez kamery a bez skenování);
  - testovat na **jeho telefonu a tabletu**;
  - vydávat **po částech**: v0.4.0 = síťové Pexeso (volba „Zkušební“).
- **Hry se nemění** (14.3). Potřebuje-li hra úpravu, je to chyba v dodržení kap. 8 – opravit ve hře a zapsat.
- Jen místní síť a žádný internet. Místnost chrání token z kódu/QR. Posílá se jen jméno a avatar.
- `protocolVersion = 1`. Jiná verze → odmítnutí s hláškou „Aktualizujte aplikaci na všech zařízeních na stejnou verzi“ (14.3).
- Hostitel posílá `ping` každé 3 s. Klient bez odezvy 8 s = odpojený.
- Tah se má zobrazit na všech zařízeních do 300 ms (14.9).
- UDP oznámení na portu **47123**, každé 2 s, broadcast `255.255.255.255` i na adresu podsítě. WebSocket server na volném portu.
- **Nová oprávnění v Androidu:** `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`. `INTERNET` už je.
- Texty cs/en/es. Cíle ≥ 48 dp. Pravidla CLAUDE.md (nic nemazat, zálohy, nevratné kroky jen se souhlasem).

## Review Focus
1. **Hostitel ověřuje každý tah.** Podvržený nebo pozdní `move_request` (cizí místo, ne na tahu, starý stav) se odmítne a stav se nezmění. → Task 3
2. **Ztráta a pořadí zpráv:** zdvojený nebo vynechaný `move_applied` u klienta. Pořadová čísla, nesoulad → `state_snapshot`, hra pokračuje. → Task 3
3. **Odpojení uprostřed tahu nebo animace:** pauza u všech. Návrat se stejným tokenem do 30 s vrátí hráče na místo. Po 30 s Čekat / Robot / Ukončit. → Task 7
4. **Body a odznaky se nezdvojí a nepřipíšou cizím profilům.** Každé zařízení zapisuje jen svým; host nikdy nepřipíše body profilu klienta. → Task 6
5. **Wi-Fi změny:** žádná Wi-Fi nebo jiná síť → srozumitelná hláška, nic nespadne. UDP socket i server se zavřou po odchodu z místnosti. → Task 4, 5

---

### Task 1: Protokol a kanál (`core/multiplayer`)
**Files:** Create `lib/core/multiplayer/{protocol.dart,message_channel.dart,loopback_channel.dart}`. Test: `test/core/multiplayer/protocol_test.dart`.

**Interfaces – Produces:**
- `sealed class NetMessage { Map<String,Object?> toJson(); static NetMessage? fromJson(Object?); }`. Typy:
  - `Hello(protocolVersion, appVersion, roomCode, token?, profiles: [ProfileCard])`
  - `LobbyState(slots, options, difficulty, robotSpeed)`
  - `Ready(bool)`
  - `Start(config, seed, yourSeats)`
  - `MoveRequest(move, basedOn)`
  - `MoveApplied(seq, move, stateHash)`
  - `MoveRejected(reason)`
  - `SnapshotRequest`
  - `StateSnapshot(seq, savedGame)`
  - `Pause`, `Resume`
  - `GameOver(result)`
  - `Bye(reason)`
  - `Ping(t)`, `Pong(t)`
  - `Kick`
- `ProfileCard(name, avatarJson)`.
- `abstract class MessageChannel { Stream<NetMessage> get incoming; void send(NetMessage); Future<void> close(); }`.
- `LoopbackChannel.pair({Duration latency})` → `(a, b)` pro testy.

- [ ] Testy:
  - každá zpráva projde JSON tam a zpět;
  - neznámý typ nebo poškozená data → `null`, nic nespadne;
  - loopback doručí v pořadí se zpožděním.

  RED → implementace → zelené → commit.

### Task 2: Vzdálené místo a pohled zařízení na konfiguraci
**Files:** Modify `lib/core/game/game_config.dart` (`RemoteSeat`), `lib/features/game_setup/seat_editor.dart`, `lib/features/game_play/seat_identity.dart`, `lib/app/stats_service.dart`. Test: `test/core/game/remote_seat_test.dart`, doplnit testy statistik.

**Interfaces – Produces:**
- `RemoteSeat(clientId, name, avatarJson)` se serializací.
- `GameConfig.forDevice(Map<int,int> localProfiles)`: pohled zařízení – místa z mapy jako `HumanSeat(profileId)`, ostatní lidé jako `RemoteSeat`.
- `SeatIdentity` ukazuje jméno a avatar vzdáleného hráče s ikonou 📱.
- **Ve statistikách** je `RemoteSeat` host:
  - partie se zapíše s `playerId: null, robot: false`;
  - bez bodů a mimo žebříček;
  - hra 2+ lidí se pro pravidlo proti farmení počítá jako hra více lidí (14.5).

- [ ] Testy:
  - JSON, `forDevice`;
  - hosté nedostanou body ani místo v žebříčku;
  - hra s hostem a jedním místním člověkem není „sólo s roboty“ (farmení).

  RED → zelené → commit.

### Task 3: `HostRoom`, `ClientRoom`, `NetworkTransport` (loopback)
**Files:** Create `lib/core/multiplayer/{host_room.dart,client_room.dart,network_transport.dart}`. Test: `test/core/multiplayer/room_test.dart` (2–4 virtuální klienti přes loopback, zpoždění 0–500 ms).

**Interfaces – Produces:**
- `HostRoom` (s `gameModules`, místní profily hostitele):
  - lobby: připojení přes `Hello`, kontrola verze a kódu, přidělení `token` a místa, `Ready`;
  - `start()` → `GameSession` + `Start` všem;
  - příjem `MoveRequest`: ověří místo, jestli je na tahu, a `basedOn == seq`, pak `isLegal`; aplikuje, rozešle `MoveApplied(seq+1, …, hash)`, jinak `MoveRejected`;
  - roboty hraje `TurnController` hostitele.
- `ClientRoom`: aplikuje `MoveApplied` v pořadí. Vynechané nebo nesoulad hashe → `SnapshotRequest` → `StateSnapshot` → obnova přes `GameSession.restore`.
- `NetworkTransport implements MoveTransport`:
  - na hostiteli = místní aplikace + rozeslání;
  - u klienta = `submit` pošle `MoveRequest` a čeká na `MoveApplied`/`MoveRejected` (časový limit 5 s);
  - `applied` vydává tahy v pořadí.

- [ ] Testy:
  - celá partie Pexesa se 2, 3 a 4 zařízeními a roboty – všechna zařízení skončí se stejným hashem a výsledkem;
  - cizí nebo pozdní tah se odmítne;
  - úmyslně poškozený stav klienta se opraví snapshotem (14.7);
  - jiná `protocolVersion` se odmítne.

  RED → zelené → commit.

### Task 4: Skutečné spojení – WebSocket server a klient
**Files:** Create `lib/core/multiplayer/socket_channel.dart`, `lib/core/multiplayer/net_server.dart`. Test: `test/core/multiplayer/socket_test.dart` (localhost).

**Interfaces – Produces:**
- `NetServer.start()` → port, příchozí `MessageChannel`y.
- `SocketChannel.connect(host, port)`.
- `ping`/`pong` každé 3 s a detekce odpojení (8 s).
- Vše se zavře po `close()`: žádný otevřený socket po odchodu z místnosti.

- [ ] Testy na `127.0.0.1`: hello → lobby → start → tahy; odpojení klienta je vidět do 8 s; po `close` je port volný. RED → zelené → commit.

### Task 5: Hledání v síti a kód místnosti
**Files:**
- Create `lib/core/multiplayer/{room_announcer.dart,room_finder.dart,local_address.dart}`
- Modify `android/app/src/main/kotlin/…/MainActivity.kt` (kanál `deskovky/multicast`: acquire/release `MulticastLock`) a `AndroidManifest.xml` (oprávnění)
- Test: `test/core/multiplayer/discovery_test.dart`

**Interfaces – Produces:**
- `RoomAnnouncer(room: RoomInfo)`: každé 2 s posílá JSON `{v, code, game, host, avatar, port, free, ip}` na UDP 47123.
- `RoomFinder.rooms`: `Stream<List<RoomInfo>>`; místnost zmizí po 6 s bez oznámení.
- `localWifiAddress()`: IPv4 Wi-Fi rozhraní, nebo null s důvodem „Nejsi ve Wi-Fi“.
- Kód místnosti: 4 číslice + token (16 znaků).
- QR (`qr_flutter`) obsahuje `deskovky://join?ip=…&port=…&code=…&token=…`.

- [ ] Testy:
  - oznámení a nalezení přes loopback rozhraní;
  - zastaralá místnost zmizí;
  - poškozený UDP paket se ignoruje.

  RED → zelené → commit. Na emulátoru ověřit, že lock jde získat i uvolnit.

### Task 6: Obrazovky Místnost a Připojit se
**Files:**
- Create `lib/features/multiplayer/{host_room_screen.dart,join_screen.dart,client_lobby_screen.dart}`, `lib/app/multiplayer_providers.dart`
- Modify `lib/features/game_setup/game_setup_screen.dart` (volba „Kde se hraje: Na tomto zařízení / Každý na svém (Wi-Fi) – Zkušební“, jen pro hry z `networkGames = {'memory'}`), `lib/features/home/home_screen.dart` (tlačítko „Připojit se ke hře“ s ikonou Wi-Fi), router, texty
- Test: `test/features/multiplayer/*_test.dart`

**Chování (14.2, 14.6):**
- **Hostitel:** QR, kód, sloty s 🏠 / 📱 / 🤖, stav „Připraven“, tečka kvality spojení, nastavení hry, Odebrat hráče, Spustit (až jsou všichni připraveni).
- **Klient:** seznam místností (avatar hostitele + název hry), zadání kódu (a ručně IP:port v „Pokročilé“), výběr svého profilu, nastavení jen pro čtení, Připraven.
- **Bez Wi-Fi** je volba neaktivní s vysvětlením.

- [ ] Widget testy s falešnou místností (loopback):
  - hostitel vidí připojeného hráče s avatarem;
  - klient vidí nastavení jen pro čtení;
  - Spustit je aktivní až po Připraven;
  - texty se vejdou na 360 dp při 130 % ve 3 jazycích.

  RED → zelené → commit.

### Task 7: Síťová hra, výsledky, výpadky
**Files:** Modify `lib/features/game_play/game_screen.dart` (síťový režim: `NetworkTransport`, místa tohoto zařízení, „Jsi na tahu!“ + vibrace a zvuk `turn`, „Na tahu: Kuba (na svém telefonu)“, pauza od kohokoli, Ukončit jen hostitel), `lib/features/results/results_screen.dart` (výsledky zároveň na všech, Odveta). Test: `test/features/multiplayer/network_game_test.dart`.

**Chování (14.4):**
- **Odpojený klient:** hra se u všech pozastaví a u avatara je „Odpojeno – čekám (0:30)“. Návrat se stejným tokenem → stav a pokračování. Po 30 s hostitel: Čekat dál / Nahradit robotem / Ukončit hru; vrácený hráč převezme místo od robota.
- **Odchod hostitele:** hra se u něj uloží a klienti vidí „Hostitel se odpojil“.
- **Aplikace na pozadí** = dočasné odpojení.

- [ ] Widget a loopback testy:
  - tah na jednom zařízení se ukáže na druhém;
  - kdo není na tahu, nemůže táhnout;
  - odpojení → pauza → návrat;
  - nahrazení robotem;
  - výsledky a body každému jen na jeho zařízení.

  RED → zelené → commit.

### Task 8: Ověření a vydání v0.4.0
- [ ] Celá sada testů, `flutter analyze --fatal-infos`, emulátor (UI místnosti a připojení k místnosti hostitele na emulátoru přes `adb forward`).
- [ ] **Ruční test s Milošem doma:** telefon + tablet ve stejné Wi-Fi a také přes hotspot telefonu; Pexeso pro 2 lidi + robota; odpojení Wi-Fi a návrat. Testovací APK dostane Miloš přes GitHub Release až s jeho souhlasem.
- [ ] Nezávislá revize (opus), oprava nálezů, CLAUDE.md a `docs/ARCHITECTURE.md` (síťová vrstva), CHANGELOG, verze 0.4.0.
- [ ] Push, PR, sloučení a tag `v0.4.0` – každý krok jen s Milošovým výslovným souhlasem.

**Fáze 3b (potom):** ověření Piškvorek, Min a Člověče přes síť (lze paralelně po hrách, 14.8 bod 6), emotes a doladění UI (14.8 bod 7), hry mimo pořadí (vlajky v Minách) a Dáma.
