# Milník 8 – Podepsané vydání a aktualizace z GitHubu: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Aplikace jde nainstalovat na skutečné telefony z GitHub Releases a sama si najde, stáhne, ověří a nainstaluje novější verzi bez ztráty dat. Vydání vzniká automaticky po pushnutí tagu `v*`. APK do 40 MB.

**Proč teď:** Miloš chce aplikaci nasadit co nejdřív a ladit ji za provozu (pořadí: m8 → Piškvorky → 7b obchod a šatník → další hry).

**Architecture:** `lib/core/update/` – `UpdateService` (čistá logika: semver, `latest.json`, limit 1× za 6 h, timeout 4 s, nikdy neblokuje start) nad rozhraními `ReleaseSource` (GitHub API přes `http`) a `ApkInstaller` (Kotlin MethodChannel: FileProvider + systémová instalace). Stažení na pozadí s ověřením SHA-256 (`crypto`). UI: karta „Nová verze“ na domovské obrazovce, v Nastavení verze, „Zkontrolovat teď“ a přepínač „Automaticky kontrolovat“. `.github/workflows/release.yml`: testy → build → podpis → SHA-256 → `latest.json` → Release.

**Tech Stack:** Flutter, nové balíčky `http` a `crypto` (oba od týmu Dartu), Kotlin v `android/app`, GitHub Actions.

**Spec:** `docs/ZADANI-deskovky.md` – kap. 4 (celá), 10 (testy update služby), 12 (akceptace: tag → podepsaný release → starší verze najde novější, stáhne, ověří SHA-256, nainstaluje, data zůstanou).

## Global Constraints
- Kontrola nikdy neblokuje start ani hraní; bez sítě, při chybě nebo limitu API tiše pokračuje a jen zaloguje.
- `GET https://api.github.com/repos/mpridal/deskovky/releases/latest`, bez tokenu, timeout 4 s, nejvýš 1× za 6 h (čas poslední kontroly v `app_settings`).
- Asset `deskovky-<verze>.apk` a `latest.json` = `{version, versionCode, sha256, minSupportedVersion, notes_cs, notes_en, notes_es}`.
- `versionCode = major*10000 + minor*100 + patch`, odvozený z tagu.
- Všechny verze podepsané **stejným klíčem** z GitHub Secrets; klíč ani hesla nikdy neprojdou kódem ani logem.
- Povinná aktualizace jen když `minSupportedVersion` > aktuální a zařízení je online; offline se hraje dál.
- Aktualizace nesmí smazat data – instalace přes stávající aplikaci (stejný podpis, stejné `applicationId`).
- Texty CS/EN/ES, 360 dp nepřetéká, srozumitelné vysvětlení oprávnění „Instalace neznámých aplikací“.

## Rozhodnutí k potvrzení (navrhuju)
1. **Jen `arm64-v8a`** (všechny telefony a tablety z posledních ~7 let) → APK ~20 MB místo 63 MB. Starší 32bitová zařízení by potřebovala druhý soubor – zatím ne.
2. **Verze:** `v0.1.0` = první rodinná instalace (ukázková hra), `v0.1.1` = zkouška aktualizace. Piškvorky pak `v0.2.0`.
3. **Poznámky k vydání** píšu do `CHANGELOG.md` (sekce podle verze, CS/EN/ES); workflow je z něj vytáhne do `latest.json`.

## Review Focus
1. Pomalá / žádná síť, odpověď 403 (rate-limit), nesmyslný JSON → žádný pád, start nezdržen → testy v Task 1.
2. Stažený soubor s jiným SHA-256 (poškozený / podvržený) → neinstaluje se, smaže se → test v Task 2.
3. Odchod z aplikace během stahování, opakované „Aktualizovat“ → jedno stahování, žádné dvojité instalace → test v Task 2.
4. Tag a verze v `pubspec.yaml` nesouhlasí → workflow selže dřív, než něco zveřejní → Task 4.
5. Povinná aktualizace offline → hraje se dál → test v Task 1.

## Tasks (stručně)
1. **UpdateService** – `Semver.parse/compare`, `ReleaseInfo.fromLatestJson`, `checkForUpdate()` s limitem 6 h, timeoutem a tichými chybami; nastavení `autoCheckUpdates`, `lastUpdateCheck`. Testy s falešným `ReleaseSource`.
2. **Stažení a instalace** – `UpdateDownloader` (stream do `getApplicationCacheDirectory`, SHA-256, jedno stahování naráz), Kotlin `ApkInstaller` (FileProvider, `REQUEST_INSTALL_PACKAGES`, kontrola `canRequestPackageInstalls`). Testy s falešným HTTP klientem a instalátorem.
3. **UI** – karta na domovské obrazovce (Aktualizovat / Později, průběh stahování, povinná varianta), dialog s vysvětlením oprávnění, Nastavení: verze, „Zkontrolovat aktualizace teď“, přepínač. Fit testy 360 dp × 3 jazyky.
4. **Podpis a release.yml** – `android/key.properties` (jen lokálně / v CI ze Secrets, v `.gitignore`), `signingConfigs.release`, `flutter build apk --release --target-platform android-arm64 --build-name/--build-number z tagu`, kontrola tag = pubspec, SHA-256, `latest.json` z `CHANGELOG.md`, `gh release create`. Lokální suchý běh skriptu na generování `latest.json` testem.
5. **Ověření celého cyklu** – (s tvým „ano“ ke každému zveřejnění) tag `v0.1.0` → Release → instalace na emulátor/telefon → vytvořit data → tag `v0.1.1` → aplikace nabídne aktualizaci → stáhne, ověří, nainstaluje → data zůstala. Dokumentace: CLAUDE.md (jak vydat verzi), `docs/INSTALACE.md` (jak nainstalovat na telefon).

## Co potřebuju od tebe (já to udělat nemůžu – klíče a hesla nikdy nezadávám)
1. Vytvořit podpisový klíč (jednou, pak ho **zálohovat** – bez něj nepůjde vydat žádnou aktualizaci) – přesný příkaz dostaneš v Task 4.
2. Vložit do GitHubu → Settings → Secrets → Actions: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.
3. Potvrdit každé zveřejnění vydání (`v0.1.0`, `v0.1.1`).

**Odhad:** ~1 den práce (Tasky 1–4 udělám bez tebe, Task 5 potřebuje klíč a dvě tvá „ano“).
