# Milník 4 – herní API, nastavení hry, HUD, výsledky a ukázková hra: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Framework umí spustit libovolnou hru přes jednotné API: obrazovka nastavení (počet míst, lidé ⇄ roboti, obtížnost, volby hry, pamatování), hra se společným HUD (konec, pauza, hudba/efekty, pruh hráčů, bublina tahu), roboti hrají sami, rozehraná hra se uloží a obnoví, výsledky s pořadím a hvězdami. Vše ověřuje ukázková hra **„Hádej číslo“** (`lib/games/_sample/`), jejíž každá akce je `Move` přes `LocalTransport`.

**Architecture:** Herní logika je deterministický stavový automat (`GameRules<S>`: počáteční stav ze seedu → `apply(state, move)`), tahy jsou JSON `Move`. Framework vlastní `GameSession` (stav + log tahů + seed), `LocalTransport` (ověří a aplikuje tah) a `TurnController` (pořadí, roboti s prodlevou, AI mimo UI vlákno přes `AiRunner`). Hra dodá jen `GameModule` (manifest, pravidla, AI, widget desky). Uložení partie = konfigurace + seed + seznam tahů, obnovení = přehrání (replay). Poslední nastavení a rozehrané partie jsou v DB (schéma v2 s migrací).

**Tech Stack:** Flutter 3.47.8, Drift (schéma v2), Riverpod, go_router. Žádné nové balíčky.

**Spec:** `docs/ZADANI-deskovky.md` – kap. 5.1 („Pokračovat“, karty her), 5.7 + 5.7.1 (nastavení hry, roboti), 5.8 (HUD), 5.9 (konec hry), 8 (GameModule, GameHost, GameResult, „Tahy jako přenositelné zprávy“), 9 (AI), 12 (akceptační kritéria týkající se ukázkové hry a HUD). Vizuál: mockup „Nastavení hry před startem“ (`#phoneSetup`), „Ve hře – společné HUD“ (`#tabletGame`, `.hud`, `.pchip`, `.turn`), „Výsledky“ (`#phoneResults`).

## Global Constraints

- Platí vše z Global Constraints milníků 1–3.
- **Herní logika bez UI a bez `Random()`**: náhoda jen přes `SeededRandom(seed)` ze stavu; UI mění stav výhradně posláním `Move` přes `MoveTransport`.
- `Move`, `GameConfig`, stav hry i uložená partie mají `toJson`/`fromJson`; `stateHash` je deterministický (FNV-1a 32 bit nad kanonickým JSON se seřazenými klíči).
- Místa u stolu: 0–3 = barvy `AppColors.players[0..3]`; počet míst v rozsahu hry; aspoň 1 člověk; jeden profil nejvýš v jednom slotu; volné sloty automaticky roboti.
- Roboti: jména podle místa (cs Robík, Čipík, Šroubek, Bzučák; en Robo, Chip, Bolt, Buzz; es Robi, Chispa, Tornillo, Zumbi), `RobotAvatar` v barvě místa, obtížnost 1–3 tečky, prodleva tahu Pomalu 1 200 / Normálně 600 / Rychle 250 ms, během tahu robota lidé nemohou hrát (jen pauza).
- AI běží mimo UI vlákno (`Isolate.run`) – v testech se nahrazuje synchronním `InlineAiRunner`.
- HUD: Konec (✕, potvrzení), Pauza (Pokračovat, Restart, Pravidla, Konec), Hudba a Efekty zvlášť (stav se pamatuje v `app_settings`; skutečný zvuk přijde v milníku 5), systémové Zpět = Pauza.
- Body, odznaky a ukládání výsledků do statistik jsou milníky 6–7 – výsledky partie se zatím nikam neukládají.
- Všechny texty v ARB (cs/en/es); texty ukázkové hry s prefixem `sample` ve sdílených ARB (přesun do složky hry řeší milník 9).

## Review Focus

1. **Zabití aplikace uprostřed partie** – po novém spuštění „Pokračovat“ obnoví přesně stejnou partii (stejné tajné číslo, stejné tahy, stejný hráč na tahu) → test v Task 3/6.
2. **Smazaný profil v uloženém nastavení nebo v rozehrané partii** – slot dostane robota, nastavení se ukáže s poznámkou; rozehraná partie se smazaným hráčem se zahodí místo pádu → testy v Task 5/6.
3. **Tah robota a rychlé ťukání člověka / pauza / opuštění obrazovky během „přemýšlení“** – žádný tah navíc, žádná výjimka po zavření obrazovky, pauza robota zastaví → testy v Task 6.
4. **Neplatný nebo poškozený JSON** (uložená partie z jiné verze, nastavení s neznámou volbou) – ignoruje se, použije se výchozí → testy v Task 1/3.
5. **Telefon 360 dp, španělsky, písmo 130 %, 4 hráči** – pruh hráčů v HUD a sloty v nastavení se vejdou (jména se zkrátí výpustkou, ne zalomí) → text-fit v Task 8.

---

### Task 1: Jádro herního API

**Files:**
- Create v `lib/core/game/`: `difficulty.dart`, `game_config.dart`, `move.dart`, `game_rules.dart`, `game_result.dart`, `seeded_random.dart`, `state_hash.dart`, `game_session.dart`, `move_transport.dart`, `ai_player.dart`, `game_module.dart`, `game_option.dart`
- Test: `test/core/game/*_test.dart` + `test/core/game/fake_game.dart` (minimální hra „kdo dřív napočítá do 5“ pro testy frameworku)

**Interfaces:**
- Produces:
  - `enum Difficulty { easy, medium, hard }`; `enum RobotSpeed { slow, normal, fast; Duration get delay; }` (1200/600/250 ms).
  - `sealed class SeatConfig` – `HumanSeat(int profileId)`, `RobotSeat()`; JSON `{"type":"human","profileId":3}` / `{"type":"robot"}`.
  - `@immutable class GameConfig { String gameId; List<SeatConfig> seats; Difficulty difficulty; RobotSpeed robotSpeed; Map<String, Object?> options; toJson(); static GameConfig? fromJson(Map?) }` – `fromJson` vrací `null` při poškozených datech (neznámý typ místa, prázdná místa, chybějící `gameId`).
  - `@immutable class Move { int seat; String type; Map<String, Object?> data; toJson(); factory fromJson; == }`.
  - `class SeededRandom { SeededRandom(int seed); int nextInt(int max); double nextDouble(); }` – vlastní deterministický generátor (xorshift32), **ne** `dart:math Random` (jeho posloupnost není zaručena napříč platformami a verzemi).
  - `String stateHash(Object? json)` – kanonický JSON (seřazené klíče) → FNV-1a 32 bit hex.
  - `abstract class GameRules<S> { S initialState(GameConfig config, int seed); int? currentSeat(S state); bool isLegal(S state, Move move); S apply(S state, Move move); bool isOver(S state); GameResult result(S state); int score(S state, int seat); Map<String, Object?> stateToJson(S state); S stateFromJson(Map<String, Object?> json); }`
  - `@immutable class GameResult { List<int> places; List<int> scores; List<int> stars; Map<String, Object?> stats; }` – po místech; `places` 1-based se shodami (remíza = stejné místo); `stars` 0–3.
  - `class GameSession<S>` – `GameSession.start(GameRules<S> rules, GameConfig config, int seed)`, `GameSession.restore(rules, SavedGame save)`; `S get state`, `List<Move> get moves`, `Move? get lastMove`, `bool apply(Move m)` (vrátí `false` a nic nezmění u nelegálního tahu), `SavedGame toSave()`.
  - `@immutable class SavedGame { GameConfig config; int seed; List<Move> moves; toJson(); static SavedGame? fromJson(Map?) }`.
  - `abstract class MoveTransport { Stream<Move> get applied; Future<bool> submit(Move move); void dispose(); }`; `class LocalTransport<S> implements MoveTransport { LocalTransport(GameSession<S> session); }` – ověří legalitu, aplikuje, vyšle `applied`.
  - `abstract class AiPlayer<S> { Move chooseMove(S state, int seat, Difficulty difficulty, SeededRandom random); }` (synchronní, čistá funkce – běží v izolátu); `abstract class AiRunner { Future<Move> run<S>(AiPlayer<S> ai, S state, int seat, Difficulty d, int seed); }`; `IsolateAiRunner` (`Isolate.run`) a `InlineAiRunner` (testy).
  - `sealed class GameOption` – `ChoiceOption(id, labelKey, List<(Object value, String labelKey)> choices, Object defaultValue)`, `ToggleOption(id, labelKey, bool defaultValue)`; `Map<String, Object?> normalizeOptions(List<GameOption> schema, Map<String, Object?>? raw)` – doplní výchozí, zahodí neznámé klíče a neplatné hodnoty.
  - `enum GameOrientation { any, portrait, landscape }`; `abstract class GameModule<S> { String id; String titleKey; String descriptionKey; String rulesKey; int minPlayers; int maxPlayers; bool supportsAi; List<Difficulty> difficulties; List<GameOption> options; GameOrientation phoneOrientation; String musicTrack; bool supportsSaveResume; bool available; GameRules<S> rules; AiPlayer<S>? ai; Widget icon(BuildContext); Widget board(BuildContext, GameBoardView<S> view); String? turnHint(BuildContext, S state, int seat); }`
  - `class GameBoardView<S> { S state; Move? lastMove; int? mySeat /* člověk na tahu, jinak null */; bool canAct; Future<bool> Function(Move) submit; GameHost host; }`
  - `abstract class GameHost { void haptic(); void playSfx(String id); void reportEvent(String id, [Map<String, Object?> data]); }` – v milníku 4 `playSfx` nic nedělá a `reportEvent` jen sbírá události (odznaky milník 6).
  - Lokalizace textů modulu: klíče `titleKey` atd. se překládají přes `AppLocalizations` funkcí `String gameText(AppLocalizations l10n, String key)` v `lib/games/game_texts.dart` (switch nad známými klíči; milník 9 nahradí slučováním ARB ze složek her).

- [ ] **Step 1: Napsat failing testy** (s `fake_game.dart`):
  - `SeededRandom(42)` dá vždy stejnou posloupnost 10 čísel (zapsat konkrétní hodnoty po prvním běhu jako regresní); `nextInt(6)` z 10 000 vzorků pokryje 0–5.
  - `stateHash({'b':1,'a':[1,2]}) == stateHash({'a':[1,2],'b':1})`, jiný obsah → jiný hash.
  - `GameConfig`, `Move`, `SavedGame` round-trip přes JSON; `GameConfig.fromJson` s `{'gameId':'x','seats':[{'type':'alien'}]}` → `null`; `SavedGame.fromJson(null)` → `null`.
  - `normalizeOptions`: chybějící → výchozí, neznámý klíč zahozen, hodnota mimo `choices` → výchozí.
  - `GameSession`: nelegální tah vrátí `false` a stav/log se nezmění; **replay** – `GameSession.restore(rules, session.toSave())` má stejný `stateHash` i `currentSeat` jako původní po 20 náhodných legálních tazích.
  - `LocalTransport`: legální tah vyšle `applied`, nelegální ne a vrátí `false`.
  - `InlineAiRunner` vrací tah AI fake hry; `IsolateAiRunner` vrátí stejný tah jako inline (test mimo `testWidgets`).
- [ ] **Step 2: Run** `flutter test test/core/game` → FAIL.
- [ ] **Step 3: Implementovat.**
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(game): core game API – config, moves, rules, session, transport, AI runner`

### Task 2: Ukázková hra „Hádej číslo“ – pravidla a AI

**Files:**
- Create: `lib/games/_sample/sample_rules.dart`, `lib/games/_sample/sample_ai.dart`, `lib/games/_sample/README.md`
- Test: `test/games/_sample/sample_rules_test.dart`, `test/games/_sample/sample_ai_test.dart`

**Interfaces:**
- Produces:
  - Volba `range`: `ChoiceOption('range', 'sampleOptionRange', [(20,'…'),(50,'…'),(100,'…')], 50)`.
  - Stav `SampleState { int range; int secret; int low; int high; int current; List<SampleGuess> guesses; int? winner; }` (`SampleGuess { int seat; int value; int verdict /* -1 tajné je menší, 1 větší, 0 trefa */ }`).
  - `SampleRules implements GameRules<SampleState>`: `secret = 1 + SeededRandom(seed).nextInt(range)`; začíná místo 0; tah `Move(seat, 'guess', {'value': v})` je legální jen pro hráče na tahu a `low ≤ v ≤ high`; netrefa zúží `low`/`high` (společné pro všechny) a tah přejde na další místo; trefa ukončí hru. `result`: vítěz místo 1, ostatní sdílené místo 2 (u 1 hráče jen místo 1); `scores` = počet tipů každého; `stars` – 1 hráč: tipy ≤ ⌈log2(range)⌉ → 3, ≤ ⌈log2(range)⌉+3 → 2, jinak 1; více hráčů: vítěz 3, ostatní 1.
  - `SampleAi implements AiPlayer<SampleState>`: Těžká = střed `(low+high)~/2`; Střední = střed ± náhodně až 25 % rozpětí (v mezích); Lehká = náhodné číslo v `[low, high]`.

- [ ] **Step 1: Napsat failing testy**: stejný seed → stejné tajné číslo; tah mimo pořadí / mimo meze nelegální; netrefa zúží meze a posune tah (1 → 2 → 3 → 1 pro 3 hráče); trefa ukončí hru a `currentSeat == null`; výsledek 3 hráčů (vítěz 1., ostatní 2.); hvězdy pro 1 hráče na rozsahu 50 (6 tipů → 3, 9 → 2, 10 → 1); serializace stavu tam a zpět; **AI self-play**: pro každou obtížnost a 1–4 hráče 100 partií (seed 0–99) přes `GameSession` doběhne bez nelegálního tahu do konce; Těžká AI uhodne rozsah 100 vždy do 7 tipů; replay každé partie dá stejný hash.
- [ ] **Step 2: Run** → FAIL. **Step 3: Implementovat.** **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(sample): guess-the-number rules and AI`

### Task 3: Databáze v2 – poslední nastavení a rozehrané partie; hudba/efekty

**Files:**
- Modify: `lib/core/db/tables.dart`, `lib/core/db/app_database.dart` (`schemaVersion => 2`, `onUpgrade` z 1 na 2 vytvoří nové tabulky), `lib/core/settings/settings_repository.dart`
- Create: `lib/core/game/game_store.dart`, `drift_schemas/app/drift_schema_v2.json`, regenerovaný `test/core/db/generated/`
- Test: `test/core/db/migration_test.dart` (v1 → v2 se zachováním hráčů), `test/core/game/game_store_test.dart`, doplnit `test/core/settings/settings_repository_test.dart`

**Interfaces:**
- Produces:
  - Tabulky `GameSettingsLast(gameId text PK, configJson text, updatedAt dateTime)` a `SavedSessions(gameId text PK, saveJson text, updatedAt dateTime)`.
  - `class GameStore { GameStore(AppDatabase db); Future<void> saveLastConfig(GameConfig c); Future<GameConfig?> lastConfig(String gameId); Stream<GameConfig?> watchLastPlayed(); Future<void> saveSession(SavedGame s); Future<SavedGame?> savedSession(String gameId); Stream<SavedGame?> watchLastSaved(); Future<void> deleteSession(String gameId); }` – `watchLastPlayed` = nejnověji uložený config ze všech her; poškozený JSON → `null`.
  - `SettingsRepository`: `watchMusicOn()/setMusicOn(bool)`, `watchSfxOn()/setSfxOn(bool)` – výchozí `true`.

- [ ] **Step 1: Napsat failing testy**: migrace v1 (s hráčem a aktivním hráčem) → v2: hráč i nastavení zůstanou a nové tabulky existují (`verifier.startAt(1)` + vložení dat + `migrateAndValidate(db, 2)`); `GameStore`: uložení a načtení configu, přepsání stejné hry, `watchLastPlayed` vrací poslední hranou hru, poškozený JSON v DB → `null`, uložení/smazání partie; hudba/efekty výchozí `true`, uložení vydrží znovuotevření souborové DB.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat**; postup změny schématu podle CLAUDE.md (make-migrations, schema generate).
- [ ] **Step 4: Run** → PASS. **Step 5: Commit** `feat(db): schema v2 with last game settings and saved sessions`

### Task 4: Registr her, karty na hlavní stránce a „Pokračovat“

**Files:**
- Create: `lib/games/registry.dart`, `lib/games/_sample/sample_module.dart` (manifest + ikona; deska přijde v Task 8 – zatím jednoduchý `Placeholder`-free text), `lib/games/game_texts.dart`, `lib/features/home/game_card.dart`, `lib/features/home/continue_bar.dart`
- Modify: `lib/features/home/home_screen.dart`, `lib/app/providers.dart` (`gameStoreProvider`, `lastPlayedProvider`, `lastSavedProvider`), ARB
- Test: `test/features/home/home_screen_test.dart` (doplnit), `test/features/home/continue_bar_test.dart`

**Interfaces:**
- Produces:
  - `final List<GameModule<Object?>> gameModules = [sampleModule];` a `GameModule? moduleById(String id)`.
  - Mřížka: nejdřív karty modulů (`GameCard`: ikona na pastelovém podkladu, název, „1–4 hráči“ přes ICU plural `gamePlayersRange`, štítek „Brzy“ u `available == false`), za nimi zbývající zástupné karty „Brzy“ do celkového počtu 6. Tap na dostupnou kartu → `/play/<id>/setup`.
  - `ContinueBar` (mockup `.continue`, zlatý přechod): když existuje rozehraná partie → „Pokračovat: <hra>“ + „Rozehraná hra“; jinak když existuje poslední config → „Pokračovat: <hra>“ + souhrn („2 hráči (1 + 1 🤖) · Střední“); tap = obnovit partii / rovnou spustit hru s posledním nastavením (profily, které mezitím zmizely, nahradí roboti). Bez historie se nezobrazí.
  - ARB: `sampleTitle` Hádej číslo / Guess the number / Adivina el número; `sampleDescription`; `gamePlayersRange` („{min}–{max} hráči“ s plurálem), `continueTitle` „Pokračovat: {game}“, `continueSaved` Rozehraná hra / Game in progress / Partida en curso, `continueSummary` „{players} · {difficulty}“, `seatSummary` „{humans} + {robots} 🤖“, `difficultyEasy/Medium/Hard` Lehká/Střední/Těžká, Easy/Medium/Hard, Fácil/Media/Difícil.

- [ ] **Step 1: Napsat failing testy**: první karta je „Hádej číslo“ s „1–4 hráči“ a bez štítku „Brzy“, dalších 5 karet má „Brzy“; tap na ni otevře nastavení; bez historie není `ContinueBar`; s uloženým configem ukazuje souhrn a tap spustí hru (`GameScreen` v stromu); s uloženou partií ukazuje „Rozehraná hra“ a tap obnoví (stejný hash stavu).
- [ ] **Step 2–4:** FAIL → implementace → PASS. **Step 5: Commit** `feat(home): game registry, game cards and continue bar`

### Task 5: Obrazovka nastavení hry

**Files:**
- Create: `lib/features/game_setup/game_setup_screen.dart`, `lib/features/game_setup/seat_editor.dart` (čistá logika míst), `lib/features/game_setup/profile_picker_sheet.dart`
- Modify: `lib/app/router.dart` (`/play/:gameId/setup`, full screen), ARB
- Test: `test/features/game_setup/seat_editor_test.dart`, `test/features/game_setup/game_setup_screen_test.dart`

**Interfaces:**
- Produces:
  - Čistá logika `SeatEditor` (testovatelná bez UI): `List<SeatConfig> resize(List<SeatConfig> seats, int count)` (nová místa = roboti, ubírá se od konce, ale nikdy neodebere posledního člověka – místo něj odebere robota), `toggle(seats, index, {required int? profileForHuman})` (člověk ⇄ robot; na člověka jen s volným profilem), `move(seats, from, to)`, `List<SeatConfig> sanitize(List<SeatConfig> seats, Set<int> existingProfileIds)` (smazaný profil → robot; duplicitní profil → robot; žádný člověk → první místo dostane aktivního hráče), `bool isValid(seats)`.
  - Výchozí config bez historie: počet míst `clamp(2, min, max)`, místo 0 = aktivní hráč, ostatní roboti, obtížnost Střední, rychlost Normálně, volby výchozí.
  - UI (mockup `#phoneSetup`): horní pruh (Zpět, název hry); „Počet hráčů“ `SegmentedControl` min..max; nadpis s plurálem „Hráči · 2 lidé + 2 roboti“; seznam `PlayerSlot` – člověk = `AvatarView` 40 + jméno + štítek „Člověk“, tap = výběr profilu (`ProfilePickerSheet`: volné profily + „🤖 Robot“), robot = `RobotAvatar` v barvě místa + jméno robota + tečky obtížnosti + štítek „🤖 Robot“, tap = přepnout na člověka (otevře výběr profilu; bez volného profilu toast „Všichni hráči už sedí u stolu“); u každého slotu šipky ↑/↓ (`RoundIconButton` 44, popisky „Posunout výš/níž“) mění pořadí; „Obtížnost robotů“ a „Rychlost robotů“ (segmenty; schované, když u stolu není robot); volby hry podle schématu (`ChoiceOption` → `SegmentedControl`/`ChoicePills`, `ToggleOption` → `Switch`); poznámka „↺ Nastavení načteno z minulé hry“ (a „· volné sloty doplněny roboty“, když `sanitize` něco změnil); dole `PrimaryButton` „Hrát!“ → uloží config (`GameStore.saveLastConfig`), smaže případnou starou rozehranou partii této hry a otevře `/play/<id>`.
  - ARB: `setupPlayers` Počet hráčů; `setupSeats` „Hráči · {humans, plural…} + {robots, plural…}“ (cs: 1 člověk / 2–4 lidé / 5+ lidí; robot / roboti / robotů); `setupDifficulty` Obtížnost robotů; `setupSpeed` Rychlost robotů; `speedSlow/Normal/Fast` Pomalu/Normálně/Rychle; `seatHuman` Člověk; `seatRobot` 🤖 Robot; `setupLoaded` „↺ Nastavení načteno z minulé hry“; `setupFilled` „volné sloty doplněny roboty“; `setupNoFreeProfile` „Všichni hráči už sedí u stolu.“; `seatMoveUp`/`seatMoveDown`; `setupPlay` Hrát!; `robotName0..3`; `sampleOptionRange` Rozsah čísel / Number range / Rango de números.

- [ ] **Step 1: Napsat failing testy**: `SeatEditor` – resize 2→4 přidá 2 roboty, 4→1 ponechá člověka; toggle na člověka bez volného profilu nic nezmění; sanitize nahradí smazaný profil robotem a doplní člověka; widget – výchozí stav (aktivní hráč + 1 robot „Robík“… pozor: jméno podle místa → místo 1 = „Čipík“); 4 místa se 2 lidmi → sloty 3–4 roboti s `RobotAvatar` barvy slotu; souhrn „2 lidé + 2 roboti“; tap na robota → výběr profilu → člověk; šipka ↓ prohodí pořadí; s uloženým configem se předvyplní a ukáže poznámku; smazaný profil → robot + „volné sloty doplněny roboty“; „Hrát!“ uloží config a otevře hru; bez robotů nejsou segmenty obtížnosti a rychlosti.
- [ ] **Step 2–4.** **Step 5: Commit** `feat(game_setup): seats with robots, difficulty, options and remembered settings`

### Task 6: Herní obrazovka – HUD, pauza, roboti, ukládání

**Files:**
- Create: `lib/features/game_play/game_screen.dart`, `lib/features/game_play/turn_controller.dart`, `lib/features/game_play/game_hud.dart`, `lib/features/game_play/pause_overlay.dart`, `lib/features/game_play/player_chip.dart`, `lib/features/game_play/seat_identity.dart`
- Modify: `lib/app/router.dart` (`/play/:gameId` full screen; `extra` = `GameConfig` nebo `SavedGame`), `lib/app/providers.dart` (`aiRunnerProvider` – produkce `IsolateAiRunner`, testy `InlineAiRunner`), ARB
- Test: `test/features/game_play/turn_controller_test.dart`, `test/features/game_play/game_screen_test.dart`

**Interfaces:**
- Produces:
  - `SeatIdentity { int seat; String name; Widget avatar(double size); bool isRobot; Difficulty? robotDifficulty; }` – vytvoří se z configu a profilů (robot = `RobotAvatar(AppColors.players[seat])` + `robotName<seat>`); sdílí ho HUD i výsledky.
  - `TurnController<S>` (bez widgetů): `TurnController({required GameSession<S> session, required LocalTransport transport, required GameModule<S> module, required AiRunner runner, required Duration robotDelay})`; `Stream<S> states`; `bool get robotThinking`; `void pause()`, `void resume()`, `void dispose()`; po každém tahu, je-li na tahu robot a hra neskončila a není pauza: počká `robotDelay`, zavolá `runner.run` se seedem `session.seed + moves.length` a pošle tah přes transport; po `dispose` ani pauze už žádný tah nepošle (i když AI doběhne později).
  - `GameScreen` (mockup `#tabletGame`): `GameHud` nahoře – `RoundIconButton` Konec (✕) a Pauza, uprostřed `PlayerChip`y (avatar 40, jméno s výpustkou, skóre `rules.score`, na tahu papírový podklad + jemné pulzování 1,0→1,04, u robota na tahu „…“ animované tečky), vpravo Hudba a Efekty (ikony přeškrtnuté při vypnutí, stav v `SettingsRepository`); na telefonu < 600 dp se pruh hráčů přesune pod horní lištu (druhý řádek, vodorovně posuvný); deska = `module.board(context, view)` na `FeltBackground`; dole bublina (mockup `.turn`) s `module.turnHint` nebo „Na tahu: {name}“ / „🤖 {name} přemýšlí…“.
  - Konec: `showAppConfirmDialog` „Opravdu ukončit?“ + „Rozehraná hra se uloží.“ / „Rozehraná hra se neuloží.“ podle `supportsSaveResume`; potvrzení uloží (nebo smaže) partii a vrátí se domů.
  - Pauza (tlačítko i systémové Zpět přes `PopScope(canPop: false)`): `PauseOverlay` – Pokračovat, Restart (nový seed, stejný config, smaže uloženou partii), Pravidla (dialog s `rulesKey`), Konec (stejný dialog jako ✕). Během pauzy robot nehraje.
  - Ukládání: při `AppLifecycleState.paused`/`detached` a po každém tahu (pokud `supportsSaveResume`) `GameStore.saveSession(session.toSave())`; po konci hry `deleteSession`. Obnovení: `extra` je `SavedGame` → `GameSession.restore`; pokud obsahuje profil, který už neexistuje, partie se zahodí (toast „Rozehranou hru nejde obnovit.“) a otevře se nastavení.
  - Konec partie: `rules.isOver` → po 600 ms přechod na výsledky (`/play/<id>/results`, `extra` = `GameOutcomeView { config, result, seats: List<SeatIdentity> }`).
  - ARB: `hudExit` Konec; `hudPause` Pauza; `hudMusic` Hudba; `hudSfx` Efekty; `exitTitle` Opravdu ukončit?; `exitSaved` / `exitNotSaved`; `exitConfirm` Ukončit; `pauseTitle` Pauza; `pauseResume` Pokračovat; `pauseRestart` Začít znovu; `pauseRules` Pravidla; `turnOf` „Na tahu: {name}“; `robotThinking` „🤖 {name} přemýšlí…“; `resumeFailed` „Rozehranou hru nejde obnovit.“

- [ ] **Step 1: Napsat failing testy**:
  - `TurnController` (s fake hrou, `InlineAiRunner`, `fake_async`): partie 1 člověk + 3 roboti – po tahu člověka odehrají roboti postupně s prodlevou 250 ms; v pauze nehrají, po `resume` pokračují; `dispose` během prodlevy → žádný další tah; člověk nemůže poslat tah za robota (transport vrátí `false`).
  - `GameScreen` se vzorovou hrou: HUD má Konec, Pauza, Hudba, Efekty (popisky), čipy všech hráčů; přepnutí Hudby se uloží a po novém otevření zůstane vypnuté; systémové Zpět otevře pauzu; Konec → dialog → „Ukončit“ → domů a partie je uložená; **restart aplikace** (nový `pumpApp` se stejnou DB) → „Pokračovat“ → stejný stav (`stateHash`) a stejný hráč na tahu; obnovení partie se smazaným profilem → toast a nastavení; během „přemýšlení“ robota tap na desku nic nepošle.
- [ ] **Step 2–4.** **Step 5: Commit** `feat(game_play): game screen with HUD, pause, robots and save/resume`

### Task 7: Výsledky partie

**Files:**
- Create: `lib/features/results/results_screen.dart`, `lib/features/results/confetti.dart`
- Modify: `lib/app/router.dart` (`/play/:gameId/results`), ARB
- Test: `test/features/results/results_screen_test.dart`

**Interfaces:**
- Produces (mockup `#phoneResults` bez rozpisu bodů – ten přijde v milníku 7):
  - Nadpis: „Vyhrál(a) {name}!“ → v ARB neutrálně „{name} vyhrává!“ / „{name} wins!“ / „¡Gana {name}!“; při shodě na 1. místě „Remíza!“; u robota stejně (jméno robota).
  - Podtitul „{hra} · {obtížnost}“ (obtížnost jen když hrál robot).
  - Avatar vítěze 120 dp (u robota `RobotAvatar` 120).
  - Seznam podle pořadí: `PlayerSlot` s „{place}. {name}“, skóre a hvězdami ★ (zlaté, prázdné ☆ do 3) u lidí; robot má štítek „robot“ a žádné hvězdy.
  - Tlačítka: `PrimaryButton` „Hrát znovu“ (stejný config, nový seed), druhé tlačítko na `paper` „Změnit nastavení“ (setup s tímto configem), a „Domů“.
  - `Confetti` – 80 papírků v barvě vítěze (+ zlatá), padají 1,5 s (`CustomPainter`, `SeededRandom(0)`), při omezení animací se nezobrazí.
  - ARB: `resultWins`, `resultDraw` Remíza! / It's a draw! / ¡Empate!; `resultPlayAgain` Hrát znovu; `resultChangeSettings` Změnit nastavení; `resultHome` Domů; `resultRobotTag` robot.

- [ ] **Step 1: Napsat failing testy**: výhra člověka – nadpis se jménem, pořadí, hvězdy; výhra robota – nadpis se jménem robota a `RobotAvatar`; remíza; „Hrát znovu“ otevře `GameScreen` se stejným configem; „Změnit nastavení“ otevře setup předvyplněný; „Domů“; s `disableAnimations` není konfeta; text-fit tlačítek a nadpisu (es, 360 dp, 130 %).
- [ ] **Step 2–4.** **Step 5: Commit** `feat(results): results screen with ranking, stars and confetti`

### Task 8: Deska ukázkové hry, pravidla, kompletní průchod

**Files:**
- Create: `lib/games/_sample/sample_board.dart`, `lib/games/_sample/sample_icon.dart`
- Modify: `lib/games/_sample/sample_module.dart`, ARB, `test/app/text_fit_test.dart`
- Test: `test/games/_sample/sample_board_test.dart`, `test/games/_sample/sample_flow_test.dart`

**Interfaces:**
- Produces:
  - Deska: nahoře velký text rozsahu „{low} – {high}“ (Baloo 2, 40), pod ním mřížka čísel `low..high` jako papírové dlaždice ≥ 56 dp (dětská plocha), vyřazená čísla zmizí; poslední tip zvýrazněný v barvě hráče s šipkou „Víc!“ / „Míň!“; tap na číslo → `submit(Move(seat, 'guess', {'value': n}))`, když `canAct`; při `!canAct` (robot na tahu) jsou dlaždice ztlumené.
  - `turnHint`: „{name}, tipni číslo od {low} do {high}“.
  - Ikona: papírová kartička s „?“ a čísly v barvách hráčů (kresleno `CustomPainter`, jednotný styl ikon kap. 6.5).
  - Pravidla (`sampleRules`): krátký text ve 3 jazycích.
  - ARB: `sampleHigher` Víc! / Higher! / ¡Más!; `sampleLower` Míň! / Lower! / ¡Menos!; `sampleTurnHint`; `sampleRules`; `sampleOptionRange` a hodnoty.

- [ ] **Step 1: Napsat failing testy**:
  - deska: jen čísla v mezích, tap pošle správný `Move`, při `canAct == false` nic; dlaždice ≥ 56 dp.
  - **kompletní průchod** (`sample_flow_test`): domů → karta „Hádej číslo“ → nastavení (4 místa, 2 profily) → sloty 3–4 roboti → „Hrát!“ → hra; člověk i roboti hrají (rychlost Rychle, `InlineAiRunner`) až do konce → výsledky s robotím avatarem u robotů; „Hrát znovu“; zpět domů → „Pokračovat“ ukazuje Hádej číslo; nové otevření nastavení je předvyplněné.
  - **replay kontrakt**: po skončení průchodu `GameSession.restore(save)` dá stejný `stateHash` (všechny akce šly přes `Move`/`LocalTransport`).
  - text-fit: nastavení hry (4 místa), HUD se 4 čipy a výsledky – cs/en/es, 360×740 a 1280×800, 1,0 a 1,3.
- [ ] **Step 2–4.** **Step 5: Commit** `feat(sample): board, icon and rules; full play-through tests`

### Task 9: Ověření na emulátorech a dokumentace

**Files:**
- Modify: `docs/ARCHITECTURE.md` (herní API, tok tahu, ukládání/replay), `CLAUDE.md` (jak přidat hru – krátce; plné `GAME_MODULE_GUIDE.md` v milníku 10)
- Create: `docs/milestones/m4/*.png`

- [ ] **Step 1: Telefon (release APK)**: odehrát Hádej číslo 1 člověk + 1 robot do konce (výsledky); 4 místa / 2 lidé (sloty, HUD s 4 čipy); vypnout hudbu, ukončit, znovu otevřít – zůstává vypnutá; uprostřed partie zabít aplikaci a přes „Pokračovat“ obnovit; screenshoty nastavení, HUD (robot přemýšlí), pauza, výsledky.
- [ ] **Step 2: Tablet na šířku** – HUD s pruhem hráčů uprostřed, výsledky; screenshoty.
- [ ] **Step 3:** `flutter analyze --fatal-infos`, `flutter test`, velikost APK.
- [ ] **Step 4:** dokumentace. **Step 5: Commit** `docs: milestone 4 screenshots and game API notes`. **Step 6:** shrnutí – push/PR jen na pokyn.
