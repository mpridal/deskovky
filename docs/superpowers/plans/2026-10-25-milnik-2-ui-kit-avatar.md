# Milník 2 – UI kit, avatar renderer a editor avatara: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sdílená knihovna komponent `ui_kit` podle kap. 6.3, vektorový avatar skládaný z vrstev (lidský i robot) vykreslitelný v 28–160 dp a editor avatara podle mockupu.

**Architecture:** Avatar je neměnný model `AvatarSpec` (malý JSON) + `CustomPainter` kreslící v souřadnicích 100×100 (stejné jako SVG v mockupu), škálovaný na cílovou velikost. Robot má vlastní painter. Komponenty UI kitu jsou samostatné widgety v `lib/ui_kit/components/`. Editor je obrazovka v `lib/features/avatar_editor/`, která vrací upravený `AvatarSpec`; ukládání k profilu přijde v milníku 3.

**Tech Stack:** Flutter 3.47.8, `CustomPainter`, `go_router`, `flutter_test` (widget + golden testy). Žádné nové balíčky.

**Spec:** `docs/ZADANI-deskovky.md` – kap. 5.3 (editor avatara), 5.7.1 (robot), 6.1, 6.3, 6.4, 10. Vizuál: `docs/design/deskovky-navrh-vizualu.html` – funkce `avatar()`, `robot()`, konstanty `SKIN`, `HAIR`, obrazovka „Editor avatara“ (`#phoneAvatar`).

## Global Constraints

- Platí vše z Global Constraints milníku 1 (barvy, písmo, ARB pro všechny texty, unikátní klíče sourozenců, cíle ≥ 48 dp, nic se nepushuje bez pokynu).
- Avatar se kreslí **jen kódem** (žádné bitmapy ani cizí obrázky), musí být čitelný v 28 dp a ostrý v 160 dp.
- Minimální počty variant (kap. 5.3): tvar obličeje 4, pleť 6, účes 10, barva vlasů 8, oči 6, ústa 6, pozadí 8.
- Pleť (mockup `SKIN`): `#F6D7C3 #EEC1A0 #D9A07A #B97A55 #8D5A3B #5C3A26`.
- Vlasy (mockup `HAIR`, pořadí jako v zadání černá, hnědá, kaštanová, blond, platinová, zrzavá, šedá, modrá): `#2B1E16 #5A3825 #A0522D #D8A657 #E8D9B5 #B03A2E #7A7A7A #3B7DD8`.
- Animace 150–300 ms, ease-out; změna avatara v editoru „bounce“ 200 ms; při `MediaQuery.disableAnimationsOf(context) == true` bez animace.
- Robot: hlavní barva = barva slotu, odznak „AI“ v rohu, když je avatar < 64 dp (kap. 5.7.1).
- Ve fázi 1 se nepřidávají balíčky, ledaže by bez nich krok nešel splnit.

## Review Focus

1. **Avatar v 28 dp** (nejmenší velikost v HUD a žebříčcích) – obličej, oči a účes musí být rozeznatelné, robot musí mít čitelný odznak „AI“ → golden test v Task 2 a 3 obsahuje řádek 28 dp.
2. **Poškozený nebo starší JSON avatara** (chybějící klíč, neznámý účes, index barvy mimo rozsah, `null`) – aplikace nesmí spadnout, použije výchozí hodnotu → testy v Task 1.
3. **Editor na telefonu 360 dp ve španělštině s písmem 130 %** – záložky vrstev a tlačítka se nesmí lámat ani přetékat → text-fit test v Task 5.
4. **Rychlé opakované ťukání** na varianty a „Náhodně“ během bounce animace – žádná výjimka, náhled ukazuje poslední volbu → test v Task 5.
5. **Ovládání čtečkou obrazovky** – každá varianta a barevný vzorník má popisek (název účesu / barvy), vybraný stav je ohlášen → test v Task 5.

---

### Task 1: Model `AvatarSpec`

**Files:**
- Create: `lib/core/avatar/avatar_spec.dart`
- Test: `test/core/avatar/avatar_spec_test.dart`

**Interfaces:**
- Produces:
  - `enum FaceShape { oval, round, wide, square }`
  - `enum HairStyle { short, long, curly, bun, spiky, pigtails, bob, braids, cap, bald }`
  - `enum EyeStyle { round, happy, wink, sleepy, wide, lashes }`
  - `enum MouthStyle { smile, open, flat, grin, tongue, surprised }`
  - `abstract final class AvatarPalette { static const List<Color> skin; static const List<Color> hair; static const List<Color> background; }` – `background` = `AppColors.players` (4) + `AppColors.gold`, `#8E5BC8`, `#E88FB4`, `AppColors.woodLight` (celkem 8).
  - `@immutable class AvatarSpec { final FaceShape face; final int skin; final HairStyle hair; final int hairColor; final EyeStyle eyes; final MouthStyle mouth; final int background; const AvatarSpec({...}); static const AvatarSpec defaults; AvatarSpec copyWith({...}); Map<String, Object?> toJson(); factory AvatarSpec.fromJson(Map<String, Object?>? json); factory AvatarSpec.random(Random random); }` + `==`/`hashCode`.
  - JSON: `{"v": 1, "face": "oval", "skin": 1, "hair": "long", "hairColor": 3, "eyes": "happy", "mouth": "smile", "bg": 0}` (enumy jako `name`).
  - `defaults` = oval, skin 1, short, hairColor 0, round, smile, bg 4 (gold).

- [ ] **Step 1: Napsat failing testy**
  - Počty: `FaceShape.values.length == 4`, `AvatarPalette.skin.length == 6`, `HairStyle.values.length == 10`, `AvatarPalette.hair.length == 8`, `EyeStyle`/`MouthStyle` po 6, `AvatarPalette.background.length == 8`; `AvatarPalette.skin[0] == Color(0xFFF6D7C3)`, `hair[7] == Color(0xFF3B7DD8)`.
  - Round-trip: pro 50 avatarů z `AvatarSpec.random(Random(i))` platí `AvatarSpec.fromJson(spec.toJson()) == spec`; `toJson()['v'] == 1`.
  - Tolerance: `fromJson(null) == defaults`; `fromJson({})` == defaults; `fromJson({'hair': 'mohawk'}).hair == defaults.hair`; `fromJson({'skin': 99}).skin == defaults.skin`; `fromJson({'skin': -1})` → default; `fromJson({'skin': '2'})` → default (špatný typ); `fromJson({'eyes': 'wink', 'extra': true}).eyes == EyeStyle.wink` (neznámé klíče se ignorují – příprava na vylepšení v milníku 7).
  - `random` je deterministický: `AvatarSpec.random(Random(7)) == AvatarSpec.random(Random(7))`; 200 náhodných avatarů pokryje všech 10 účesů.
  - `copyWith(hair: HairStyle.bob)` mění jen účes.
- [ ] **Step 2: Run** `flutter test test/core/avatar` → FAIL (chybí soubor).
- [ ] **Step 3: Implementovat** `avatar_spec.dart` dle Interfaces (`fromJson` validuje každé pole zvlášť a při chybě bere hodnotu z `defaults`).
- [ ] **Step 4: Run** `flutter test test/core/avatar` → PASS.
- [ ] **Step 5: Commit** `feat(avatar): AvatarSpec model with tolerant JSON`

### Task 2: Kreslení lidského avatara

**Files:**
- Create: `lib/ui_kit/avatar/avatar_painter.dart`, `lib/ui_kit/avatar/avatar_view.dart`
- Create: `test/flutter_test_config.dart` (tolerantní porovnávání goldenů), `test/ui_kit/avatar/avatar_view_test.dart`, `test/ui_kit/avatar/goldens/avatar_sheet.png` (vygeneruje `--update-goldens`)

**Interfaces:**
- Consumes: `AvatarSpec`, `AvatarPalette` (Task 1).
- Produces:
  - `class AvatarPainter extends CustomPainter { AvatarPainter(AvatarSpec spec); }` – kreslí ve viewBoxu 100×100 (`canvas.scale(size.width / 100)`), pořadí vrstev jako mockup `avatar()`: kruh pozadí (r 50, oříznutí na kruh) → zadní vlasy (long, pigtails, braids, bob) → ramena (`paper`, cesta `M22 100 Q24 78 50 78 Q76 78 78 100Z`) → krk → obličej (oval rx24/ry28, round 27/27, wide 28/25, square = RRect 52×54 r14 se středem 50,50) → tvářičky → oči → ústa → přední vlasy / kšiltovka. Geometrii účesů short, long, curly, bun, spiky, oči round/happy a ústa smile/open/flat převzít z mockupu; zbylé varianty dokreslit ve stejném stylu (silné tahy ≥ 3 jednotky, aby přežily 28 dp). `shouldRepaint` = `spec != old.spec`.
  - `class AvatarView extends StatelessWidget { const AvatarView({super.key, required AvatarSpec spec, required double size, Color? ringColor, String? semanticLabel}); }` – `size` 28–160 (assert), `ringColor` = rámeček v barvě hráče (tloušťka `size * 0.06`, min 2 dp), obal `Semantics(image: true, label: semanticLabel)`.
  - `class AnimatedAvatarView extends StatefulWidget` – stejné parametry jako `AvatarView`; při změně `spec` přehraje bounce: scale 1.0 → 1.08 → 1.0 za 200 ms (`Curves.easeOut`), při `disableAnimations` bez animace.
- `test/flutter_test_config.dart`: nastaví `goldenFileComparator` na podtřídu `LocalFileComparator`, která projde při rozdílu ≤ 1,0 % pixelů (`result.diffPercent <= 0.01`) – kvůli rozdílům antialiasingu Windows × Linux v CI.

- [ ] **Step 1: Napsat failing testy** `avatar_view_test.dart`:
  - `AvatarView` se vykreslí ve velikostech 28, 64, 160 pro všech 10 účesů × 4 obličeje bez výjimky a jeho `tester.getSize` == `Size(size, size)`.
  - S `ringColor: AppColors.players[1]` existuje dekorace s `Border` té barvy.
  - `semanticLabel: 'Tereza'` → `find.bySemanticsLabel('Tereza')` 1×.
  - `AnimatedAvatarView`: po změně `spec` je v čase 100 ms `Transform` se scale > 1.0, po 250 ms scale == 1.0; s `MediaQueryData(disableAnimations: true)` je scale po změně hned 1.0.
  - Golden `avatar_sheet.png`: mřížka – řádek pro každý účes (10) × sloupce 4 tvary obličeje v 64 dp + řádek „28 dp“ s 8 různými avatary + řádek všech očí a úst v 64 dp; porovnání `matchesGoldenFile('goldens/avatar_sheet.png')`.
- [ ] **Step 2: Run** `flutter test test/ui_kit/avatar` → FAIL.
- [ ] **Step 3: Implementovat** painter a widgety; vygenerovat golden `flutter test --update-goldens test/ui_kit/avatar`; **prohlédnout PNG** (Read) a opravit kresbu, dokud všechny varianty nevypadají dobře a v 28 dp jsou čitelné.
- [ ] **Step 4: Run** `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(ui_kit): layered vector avatar painter and AvatarView`

### Task 3: Avatar robota

**Files:**
- Create: `lib/ui_kit/avatar/robot_avatar.dart`
- Test: `test/ui_kit/avatar/robot_avatar_test.dart`, golden `test/ui_kit/avatar/goldens/robot_sheet.png`

**Interfaces:**
- Produces: `class RobotAvatar extends StatelessWidget { const RobotAvatar({super.key, required Color color, required double size, String? semanticLabel}); }` + privátní `_RobotPainter` podle mockupu `robot()`: kruh v `color`, anténa s kuličkou v `color`, šedá hranatá hlava `#C9D1D8` s obrysem `#5B6670`, tmavý displej s LED očima v `color`, mřížka úst. Při `size < 64` odznak jako widget v `Stack` nad painterem: tmavý kruh `ink` (průměr `size * 0.38`) s bílým okrajem a `Text('AI')` (Nunito w800, `FittedBox`) vpravo dole. Text „AI“ je stejný ve všech jazycích, proto není v ARB.

- [ ] **Step 1: Napsat failing testy**: `RobotAvatar(color: …, size: 40)` → `find.text('AI')` 1×; `size: 64` a `160` → `find.text('AI')` 0×; velikost widgetu == size; golden `robot_sheet.png` se 4 barvami hráčů × velikosti 28, 40, 64, 160.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implementovat**, vygenerovat golden a prohlédnout ho.
- [ ] **Step 4: Run** `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(ui_kit): robot avatar in slot color with AI badge`

### Task 4: Komponenty UI kitu a plstěné pozadí

**Files:**
- Create v `lib/ui_kit/components/`: `paper_card.dart`, `primary_button.dart`, `round_icon_button.dart`, `segmented_control.dart`, `color_swatch_picker.dart`, `tag_pill.dart`, `player_slot.dart`, `app_dialog.dart`, `app_toast.dart`
- Create: `lib/ui_kit/surfaces/felt_background.dart`
- Modify: `lib/app/app_shell.dart` (obsah záložek na `FeltBackground`)
- Test: `test/ui_kit/components/*_test.dart` (jeden soubor na komponentu), `test/ui_kit/surfaces/felt_background_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppTypography`, `AvatarView`, `RobotAvatar`.
- Produces:
  - `PaperCard({Widget child, EdgeInsets padding = EdgeInsets.all(12), VoidCallback? onTap})` – `paper`, radius 18, spodní stín `paper2` offset 5 + měkký stín (jako karta v milníku 1; `HomeScreen._PlaceholderCard` ji začne používat).
  - `PrimaryButton({required String label, required VoidCallback? onPressed, IconData? icon})` – `gold`, pill, výška ≥ 52, spodní stín 5 dp `#9B6A12`; při stisku (`onTapDown`) se obsah posune o 3 dp dolů a stín zmenší na 2 dp, `onTapUp/Cancel` vrátí; `onPressed == null` → zašedlé (opacity 0.5), nereaguje. Zvuk `tap` doplní milník 5 (zatím žádný hook).
  - `RoundIconButton({required IconData icon, required String tooltip, required VoidCallback? onPressed, double size = 48})` – kruh `paper`, ikona `ink`, `Semantics(button: true, label: tooltip)`, hit area ≥ 48.
  - `SegmentedControl<T>({required List<(T value, String label)> segments, required T selected, required ValueChanged<T> onChanged})` – podklad `Color(0x40000000)`, pill; vybraný segment `paper` s textem `ink`; každý segment ≥ 48 dp vysoký.
  - `ColorSwatchPicker({required List<Color> colors, required int selected, required ValueChanged<int> onSelected, required List<String> semanticLabels})` – kruhy 38 dp s okrajem `paper` 3 dp, vybraný má zlatý obrys s odsazením 2 dp; tap target 48 dp; `Semantics(selected: i == selected, label: semanticLabels[i])`.
  - `TagPill({required String label, Color background = AppColors.walnut, Color foreground = AppColors.paper})` – štítek (např. „Brzy“, „Člověk“, „🤖 Robot“), škáluje se dolů místo ořezu (`FittedBox`).
  - `PlayerSlot({required int seat, required Widget avatar, required String name, required String tag, Widget? trailing})` – papírový řádek s levým pruhem 8 dp v `AppColors.players[seat]`, avatar 40 dp, jméno (Nunito w800), `TagPill`.
  - `Future<bool> showAppConfirmDialog(BuildContext context, {required String title, required String message, required String confirmLabel, required String cancelLabel})` – dialog na `paper`, radius 18, potvrzení `PrimaryButton`, zrušení textové tlačítko; vrací `true` jen při potvrzení.
  - `void showAppToast(BuildContext context, String message)` – plovoucí `SnackBar` s pozadím `walnut`, text `paper`, radius 999, 2,5 s.
  - `FeltBackground({required Widget child})` – `CustomPaint` s plstí: podklad `felt`, radiální přechod (bílá 8 % ve středu nahoře → průhledná) a jemný šum: 600 bodů r 0,6–1,2 v `feltDark` s 25% krytím rozmístěných `Random(42)` přes plochu (deterministicky, žádná bitmapa); `isComplex: true`, `willChange: false`.

- [ ] **Step 1: Napsat failing testy** (každá komponenta vlastní soubor):
  - `PrimaryButton`: tap volá `onPressed`; během držení je `Transform.translate` offset `Offset(0, 3)`, po puštění `Offset.zero`; s `onPressed: null` tap nic nevolá; výška ≥ 52.
  - `RoundIconButton`: `tester.getSize` ≥ 48×48; `find.bySemanticsLabel('Zvuk')` 1×; tap volá callback.
  - `SegmentedControl<int>`: tap na segment „3“ volá `onChanged(3)`; vybraný segment má pozadí `paper`; výška ≥ 48.
  - `ColorSwatchPicker`: tap na 3. vzorník → `onSelected(2)`; sémantika `selected` jen u vybraného; každý cíl ≥ 48×48.
  - `TagPill` v úzkém rodiči (40 dp) nevyhodí výjimku a text je v rámci rodiče.
  - `PlayerSlot(seat: 2, …)` má levý pruh barvy `AppColors.players[2]`.
  - `showAppConfirmDialog`: potvrzení → `true`, zrušení → `false`, zavření tapem mimo → `false`.
  - `showAppToast`: text se objeví, po 3 s zmizí.
  - `FeltBackground`: vykreslí se bez výjimky v 360×740 a 1280×800; `child` je vidět; painter `shouldRepaint` vrací `false`.
- [ ] **Step 2: Run** `flutter test test/ui_kit/components test/ui_kit/surfaces` → FAIL.
- [ ] **Step 3: Implementovat** komponenty; `HomeScreen._PlaceholderCard` přepsat na `PaperCard` + `TagPill` (chování z milníku 1 zůstává, testy home a text-fit musí dál procházet); `AppShell` obalí obsah záložek `FeltBackground`.
- [ ] **Step 4: Run** `flutter analyze --fatal-infos && flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(ui_kit): core components and felt background`

### Task 5: Editor avatara

**Files:**
- Create: `lib/features/avatar_editor/avatar_editor_screen.dart`
- Modify: `lib/app/router.dart` (route `/players/avatar` pod větví Hráči), `lib/features/players/players_screen.dart`, `lib/l10n/app_{cs,en,es}.arb`
- Test: `test/features/avatar_editor/avatar_editor_screen_test.dart`, doplnit `test/app/text_fit_test.dart`

**Interfaces:**
- Consumes: `AvatarSpec`, `AnimatedAvatarView`, `AvatarView`, `PrimaryButton`, `RoundIconButton`, `ColorSwatchPicker`, `PaperCard`.
- Produces:
  - `class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key, AvatarSpec initial = AvatarSpec.defaults, Random? random}); }` – `random` jen pro testy (výchozí `Random()`); tlačítko Uložit → `context.pop(spec)`; Zpět → `context.pop()` (null).
  - Rozložení podle mockupu: horní pruh (`RoundIconButton` zpět, nadpis `avatarEditorTitle`, `RoundIconButton` 🎲 s popiskem `avatarRandom`), náhled `AnimatedAvatarView` 150 dp s `paper` lemem 6 dp, vodorovně posuvné záložky (pill, vybraná `paper`) **Obličej · Pleť · Vlasy · Oči · Ústa · Pozadí**, pod nimi `PaperCard` s mřížkou 4 sloupců variant (každá varianta = celý avatar 58 dp s průhledným pozadím; vybraná má zlatý obrys 4 dp) nebo `ColorSwatchPicker` (Pleť, Pozadí); na záložce Vlasy pod mřížkou nadpis `avatarHairColor` a `ColorSwatchPicker` barev vlasů; dole `PrimaryButton(label: avatarSave)`.
  - Tablet (≥ 600 dp šířky): náhled vlevo, záložky a volby vpravo (dva sloupce).
  - Route: `GoRoute(path: 'avatar', builder: …AvatarEditorScreen())` jako podcesta `/players`; `PlayersScreen` dostane `AvatarView` (150 dp) aktuálního „zkušebního“ avatara a `PrimaryButton(avatarEdit)`, který otevře editor přes `context.push<AvatarSpec>('/players/avatar')` a výsledek uloží do stavu obrazovky (jen v paměti – perzistence je milník 3).
  - Nové ARB klíče (cs / en / es): `avatarEditorTitle` Můj avatar / My avatar / Mi avatar; `avatarEdit` Upravit avatar / Edit avatar / Editar avatar; `avatarSave` Uložit / Save / Guardar; `avatarRandom` Náhodně / Random / Al azar; `avatarTabFace` Obličej / Face / Cara; `avatarTabSkin` Pleť / Skin / Piel; `avatarTabHair` Vlasy / Hair / Pelo; `avatarTabEyes` Oči / Eyes / Ojos; `avatarTabMouth` Ústa / Mouth / Boca; `avatarTabBackground` Pozadí / Background / Fondo; `avatarHairColor` Barva vlasů / Hair colour / Color de pelo; názvy variant pro čtečku: `faceOval…faceSquare`, `hairShort…hairBald` (cs dle zadání: krátké, dlouhé, kudrny, drdol, ježek, culíky, mikádo, copánky, kšiltovka, bez vlasů), `eyesRound…eyesLashes`, `mouthSmile…mouthSurprised`, `hairColorBlack…hairColorBlue` (černá, hnědá, kaštanová, blond, platinová, zrzavá, šedá, modrá), `skinTone` s parametrem `{n}` („Pleť {n}“ / „Skin tone {n}“ / „Tono {n}“), `backgroundColor` s `{n}` („Pozadí {n}“ / „Background {n}“ / „Fondo {n}“).

- [ ] **Step 1: Napsat failing testy** `avatar_editor_screen_test.dart`:
  - Záložka Vlasy → tap na variantu se sémantikou „mikádo“ → náhled (`AnimatedAvatarView`) má `spec.hair == HairStyle.bob`.
  - Na záložce Vlasy tap na vzorník „zrzavá“ → `spec.hairColor == 5`.
  - Záložka Pleť → vzorník „Pleť 4“ → `spec.skin == 3`; Pozadí → „Pozadí 6“ → `spec.background == 5`.
  - 🎲 s `Random(1)` nastaví `spec == AvatarSpec.random(Random(1))` (stejná sekvence – editor volá `AvatarSpec.random` s injektovaným `Random`).
  - Rychlé ťukání: 5 různých variant během 100 ms → bez výjimky, náhled = poslední volba.
  - Uložit vrátí upravený spec (test přes `GoRouter` s nadřazenou route, která `await`uje `push`), Zpět vrátí `null`.
  - Sémantika: každá varianta na aktuální záložce má label a vybraná je `selected`.
  - Všechny cíle (varianty, vzorníky, záložky, tlačítka) ≥ 48×48 dp na 360×740.
  - Tablet 1280×800: náhled a volby jsou vedle sebe (`getCenter(preview).dx < getCenter(options).dx` a stejná výška horní hrany ± 50).
  - `text_fit_test.dart`: přidat průchod editorem – na `/players/avatar` se ve všech jazycích, velikostech a měřítkách (matice z milníku 1) žádný popisek záložky ani tlačítka nezalomí (`_fitsOnOneLine`).
  - `arb_parity_test` (existující) musí dál procházet s novými klíči.
- [ ] **Step 2: Run** `flutter test test/features/avatar_editor test/app/text_fit_test.dart` → FAIL.
- [ ] **Step 3: Implementovat** obrazovku, route, ARB klíče, úpravu `PlayersScreen`.
- [ ] **Step 4: Run** `flutter analyze --fatal-infos && flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(avatar_editor): layered avatar editor with random and save`

### Task 6: Katalog komponent, ověření na emulátorech a shrnutí

**Files:**
- Create: `lib/features/settings/ui_kit_catalog_screen.dart` (jen v debug buildu)
- Modify: `lib/features/settings/settings_screen.dart` (v `kDebugMode` odkaz „UI kit“), `lib/app/router.dart` (`/settings/ui-kit`), `CLAUDE.md`
- Create: `docs/milestones/m2/*.png`

- [ ] **Step 1: Katalog** – obrazovka se všemi komponentami z Task 4, avatary ve velikostech 28/40/64/160 a robotem ve 4 barvách. Widget test: obrazovka se vykreslí bez výjimky na 360×740 a 1280×800. Texty katalogu nejsou lokalizované (vývojový nástroj, jen debug) – výjimka z pravidla „žádné natvrdo psané texty“, poznamenat komentářem.
- [ ] **Step 2: Emulátory** – release APK (debug nestartuje mimo `flutter run`, viz CLAUDE.md); na `Deskovky_Phone` a `Deskovky_Tablet` pořídit screenshoty: Hráči, editor na záložce Vlasy (cs), editor na záložce Pleť (es), editor na tabletu na šířku. Katalog komponent v release buildu není; místo jeho screenshotu se do `docs/milestones/m2/` zkopírují golden obrázky z Task 2–3.
- [ ] **Step 3: Ověřit** `flutter analyze --fatal-infos`, `flutter test`, velikost release APK (nesmí vzrůst o víc než 1 MB proti milníku 1 – žádné nové assety).
- [ ] **Step 4: CLAUDE.md** – doplnit: komponenty UI kitu a kde jsou, `AvatarSpec` + `AvatarView`/`RobotAvatar` jako jediný způsob kreslení avatarů, golden testy a `flutter test --update-goldens` + povinnost prohlédnout vygenerovaný PNG.
- [ ] **Step 5: Commit** `docs: milestone 2 screenshots, UI kit catalog`
- [ ] **Step 6: Shrnutí Milošovi** – push a PR jen na jeho pokyn.
