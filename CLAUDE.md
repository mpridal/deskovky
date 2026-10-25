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

Pravidla paralelní práce (kap. 13.2 zadání) se doplní v milníku 9.
