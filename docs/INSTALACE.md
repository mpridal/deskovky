# Instalace a vydávání Deskovek

Deskovky se neinstalují z Google Play, ale z GitHub Releases (zadání kap. 4). Každá verze je podepsaná **stejným klíčem**, jinak by Android aktualizaci odmítl.

## 1. Podpisový klíč (jednou, dělá Miloš)

Klíč ani hesla nikdy nevidí Claude ani nejsou v repozitáři.

1. Vytvořit klíč (zeptá se na heslo a pár údajů o tobě – stačí jméno):

   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore C:\dev\deskovky-upload.jks -keyalg RSA -keysize 4096 -validity 36500 -alias deskovky
   ```

2. **Zálohovat** `C:\dev\deskovky-upload.jks` a heslo (správce hesel + kopie mimo počítač). Bez nich už nepůjde vydat žádnou aktualizaci – rodina by musela aplikaci přeinstalovat a přišla by o data.
3. Vložit do GitHubu (repozitář → Settings → Secrets and variables → Actions → New repository secret), nebo přes `gh`:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\dev\deskovky-upload.jks")) | gh secret set KEYSTORE_BASE64 --repo mpridal/deskovky
   gh secret set KEYSTORE_PASSWORD --repo mpridal/deskovky
   gh secret set KEY_ALIAS --repo mpridal/deskovky --body deskovky
   gh secret set KEY_PASSWORD --repo mpridal/deskovky
   ```

   (`gh secret set` bez `--body` se na hodnotu zeptá – heslo se nikam neuloží.)

## 2. Vydání nové verze

1. V `pubspec.yaml` zvýšit `version: x.y.z+kód`, kde kód = `x*10000 + y*100 + z` (např. `0.1.1+101`). Test to hlídá.
2. Do `CHANGELOG.md` přidat sekci `## x.y.z` s `### cs`, `### en`, `### es` (volitelně `Minimální verze: …` pro povinnou aktualizaci).
3. Sloučit do `main`, pak tag: `git tag vx.y.z` a `git push origin vx.y.z`.
4. GitHub Actions (`release.yml`) spustí testy, sestaví a podepíše APK (jen arm64, ~24 MB), spočítá SHA-256, vytvoří `latest.json` a zveřejní Release.

## 3. Instalace na telefon (poprvé)

1. Na telefonu otevřít <https://github.com/mpridal/deskovky/releases/latest> a stáhnout `deskovky-x.y.z.apk`.
2. Otevřít stažený soubor; Android se zeptá, zda prohlížeč smí instalovat aplikace – povolit, nainstalovat.
3. Další verze už aplikace najde sama: na domovské obrazovce se objeví karta „Je tu nová verze“ → **Aktualizovat**. Poprvé Android požádá o povolení „Instalace neznámých aplikací“ pro Deskovky – aplikace to dětem vysvětlí, povolí dospělý.

Data (hráči, statistiky, body) aktualizace nesmaže.
