# Milník 3 – profily hráčů, perzistence a aktivní hráč: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hráči si vytvoří až 8 profilů (jméno + avatar), upraví je a smažou; data přežijí restart i aktualizaci aplikace; aktivní hráč a zvolený jazyk se pamatují; hlavní stránka ukazuje aktivního hráče a umí ho přepnout.

**Architecture:** Lokální SQLite přes **Drift** (`lib/core/db/`) s verzovaným schématem a testy migrací. Nad ním repozitáře (`PlayerRepository`, `SettingsRepository`) s validací pravidel ze zadání. Do UI se dostávají přes **Riverpod** (`flutter_riverpod`) – providery v `lib/app/providers.dart`, databáze se v testech nahrazuje pamětí (`NativeDatabase.memory()`). Obrazovky sledují data jako `Stream`, takže se po změně překreslí samy.

**Tech Stack:** Flutter 3.47.8, `drift` + `drift_flutter` (otevření DB na Androidu), `drift_dev` + `build_runner` (generování kódu a schémat, jen dev), `flutter_riverpod`. Ostatní beze změny.

**Spec:** `docs/ZADANI-deskovky.md` – kap. 5.1 (horní pruh hlavní stránky), 5.2 (správa hráčů), 5.10 (jazyk v Nastavení), 8 „Data (lokální DB)“, 4 („aktualizace nesmí smazat lokální data“, „migrace verzované a testované“), 10. Vizuál: mockup – horní pruh hlavní stránky (`.bar`, `.hello`), editor avatara s polem jména (`.namefield`), panel „Hráči na zařízení“ (`.plist`, `.add`).

## Global Constraints

- Platí vše z Global Constraints milníků 1 a 2.
- Profil: `id` (autoincrement int), `name` 1–16 znaků po oříznutí mezer, **unikátní bez ohledu na velikost písmen a okrajové mezery; diakritika se rozlišuje** (`Tereza` = `tereza` = `" Tereza "`, ale `Tereza` ≠ `Teréza`), `avatar` = JSON z `AvatarSpec.toJson()`, `favoriteSeat` volitelný 0–3, `createdAt` (UTC). **Max. 8 profilů.**
- Smazání profilu vždy po potvrzení (`showAppConfirmDialog`).
- Aktivní hráč se pamatuje; když je smazán, aktivním se stane nejstarší zbývající profil, bez profilů žádný.
- Jazyk: `null` = podle systému (pravidlo z milníku 1), jinak `cs` / `en` / `es`; volba se pamatuje.
- Žádné osobní údaje kromě přezdívky; žádná síť.
- DB soubor v adresáři aplikace (`drift_flutter` → `getApplicationSupportDirectory`), nikdy ne v cache – aktualizace APK ho nesmaže.
- Každá změna schématu = nová `schemaVersion` + migrace + uložený snapshot schématu v `drift_schemas/` + test migrace.

## Review Focus

1. **Duplicitní jméno s jinou velikostí písmen nebo mezerami** (`" tereza "` vs. `Tereza`) – odmítnout s hláškou „Toto jméno už má jiný hráč“ → test v Task 2.
2. **Devátý profil** – tlačítko „Nový hráč“ je neaktivní s vysvětlením a repozitář ho odmítne i při přímém volání → testy v Task 2 a 5.
3. **Smazání aktivního hráče / posledního hráče** – aktivní přejde na nejstaršího zbývajícího, při nule profilů hlavní stránka nabídne „Vytvořit hráče“ a nespadne → testy v Task 3 a 6.
4. **Restart aplikace** (zabití procesu) – profily, avatary, aktivní hráč a jazyk zůstanou → test se souborovou DB v Task 1/3 + ověření na emulátoru v Task 8.
5. **Rozepsaná úprava a tlačítko Zpět** – editor se zeptá „Zahodit změny?“, nic se neuloží bez potvrzení (odložená drobnost z milníku 2) → test v Task 5.

---

### Task 1: Databáze Drift, schéma v1 a testy migrací

**Files:**
- Modify: `pubspec.yaml` (deps `drift`, `drift_flutter`, `flutter_riverpod`; dev `drift_dev`, `build_runner`), `analysis_options.yaml` (vyloučit `**/*.g.dart` z analýzy). CI se nemění – generované soubory se commitují (Step 4).
- Create: `lib/core/db/app_database.dart`, `lib/core/db/tables.dart`, `lib/core/db/app_database.g.dart` (generovaný), `drift_schemas/drift_schema_v1.json`, `test/core/db/generated/` (generovaný verifier), `test/core/db/migration_test.dart`, `test/core/db/app_database_test.dart`, `build.yaml` (nastavení `drift_dev`: `databases: {app: lib/core/db/app_database.dart}`, `schema_dir: drift_schemas/`, `test_dir: test/core/db/generated/`)

**Interfaces:**
- Produces:
  - Tabulka `Players`: `id` int autoIncrement, `name` text 1–16, `nameKey` text unique (normalizovaný klíč pro unikátnost: `name.trim().toLowerCase()`), `avatarJson` text, `favoriteSeat` int nullable, `createdAt` dateTime.
  - Tabulka `AppSettings`: `key` text primary key, `value` text.
  - `@DriftDatabase(tables: [Players, AppSettings]) class AppDatabase extends _$AppDatabase { AppDatabase(QueryExecutor e); factory AppDatabase.open(); int get schemaVersion => 1; MigrationStrategy get migration; }` – `open()` používá `driftDatabase(name: 'deskovky')` z `drift_flutter`; `migration.onCreate` = `m.createAll()`, `beforeOpen` zapne `PRAGMA foreign_keys = ON`.

- [ ] **Step 1: Přidat balíčky** (`flutter pub add drift drift_flutter flutter_riverpod` a `flutter pub add dev:drift_dev dev:build_runner`), zapsat do ledgeru zvolené verze. **Ověřit prostředí:** minimální test s `NativeDatabase.memory()` musí na Windows proběhnout (`flutter test`) – pokud selže kvůli chybějící knihovně SQLite, rozhodnout (ruling) mezi `sqlite3` s build hooks a přibalením `sqlite3.dll` do `test/` a postup zapsat do CLAUDE.md.
- [ ] **Step 2: Napsat failing testy** `app_database_test.dart`: v paměťové DB lze vložit hráče a přečíst ho; vložení druhého hráče se stejným `nameKey` vyhodí `SqliteException` (unique); `AppSettings` uloží a přepíše hodnotu pod stejným klíčem; **souborová DB** (`NativeDatabase(File(tmp))`) – zapsat hráče, zavřít, otevřít znovu → hráč tam je.
- [ ] **Step 3: Run** `flutter test test/core/db` → FAIL.
- [ ] **Step 4: Implementovat** tabulky a `AppDatabase`; `dart run build_runner build --delete-conflicting-outputs`. Generované `*.g.dart` **commitovat** (CI pak build_runner nepotřebuje; ruling zapsat), vyloučit je z analýzy.
- [ ] **Step 5: Snapshot schématu a test migrace**: `dart run drift_dev make-migrations` (vytvoří `drift_schemas/drift_schema_v1.json` a verifier v `test/core/db/generated/`); `migration_test.dart` ověří, že čerstvá DB odpovídá snapshotu v1 (`verifier.migrateAndValidate(db, 1)`). Do CLAUDE.md zapsat postup pro každou další verzi schématu.
- [ ] **Step 6: Run** `flutter analyze --fatal-infos && flutter test` → PASS.
- [ ] **Step 7: Commit** `feat(db): Drift database with schema v1 and migration tests`

### Task 2: `PlayerRepository` s pravidly profilu

**Files:**
- Create: `lib/core/players/player_profile.dart`, `lib/core/players/player_repository.dart`
- Test: `test/core/players/player_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 1), `AvatarSpec` (milník 2).
- Produces:
  - `@immutable class PlayerProfile { final int id; final String name; final AvatarSpec avatar; final int? favoriteSeat; final DateTime createdAt; }`
  - `enum ProfileError { nameEmpty, nameTooLong, nameTaken, limitReached, notFound }` a `class ProfileException implements Exception { final ProfileError error; }`
  - `class PlayerRepository { PlayerRepository(AppDatabase db); static const maxProfiles = 8; static const maxNameLength = 16; Stream<List<PlayerProfile>> watchAll(); Future<List<PlayerProfile>> all(); Future<PlayerProfile?> byId(int id); Future<PlayerProfile> create({required String name, required AvatarSpec avatar, int? favoriteSeat}); Future<PlayerProfile> update(int id, {String? name, AvatarSpec? avatar, int? favoriteSeat}); Future<void> delete(int id); }`
  - Pořadí v `watchAll`/`all`: podle `createdAt` vzestupně (nejstarší první).
  - Jméno se ukládá oříznuté (`trim()`); délka se počítá v Unicode znacích (`characters.length`), aby emoji a diakritika nepočítaly víc.

- [ ] **Step 1: Napsat failing testy**: vytvoření vrátí profil s id a `createdAt`; `"  Kuba  "` se uloží jako `Kuba`; `""` a `"   "` → `nameEmpty`; 17 znaků → `nameTooLong`, 16 znaků projde, `"Žofie🦄"` (7 znaků) projde; `Tereza` a pak `tereza` → `nameTaken`; `update` na jméno jiného hráče → `nameTaken`, na vlastní jméno s jinou velikostí písmen projde; 8 profilů projde, 9. → `limitReached`; `delete` neexistujícího → `notFound`; avatar se uloží a načte stejný (`==`); poškozený `avatarJson` v DB (zapsaný přímo SQL) se načte jako `AvatarSpec.defaults` bez pádu; `watchAll` vydá nový seznam po `create`, `update` a `delete`; pořadí je od nejstaršího.
- [ ] **Step 2: Run** `flutter test test/core/players` → FAIL.
- [ ] **Step 3: Implementovat** repozitář (kontrola limitu a unikátnosti v transakci; unikátnost navíc jistí unique index `nameKey`).
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(players): player repository with profile rules`

### Task 3: `SettingsRepository` – aktivní hráč a jazyk

**Files:**
- Create: `lib/core/settings/settings_repository.dart`
- Test: `test/core/settings/settings_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `PlayerRepository`.
- Produces:
  - `class SettingsRepository { SettingsRepository(AppDatabase db); Stream<int?> watchActivePlayerId(); Future<void> setActivePlayerId(int? id); Stream<Locale?> watchLocale(); Future<void> setLocale(Locale? locale); }` – klíče `activePlayerId`, `locale` (`'cs'|'en'|'es'`, smazání klíče = systém).
  - `Stream<PlayerProfile?> watchActivePlayer(PlayerRepository players, SettingsRepository settings)` (v `lib/core/players/active_player.dart`) – kombinuje oba proudy: uložené id, pokud profil existuje; jinak nejstarší profil (a zároveň ho uloží jako aktivní); bez profilů `null`.

- [ ] **Step 1: Napsat failing testy**: výchozí `activePlayerId` je `null` a jazyk `null`; uložení a nové otevření souborové DB vrátí stejné hodnoty; `setLocale(null)` klíč smaže; `watchActivePlayer`: bez profilů `null`; po vytvoření prvního profilu je aktivní on; po ručním výběru druhého je aktivní druhý; po smazání aktivního je aktivní nejstarší zbývající; po smazání všech `null`; neznámá hodnota jazyka v DB (`'de'`) → `null`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat.**
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(settings): persisted active player and language`

### Task 4: Napojení na aplikaci (Riverpod)

**Files:**
- Create: `lib/app/providers.dart`
- Modify: `lib/main.dart` (`ProviderScope`), `lib/app/app.dart` (jazyk z nastavení), `test/helpers/pump_app.dart` (paměťová DB přes `overrides`), `docs/ARCHITECTURE.md` (Riverpod + Drift, proč)
- Test: `test/app/locale_setting_test.dart`

**Interfaces:**
- Produces:
  - `final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError())` – v `main()` přepsán `AppDatabase.open()`, v testech `AppDatabase(NativeDatabase.memory())`; `ref.onDispose(db.close)`.
  - `playerRepositoryProvider`, `settingsRepositoryProvider` (`Provider`), `playersProvider` (`StreamProvider<List<PlayerProfile>>`), `activePlayerProvider` (`StreamProvider<PlayerProfile?>`), `localeSettingProvider` (`StreamProvider<Locale?>`).
  - `DeskovkyApp` je `ConsumerStatefulWidget`; `MaterialApp.router(locale: ref.watch(localeSettingProvider).value, …)` – `null` nechá rozhodnout `resolveAppLocale` jako dosud.
  - `pumpApp(..., {AppDatabase? db})` vytvoří paměťovou DB, pokud ji test nedá, a zavře ji v `addTearDown`.

- [ ] **Step 1: Napsat failing test** `locale_setting_test.dart`: se systémem `cs` a uloženým jazykem `es` je navigace španělsky; po `setLocale(null)` česky.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat**; všechny dosavadní testy musí projít beze změny chování (jen přes upravený `pumpApp`).
- [ ] **Step 4: Run** `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(app): Riverpod providers for database, players and settings`

### Task 5: Obrazovka Hráči a úprava profilu

**Files:**
- Modify: `lib/features/players/players_screen.dart`, `lib/features/avatar_editor/avatar_editor_screen.dart` (pole jména, dotaz na zahození změn), `lib/app/router.dart`, `lib/l10n/app_{cs,en,es}.arb`
- Create: `lib/features/players/player_tile.dart`
- Test: `test/features/players/players_screen_test.dart` (přepsat), doplnit `test/features/avatar_editor/avatar_editor_screen_test.dart`, `test/app/text_fit_test.dart`

**Interfaces:**
- Consumes: providery z Task 4, `PlayerRepository`, UI kit.
- Produces:
  - **Hráči** (`/players`): nadpis, seznam `PaperCard` řádků `PlayerTile` (avatar 56 dp s rámečkem v `favoriteSeat` barvě, jméno, štítek „Hraje teď“ u aktivního, ikona ✎ „Upravit“, ikona koše „Smazat“), dole `PrimaryButton(playersNew)`; při 8 profilech je neaktivní a pod ním text `playersLimit` („Na tomto zařízení může být nejvýš 8 hráčů.“). Tap na řádek = nastavit aktivního hráče + toast `playersNowPlaying(name)`. Prázdný stav: velký přerušovaný kruh „+“ a text `playersEmpty` („Zatím tu nikdo není. Vytvoř prvního hráče!“).
  - **Úprava profilu**: `AvatarEditorScreen` dostane volitelné `initialName` a `showName: true`; pod náhledem pole jména (paper, radius 14, ikona ✎, `maxLength: 16` s počítadlem, `TextCapitalization.words`); Uložit vrací `AvatarEditResult(name, avatar)`; chyby repozitáře se zobrazí pod polem (`profileErrorEmpty`, `profileErrorTooLong`, `profileErrorTaken`) a editor zůstane otevřený. Když se něco změnilo, Zpět i systémové zpět (`PopScope`) ukážou `showAppConfirmDialog(discardTitle, discardMessage, discardConfirm, discardCancel)`.
  - Routy: `/players/new` a `/players/:id/edit` (full screen, root navigator). Uložení volá `create`/`update` a pak `pop`.
  - Smazání: `showAppConfirmDialog(deleteTitle(name), deleteMessage, deleteConfirm, cancel)` → `delete`.
  - Nové ARB klíče (cs / en / es): `playersNew` Nový hráč / New player / Nuevo jugador; `playersLimit`; `playersEmpty`; `playersNowPlaying` „Teď hraje {name}“ / „{name} is playing now“ / „Ahora juega {name}“; `playerActiveTag` Hraje teď / Playing / Jugando; `playerEdit` Upravit / Edit / Editar; `playerDelete` Smazat / Delete / Eliminar; `profileName` Jméno / Name / Nombre; `profileErrorEmpty` Napiš jméno. / Enter a name. / Escribe un nombre.; `profileErrorTooLong` Nejvýš 16 znaků. / 16 characters at most. / Máximo 16 caracteres.; `profileErrorTaken` Toto jméno už má jiný hráč. / Another player already has this name. / Otro jugador ya tiene este nombre.; `deleteTitle` „Smazat hráče {name}?“; `deleteMessage` „Smažou se i jeho výsledky. Tohle nejde vrátit.“ / en / es; `discardTitle` Zahodit změny? / Discard changes? / ¿Descartar cambios?; `discardMessage`; `discardConfirm` Zahodit / Discard / Descartar; `cancel` Zrušit / Cancel / Cancelar.

- [ ] **Step 1: Napsat failing testy**:
  - prázdný stav ukazuje `playersEmpty` a tlačítko; vytvoření „Tereza“ přes editor → řádek „Tereza“ se štítkem „Hraje teď“;
  - druhý hráč „Kuba“, tap na jeho řádek → štítek přejde ke Kubovi a objeví se toast „Teď hraje Kuba“;
  - úprava jména na „tereza“ u Kuby → chyba „Toto jméno už má jiný hráč.“, editor zůstává otevřený;
  - prázdné jméno → „Napiš jméno.“;
  - smazání s potvrzením → řádek zmizí; zrušení → zůstane;
  - 8 profilů (vložených přes repozitář) → tlačítko neaktivní a text limitu;
  - editor: změna účesu a Zpět → dialog „Zahodit změny?“; „Zrušit“ ponechá editor; „Zahodit“ zavře bez uložení; bez změn Zpět zavře hned;
  - text-fit: obrazovka Hráči a editor s polem jména ve všech jazycích/velikostech/měřítkách.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat.**
- [ ] **Step 4: Run** `flutter analyze --fatal-infos && flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(players): profile list, create, edit, delete and active player`

### Task 6: Horní pruh hlavní stránky a přepnutí hráče

**Files:**
- Create: `lib/features/home/active_player_bar.dart`, `lib/features/home/player_switcher_sheet.dart`
- Modify: `lib/features/home/home_screen.dart`, `lib/app/app_shell.dart` (pravý panel „Hráči na zařízení“ ukazuje profily), ARB
- Test: `test/features/home/active_player_bar_test.dart`, doplnit `test/app/app_shell_test.dart`

**Interfaces:**
- Produces:
  - `ActivePlayerBar` (nahoře na Hry, podle mockupu `.bar`): `AvatarView` 44 dp s rámečkem, nad jménem malý text `homeHello` („Ahoj,“ / „Hi,“ / „¡Hola,“) a jméno (Baloo 2, 20); celý pruh je tlačítko (≥ 48 dp, popisek `homeSwitchPlayer` „Přepnout hráče“) → `showModalBottomSheet` se `PlayerSwitcherSheet`: mřížka avatarů 64 dp se jmény, aktivní se zlatým rámečkem, tap = přepnout a zavřít, poslední položka „+ Nový hráč“ (pokud < 8) otevře `/players/new`. Bez profilů je místo pruhu `PrimaryButton(homeCreatePlayer)` „Vytvořit hráče“.
  - Počítadlo bodů a tlačítko zvuku z mockupu přijdou v milnících 5 a 7 – místo pro ně se nechává (pruh je `Row`, jméno `Expanded`).
  - Pravý panel (≥ 840 dp): sekce „Hráči na zařízení“ ukáže avatary 52 dp se jmény + „+ Nový“ (mockup `.plist`/`.add`).

- [ ] **Step 1: Napsat failing testy**: bez profilů je vidět „Vytvořit hráče“ a vede na editor; s profily „Ahoj, Tereza“ a avatar; tap → sheet se všemi hráči; tap na „Kuba“ → pruh ukazuje Kubu a po novém `pumpApp` se stejnou DB (simulace restartu) je pořád Kuba; v panelu na 1280×800 jsou jména všech hráčů; text-fit pruhu a sheetu (dlouhé jméno 16 znaků „Maximiliánek123“ se nezalomí – ellipsis povolen jen u jména, ne u „Ahoj“).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat.**
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(home): active player bar and player switcher`

### Task 7: Volba jazyka v Nastavení

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`, ARB
- Test: `test/features/settings/settings_screen_test.dart`

**Interfaces:**
- Produces: sekce `settingsLanguage` („Jazyk“ / „Language“ / „Idioma“) se `SegmentedControl<String?>` o čtyřech segmentech: `settingsLanguageSystem` („Podle telefonu“ / „Phone setting“ / „Según el teléfono“), „Čeština“, „English“, „Español“ (názvy jazyků se nepřekládají – každý ve svém jazyce, nejsou v ARB). Volba volá `SettingsRepository.setLocale` a UI se přepne okamžitě. Ukázkový text fontů (milník 1) zůstává pod tím.

- [ ] **Step 1: Napsat failing testy**: výběr „Español“ přepne navigaci na „Ajustes“ a vydrží nový `pumpApp` se stejnou DB; „Podle telefonu“ vrátí systémový jazyk; segmenty se na 360 dp při 130 % nezalomí (pokud se 4 segmenty nevejdou, ruling: dvouřádková mřížka 2×2 místo segmented controlu).
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat.**
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(settings): language choice`

### Task 8: Ověření na emulátorech, dokumentace

**Files:**
- Modify: `CLAUDE.md` (Drift: kde je DB, postup při změně schématu, generování kódu; Riverpod providery), `docs/ARCHITECTURE.md`
- Create: `docs/milestones/m3/*.png`

- [ ] **Step 1: Release APK na telefonu**: vytvořit 3 hráče s různými avatary, jednoho upravit, jednoho smazat (s potvrzením), přepnout aktivního, zvolit španělštinu; **zabít aplikaci** (`adb shell am force-stop`) a spustit znovu → vše zůstalo (screenshoty před a po).
- [ ] **Step 2: Aktualizace bez ztráty dat**: nainstalovat přes stávající release APK s vyšším `versionCode` (dočasně v `pubspec.yaml` `0.1.0+2`, neukládat do gitu) pomocí `adb install -r` → data zůstala. Postup a výsledek zapsat do ledgeru.
- [ ] **Step 3: Tablet na šířku**: pravý panel s hráči, horní pruh, přepínač hráče – screenshoty.
- [ ] **Step 4: Ověřit** `flutter analyze --fatal-infos`, `flutter test`, velikost release APK (Drift + sqlite3 přidají ~1–2 MB; zapsat).
- [ ] **Step 5: Dokumentace** – CLAUDE.md a ARCHITECTURE.md doplnit.
- [ ] **Step 6: Commit** `docs: milestone 3 screenshots and database notes`
- [ ] **Step 7: Shrnutí Milošovi** – push a PR jen na jeho pokyn.
