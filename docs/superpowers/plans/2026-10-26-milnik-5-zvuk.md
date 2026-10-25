# Milník 5 – AudioService, zástupné zvuky, CREDITS a nastavení zvuku: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplikace hraje hudbu (menu a vlastní podkres každé hry, plynulé prolínání 600 ms) a zvukové efekty (min. 6 současně), hudba a efekty mají vlastní hlasitost a vypínač, které se pamatují; při výhře se hudba ztlumí (−8 dB) a zazní jingle; v pozadí se hudba pozastaví. Obrazovka „Autoři a licence“ se generuje z `assets/audio/CREDITS.json`. Dokud Miloš nevybere skutečné skladby, hrají zástupné zvuky.

**Architecture:** `AudioService` (`lib/core/audio/`) je čistá logika nad rozhraním `AudioBackend` (hudební kanál se dvěma přehrávači pro prolínání + pool efektů). V aplikaci backend nad balíčkem `just_audio`, v testech `FakeAudioBackend`, který zaznamenává volání. UI kit nezná `core`: zvuky tlačítek jdou přes `UiFeedback` (InheritedWidget s callbacky `tap`/`back`/`toggle`), který aplikace napojí na `AudioService`.

**Tech Stack:** Flutter 3.47.8, nový balíček `just_audio` (doporučen v kap. 2 zadání), Riverpod, Drift (`app_settings`). Zástupné zvuky generuje skript `tool/generate_placeholder_audio.py` (Python, jen standardní knihovna).

**Spec:** `docs/ZADANI-deskovky.md` – kap. 5.8 (HUD hudba/efekty), 5.10 (nastavení: hlasitosti, vypínače, vibrace, Autoři a licence), 7.1–7.4, 8 (hra registruje hudbu a efekty v manifestu), 12 („ukázková hra má vlastní hudbu odlišnou od menu, přechod je plynulý“).

## Global Constraints

- Platí vše z milníků 1–4.
- Kanál hudby: jedna smyčka; změna skladby = prolínání **600 ms**; stejná skladba se nerestartuje.
- Pool efektů: **min. 6** současně, další efekt nahradí nejstarší.
- Ducking: při jinglu a odznaku hudba na **−8 dB** (×0,398) po dobu jinglu, pak zpět (300 ms).
- Aplikace v pozadí (`AppLifecycleState.paused/hidden`) → hudba pozastavena, po návratu pokračuje.
- Hlasitost hudby a efektů 0–1 (slidery), vypínače hudby a efektů a vibrace – vše v `app_settings`, výchozí: zapnuto, hudba 0,7, efekty 0,9.
- Soubory: hudba `assets/audio/music/<id>.<ext>`, efekty `assets/audio/sfx/<id>.<ext>`; **zástupné soubory jsou WAV** (na počítači není kodér OGG – ruling), názvy podle kap. 7.2/7.3; skutečné OGG dodá Miloš a cesty se změní v jednom místě (`AudioCatalog`).
- `CREDITS.json`: záznam pro každý soubor `{file, title, author, source_url, license, attribution_text}`; zástupné: autor „Deskovky (vygenerováno)“, licence CC0.
- Hudba celkem ≤ 15 MB (kontrolní test nad velikostí složky).
- Žádné stahování cizích zvuků – výběr a stažení skladeb je úkol Miloše (kap. 7.2).

## Review Focus

1. **Rychlé přepínání obrazovek** (menu → hra → výsledky → hra) – nikdy dvě skladby naplno současně, poslední požadovaná vyhraje → test v Task 1.
2. **Vypnutá hudba nebo hlasitost 0** při startu aplikace – nic nehraje, zapnutí začne aktuální skladbou → test v Task 1/4.
3. **Aplikace v pozadí během prolínání nebo jinglu** – po návratu hraje správná skladba ve správné hlasitosti (žádné „zaseknuté“ ztlumení) → test v Task 1.
4. **Chybějící nebo poškozený zvukový soubor** – žádný pád, chyba se jen zaloguje → test v Task 2.
5. **Obrazovka Autoři a licence** ve 3 jazycích na 360 dp – dlouhé texty licencí se zalamují, nepřetékají → test v Task 6.

## Tasks (stručně)

1. **AudioService + FakeAudioBackend** (`lib/core/audio/audio_service.dart`, `audio_backend.dart`, `audio_settings.dart`): `playMusic(String? track)`, `playSfx(String id)`, `duck(Duration)`, `onLifecycle(AppLifecycleState)`, nastavení z `SettingsRepository` (přidat `musicVolume`, `sfxVolume`, `vibrationOn`). Testy s fake backendem a `fake time`: prolínání 600 ms, stejná skladba nerestartuje, rychlé přepínání, pool 6, ducking a návrat, pozadí, vypnutí/zapnutí, hlasitosti.
2. **JustAudioBackend + katalog** (`lib/core/audio/just_audio_backend.dart`, `audio_catalog.dart`): přidat `just_audio`; dva přehrávače pro hudbu s lineárním prolínáním, 6 přehrávačů pro efekty; chyba načtení souboru → log, bez výjimky. Katalog mapuje id → asset (`menu`, `sample`, `tictactoe`, …; efekty z kap. 7.3; `jingle_win`, `jingle_lose`).
3. **Zástupné zvuky a CREDITS** – `tool/generate_placeholder_audio.py` (WAV 22,05 kHz mono 16 bit: hudba = tichý akord 4 s se smyčkou, efekty = krátké tóny různé výšky/délky, jingly = 3 vzestupné/sestupné tóny), `assets/audio/CREDITS.json`, `pubspec.yaml` assets; test: každý soubor z katalogu existuje a má záznam v CREDITS, hudba ≤ 15 MB.
4. **Napojení na aplikaci** – `audioServiceProvider`; shell hraje `menu`, `GameScreen` hraje `module.musicTrack` (sample → `sample`), po odchodu zpět `menu`; výsledky: `jingle_win` (vyhrál člověk) / `jingle_lose` s duckingem; `GameHost.playSfx` → service; `GameHost.haptic` respektuje vibrace; HUD vypínače hudby/efektů už jen přepínají nastavení (service reaguje); `UiFeedback` v `ui_kit` – `PrimaryButton` → `tap`, `RoundIconButton` → `tap` (Zpět → `back`), `SegmentedControl`/`ChoicePills`/`Switch` → `toggle`; ukázková hra: tip → `piece_place`, změna hráče → `turn`.
5. **Nastavení zvuku** – v Nastavení sekce Zvuk: slider Hudba + vypínač, slider Efekty + vypínač, vypínač Vibrace; vše se okamžitě projeví a pamatuje.
6. **Autoři a licence** – obrazovka z `CREDITS.json` (název, autor, licence, text uvedení), fonty (OFL z `assets/fonts/OFL-*.txt`), tlačítko „Licence knihoven“ → `showLicensePage`. Fonty a CREDITS registrovat i do `LicenseRegistry`.
7. **Ověření a dokumentace** – emulátor: logcat bez chyb přehrávače, přepnutí obrazovek, pozadí; CLAUDE.md: jak vyměnit zástupné zvuky za skutečné (soubor + CREDITS + katalog), `docs/milestones/m5/`.
