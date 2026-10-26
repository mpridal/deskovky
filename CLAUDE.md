# Trvalá pravidla (platí pro každý úkol)

1. **Nikdy nic nemažu natvrdo.** Místo trvalého smazání souboru/dat vždy přesouvám do koše (nebo do zálohové/archivní složky, pokud koš není dostupný), aby šlo vše vrátit zpět.

2. **Nic nevratného bez schválení.** U akcí jako odeslání e-mailu, vystavení faktury, platba, mazání nebo publikování vše připravím, zastavím se a počkám na výslovné potvrzení ("ano"/"potvrzuji") — nikdy to neprovedu automaticky, i kdyby to z kontextu vypadalo žádoucí.

3. **Záloha před zásahem do souborů.** Než upravím nebo přepíšu uživatelovy soubory, vytvořím zálohu (kopii), ze které lze změny vrátit zpět.

Tato pravidla mají přednost před běžným výchozím chováním a platí vždy, bez ohledu na konkrétní zadání úkolu.

# Projekt Deskovky

- Rodinná Android aplikace s deskovými hrami ve Flutteru. Kompletní zadání: `docs/ZADANI-deskovky.md`, vizuální návrh: `docs/design/deskovky-navrh-vizualu.html`.
- GitHub: `mpridal/deskovky` (veřejný). Push a vydání verzí (tagy `v*`) jen na výslovný pokyn.
- Flutter SDK: `C:\dev\flutter`.

## Jak spustit a ověřit

Flutter není v PATH starších terminálů – v případě potřeby `export PATH=/c/dev/flutter/bin:$PATH` (bash).

- `flutter analyze --fatal-infos` a `flutter test` – musí projít před každým commitem (totéž běží v CI).
- `flutter run -d <emulátor>` – vývoj s hot reloadem.
- Emulátory: `Deskovky_Phone` (Pixel 7, 412×915 dp) a `Deskovky_Tablet` (Pixel Tablet, 1280×800 dp).
- Screenshoty mimo `flutter run`: instalovat **release** APK (`flutter build apk --release`); ladicí APK spuštěné samostatně nenastartuje engine.
- Jazyk aplikace na emulátoru: `adb shell cmd locale set-app-locales cz.mpridal.deskovky --locales es-ES`.

## Konvence

- Kód Dartu je pod `lib/` (`lib/app`, `lib/core`, `lib/ui_kit`, `lib/features`, `lib/games`) – viz `docs/ARCHITECTURE.md`.
- Žádné texty natvrdo v UI: vše přes `lib/l10n/app_{cs,en,es}.arb` (šablona `app_en.arb`).
- Barvy a písmo jen z `lib/ui_kit/tokens`.
- Sourozenecké widgety v seznamech/mřížkách musí mít **unikátní** klíče.
- `Container` s `alignment` se roztáhne na celou šířku rodiče – v `Wrap`/`Row` ho nepoužívat pro „pilulky“.

## UI kit a avatary

- Komponenty jsou v `lib/ui_kit/components/` (`PaperCard`, `PrimaryButton`, `RoundIconButton`, `SegmentedControl`, `ColorSwatchPicker`, `TagPill`, `ChoicePills`, `PlayerSlot`, `showAppConfirmDialog`, `showAppToast`), plsť v `lib/ui_kit/surfaces/felt_background.dart`. Hry i obrazovky používají jen je – nové komponenty patří sem.
- Avatar člověka: model `AvatarSpec` (`lib/core/avatar`, JSON s `v`, tolerantní `fromJson`) + `AvatarView` / `AnimatedAvatarView`. Robot: `RobotAvatar(color: barva slotu)`. Jinak se avatary nekreslí.
- Debug build má v Nastavení tlačítko „UI kit“ s katalogem všech komponent.

## Golden testy

- Referenční obrázky jsou v `test/**/goldens/`; porovnání toleruje 1 % pixelů (`test/flutter_test_config.dart`, Windows × Linux v CI).
- Po změně kresby: `flutter test --update-goldens <soubor>` a **vygenerovaný PNG vždy prohlédnout** dřív, než se commitne.
- Text v testech měří skutečnými fonty jen tam, kde se volá `setUpAll(loadAppFonts)` (`test/helpers/app_fonts.dart`); jinak se kreslí testovacím písmem.

## Data (Drift) a Riverpod

- Databáze: `lib/core/db/` (tabulky v `tables.dart`, `AppDatabase` v `app_database.dart`). UI k ní nepřistupuje přímo, jen přes repozitáře (`PlayerRepository`, `SettingsRepository`) a providery v `lib/app/providers.dart`.
- Generovaný kód (`*.g.dart`, `test/core/db/generated/`) se **commituje**; po změně tabulek: `dart run build_runner build --delete-conflicting-outputs`.
- **Změna schématu** (nikdy jinak – data hráčů nesmí aktualizace smazat):
  1. zvýšit `schemaVersion` a doplnit krok do `migration.onUpgrade`,
  2. `MSYS_NO_PATHCONV=1 dart run drift_dev make-migrations` – uloží `drift_schemas/app/drift_schema_vN.json` a pomocné soubory do `test/core/db/generated/app/` (včetně vzorového testu bez dat),
  3. do `test/core/db/migration_test.dart` přidat test migrace z každé starší verze na novou **s daty** (vložit řádky přes `vN.DatabaseAtVN`, migrovat, ověřit přes repozitáře),
  4. časová razítka pro řazení ukládat jako `int` ms (`DateTimeColumn` drží jen sekundy).
- Testy widgetů používají `testDatabase()` (`test/helpers/test_database.dart`, proudy se zavírají synchronně); zápisy do DB přímo v těle `testWidgets` jen přes `tester.runAsync`.
- V Git Bash na Windows při `adb shell … /sdcard/…` nastavit `MSYS_NO_PATHCONV=1`, jinak se cesta přepíše.

## Hry a testy her

- Nová hra = `GameModule` + `GameRules` + `AiPlayer` + deska ve `lib/games/<id>/`, registrace v `lib/games/registry.dart` (podrobný návod `docs/GAME_MODULE_GUIDE.md` v milníku 10). Vzor: `lib/games/_sample/`.
- Každá akce hráče je `Move` přes `GameBoardView.submit`; deska nikdy nemění stav sama.
- Testy, které otevřou herní obrazovku: `pumpApp(..., disableAnimations: true)` (pulzování hráče na tahu je nekonečné → `pumpAndSettle` by nikdy neskončil). Roboti v testech běží přes `InlineAiRunner` (nastavuje `pumpApp`).
- Ruční průchod na emulátoru skriptem přes `uiautomator dump`: na herní obrazovce dočasně `adb shell settings put global animator_duration_scale 0` (a transition/window), jinak uiautomator nečeká na klid; po skončení vrátit na 1.

Pravidla paralelní práce (kap. 13.2 zadání) se doplní v milníku 9.

## Zvuk (milník 5)

- `AudioService` (`lib/core/audio/`) – hudba se prolíná 600 ms, efekty v poolu 6 slotů, ducking −8 dB, pauza v pozadí. Platformu obstarává `JustAudioBackend`, testy `FakeAudioBackend` (`test/core/audio/`); `pumpApp(audio: …)` ho předá aplikaci.
- Hudbu vybírá `AudioDirector` (`lib/app/audio_director.dart`) podle trasy: `/play/<id>` a jeho výsledky → `module.musicTrack`, jinde `menu`. Hry samy hudbu nespouštějí, jen efekty přes `GameHost.playSfx(id)`; zvuk `turn` hraje framework při změně hráče.
- Tlačítka ui_kitu cvakají přes `UiFeedback` (tap/back/toggle); zpětné tlačítko dostane `sound: UiSound.back`.
- **Výměna zástupných zvuků za skutečné:** 1) soubor do `assets/audio/music/` nebo `sfx/` (OGG), 2) cesta v `AudioCatalog.standard` (`lib/core/audio/audio_catalog.dart`), 3) záznam v `assets/audio/CREDITS.json` (`file, title, author, source_url, license, attribution_text`; u CC BY přesný text uvedení). Test `audio_assets_test.dart` hlídá, že každý soubor existuje, má záznam a hudba je ≤ 15 MB. Zástupné WAV znovu vygeneruje `python tool/generate_placeholder_audio.py` (přepíše i CREDITS.json – po výměně za skutečné soubory ho už nespouštět).
- `dart format` spouštěj jen na nové soubory, ne na celý strom (přeformátoval by stovky řádků).
