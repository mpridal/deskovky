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

- `GameRules.legalMoves(state, seat)` je povinný: když AI spadne nebo vrátí neplatný tah, `TurnController` zahraje legální tah vybraný ze seedu – robot nikdy „nepřemýšlí“ navždy.

- Nová hra = `GameModule` + `GameRules` + `AiPlayer` + deska ve `lib/games/<id>/`, texty v `<id>_texts.dart` (`GameTexts`, cs/en/es). Návod: `docs/GAME_MODULE_GUIDE.md`. Vzor: `lib/games/_sample/`. Všech 5 her fáze 2 je zaregistrovaných jako kostry (`available: false` → „Brzy“).
- Každá akce hráče je `Move` přes `GameBoardView.submit`; deska nikdy nemění stav sama.
- Testy, které otevřou herní obrazovku: `pumpApp(..., disableAnimations: true)` (pulzování hráče na tahu je nekonečné → `pumpAndSettle` by nikdy neskončil). Roboti v testech běží přes `InlineAiRunner` (nastavuje `pumpApp`).
- Ruční průchod na emulátoru skriptem přes `uiautomator dump`: na herní obrazovce dočasně `adb shell settings put global animator_duration_scale 0` (a transition/window), jinak uiautomator nečeká na klid; po skončení vrátit na 1.

### Paralelní vývoj her (kap. 13.2, milník 9)
- 1 hra = 1 větev `game/<id>` = 1 worktree = 1 session. Session mění **jen** `lib/games/<id>/**`, `assets/games/<id>/**`, `test/games/<id>/**` a `assets/audio/music/<id>.ogg`; CI to hlídá (`dart run tool/check_scope.dart <větev>`).
- Framework, `registry.dart`, sdílené ARB, `pubspec.yaml` a CI se v herní větvi nemění; potřeby frameworku → `lib/games/<id>/FRAMEWORK_REQUESTS.md`.
- Každá hra projde `runGameContract(<id>Module)` z `test/games/contract.dart`.
- API v1.0 (`GameModule`, `GameRules`, `GameBoardView`, `GameHost`, `GameResult`, `GameTexts`, game kit) je zmrazené tagem `framework-v1` – tag `v0.9.0-framework` ze zadání se nepoužívá, protože tagy `v*` spouštějí vydání.
- Game kit: `lib/core/game_kit/` (`BoardGrid`, `PieceToken`/`HoppingPiece`, `FlipCard`, `Dice`, `GameSearch`); herní čas je `GameBoardView.elapsed()` a ukládá se s partií.
- `flutter run --dart-define=GAME=<id>` otevře v debug buildu rovnou nastavení dané hry.

## Zvuk (milník 5)

- `AudioService` (`lib/core/audio/`) – hudba se prolíná 600 ms, efekty v poolu 6 slotů, ducking −8 dB, pauza v pozadí. Platformu obstarává `JustAudioBackend`, testy `FakeAudioBackend` (`test/core/audio/`); `pumpApp(audio: …)` ho předá aplikaci.
- Hudbu vybírá `AudioDirector` (`lib/app/audio_director.dart`) podle trasy: `/play/<id>` a jeho výsledky → `module.musicTrack`, jinde `menu`. Hry samy hudbu nespouštějí, jen efekty přes `GameHost.playSfx(id)`; zvuk `turn` hraje framework při změně hráče.
- Tlačítka ui_kitu cvakají přes `UiFeedback` (tap/back/toggle); zpětné tlačítko dostane `sound: UiSound.back`.
- **Výměna zástupných zvuků za skutečné:** 1) soubor do `assets/audio/music/` nebo `sfx/` (OGG nebo MP3 – just_audio hraje obojí; bez ffmpeg necháváme MP3 tak, jak je), 2) cesta v `AudioCatalog.standard` (`lib/core/audio/audio_catalog.dart`), 3) záznam v `assets/audio/CREDITS.json` (`file, title, author, source_url, license, attribution_text`; u CC BY přesný text uvedení). Test `audio_assets_test.dart` hlídá, že každý soubor existuje, má záznam a hudba je ≤ 15 MB. Zástupné WAV znovu vygeneruje `python tool/generate_placeholder_audio.py` (záznamy skutečných nahrávek v CREDITS.json ponechá; vyměněnou stopu z jeho seznamu `MUSIC`/`SFX` smaž).
- Hudba je OGG (`music/<id>.ogg`, převod `C:/dev/tools/ffmpeg/bin/ffmpeg.exe -i x.mp3 -c:a libvorbis -b:a 96k x.ogg`); efekty her jsou v `assets/games/<id>/sfx/` a jejich licence v `assets/games/<id>/CREDITS.json`. Skutečná hudba: menu „Carefree“, Hádej číslo „Quirky Dog“, Piškvorky „Local Forecast – Elevator“, Pexeso „Monkeys Spinning Monkeys“, Miny „Sneaky Snitch“, Člověče „Fluffing a Duck“ (Kevin MacLeod, CC BY 4.0); Dáma zatím zástupná.
- `dart format` spouštěj jen na nové soubory, ne na celý strom (přeformátoval by stovky řádků).

## Statistiky a odznaky (milník 6)

- Každá dohraná partie jde přes `StatsService.recordFinished` (`lib/app/stats_service.dart`) do tabulek `matches` a `match_participants` (roboti s `robot = true`, smazaný hráč = `player_id NULL` a `robot = false`). Žebříčky a statistiky jsou čisté funkce nad všemi partiemi (`lib/core/stats/leaderboard.dart`, `player_stats.dart`) – testuj je bez UI.
- **Výhra** = samostatně 1. místo; sdílené 1. místo = remíza. **Hra pro 1 hráče:** úspěšné dokončení = místo 1, neúspěch = místo 2 (zadání 5.6). Roboti nikdy nejsou v žebříčcích ani nedostávají odznaky.
- **Jak přidat odznak hry:** v manifestu `List<BadgeDef> get badges` s id `<hra>.<nazev>`, podmínka ze stavebnice `BadgeCondition` (`wins`, `winStreak`, `played`, `counter`, `wonAgainst`, `won`, `event`, `allGames`, `all`), odměna +15 až +50 (vyplácí m7). Událost hlásí hra `view.host.reportEvent('<hra>.<udalost>', {'seat': seat, 'count': n})` – se `seat` platí jen pro hráče na tom místě. Texty: klíče do ARB + řádek do `badgeText` (`lib/games/badge_texts.dart`); test `badge_texts_test.dart` hlídá všechny 3 jazyky.
- Widget testy, které dohrají partii, musí dát databázi reálný čas (`tester.runAsync`) – viz `_letRecord` v `test/features/game_play/game_stats_test.dart`.

## Body a úrovně (milník 7a)

- **Ladění bodů:** jen `assets/config/rewards.json` (základ Lehká/Střední/Těžká, bonusy, ochrana proti farmení, rozsah násobiče). Čte se jednou při startu (`main()` → `rewardsConfigProvider`); chybné pole = výchozí hodnota z `RewardsConfig.defaults`. Test hlídá, že soubor a výchozí hodnoty v kódu se shodují – při změně souboru uprav i `defaults`.
- Výpočet je čistá funkce `computeMatchPoints` (`lib/core/points/points_math.dart`); `StatsService.recordFinished` ji volá v transakci se zápisem partie a odznaků a každý řádek zapíše do `points_ledger`. Zůstatek = součet knihy, „celkem získáno“ = součet kladných záznamů (úroveň), žebříček = body z partií v období (dárky ne).
- Hra může upravit základ přes `GameModule.pointsMultiplier` (0,5–2).
- Partie jen lidí = sloupec Střední. Po ochraně proti farmení (11. výhra dne na Lehkou sám s roboty) je celá partie za 1 bod, odměny za odznaky zůstávají.
- Rodičovská zóna: Nastavení → Rodičovská zóna (příklad z násobilky) → dárek bodů.

## Obchod, šatník a vylepšení avatara (milník 7b)

- **Přidání položky:** (1) záznam v `assets/config/shop_items.json` (`id`, `slot` head/face/hand/pet/frame/effect, `rarity`, `price` nebo `unlock: "badge:<id>"`, volitelně `minLevel`, `colorVariants`, `animated`); (2) kresba v `lib/ui_kit/avatar/accessories/<slot>_arts.dart` v prostoru 100×100 (klobouky s `hairLine`, barvy přes `Art.variant`); (3) název `item<Id>` ve všech 3 ARB a větev v `lib/games/item_texts.dart`; (4) `flutter test test/ui_kit/avatar test/core/shop` – testy hlídají, že každá položka má kresbu i text a nic nepřesahuje kruh; vzorník obnov `--update-goldens` a zkontroluj očima.
- Vlastnictví = tabulka `player_items` (schéma v5) ∪ položky odemčené odznakem; nasazené jsou v `AvatarSpec.equipped` (JSON klíč `eq`), neznámé položky se tiše ignorují. Vše přes `ShopRepository` (`buy` v transakci, `equip`, `unequip`, `reset`).
- Mazlíček a efekt se kreslí až od 40 dp, animace jen od 64 dp a bez omezení pohybu.
- Vyzkoušené položky (pro „Teď si můžeš koupit…“ ve výsledcích) jsou v `app_settings` pod `triedItems.<id hráče>`.
- Rodičovská zóna má i „Vynulovat“ (zůstatek 0, koupené položky pryč, úroveň a odznaky zůstanou).

## Vydání a aktualizace (milník 8)

- Vydání = tag `vX.Y.Z` (podrobně `docs/INSTALACE.md`): `pubspec.yaml` `version: X.Y.Z+kód` (kód = X·10000 + Y·100 + Z) a sekce v `CHANGELOG.md` (cs/en/es) – obojí hlídá `test/tool/latest_json_test.dart`. `release.yml` staví jen arm64.
- Podpis: `android/key.properties` vzniká jen v CI ze Secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`); lokální release build se podepíše debug klíčem. Klíče a hesla nikdy nezadávej ani nečti – dělá je Miloš.
- Aplikace: `UpdateService` (kontrola max 1× za 6 h, 4 s timeout, chyby tiše), `UpdateDownloader` (jen do `cache/updates/`, ověří SHA-256), Kotlin kanál `deskovky/update` v `MainActivity` (verze, povolení, instalace přes FileProvider). Widget testy mají kontrolu při startu vypnutou (`pumpApp(checkUpdates: true)` ji zapne).
- Emulátor je x86_64 – APK z vydání (arm64) na něm neběží; pro emulátor stav `flutter build apk --release` bez `--target-platform`.
