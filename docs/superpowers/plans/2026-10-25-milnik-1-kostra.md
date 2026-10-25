# Milník 1 – kostra projektu: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Spustitelná Flutter aplikace pro Android s CI, design tokeny, přibalenými fonty, lokalizací CS/EN/ES, navigací Hry · Hráči · Žebříčky · Nastavení a responzivním rozložením (zatím prázdné obrazovky).

**Architecture:** Jeden Flutter balíček `deskovky`. Adresáře ze zadání (kap. 8) leží pod `lib/` (`lib/app`, `lib/core`, `lib/ui_kit`, `lib/features`, `lib/games`), protože Dart kód musí být v `lib/`. Routing přes `go_router` (`StatefulShellRoute` = 4 větve navigace se zachovaným stavem), lokalizace přes `flutter_localizations` + `gen-l10n` (ARB). Rozložení se řídí třídou šířky okna (compact/medium/expanded) z kap. 3.

**Tech Stack:** Flutter 3.47.8 (stable), Dart 3.13, `go_router`, `flutter_localizations`, `intl`, `flutter_lints`. GitHub Actions s `subosito/flutter-action@v2`.

**Spec:** `docs/ZADANI-deskovky.md` (kap. 1, 2, 3, 5.1, 6.1–6.2, 8 – struktura, 11 bod 1). Vizuál: `docs/design/deskovky-navrh-vizualu.html`.

## Global Constraints

- Android min. **8.0 (API 26)**, cílové API = výchozí aktuální z Flutteru. Jen platforma Android.
- Application ID `cz.mpridal.deskovky`, název aplikace „Deskovky“ ve všech jazycích (otevřený bod kap. 15 – výchozí volba, lze změnit).
- Plně offline: fonty přibalené v `assets/fonts/`, žádný `google_fonts` za běhu, žádná analytika.
- Žádné natvrdo psané texty v UI – vše přes ARB; klíče anglicky; čeština má ICU plural tvary one / few / other (1 / 2–4 / 5+).
- Výchozí jazyk podle systému: `cs` → čeština, `es` → španělština, jinak angličtina.
- Barvy přesně dle kap. 6.1 (`walnut #3B2A20`, `wood #8B5A3C`, `woodLight #C89B6D`, `felt #2F5D50`, `feltDark #234A3F`, `paper #F4EADB`, `paper2 #E9DCC7`, `ink #2B211B`, `gold #E0A82E`, `player1..4 #D9534F #3B7DD8 #E8B931 #4CAF6A`).
- Typografie: nadpisy **Baloo 2** (600/800), texty **Nunito** (400/600/800); H1 30, H2 22, tělo 16, popisky 12–13 sp; systémové zvětšení písma do 130 % nesmí rozbít layout.
- Třídy šířky: compact < 600 dp (spodní navigace, mřížka 2 sloupce), medium 600–839 (rail vlevo, 3 sloupce), expanded ≥ 840 (rail, 3–4 sloupce, pravý panel).
- Dotykové cíle min. 48 dp; ikonová tlačítka mají popisek pro čtečku obrazovky.
- Testovací velikosti: 360×740, 412×915, 800×1280, 1280×800.
- Nic se neodesílá na GitHub (push) bez výslovného pokynu Miloše; commity lokálně ano.

## Review Focus

1. **Španělština (+30 % délky) na telefonu 360 dp se zvětšeným písmem 130 %** – popisky navigace a nadpisy nesmí přetéct → test v Task 5.
2. **Systémový jazyk s regionem nebo jen skriptem** (`cs_CZ`, `es_419`, `es_MX`, `sk_SK`, prázdný seznam) – očekává se správná volba cs/es/en → testy v Task 3.
3. **Telefon na šířku** (740×360) – šířka 740 = medium → rail místo spodní lišty, nic nepřeteče → test v Task 4.
4. **Hranice tříd šířky** přesně na 599,9 / 600 / 839,9 / 840 dp → testy v Task 4.
5. **Česká diakritika a španělské znaky** (ě š č ř ž ů ñ ¿ ¡) se vykreslí přibaleným fontem, ne náhradním → ověřit vizuálně na screenshotu v Task 6 (text „Příliš žluťoučký kůň · ¿Español? ñ“ na obrazovce Nastavení).

---

### Task 1: Kostra Flutter projektu, CI a ARCHITECTURE.md

**Files:**
- Create (vygeneruje `flutter create`): `pubspec.yaml`, `lib/main.dart`, `android/**`, `analysis_options.yaml`, `test/widget_test.dart`
- Create: `.github/workflows/ci.yml`, `docs/ARCHITECTURE.md`
- Modify: `android/app/build.gradle.kts` (minSdk 26), `android/app/src/main/AndroidManifest.xml` (label)

**Interfaces:**
- Produces: balíček `deskovky`, `lib/main.dart` s `void main()`; další tasky ho přepíšou na `runApp(const DeskovkyApp())`.

- [ ] **Step 1: Vygenerovat projekt** v `C:\dev\deskovky`:
  `flutter create --org cz.mpridal --project-name deskovky --platforms android --android-language kotlin --empty .`
  Očekávání: „All done!“, existující `docs/`, `CLAUDE.md`, `.gitignore` zůstanou (pokud `flutter create` `.gitignore` přepíše/doplní, sloučit tak, aby zůstaly řádky pro `*.jks`, `*.keystore`, `key.properties`).
- [ ] **Step 2: Nastavit Android** – v `android/app/build.gradle.kts` `minSdk = 26`; v `AndroidManifest.xml` `android:label="Deskovky"`.
- [ ] **Step 3: Napsat `.github/workflows/ci.yml`** – spouští se na `push` a `pull_request`; job na `ubuntu-latest`: checkout → `subosito/flutter-action@v2` s `flutter-version: 3.47.8`, `channel: stable`, `cache: true` → `flutter pub get` → `flutter analyze --fatal-infos` → `flutter test`.
- [ ] **Step 4: Napsat `docs/ARCHITECTURE.md`** – krátké zdůvodnění volby Flutteru vůči kritériím kap. 2 (jeden kód telefon/tablet, 60 fps, `CustomPainter` pro vektorovou grafiku, zvuk, lokální DB, podepsaný APK v Actions; OTA web-bundle Capacitoru nepotřebujeme, protože aktualizace jde přes APK z Releases – kap. 4), mapování struktury kap. 8 na `lib/…`, volba `go_router` a `gen-l10n`. Poznámka: cesty `games/<id>/**` ze zadání znamenají `lib/games/<id>/**`.
- [ ] **Step 5: Ověřit**
  Run: `flutter analyze` → „No issues found!“; `flutter test` → All tests passed; `flutter build apk --debug` → „Built build\app\outputs\flutter-apk\app-debug.apk“.
- [ ] **Step 6: Commit**
  `git add -A && git commit -m "chore: Flutter project skeleton, CI, architecture notes"`

### Task 2: Design tokeny, fonty a téma

**Files:**
- Create: `assets/fonts/Baloo2-Variable.ttf`, `assets/fonts/Nunito-Variable.ttf`, `assets/fonts/OFL-Baloo2.txt`, `assets/fonts/OFL-Nunito.txt`
- Create: `lib/ui_kit/tokens/app_colors.dart`, `lib/ui_kit/tokens/app_typography.dart`, `lib/ui_kit/tokens/app_theme.dart`
- Modify: `pubspec.yaml` (sekce `fonts`)
- Test: `test/ui_kit/tokens_test.dart`

**Interfaces:**
- Produces:
  - `abstract final class AppColors { static const Color walnut, wood, woodLight, felt, feltDark, paper, paper2, ink, gold; static const List<Color> players; }` (`players` = player1..4 v pořadí)
  - `abstract final class AppTypography { static const String headingFamily = 'Baloo2'; static const String bodyFamily = 'Nunito'; static TextStyle h1({Color? color}); static TextStyle h2({Color? color}); static TextStyle body({Color? color}); static TextStyle caption({Color? color}); static TextStyle button({Color? color}); }`
  - `ThemeData buildAppTheme()`

- [ ] **Step 1: Stáhnout fonty** (SIL OFL, oficiální repozitář Google Fonts):
  `https://github.com/google/fonts/raw/main/ofl/baloo2/Baloo2%5Bwght%5D.ttf` → `assets/fonts/Baloo2-Variable.ttf`,
  `https://github.com/google/fonts/raw/main/ofl/nunito/Nunito%5Bwght%5D.ttf` → `assets/fonts/Nunito-Variable.ttf`,
  `…/ofl/baloo2/OFL.txt` a `…/ofl/nunito/OFL.txt` → `OFL-*.txt`. Ověřit, že soubory jsou TTF (`file` / první bajty `00 01 00 00`) a mají desítky–stovky kB.
- [ ] **Step 2: Zaregistrovat fonty** v `pubspec.yaml` jako rodiny `Baloo2` a `Nunito` (každá jeden variabilní soubor).
- [ ] **Step 3: Napsat failing test** `test/ui_kit/tokens_test.dart`:
  - `AppColors.felt == const Color(0xFF2F5D50)`, `AppColors.gold == const Color(0xFFE0A82E)`, `AppColors.players == [Color(0xFFD9534F), Color(0xFF3B7DD8), Color(0xFFE8B931), Color(0xFF4CAF6A)]` (+ zbylé tokeny z Global Constraints).
  - `AppTypography.h1().fontSize == 30`, `.fontFamily == 'Baloo2'`, `.fontWeight == FontWeight.w800`, `.fontVariations` obsahuje `FontVariation.weight(800)`; `h2().fontSize == 22` (w600); `body().fontSize == 16`, family `Nunito`, w400; `caption().fontSize == 13`; `button()` Nunito w800.
  - `buildAppTheme().scaffoldBackgroundColor == AppColors.felt`, `.textTheme.bodyMedium!.fontFamily == 'Nunito'`.
- [ ] **Step 4: Run** `flutter test test/ui_kit/tokens_test.dart` → FAIL (chybějící třídy).
- [ ] **Step 5: Implementovat** `app_colors.dart`, `app_typography.dart`, `app_theme.dart`. Variabilní font: každý `TextStyle` nastaví **současně** `fontWeight` i `fontVariations: [FontVariation.weight(<stejná hodnota>)]`, aby se váha projevila na všech verzích enginu. Téma: Material 3, `ColorScheme.fromSeed(seedColor: AppColors.felt)` s přepsaným `primary: AppColors.gold`, `surface: AppColors.paper`; `NavigationBarTheme`/`NavigationRailTheme` s pozadím `walnut`, vybraná položka `gold`, nevybraná `woodLight`.
- [ ] **Step 6: Run** `flutter test test/ui_kit/tokens_test.dart` → PASS.
- [ ] **Step 7: Commit** `git commit -m "feat(ui_kit): design tokens, bundled Baloo 2 + Nunito, app theme"`

### Task 3: Lokalizace CS/EN/ES a volba výchozího jazyka

**Files:**
- Create: `l10n.yaml`, `lib/l10n/app_en.arb` (šablona), `lib/l10n/app_cs.arb`, `lib/l10n/app_es.arb`
- Create: `lib/core/l10n/locale_resolution.dart`
- Modify: `pubspec.yaml` (`flutter_localizations: sdk`, `intl: any`, `flutter: generate: true`)
- Test: `test/core/l10n/locale_resolution_test.dart`, `test/core/l10n/arb_parity_test.dart`, `test/core/l10n/plural_test.dart`

**Interfaces:**
- Produces:
  - `const List<Locale> supportedAppLocales = [Locale('cs'), Locale('en'), Locale('es')];`
  - `Locale resolveAppLocale(List<Locale>? systemLocales)` – bere první systémový jazyk; `cs` → `Locale('cs')`, `es` → `Locale('es')`, cokoli jiného / prázdné / null → `Locale('en')`.
  - Generovaná třída `AppLocalizations` (`package:deskovky/l10n/app_localizations.dart`) s klíči níže.
- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`.

Klíče (cs / en / es):

| Klíč | cs | en | es |
|---|---|---|---|
| `appTitle` | Deskovky | Deskovky | Deskovky |
| `navGames` | Hry | Games | Juegos |
| `navPlayers` | Hráči | Players | Jugadores |
| `navLeaderboards` | Žebříčky | Leaderboards | Clasificaciones |
| `navSettings` | Nastavení | Settings | Ajustes |
| `comingSoon` | Brzy | Soon | Próximamente |
| `panelPlayersOnDevice` | Hráči na zařízení | Players on this device | Jugadores en este dispositivo |
| `panelLeaderboardWeek` | Žebříček tento týden | This week's leaderboard | Clasificación de esta semana |
| `panelLastReward` | Poslední odměna | Latest reward | Última recompensa |
| `screenEmpty` | Tady zatím nic není. | Nothing here yet. | Aquí todavía no hay nada. |
| `fontSample` | Příliš žluťoučký kůň úpěl ďábelské ódy | The quick brown fox jumps over the lazy dog | ¿Pingüino? ¡Ñandú! Pequeño café |
| `playersCount` (plural `count`) | `{count, plural, one{{count} hráč} few{{count} hráči} other{{count} hráčů}}` | `{count, plural, one{{count} player} other{{count} players}}` | `{count, plural, one{{count} jugador} other{{count} jugadores}}` |

- [ ] **Step 1: Napsat failing testy**
  - `locale_resolution_test.dart`: `[Locale('cs','CZ')]`→cs; `[Locale('cs')]`→cs; `[Locale('es','MX')]`→es; `[Locale('es','419')]`→es; `[Locale('sk','SK')]`→en; `[Locale('de'), Locale('cs')]`→en (rozhoduje první); `[]`→en; `null`→en.
  - `arb_parity_test.dart`: načte tři ARB jako JSON, množina klíčů bez `@`-prefixu je u všech stejná a žádná hodnota není prázdná.
  - `plural_test.dart`: přes `lookupAppLocalizations(Locale('cs'))`: `playersCount(1) == '1 hráč'`, `(3) == '3 hráči'`, `(5) == '5 hráčů'`; en `(1) == '1 player'`, `(2) == '2 players'`; es `(1) == '1 jugador'`, `(4) == '4 jugadores'`.
- [ ] **Step 2: Run** `flutter test test/core/l10n` → FAIL.
- [ ] **Step 3: Implementovat** ARB soubory (tabulka výše, s `@playersCount` placeholderem `count: int`), `l10n.yaml`, `pubspec.yaml`, `locale_resolution.dart`; spustit `flutter gen-l10n`.
- [ ] **Step 4: Run** `flutter test test/core/l10n` → PASS.
- [ ] **Step 5: Commit** `git commit -m "feat(l10n): cs/en/es ARB, system-locale resolution"`

### Task 4: Responzivní třídy a navigační shell

**Files:**
- Create: `lib/ui_kit/layout/window_size.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/app_shell.dart`
- Create: `lib/features/home/home_screen.dart`, `lib/features/players/players_screen.dart`, `lib/features/leaderboards/leaderboards_screen.dart`, `lib/features/settings/settings_screen.dart` (zatím jen `screenEmpty` text; Home doplní Task 5)
- Modify: `lib/main.dart`, `pubspec.yaml` (`go_router`)
- Test: `test/ui_kit/window_size_test.dart`, `test/app/app_shell_test.dart`
- Replace content: `test/widget_test.dart` (vygenerovaný) → smoke test `DeskovkyApp` se spustí

**Interfaces:**
- Consumes: `buildAppTheme()` (Task 2), `AppLocalizations`, `supportedAppLocales`, `resolveAppLocale` (Task 3).
- Produces:
  - `enum WindowSizeClass { compact, medium, expanded; static WindowSizeClass fromWidth(double widthDp); }`
  - `int gameGridColumns(double widthDp)` – compact 2, medium 3, expanded 3 pro šířku < 1200, jinak 4 (šířka = celé okno).
  - `class DeskovkyApp extends StatelessWidget` – `MaterialApp.router`, `localeListResolutionCallback: (locales, _) => resolveAppLocale(locales)`, `onGenerateTitle` z `appTitle`.
  - `GoRouter buildRouter()` – `StatefulShellRoute.indexedStack` se 4 větvemi: `/games` (Home, výchozí), `/players`, `/leaderboards`, `/settings`.
  - `class AppShell extends StatelessWidget { final StatefulNavigationShell shell; }` – compact: `NavigationBar` dole; medium/expanded: `NavigationRail` vlevo (`labelType: all`); expanded navíc pravý panel `Key('rightPanel')` šířky 320 dp s nadpisy `panelPlayersOnDevice`, `panelLeaderboardWeek`, `panelLastReward` (obsah zatím `screenEmpty`). Ikony: `casino` (Hry), `people` (Hráči), `emoji_events` (Žebříčky), `settings` (Nastavení).

- [ ] **Step 1: Napsat failing testy**
  - `window_size_test.dart`: `fromWidth(360)`→compact, `599.9`→compact, `600`→medium, `839.9`→medium, `840`→expanded, `1280`→expanded; `gameGridColumns`: 360→2, 412→2, 740→3, 800→3, 1024→3, 1280→4.
  - `app_shell_test.dart` (pomocná funkce nastaví `tester.view.physicalSize` a `devicePixelRatio = 1`, locale `cs`):
    - 360×740: `find.byType(NavigationBar)` 1×, `NavigationRail` 0×, `Key('rightPanel')` 0×.
    - 740×360 (telefon na šířku): `NavigationRail` 1×, `NavigationBar` 0×, žádná výjimka `RenderFlex overflowed`.
    - 800×1280: `NavigationRail` 1×, pravý panel 0×.
    - 1280×800: `NavigationRail` 1×, pravý panel 1× s textem „Hráči na zařízení“.
    - Tap na „Nastavení“ → URL `/settings` a vybraný index 3; zpět na „Hry“ → `/games`.
    - Každá položka navigace má sémantický popisek (`find.bySemanticsLabel('Hráči')` 1×).
- [ ] **Step 2: Run** `flutter test test/ui_kit/window_size_test.dart test/app` → FAIL.
- [ ] **Step 3: Implementovat** soubory výše; `main.dart` = `runApp(const DeskovkyApp())`. Shell bere šířku z `MediaQuery.sizeOf(context).width`.
- [ ] **Step 4: Run** `flutter test` → PASS (všechny dosavadní testy).
- [ ] **Step 5: Commit** `git commit -m "feat(app): responsive navigation shell with go_router"`

### Task 5: Hlavní stránka – mřížka a odolnost proti přetečení

**Files:**
- Modify: `lib/features/home/home_screen.dart`, `lib/features/settings/settings_screen.dart`
- Test: `test/features/home/home_screen_test.dart`, `test/app/overflow_test.dart`

**Interfaces:**
- Consumes: `gameGridColumns`, `AppColors`, `AppTypography`, `AppLocalizations`.
- Produces: `HomeScreen` – horní pruh s nadpisem `appTitle` (H1, barva `paper`) a `GridView` s 6 zástupnými kartami `Key('gamePlaceholder')`: papírová karta (`paper`, zaoblení 18 dp, spodní „fyzický“ stín 5 dp `paper2` + měkký stín), pastelový čtverec místo ikony, štítek `comingSoon` (pozadí `walnut`, text `paper`, Nunito w800 11 sp). Počet sloupců = `gameGridColumns(šířka okna)`. `SettingsScreen` zobrazí `screenEmpty` a pod ním `fontSample` (H2 i body) – slouží k vizuální kontrole diakritiky.

- [ ] **Step 1: Napsat failing testy**
  - `home_screen_test.dart`: při 360×740 mají první dvě karty stejné `dy` a třetí větší (2 sloupce); při 800×1280 první tři stejné `dy` (3 sloupce); při 1280×800 první čtyři stejné `dy` (4 sloupce); každá karta obsahuje text „Brzy“.
  - `overflow_test.dart`: pro každý jazyk `cs`, `en`, `es` × velikosti 360×740, 412×915, 800×1280, 1280×800 × `textScaler` 1.0 a 1.3 projde všechny 4 záložky a `expect(tester.takeException(), isNull)`.
- [ ] **Step 2: Run** `flutter test test/features test/app/overflow_test.dart` → FAIL.
- [ ] **Step 3: Implementovat** `HomeScreen` a `SettingsScreen` dle Interfaces. Popisky v `NavigationBar` musí ve španělštině při 130 % na 360 dp vyjít (případně `maxLines: 1` + `overflow: TextOverflow.ellipsis` jen jako pojistka, ne jako řešení – „Clasificaciones“ se má vejít).
- [ ] **Step 4: Run** `flutter analyze && flutter test` → No issues / All tests passed.
- [ ] **Step 5: Commit** `git commit -m "feat(home): placeholder game grid, overflow tests in 3 languages"`

### Task 6: Ověření na emulátorech a shrnutí milníku

**Files:**
- Create: `docs/milestones/m1/` – screenshoty `phone-cs.png`, `phone-es.png`, `tablet-portrait.png`, `tablet-landscape.png`
- Modify: `CLAUDE.md` (sekce „Jak spustit“: `flutter run`, `flutter test`, `flutter analyze`)

- [ ] **Step 1: Připravit emulátory** – pokud `flutter emulators` nevypíše telefon a tablet, vytvořit přes `avdmanager` AVD „Pixel 7“ (412×915 dp) a „Pixel Tablet“ (1280×800 dp) se systémovým obrazem API 36 x86_64 (stažení ~1,5 GB – **zeptat se Miloše předem**).
- [ ] **Step 2: Spustit** `flutter run -d <telefon>`, projít 4 záložky, otočit na šířku; pořídit screenshoty (`adb exec-out screencap -p > …`) v cs a es (jazyk emulátoru přepnout v systému).
- [ ] **Step 3: Totéž na tabletu** na výšku i na šířku; zkontrolovat pravý panel na šířku a diakritiku v `fontSample`.
- [ ] **Step 4: Ověřit** `flutter build apk --debug` a velikost APK; `flutter test` zelené.
- [ ] **Step 5: Commit** `git commit -m "docs: milestone 1 screenshots and run instructions"`
- [ ] **Step 6: Shrnutí Milošovi** – co je hotové, screenshoty, co zbývá; **push na GitHub jen na jeho pokyn**.
