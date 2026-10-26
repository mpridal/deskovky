# Milník 9 – Příprava na paralelní vývoj her: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aby šly Piškvorky, Pexeso, Miny a Člověče vyvíjet paralelně ve čtyřech sessions, kde každá mění **jen složku své hry**. Framework proto dostane:
- kostry her a registr;
- texty, zvuky a hudbu ve složce hry;
- game kit;
- kontraktní testy;
- kontrolu rozsahu změn v CI;
- návod `GAME_MODULE_GUIDE.md`.

**Architecture:**
- **Texty hry** jsou v Dart mapách ve složce hry (`lib/games/<id>/<id>_texts.dart`, cs/en/es). Registr `GameTexts` je sloučí. `gameText(l10n, key)` hledá nejdřív v nich, potom ve sdílených ARB. Ukázková hra `_sample` se na tento mechanismus převede jako důkaz.
- **Zvuky her** deklaruje manifest (`sfx`), soubory leží v `assets/games/<id>/sfx/`. `AudioCatalog` se při startu doplní z manifestů. Hudba má pevnou konvenci `music/<id>.ogg`.
- **Game kit** (`lib/core/game_kit/`) obsahuje:
  - widgety `BoardGrid`, `PieceToken`, `FlipCard`, `Dice`;
  - čisté `GameSearch` (alpha-beta s iterativním prohlubováním a časovým limitem; běží uvnitř `AiPlayer.chooseMove`, který už je v izolátu);
  - herní čas `GameClock`: pozastavitelný, ukládá se a deska ho dostane v `GameBoardView.elapsed`.
- **Kostry** her `tictactoe`, `memory`, `minesweeper`, `ludo`, `checkers` mají `available: false` (štítek „Brzy“) a jsou zaregistrované už teď. Paralelní session pak registr nemění.
- **Kontraktní testy** `runGameContract(module)` v `test/games/contract.dart` musí projít všechny hry.
- **Kontrola rozsahu** hlídá větve `game/<id>`: `tool/check_scope.dart` v CI.

**Tech Stack:** Flutter 3.47.8, Riverpod 3, go_router, Drift (beze změny schématu), just_audio. Nové závislosti nejsou. Jen pro tento PC se stáhne `ffmpeg` (Miloš schválil 2026-10-26).

**Spec:** `docs/ZADANI-deskovky.md`:
- kap. 8 „Příprava na paralelní vývoj her“ (body 1–7);
- kap. 11 milníky 9–10;
- kap. 13.2–13.4 (pravidla paralelní práce, osnova hry);
- kap. 7.1–7.4 (OGG, ≤ 15 MB, licence).

## Global Constraints
- Prefix `<id>.` mají klíče textů her, id odznaků, id efektů i soubory assetů (13.2 bod 5).
- **Kam smí paralelní session `game/<id>`:**
  - `lib/games/<id>/**`
  - `assets/games/<id>/**`
  - `test/games/<id>/**`
  - `assets/audio/music/<id>.ogg`
  - **Odchylka od 13.2:** cesta `lib/` místo `games/`, protože kód Flutteru žije v `lib/`.
- **Hudba:**
  - OGG Vorbis kolem 96 kb/s, celkem ≤ 15 MB (7.1);
  - každá skladba má záznam v `CREDITS.json` s přesným CC BY textem (7.4).
- **Skladby z tabulky 7.2** (Kevin MacLeod, incompetech.com, CC BY 4.0):
  - `tictactoe` = „Local Forecast – Elevator“
  - `memory` = „Monkeys Spinning Monkeys“
  - `minesweeper` = „Sneaky Snitch“
  - `ludo` = „Fluffing a Duck“
  - `menu` = „Carefree“ a `sample` = „Quirky Dog“ zůstávají, jen se převedou do OGG
  - `checkers` zatím zůstává zástupná
- **Vlastní efekty her ze 13.5–13.8** dostanou zatím zástupné zvuky ze skriptu:
  - `tictactoe.draw`, `tictactoe.line`
  - `memory.match`, `memory.miss`
  - `minesweeper.dig`, `minesweeper.flag`, `minesweeper.puff`
  - `ludo.hop`, `ludo.boing`, `ludo.home`
- Žádné `Random()` ve hrách – náhoda jen přes `SeededRandom` ze stavu (kap. 8).
- Hry, které nejsou hotové, mají `available: false`. Kostry projdou kontraktními testy kromě hratelnosti.
- Tag `v0.9.0-framework` se **nevytvoří**. Tag `v*` spouští vydání a 0.9.0 by bylo vyšší než budoucí 0.3.0. API v1.0 se zmrazí poznámkou v `GAME_MODULE_GUIDE.md` a tagem `framework-v1` (nespouští release).
- Vydání: podle Miloše **všechny 4 hry najednou**. Milník 9 se sloučí do `main` bez vlastního vydání.

## Review Focus
1. **Chybějící překlad:** text hry chybí v jednom jazyce nebo je jen ve sdílených ARB. Má se zobrazit anglická verze, nikdy ne holý klíč; kontraktní test na to musí upozornit. → Task 1.
2. **Neexistující zvuk:** efekt hry, jehož soubor neexistuje, nesmí aplikaci shodit, prostě se nepřehraje; test assetů na to upozorní. → Task 2.
3. **Herní čas:** pauza ani aplikace na pozadí nesmí plynout do času partie a uložení a obnovení musí čas zachovat. Hodnocení v Minách a Pexesu na tom závisí. → Task 4.
4. **Časový limit `GameSearch`:** musí platit i při hluboké pozici a pozice bez tahů nesmí spadnout. → Task 4.
5. **`check_scope`:** pustí jen soubory vlastní hry a správně se chová i pro větve, které nejsou `game/*`. → Task 7.

---

### Task 1: Texty hry ve složce hry
**Files:**
- Create: `lib/core/game/game_texts.dart`, `lib/games/_sample/sample_texts.dart`
- Modify: `lib/core/game/game_module.dart`, `lib/games/game_texts.dart`, `lib/games/badge_texts.dart`, `lib/games/_sample/*.dart`, `lib/l10n/app_{cs,en,es}.arb` (odebrat `sample*`)
- Test: `test/core/game/game_texts_test.dart`

**Interfaces – Produces:**
- `class GameTexts { const GameTexts({required Map<String,String> cs, en, es}); String? lookup(String languageCode, String key, [Map<String,Object?> args]); }` (placeholdery ve tvaru `{name}`).
- `GameModule.texts → GameTexts` (výchozí prázdné).
- `String gameText(AppLocalizations l10n, String key, [Map<String,Object?> args])`: projde texty všech modulů v jazyce `l10n.localeName`, pak `en`, pak sdílené ARB, nakonec vrátí klíč.
- `badgeText` stejným způsobem.

- [ ] Test: `gameText` vrátí český text ukázkové hry, při chybějící češtině anglický, `{name}` dosadí, neznámý klíč vrátí klíč. RED.
- [ ] Implementovat a převést `_sample` (texty, odznak, nápověda tahu, volba) na `sample_texts.dart`; klíče `sample.*` z ARB odstranit.
- [ ] `flutter test` zelené (sample flow, výsledky, odznaky, Autoři a licence) → commit.

### Task 2: Zvuky a hudba her
**Files:**
- Modify: `lib/core/audio/audio_catalog.dart`, `lib/core/game/game_module.dart`, `tool/generate_placeholder_audio.py`, `assets/audio/CREDITS.json`, `pubspec.yaml` (assets)
- Create: `assets/games/<id>/sfx/*.ogg` (zástupné), `assets/audio/music/*.ogg`
- Test: `test/core/audio/audio_assets_test.dart`, `test/core/audio/audio_catalog_test.dart`

**Interfaces – Produces:**
- `GameModule.sfx → Map<String,String>`: id → cesta pod `games/<id>/sfx/`.
- `AudioCatalog.standard.withGames(List<GameModule>)`.
- Hudba každé hry je `music/<id>.ogg`.

- [ ] Test: katalog obsahuje efekty z manifestů, každý soubor existuje, hudba je `.ogg`, celkem ≤ 15 MB, každá skladba má kompletní CC BY záznam. RED.
- [ ] Stáhnout ffmpeg do `C:\dev\tools\ffmpeg` (oficiální build gyan.dev, mimo repozitář). Stáhnout 4 skladby z incompetech.com. Převést je do OGG 96 kb/s spolu s `menu`/`sample` a zástupnými WAV. Staré soubory přesunout do zálohy.
- [ ] Skriptem vygenerovat zástupné efekty her do `assets/games/<id>/sfx/`. Do `pubspec.yaml` předem uvést `assets/games/<id>/`, `…/sfx/` a pro `memory` i `…/cards/{animals,food,transport,space}/`.
- [ ] Autoři a licence načtou i nepovinný `assets/games/<id>/CREDITS.json` každé hry (stejný formát; Pexeso tam uvede Noto Emoji, Apache 2.0) – test s falešným souborem RED → GREEN.
- [ ] Testy zelené → commit.

### Task 3: Game kit – widgety
**Files:** Create `lib/core/game_kit/{board_grid,piece_token,flip_card,dice}.dart`. Test: `test/core/game_kit/*_test.dart` + golden `test/core/game_kit/goldens/kit.png`.

**Interfaces – Produces:**
- `BoardGrid({required int columns, rows, required Widget Function(BuildContext, int col, int row) cell, ValueChanged<(int,int)>? onTap, bool zoomable = false, Set<(int,int)> highlighted})`:
  - políčka ≥ 48 dp, a pokud se nevejdou, zapne se pinch-zoom a posun;
  - `BoardGridController.center()` pro tlačítko „vycentrovat“.
- `PieceToken({required int seat, double size, bool pulse = false})` a `PieceToken.hopAlong(path)`:
  - barvy hráčů 1–4;
  - volitelná mini značka pro barvoslepé.
- `FlipCard({required bool faceUp, required Widget front, required Widget back, Duration duration})`: 3D otočení.
- `Dice({required int? value, required bool rolling, VoidCallback? onTap})`:
  - animace hodu, která respektuje omezení pohybu;
  - hodnotu určuje vždy stav hry, nikdy widget.

- [ ] Widget testy (dotyk na políčko vrátí správné `(col,row)`, malá políčka zapnou zoom, FlipCard ukáže správnou stranu, Dice ukáže 1–6, bez animace při omezení pohybu) + golden. RED → implementace → zelené → commit.

### Task 4: Game kit – logika (`GameSearch`, `GameClock`)
**Files:**
- Create: `lib/core/game_kit/game_search.dart`, `lib/core/game_kit/game_clock.dart`
- Modify: `lib/core/game/game_module.dart` (`GameBoardView.elapsed`), `lib/features/game_play/game_screen.dart`, `lib/core/game/game_store.dart` (uložit čas)
- Test: `test/core/game_kit/game_search_test.dart`, `test/features/game_play/game_clock_test.dart`

**Interfaces – Produces:**
- `GameSearch<S>` s parametry:
  - `moves(S) → List<Move>`
  - `apply(S, Move) → S`
  - `evaluate(S, int seat) → int`
  - `isOver(S) → bool`

  a metodou `Move? best(S state, int seat, {int maxDepth, Duration timeLimit, SeededRandom? tieBreak})`, která dělá alpha-beta s iterativním prohlubováním a při vypršení limitu vrátí nejlepší tah z poslední dokončené hloubky.
- `GameBoardView.elapsed → Duration`: herní čas bez pauz a pozadí. Uloží se s rozehranou partií.

- [ ] Testy:
  - Minimax najde výhru v jednom tahu a zablokuje prohru.
  - Limit 50 ms se dodrží i při hloubce 20.
  - Pozice bez tahů vrátí `null`.
  - Pauza a pozadí se nezapočítají a čas přežije uložení a obnovení.

  RED → implementace → zelené → commit.

### Task 5: Kostry 5 her + registr
**Files:** Create `lib/games/{tictactoe,memory,minesweeper,ludo,checkers}/` – `<id>_module.dart` (manifest podle 13.5–13.9, `available: false`), `<id>_rules.dart` (minimální stav), `<id>_icon.dart` (ikona kreslená kódem), `<id>_texts.dart` (název, popis, pravidla ve 3 jazycích), `README.md`. Modify `lib/games/registry.dart` (všech 6 modulů, „Brzy“ zůstává).

- [ ] Test: mřížka ukazuje Hádej číslo a 5 her se štítkem „Brzy“ s vlastními ikonami a názvy ve 3 jazycích. RED → implementace → zelené → commit.

### Task 6: `GameTestHost` + kontraktní testy
**Files:** Create `test/games/contract.dart`, `test/games/game_test_host.dart`, `test/games/contract_all_test.dart`.

**Interfaces – Produces:** `void runGameContract(GameModule module, {bool playable = true})` ověří:
- manifest (id, prefixy, rozsah hráčů, volby s výchozími hodnotami, násobič 0,5–2);
- že všechny klíče jsou ve 3 jazycích;
- start pro každý počet hráčů, kombinaci lidí a robotů a obtížnost;
- že AI odehraje partii sama se sebou bez nelegálního tahu;
- serializaci stavu a tahů;
- replay seed + tahy, který dá stejný hash;
- uložení a obnovení;
- validní `GameResult`.

S `playable: false` jen manifest a texty.

- [ ] Kontrakt pustit na `_sample` (plný) a kostry (`playable: false`). Případné nálezy v `_sample` opravit → zelené → commit.

### Task 7: Kontrola rozsahu, rychlé spuštění hry, dokumentace
**Files:**
- Create: `tool/check_scope.dart`, `docs/GAME_MODULE_GUIDE.md`
- Modify: `.github/workflows/ci.yml` (krok pro větve `game/*`), `lib/main.dart` / router (`--dart-define=GAME=<id>` otevře nastavení hry), `CLAUDE.md` (pravidla 13.2 přizpůsobená cestám v `lib/`), `docs/ARCHITECTURE.md`
- Test: `test/tool/check_scope_test.dart`

**Behaviour:**
- `dart run tool/check_scope.dart <branch> <file…>` skončí kódem 1, pokud má větev `game/<id>` soubor mimo povolené cesty.
- Ostatní větve neomezuje.

- [ ] Testy: povolené cesty projdou, cizí hra nebo `core/` neprojde, větev `main` neomezuje. RED → implementace → zelené.
- [ ] Napsat `GAME_MODULE_GUIDE.md`:
  - jak napsat hru (manifest, pravidla, AI, deska, texty, zvuky);
  - game kit s ukázkami;
  - kontraktní testy;
  - postup paralelní práce;
  - `FRAMEWORK_REQUESTS.md`;
  - zmrazení API v1.0.
- [ ] Commit.

### Task 8: Ověření a předání
- [ ] Plné testy, `flutter analyze --fatal-infos` a emulátor (mřížka s 5 hrami „Brzy“, hudba ve hře, vše přeložené) → snímky `docs/milestones/m9/`.
- [ ] Nezávislá revize (opus) a oprava nálezů.
- [ ] PR do `main`. Sloučení a tag `framework-v1` až po Miloševě souhlasu.
- [ ] Teprve potom 4 paralelní sessions (worktree `game/<id>` z `main`), každá s briefem: kap. 13.x + `GAME_MODULE_GUIDE.md` + pravidla rozsahu.
