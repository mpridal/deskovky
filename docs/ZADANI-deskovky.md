# Deskovky – zadání pro Claude Code

> Tento dokument je zadání pro Claude Code pro rodinnou herní aplikaci pro Android (telefony i tablety). Má dvě fáze:
>
> - **Fáze 1 – framework** (kap. 1–12): vše společné. Dělá se postupně v jedné session a končí **zmrazením herního API**.
> - **Fáze 2 – hry** (kap. 13): Piškvorky, Pexeso, Miny, Člověče nezlob se, Dáma. Každá hra je samostatný modul, takže **všech 5 her se vyvíjí paralelně** (5 session / 5 větví) bez vzájemných konfliktů.
>
> - **Fáze 3 – hra na více zařízeních přes domácí Wi-Fi** (kap. 14): každý hráč může táhnout na svém telefonu/tabletu. Fáze 1 a 2 na to musí být připravené (tahy jako přenositelné zprávy, kap. 8), samotná síťová hra se dělá až po dokončení her.
>
> Fázi 2 nezačínej, dokud nejsou splněna akceptační kritéria fáze 1 (kap. 12).
>
> Ulož tento soubor do repozitáře jako `docs/ZADANI-deskovky.md` a mockup jako `docs/design/deskovky-navrh-vizualu.html` – odkazují na ně prompty pro paralelní session.
>
> Vizuální reference: `docs/design/deskovky-navrh-vizualu.html` (otevři v prohlížeči). Barvy, rozložení a komponenty z mockupu ber jako závazný směr, rozměry jsou v dp.

---

## 1. Cíl a principy

- Rodinná aplikace s kolekcí klasických deskových/logických her: **Piškvorky, Pexeso, Miny (Minesweeper), Člověče, nezlob se, Dáma**.
- Hráči: děti od ~6 let i dospělí, 1–4 hráči, chybějící soupeře doplní počítač. Hraje se na jednom zařízení, které si hráči předávají (hot-seat), a ve fázi 3 také na více zařízeních přes domácí Wi-Fi.
- **Plně offline.** Síť se používá jen pro kontrolu aktualizace při startu. Žádné reklamy, žádné účty, žádná analytika, žádné odesílání dat.
- **Jeden jednotný vizuál** pro framework i všechny hry (styl „herní stůl“ – viz kap. 6).
- Jazyky: **čeština (výchozí), angličtina, španělština**, přepínatelné v Nastavení. Při prvním spuštění se předvolí podle jazyka systému (cs → čeština, es → španělština, jinak angličtina). Všechny texty přes lokalizační soubory (ARB/JSON, klíče v angličtině), žádné natvrdo psané řetězce; počítat s delšími španělskými texty (+30 %) a správným skloňováním/množným číslem (ICU plural – čeština má tvary 1 / 2–4 / 5+).
- Kód uložený v GitHubu, verze vydávané přes **GitHub Releases**.

## 2. Technologie

Volbu stacku nechávám na tobě, ale dodrž tato kritéria a rozhodnutí krátce zdůvodni v `docs/ARCHITECTURE.md`:

- Jeden kód pro telefon i tablet, plynulé 60 fps animace, dobrá podpora zvuku (smyčky hudby + krátké efekty současně).
- Snadné vykreslování vektorové grafiky (avatary a herní prvky se kreslí kódem/SVG).
- Lokální perzistence (profily, statistiky, nastavení).
- Build podepsaného APK v GitHub Actions.

**Doporučení:** Flutter (Dart) – `flutter_localizations`, lokální DB (např. Drift/SQLite nebo Hive), `just_audio`/`audioplayers` pro zvuk, `CustomPainter`/`flutter_svg` pro grafiku. Alternativa: Capacitor + TypeScript (výhoda: OTA aktualizace web-bundle bez reinstalace APK). Pokud zvolíš jinou technologii, popiš, jak splní kapitolu 4.

Minimální Android: 8.0 (API 26). Cílové API: aktuální požadované.

## 3. Podporovaná zařízení a responzivita

| Třída | Šířka (dp) | Rozložení hlavní stránky |
|---|---|---|
| Telefon (compact) | < 600 | Spodní navigace, mřížka her 2 sloupce |
| Malý tablet / telefon na šířku (medium) | 600–839 | Navigační lišta vlevo (rail), mřížka 3 sloupce |
| Tablet (expanded) | ≥ 840 | Rail vlevo, mřížka 3–4 sloupce, pravý panel (hráči + žebříček) |

- Telefon: framework primárně na výšku; tablet: na výšku i na šířku.
- Každá hra může deklarovat preferovanou orientaci (např. Dáma na telefonu na výšku).
- Hrací plocha se vždy škáluje tak, aby se vešla celá bez scrollování (letterbox na plsti).
- Dotykové cíle min. 48 dp, v herních plochách pro děti 56 dp.
- Testuj minimálně na: 360×740 (telefon), 412×915 (velký telefon), 800×1280 a 1280×800 (tablet).

## 4. Kontrola a stažení aktualizace z GitHubu

Aplikace se **nedistribuuje přes Google Play** (Play zakazuje self-update). Instaluje se APK z GitHub Releases.

### Postup při každém spuštění
1. Aplikace se spustí okamžitě – kontrola **nikdy neblokuje** start ani hraní.
2. Na pozadí (timeout 4 s) zavolá `GET https://api.github.com/repos/{OWNER}/{REPO}/releases/latest` (bez tokenu → repozitář s releasy musí být veřejný; `OWNER/REPO` v konfiguraci).
3. Porovná `tag_name` (semver, např. `v1.3.0`) s verzí aplikace.
4. Je-li novější: v release najde asset `deskovky-<verze>.apk` a `latest.json` (obsahuje `version`, `versionCode`, `sha256`, `minSupportedVersion`, `notes_cs`, `notes_en`, `notes_es`).
5. Zobrazí nenásilnou kartu „K dispozici je nová verze X – co je nového…“ s tlačítky **Aktualizovat** / **Později**. Na Wi-Fi může APK stáhnout předem na pozadí.
6. Po stažení ověří SHA-256, pak spustí systémovou instalaci (FileProvider + `REQUEST_INSTALL_PACKAGES`). Při prvním použití vysvětli dětsky srozumitelně, proč Android žádá o povolení „Instalace neznámých aplikací“.
7. Pokud `minSupportedVersion` > aktuální verze, aktualizace je povinná (jen když je zařízení online; offline se dál hraje).
8. Bez sítě / chyba / rate-limit API → tiše pokračuj, zaloguj lokálně. Max. 1 kontrola za 6 hodin (uložit čas poslední kontroly).

### Požadavky
- Všechny verze podepsané **stejným klíčem** (keystore v GitHub Secrets) – jinak Android aktualizaci odmítne.
- Aktualizace nesmí smazat lokální data (profily, statistiky).
- V Nastavení: „Zkontrolovat aktualizace teď“, zobrazená verze aplikace, přepínač „Automaticky kontrolovat“.
- Datové migrace DB verzované a testované.

### GitHub Actions (`.github/workflows/release.yml`)
- Spouští se push tagu `v*`.
- Spustí testy → build release APK → podepíše → spočítá SHA-256 → vygeneruje `latest.json` → vytvoří Release s assety.
- `versionCode` odvozený z tagu (např. `major*10000 + minor*100 + patch`).
- Druhý workflow `ci.yml`: lint + testy na každý push/PR.

## 5. Funkce frameworku

### 5.1 Hlavní stránka (viz mockup)
- **Horní pruh:** avatar a jméno aktivního hráče (tap → přepnutí hráče), zůstatek bodů ● (tap → obchod), tlačítko zvuku.
- **„Pokračovat“** (zlatý pruh): poslední hraná hra se stejným nastavením – jeden tap = start.
- **Mřížka her:** karta = ikona, název, počet hráčů, nejlepší hodnocení aktivního hráče (0–3 hvězdy). Hry, které ještě nejsou implementované, mají štítek „Brzy“ a nejdou spustit.
- **Navigace:** Hry · Hráči · Žebříčky · Nastavení (telefon = spodní lišta, tablet = rail vlevo).
- **Tablet ≥ 840 dp:** pravý panel „Hráči na zařízení“ + „Žebříček tento týden“ + „Poslední odměna“.

### 5.2 Správa hráčů
- Vytvoření, úprava, smazání (s potvrzením) profilu. Max. 8 profilů na zařízení.
- Profil: `id`, `jméno` (1–16 znaků, unikátní), `avatar`, `barva oblíbená` (volitelně), `vytvořeno`, statistiky.
- Výběr aktivního hráče (pamatuje se mezi spuštěními).
- Bez hesel. Žádné osobní údaje kromě přezdívky.
- Volitelně: export/import všech profilů do JSON souboru (záloha při přechodu na nové zařízení).

### 5.3 Editor avatara
Avatar se **skládá z vektorových vrstev** kreslených kódem (žádné cizí obrázky). Uložený jako malý JSON, vykreslitelný v libovolné velikosti (28–160 dp).

| Vrstva | Počet variant (min.) |
|---|---|
| Tvar obličeje | 4 (ovál, kulatý, široký, hranatý) |
| Barva pleti | 6 tónů (od světlé po tmavou) |
| Účes | 10 (krátké, dlouhé, kudrny, drdol, ježek, culíky, mikádo, copánky, kšiltovka, bez vlasů) |
| Barva vlasů | 8 (černá, hnědá, kaštanová, blond, platinová, zrzavá, šedá, modrá) |
| Oči | 6 |
| Ústa | 6 |
| Pozadí | 8 barev |

- Základní vzhled (tabulka výše) je **zdarma**. Vylepšení (korunka, brýle, klobouk, maska, hůlka, mobil, svatozář…) se kupují za body – viz **5.6 Body a obchod s vylepšeními**.
- UI: velký náhled nahoře, pod ním záložky vrstev, mřížka variant (náhled varianty = celý avatar), barvy jako kulaté vzorníky. Tlačítko „Náhodně“ 🎲 (míchá jen základní vzhled a vlastněná vylepšení).
- Změna se projeví okamžitě s jemnou animací (bounce 200 ms).
- Avatar se všemi nasazenými vylepšeními se zobrazuje všude: hlavní stránka, sloty hráčů, HUD ve hře, výsledky, žebříčky.

### 5.4 Žebříčky a statistiky
- Ukládá se každá dohraná partie: hra, datum, obtížnost, účastníci (hráči i AI), pořadí, skóre, délka.
- Pohledy: **celkový** (body celkem získané), **podle hry**, **podle obtížnosti**, období **týden / měsíc / vše**.
- Statistiky hráče: odehrané hry, výhry, % výher, nejlepší čas/skóre, série výher.
- Hry s časem (Miny, Pexeso pro 1 hráče) mají tabulku osobních rekordů.
- Výhry proti AI se počítají, ale v žebříčku je vidět obtížnost.

### 5.5 Odměny – přehled
Tři oddělené pojmy (v UI se nesmí plést):
- **Body** (měna, ikona zlaté mince ●) – získávají se za hry, utrácí se v obchodě s vylepšeními avatara. Detail v 5.6.
- **Hodnocení 0–3 hvězdy ★** za partii (definuje hra, např. Pexeso podle počtu chyb). Nejlepší hodnocení se ukazuje na kartě hry.
- **Odznaky (achievementy):** definované deklarativně (id, název, popis, ikona, podmínka, odměna v bodech). Framework poskytuje vyhodnocovač podmínek nad statistikami + API, kterým hra ohlásí vlastní událost. Příklady: „První výhra“, „5 výher v řadě“, „Paměť jako slon“ (Pexeso bez chyby), „Odminovač“ (Miny na těžkou), „Sběratel“ (10 vylepšení).
- Animace získání: odznak vyjede zespodu, mince přiletí do počítadla + zvukový efekt.

### 5.6 Body a obchod s vylepšeními avatara

#### Kolik bodů za co
Výchozí hodnoty jsou v jednom konfiguračním souboru `assets/config/rewards.json`, aby šly snadno ladit bez zásahu do kódu. Hra může základ upravit (násobič 0,5–2×), framework počítá zbytek.

| Událost | Lehká | Střední | Těžká |
|---|---|---|---|
| **Výhra** (1. místo; u hry pro 1 hráče = úspěšné dokončení) | 10 | 20 | 35 |
| Remíza | 5 | 10 | 15 |
| 2. místo (3–4 hráči) | 4 | 8 | 12 |
| Dohraná hra bez umístění (účast) | 2 | 3 | 4 |

Bonusy (sčítají se):
| Bonus | Body |
|---|---|
| Za každou ★ hodnocení partie | +2 |
| Série výher: 3 / 5 / 10 v řadě | +5 / +10 / +25 |
| První dohraná hra dne (za profil) | +5 |
| Nový osobní rekord (čas/skóre) | +5 |
| Získaný odznak | +15 až +50 (podle odznaku) |

Pravidla:
- Body dostávají jen **lidští hráči** (AI nic). Výhra proti AI i proti člověku se počítá stejně, rozhoduje obtížnost.
- Předčasně ukončená hra (✕ Konec) = 0 bodů.
- **Ochrana proti „farmení“:** v jedné hře na obtížnost Lehká se plné body počítají za prvních 10 výher denně, pak 1 bod za výhru. Při 2+ lidských hráčích v jedné partii to neplatí.
- Body se nikdy neodečítají za prohru.
- Evidují se dvě čísla: **zůstatek** (lze utratit) a **celkem získáno** (nikdy neklesá). Žebříčky a úrovně používají *celkem získáno* – utrácení tedy nesnižuje pořadí.
- Každý pohyb bodů je záznam v účetní knize (`points_ledger`: profil, +/− částka, důvod, odkaz na partii/nákup, čas) – zůstatek = součet; umožní přehled „Historie bodů“ v profilu.

#### Úrovně hráče
- Úroveň podle *celkem získáno*: úroveň n vyžaduje `50 × n × (n+1) / 2` bodů (1 → 50, 2 → 150, 3 → 300 … 10 → 2 750), max. úroveň 30.
- Úroveň je vidět jako malý štítek u avatara a v profilu (progress bar k další úrovni).
- Některá vylepšení vyžadují minimální úroveň (nelze je jen „koupit hned“) – motivace hrát dlouhodobě.

#### Sloty vylepšení
Na avataru může být současně nasazeno **jedno vylepšení v každém slotu**:

| Slot | Kotva / vrstva | Příklady |
|---|---|---|
| **Na hlavu** | nad vlasy; vlasy pod kloboukem se automaticky zkrátí, aby nevyčuhovaly | korunka, klobouk (cylindr), čarodějnický klobouk, kšiltovka, čelenka s oušky, pirátský šátek, svatozář |
| **Na obličej** | přes oči/obličej | brýle, sluneční brýle, maska superhrdiny, karnevalová maska, knírek, malování na obličej |
| **Do ruky** | ruka v pravém dolním rohu avatara | kouzelná hůlka, mobil, lízátko, balónek, trofej, mikrofon |
| **Mazlíček** | na rameni vlevo dole | kočka, papoušek, kuřátko, dráček |
| **Rámeček** | okraj kolem avatara | zlatý, duhový, hvězdný, plamenný |
| **Efekt** | animace kolem avatara | třpytky, bublinky, sněžení |

Svatozář je ve slotu „Na hlavu“, ale vykresluje se nad hlavou – lze ji tedy nasadit místo korunky, ne spolu s ní.

#### Katalog (startovní nabídka – min. 30 položek)
Rarita určuje barvu štítku a orientační cenu:

| Rarita | Barva | Cena | Příklady |
|---|---|---|---|
| Běžné | šedohnědá | 30–60 | brýle, kšiltovka, lízátko, balónek, čelenka s oušky |
| Vzácné | modrá `player2` | 100–200 | sluneční brýle, klobouk, maska superhrdiny, mobil, kočka, zlatý rámeček |
| Epické | fialová `#8E5BC8` | 300–500 | čarodějnický klobouk, kouzelná hůlka, karnevalová maska, papoušek, duhový rámeček, třpytky |
| Legendární | zlatá `gold` | 800–1 200 + úroveň ≥ 8 | **korunka**, **svatozář**, dráček, plamenný rámeček |
| Za odznak | zelená `player4` | nelze koupit | trofej (za 50 výher), hvězdný rámeček (za všechny hry na Těžkou) |

Každá položka je definovaná deklarativně v `assets/config/shop_items.json`:
```json
{ "id": "crown_gold", "slot": "head", "rarity": "legendary",
  "price": 1000, "minLevel": 8, "unlock": "purchase",
  "nameKey": "item.crown_gold", "painter": "CrownPainter",
  "colorVariants": ["gold", "silver"], "animated": false }
```
- Grafika vylepšení je **vektorová a kreslená kódem** (painter na položku), ve stejném stylu jako avatar. Musí sedět na všech tvarech obličeje a účesech a být čitelná i v nejmenší velikosti 28 dp (v malých velikostech se vynechá efekt a mazlíček).
- Animované položky (jiskřící hůlka, zářící svatozář, blikající displej mobilu, třpytky) se animují jen ve velikosti ≥ 64 dp a respektují „omezit animace“.
- Některé položky mají barevné varianty – koupí se jednou, barva se volí v šatníku zdarma.

#### Obchod a šatník (UI, viz mockup)
- Přístup: profil hráče → **Obchod** a **Šatník**; z hlavní stránky tapnutím na počítadlo bodů.
- Nahoře velký avatar = **zkušební kabinka**: tap na položku ji okamžitě „vyzkouší“ na avataru (bez koupě).
- Záložky podle slotů, mřížka karet: náhled, název, cena / stav (**Máš**, **Nasazeno**, **🔒 Úroveň 8**, **🔒 Odznak …**).
- Tlačítko dole: „Koupit za 150 ●“ → potvrzovací dialog → animace (mince odletí, položka „vyskočí“, zvuk `purchase`) → nabídka „Nasadit hned?“.
- Nedostatek bodů: tlačítko neaktivní s textem „Chybí ti 40 ●“ a progress barem.
- **Šatník** = vlastněné položky, nasazení/sundání zdarma a okamžitě (zvuk `equip`).
- Bez skutečných peněz, bez nákupů v aplikaci, bez reklam – body se dají získat **jen hraním**.
- Rodičovská zóna: možnost darovat hráči body (např. odměna za úkoly), resetovat body/inventář. Záznam jde také do `points_ledger` s důvodem „dárek od rodiče“.

#### Výsledky partie
Na obrazovce výsledků se u každého lidského hráče postupně „načítá“ rozpis bodů (Výhra +20, ★★ +4, Série 3 výher +5 …), pak celkový součet přiletí do počítadla. Pokud hráč dosáhl nové úrovně nebo si teď může koupit položku, kterou si dříve „zkoušel“, zobrazí se upozornění.

### 5.7 Výběr a nastavení hry (obrazovka před startem)
- **Počet hráčů 1–4** = počet **míst u stolu** (účastníků partie), omezený rozsahem, který hra deklaruje. Nezáleží na tom, kolik je skutečných lidí.
- **Sloty hráčů** v barvách hráčů 1–4 (červená, modrá, žlutá, zelená). Každý slot obsadí buď **člověk** (výběr profilu), nebo **počítač – robot** (viz 5.7.1).
- **Automatické doplnění robotem:** sloty se plní nejdřív lidmi, každý zbylý slot se **automaticky obsadí robotem**. Příklad: zvolím 4 hráče, vyberu 2 profily → sloty 3 a 4 dostanou roboty. U hry pro 2 hráče s jedním člověkem je soupeř automaticky robot.
- Tap na slot přepíná člověk ⇄ robot, dlouhý stisk / šipky mění pořadí (kdo začíná). V partii musí být **aspoň 1 člověk**; stejný profil nemůže být ve dvou slotech.
- **Obtížnost:** Lehká / Střední / Těžká (ovlivňuje AI a/nebo parametry hry). Platí pro všechny roboty v partii.
- **Kde se hraje** (aktivní až od fáze 3): *Na jednom zařízení* / *Každý na svém (Wi-Fi)* – viz kap. 14. Ve fázi 1 připravit místo v UI, volba je skrytá.
- **Specifické volby hry** (např. velikost desky, počet karet) – hra je deklaruje jako schéma, framework je vykreslí jednotnými komponentami (segmented control, přepínač, slider).
- **Pamatování nastavení:** po otevření se předvyplní poslední použitá konfigurace dané hry (počet hráčů, obsazení slotů, obtížnost, volby). Ukládá se per hra. Zobrazí se poznámka „Nastavení načteno z minulé hry“. Pokud mezitím někdo z uložených profilů zmizel, jeho slot dostane robota.

#### 5.7.1 Počítačoví hráči – roboti
Počítač se všude (sloty, HUD, výsledky, historie partií) zobrazuje jako **robot**, aby bylo na první pohled jasné, kdo je člověk a kdo stroj.

- **Avatar robota** – samostatný vektorový styl, jiný než lidské avatary: kovově šedá hranatá hlava se zaoblenými rohy, anténa s kuličkou, LED oči, mřížka úst. **Hlavní barva (pozadí, anténa, oči) = barva slotu**, takže robot ve žlutém slotu je žlutý. Žádná vylepšení z obchodu.
- **Jména robotů** (lokalizovaná), přidělená podle slotu: CS *Robík, Čipík, Šroubek, Bzučák*; EN *Robo, Chip, Bolt, Buzz*; ES *Robi, Chispa, Tornillo, Zumbi*.
- **Odznak „robot“** (malá ikona 🤖 / štítek „AI“) v rohu avatara všude, kde je avatar menší než 64 dp – rozliší robota i bez barev.
- **Obtížnost na robotovi:** 1–3 tečky/hvězdičky pod jménem (Lehká/Střední/Těžká).
- **Robot na tahu:** LED oči blikají a u avatara běží animace „přemýšlím…“ (tři tečky). Lidé během jeho tahu nemohou do hry zasahovat, jen pozastavit hru.
- **Rychlost robotů:** v nastavení hry přepínač Pomalu / Normálně / Rychle (prodleva tahu 1 200 / 600 / 250 ms), aby děti stihly sledovat, co robot udělal. Poslední tah robota je vždy zvýrazněný.
- **Body, žebříčky, odznaky:** roboti body ani odznaky nezískávají a v žebříčcích nejsou. Ve výsledcích partie se ale řadí normálně (člověk může skončit za robotem).
- **Kombinace:** jakýkoli poměr lidí a robotů v rozsahu hry (1 člověk + 3 roboti, 2 + 2, 3 + 1…). Obrazovka nastavení ukazuje souhrn „2 lidé + 2 roboti“.
- Implementace: framework poskytuje `RobotAvatar` (ui_kit), `RobotPlayer` (identita slotu, jméno, barva) a v `GameConfig` u každého slotu `type: human | robot`. Hra jen implementuje AI tah (kap. 9); vše ostatní kolem robotů řeší framework.

### 5.8 Společné HUD během hry
Horní pruh na všech hrách (viz mockup „Ve hře“):
- **Konec** (✕) – dialog „Opravdu ukončit? Rozehraná hra se uloží / neuloží“ (podle schopnosti hry).
- **Pauza** – překryv s: Pokračovat, Restart, Pravidla, Konec.
- **Hudba** zap/vyp, **Efekty** zap/vyp (samostatně).
- Uprostřed proužek hráčů: avatar, jméno, skóre; hráč na tahu zvýrazněný (papírový podklad, jemné pulzování).
- Dole volitelná bublina „Na tahu: Kuba – …“.
- Systémové tlačítko Zpět = Pauza.
- Automatické uložení rozehrané partie při odchodu z aplikace (pokud ji hra podporuje), obnovení po návratu.

### 5.9 Konec hry
Jednotná obrazovka výsledků: pořadí s avatary, skóre, získané body (rozpis viz 5.6) a odznaky, tlačítka **Hrát znovu** (stejné nastavení), **Změnit nastavení**, **Domů**. Konfety v barvě vítěze.

### 5.10 Nastavení aplikace
- Jazyk (Čeština / English / Español), hlasitost hudby a efektů (2 slidery) + vypínače, vibrace zap/vyp.
- Aktualizace (kap. 4), verze aplikace.
- „Autoři a licence“ – automaticky generovaný seznam použité hudby, zvuků, fontů a knihoven (kap. 7.4).
- Rodičovská zóna (dlouhé podržení 3 s): smazání všech dat, export/import profilů.

## 6. Vizuální systém

Styl **„herní stůl“**: tmavý ořechový rám, zelená plsť jako hrací plocha, krémové papírové karty, zlaté odměny. Hravé, teplé, ale ne příliš dětské.

### 6.1 Barvy (design tokeny)
| Token | Hex | Použití |
|---|---|---|
| `walnut` | `#3B2A20` | rám, navigace, tmavé pozadí |
| `wood` | `#8B5A3C` | okraje, rub karet, rámy desek |
| `woodLight` | `#C89B6D` | sekundární text na tmavém |
| `felt` | `#2F5D50` | hrací plocha, pozadí obrazovek |
| `feltDark` | `#234A3F` | stíny na plsti |
| `paper` | `#F4EADB` | karty, panely, dialogy |
| `paper2` | `#E9DCC7` | spodní stíny karet, oddělovače |
| `ink` | `#2B211B` | text na papíře |
| `gold` | `#E0A82E` | hlavní akce, body (mince), hodnocení ★ |
| `player1..4` | `#D9534F` `#3B7DD8` `#E8B931` `#4CAF6A` | barvy hráčů – **stejné ve všech hrách** |

Plsť má jemnou texturu (šum/radiální přechod), dřevo jemná léta – generovat kódem nebo malou dlaždicí, ne velké bitmapy.

### 6.2 Typografie
- Nadpisy: **Baloo 2** (600/800), texty a tlačítka: **Nunito** (400/600/800). Obě SIL OFL, podporují češtinu i španělštinu (ě š č ř ž ů / ñ á é í ó ú ü ¿ ¡) – přibalit do aplikace (offline).
- Velikosti: H1 30, H2 22, tělo 16, popisky 12–13 sp. Respektovat systémové zvětšení písma do 130 %.

### 6.3 Komponenty
- **Karta:** paper, zaoblení 18 dp, „fyzický“ spodní stín 5 dp + měkký stín.
- **Tlačítko primární:** gold, pill, spodní stín 5 dp; při stisku se posune o 3 dp dolů (pocit fyzického tlačítka) + zvuk `tap`.
- **Kulaté ikonové tlačítko:** 44–48 dp, paper.
- **Segmented control, slot hráče, odznak, avatar s rámečkem v barvě hráče, dialog, toast.**
- Všechny komponenty v jedné knihovně `ui_kit`, hry je jen používají.

### 6.4 Pohyb
- Délky 150–300 ms, ease-out; přechody obrazovek posunem/fade.
- Karty: 3D flip. Žetony: krátký „poskok“ při položení.
- Respektovat systémové „omezit animace“.

### 6.5 Ikony her
Jednotný styl: barevný pastelový podklad, tmavá kresba, akcent v barvách hráčů (viz mockup). Kreslit vektorově.

## 7. Zvuk a hudba

### 7.1 Architektura
- `AudioService` ve frameworku: jeden kanál **hudby** (smyčka s plynulým prolínáním 600 ms při změně obrazovky) + pool **efektů** (min. 6 současně).
- Hudba a efekty mají samostatnou hlasitost a vypínač; stav se pamatuje.
- Při událostech (výhra, odznak) se hudba krátce ztlumí (ducking −8 dB).
- Při přechodu aplikace do pozadí se hudba pozastaví.
- Hra registruje svou hudbu a případné vlastní efekty v manifestu (kap. 8).
- Formát OGG Vorbis (hudba ~96 kb/s, efekty 64 kb/s mono), hlasitost normalizovaná na cca −16 LUFS. Rozpočet: hudba celkem ≤ 15 MB.

### 7.2 Hudba – každá hra má vlastní podkres
| Kontext | Nálada | Kandidáti (Kevin MacLeod, incompetech.com, CC BY 4.0) | Soubor v projektu |
|---|---|---|---|
| Menu / framework | vlídná, akustická, nevtíravá | „Wallpaper“, „Carefree“ | `music/menu.ogg` |
| Piškvorky | klidná, soustředěná, lehké piano | „Local Forecast – Elevator“ | `music/tictactoe.ogg` |
| Pexeso | hravá, xylofon/marimba | „Monkeys Spinning Monkeys“ | `music/memory.ogg` |
| Miny | napínavá, ale tichá, minimalistická | „Sneaky Snitch“, „Investigations“ | `music/minesweeper.ogg` |
| Člověče, nezlob se | veselá, rozjetá, dechovka/polka | „Fluffing a Duck“ | `music/ludo.ogg` |
| Dáma | klasická, kavárenská, klavír | „Gymnopedie No 1“ | `music/checkers.ogg` |
| Výsledky – výhra | krátký jingle 2–4 s | Kenney „Music Jingles“ (CC0) | `sfx/jingle_win.ogg` |
| Výsledky – prohra/remíza | krátký jingle | Kenney „Music Jingles“ (CC0) | `sfx/jingle_lose.ogg` |

> Skladby vybere a stáhne Miloš (Claude Code je neumí poslechnout). Do té doby vygeneruj **zástupné soubory** (krátké tiché/sinusové smyčky se stejnými názvy), ať vše funguje. Ke každému souboru vytvoř záznam v `assets/audio/CREDITS.json`.

### 7.3 Efekty (sdílené)
Zdroj: **Kenney.nl** – balíčky „Interface Sounds“, „UI Audio“, „Casino Audio“, „Digital Audio“ (vše CC0). Alternativně freesound.org (jen CC0).

| ID | Kdy | Charakter |
|---|---|---|
| `tap` | stisk tlačítka | krátké dřevěné ťuknutí |
| `back` | zpět / zavření | tlumené ťuknutí |
| `toggle` | přepínač | klik |
| `card_flip` | otočení karty | papírový šustot |
| `piece_place` | položení žetonu/kamene | dřevo na dřevo |
| `dice_roll` | hod kostkou | kostka na desce (Casino Audio) |
| `coin` | připsání bodů | cinknutí mince |
| `achievement` | odznak | krátká fanfára |
| `error` | neplatný tah | jemné „bzz“, nestrašit děti |
| `turn` | změna hráče | jemný zvoneček |
| `purchase` | koupě vylepšení | cinkání mincí + „ta-da“ |
| `equip` | nasazení vylepšení | krátké „švih“ |
| `level_up` | nová úroveň | vzestupná melodie 1–2 s |

### 7.4 Licence
- Každý asset: `{file, title, author, source_url, license, attribution_text}` v `CREDITS.json`.
- Obrazovka „Autoři a licence“ se generuje z tohoto souboru (CC BY vyžaduje uvedení autora: *„Název“ Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution 4.0*).
- Licenci každého souboru ověřit při stažení.

## 8. Architektura – modulární hry

Framework nesmí znát vnitřek her. Každá hra je samostatný modul, který se registruje přes rozhraní:

```text
GameModule
  id: String                       // "memory"
  titleKey, descriptionKey         // lokalizace
  icon: Widget/painter
  minPlayers, maxPlayers           // např. 1..4
  supportsAi: bool
  difficulties: [easy, medium, hard]
  optionsSchema: [GameOption]      // volby specifické pro hru
  orientation: any | portrait | landscape (per form factor)
  musicTrack: "music/memory.ogg"
  sfx: {id: path}                  // volitelné vlastní efekty
  rulesKey                         // text pravidel
  achievements: [AchievementDef]
  supportsSaveResume: bool
  createGame(GameConfig, GameHost) -> GameSession
```

`GameHost` (poskytuje framework hře): přístup k audiu, haptice, UI kitu, HUD (nastavení hráče na tahu, skóre), hlášení událostí pro odznaky, `finish(GameResult)`, uložení/obnovení stavu.

`GameResult`: pořadí hráčů, skóre, hodnocení 0–3, statistiky partie (čas, chyby, …).

### Tahy jako přenositelné zprávy (příprava na fázi 3)
Aby šlo později hrát přes Wi-Fi bez předělávání her, platí pro všechny hry už od fáze 1:
- Herní logika je **deterministický stavový automat**: `initialState(config, seed)` → `legalMoves(state, seat)` → `applyMove(state, move)` → nový stav. Žádná pravidla v UI.
- **Každá akce hráče je `Move`** – malý serializovatelný objekt (JSON), včetně „hodu kostkou“ nebo „otočení karty“. Náhoda jen přes `SeededRandom` ze stavu, nikdy přímo `Random()` v UI.
- UI nemění stav přímo, ale posílá `Move` přes `MoveTransport`. Ve fázi 1 a 2 existuje jen `LocalTransport` (stejné zařízení); fáze 3 přidá síťový transport, aniž by se hry měnily.
- Stav i tahy mají `toJson`/`fromJson` a `stateHash()` (pro kontrolu synchronizace).
- Kontraktní test **replay**: počáteční stav + seed + seznam tahů → vždy stejný stav a stejný hash.

Registr her v jednom souboru. **Už ve fázi 1 v něm budou zaregistrované všechny hry** (viz níže), takže fáze 2 registr vůbec nemění.

### Příprava na paralelní vývoj her (součást fáze 1)
Cíl: každá hra fáze 2 musí jít vyvinout tak, že se mění **jen soubory v její vlastní složce**. Proto framework ve fázi 1 připraví:

1. **Kostry všech 5 her** v `games/<id>/` (`tictactoe`, `memory`, `minesweeper`, `ludo`, `checkers`): manifest s `available: false` (→ štítek „Brzy“), ikona, prázdná `GameSession`, README. Registr je importuje už teď.
2. **Vše herně specifické se načítá ze složky hry** – nic se nepřidává do sdílených souborů:
   - lokalizace `games/<id>/l10n/{cs,en,es}.arb` (framework je automaticky slučuje; klíče s prefixem `<id>.`),
   - odznaky, bodový násobič, volby, vlastní efekty → v manifestu hry,
   - assety `assets/games/<id>/**` (deklarované v manifestu; konfigurace build systému musí zahrnout celou složku `assets/games/` předem),
   - hudba `assets/audio/music/<id>.ogg` (zástupná existuje už z fáze 1).
3. **Game kit** (`core/game_kit`) – sdílené stavební kameny, aby si je hry nepsaly pětkrát:
   - `BoardGrid` – mřížka s pinch-zoom/pan, zvýraznění polí, přepočet dotyku na buňku, automatické škálování na dostupnou plochu,
   - `PieceToken` – žeton/figurka v barvě hráče (s volitelnou mini ikonou pro barvoslepé), animace „poskoku“ a přesunu po cestě,
   - `FlipCard` – karta s 3D otočením,
   - `Dice` – kostka s animací hodu (a volitelně hod zatřesením),
   - `TurnController` – pořadí tahů, hráč na tahu, napojení na HUD, AI tahy s prodlevou,
   - `GameSearch` – obecný alpha-beta / minimax s iterativním prohlubováním a časovým limitem, běžící v izolátu,
   - `SeededRandom`, `Stopwatch` (pauzovatelný), `UndoStack`, serializace stavu pro uložení/obnovení.
4. **`GameTestHost`** – falešný `GameHost` pro testy + **sada kontraktních testů**, kterou musí projít každá hra (manifest validní, všechny klíče přeložené ve 3 jazycích, hra jde spustit pro každý povolený počet hráčů, každou kombinaci lidí a robotů a každou obtížnost, AI dohraje partii sama se sebou bez pádu, uložení → obnovení vrátí stejný stav, replay tahů je deterministický, `Move` i stav projdou serializací tam a zpět, `finish()` vrací validní `GameResult`).
5. **Rychlé spuštění jedné hry** pro vývoj: debug parametr (např. `--dart-define=GAME=memory`) otevře rovnou nastavení dané hry.
6. **Kontrola rozsahu změn v CI:** pro větve `game/<id>` skript `tool/check_scope` selže, pokud diff obsahuje soubory mimo `games/<id>/**`, `assets/games/<id>/**`, `test/games/<id>/**` a `assets/audio/music/<id>.ogg`.
7. **Zmrazení API:** po fázi 1 se `GameModule`, `GameHost`, `GameResult` a game kit označí jako **v1.0** (tag `v0.9.0-framework`). Změny API během fáze 2 jen výjimečně – viz 13.2.

### Navrhovaná struktura repozitáře
```
/app                 – vstupní bod, routing, DI
/core                – modely, perzistence, AudioService, UpdateService, lokalizace
                       (+ `multiplayer` ve fázi 3; `MoveTransport` + `LocalTransport` už ve fázi 1)
/ui_kit              – design tokeny, komponenty, avatar renderer
/features
   /home /players /avatar_editor /leaderboards /achievements /settings /game_setup /results
/games
   /_sample          – ukázková „hra“ (např. Hádej číslo) ověřující celé API
   /tictactoe /memory /minesweeper /ludo /checkers   – fáze 2 (zatím jen manifest se štítkem „Brzy“)
/assets/audio/{music,sfx}  /assets/fonts
/docs                – ARCHITECTURE.md, GAME_MODULE_GUIDE.md, design/
/.github/workflows   – ci.yml, release.yml
CLAUDE.md            – konvence projektu pro další práci
```

### Data (lokální DB)
- `players`, `avatar` (JSON v profilu), `game_results`, `result_participants`, `achievements_unlocked`, `points_ledger` (pohyby bodů), `inventory` (vlastněná vylepšení + zvolená barevná varianta), `equipped` (součást avatar JSON: slot → item), `game_settings_last` (per hra), `app_settings`, `saved_sessions`.
- Verzované migrace + testy migrací.

## 9. AI soupeř (příprava ve frameworku)
- Framework definuje rozhraní `AiPlayer.chooseMove(state, difficulty)` běžící mimo UI vlákno, s umělou prodlevou 400–900 ms („přemýšlí“ – animace teček u avatara).
- Konkrétní AI implementují hry ve fázi 2. Lehká obtížnost má dělat i chyby, aby děti mohly vyhrát.

## 10. Kvalita a přístupnost
- Unit testy: služby (update – porovnání verzí, parsování `latest.json`), výpočet bodů a bonusů, úrovně, nákup/nedostatek bodů, konzistence `points_ledger`, vyhodnocení odznaků, pamatování nastavení, migrace.
- Widget/UI testy hlavních obrazovek + golden testy ve 3 velikostech (telefon, tablet na výšku, tablet na šířku).
- Kontrast textu WCAG AA, popisky pro čtečku obrazovky u ikonových tlačítek, nespoléhat jen na barvu (hráči mají i tvar/ikonu u žetonu).
- Start aplikace do hlavní obrazovky < 2 s na středním zařízení; velikost APK cíl < 40 MB.
- Oprávnění: `INTERNET`, `REQUEST_INSTALL_PACKAGES`; od fáze 3 navíc `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE` (vyhledání hry v síti) a `CAMERA` (sken QR kódu – vyžádat až při použití, s náhradou ručním zadáním kódu).

## 11. Postup a milníky (fáze 1)

1. **Kostra projektu**, CI, design tokeny, fonty, lokalizace, navigace, responzivní layout (prázdné obrazovky).
2. **UI kit** + avatar renderer + editor avatara.
3. **Profily hráčů** + perzistence + výběr aktivního hráče.
4. **Herní API** (`GameModule`, `GameHost`), obrazovka nastavení hry s pamatováním, HUD, pauza, výsledky, ukázková hra `_sample`.
5. **AudioService**, zástupné zvuky, CREDITS, nastavení zvuku.
6. **Statistiky, žebříčky, odznaky.**
7. **Body, úrovně, obchod a šatník** – `rewards.json`, `shop_items.json`, min. 30 vylepšení s vektorovou grafikou, rozpis bodů ve výsledcích.
8. **UpdateService** + `release.yml` + ověření celého cyklu: vydat `v0.1.0`, nainstalovat, vydat `v0.1.1`, aplikace nabídne aktualizaci a nainstaluje ji bez ztráty dat.
9. **Příprava fáze 2** (kap. 8 – „Příprava na paralelní vývoj“): kostry 5 her, game kit, `GameTestHost` + kontraktní testy, kontrola rozsahu v CI, zmrazení API, tag `v0.9.0-framework`.
10. Dokumentace: `ARCHITECTURE.md`, `GAME_MODULE_GUIDE.md` (jak přidat hru, jak používat game kit), `CLAUDE.md` (včetně pravidel paralelní práce z 13.2).

Po každém milníku krátké shrnutí + screenshoty z emulátoru (telefon a tablet).

## 12. Akceptační kritéria fáze 1
- [ ] Aplikace běží bez internetu kompletně (kromě kontroly aktualizace).
- [ ] Hlavní stránka odpovídá mockupu na telefonu i tabletu, otočení displeje nerozbije layout.
- [ ] Lze vytvořit 4 hráče s různými avatary, upravit je, smazat.
- [ ] Ukázková hra jde spustit pro 1–4 hráče; při 4 slotech a 2 vybraných lidech se zbylé 2 sloty samy obsadí roboty s robotím avatarem v barvě slotu (ve slotech, HUD i výsledcích); roboti nezískají body ani místo v žebříčku; s volbou obtížnosti; po návratu je nastavení předvyplněné z minula; „Pokračovat“ na hlavní stránce funguje.
- [ ] HUD: konec s potvrzením, pauza, hudba a efekty zap/vyp – stav se pamatuje.
- [ ] Ukázková hra má vlastní hudbu odlišnou od menu, přechod je plynulý.
- [ ] Výsledky se propíší do žebříčků a odznaků; vítěz dostane body podle tabulky 5.6 (ověřeno unit testy včetně bonusů a limitu proti farmení).
- [ ] Za body lze v obchodě vyzkoušet, koupit a v šatníku nasadit vylepšení (korunka, brýle, klobouk, maska, hůlka, mobil, svatozář…); nasazený vzhled se ukazuje ve všech obrazovkách a ve všech velikostech avatara.
- [ ] Utrácení bodů nesníží pořadí v žebříčku ani úroveň.
- [ ] Tag `v*` vytvoří podepsaný release; starší verze při spuštění najde novější, stáhne, ověří SHA-256 a nainstaluje; data zůstanou.
- [ ] Přepnutí CZ / EN / ES přeloží celé UI včetně pravidel her, názvů vylepšení a odznaků; žádný text nepřetéká na telefonu 360 dp.
- [ ] Hry z fáze 2 jsou v mřížce se štítkem „Brzy“; jejich kostry procházejí kontraktními testy (kromě testů hratelnosti) a game kit má vlastní testy.
- [ ] Ukázková hra `_sample` je postavená jen z game kitu a ze souborů ve své složce – důkaz, že hra jde přidat bez zásahu do frameworku.
- [ ] Všechny akce v `_sample` jdou přes `Move` a `LocalTransport`; replay test a serializace tahů procházejí (příprava na fázi 3).

## 13. Fáze 2 – jednotlivé hry (paralelní vývoj)

### 13.1 Předpoklady
- Fáze 1 je hotová a všechna kritéria z kap. 12 jsou splněná, `main` je na tagu `v0.9.0-framework`.
- Každá hra se staví **jen z API v1.0 a game kitu** (kap. 8). Hry na sobě vzájemně nezávisí – lze je dělat v libovolném pořadí i všechny najednou.
- Orientační složitost (pro plánování): Pexeso ● Piškvorky ●● Miny ●● Člověče ●●● Dáma ●●●●.

### 13.2 Pravidla paralelní práce
1. **1 hra = 1 větev `game/<id>` = 1 git worktree = 1 Claude Code session** (nebo 1 subagent v izolovaném worktree).
2. Session smí měnit **jen**: `games/<id>/**`, `assets/games/<id>/**`, `test/games/<id>/**`, `assets/audio/music/<id>.ogg`. CI to vynucuje (`tool/check_scope`).
3. **Zákaz úprav** `core/`, `ui_kit/`, `features/`, `app/`, registru her, sdílených lokalizací, `pubspec`/build konfigurace a CI. Žádné nové závislosti (balíčky) bez schválení.
4. Potřebuje-li hra něco od frameworku: **neupravuj ho**. Zapiš požadavek do `games/<id>/FRAMEWORK_REQUESTS.md` (co, proč, navržené API), dočasně to vyřeš lokálně ve složce hry a pokračuj. Požadavky zpracuje samostatná větev `framework/*`, po jejím sloučení do `main` se herní větve rebasují.
5. Prefix `<id>.` pro všechny klíče lokalizace, id odznaků, id efektů a soubory assetů.
6. Pomocný kód, který by se hodil i jiné hře, zůstává ve složce hry. Sjednocení do game kitu až po dokončení všech her.
7. Rebase na `main` minimálně jednou denně a vždy před PR. Každá větev musí samostatně projít celým CI.
8. Hotová hra: PR → CI zelené → Miloš si hru zahraje → merge → přepnout v manifestu `available: true` (je v její složce) → vydat novou minor verzi (`v1.1.0`, `v1.2.0`…). Tagy vydává jen Miloš nebo integrační session z `main`.

### 13.3 Jak paralelní vývoj spustit
**Varianta A – 5 samostatných session (doporučeno):**
```bash
git worktree add ../deskovky-tictactoe   -b game/tictactoe
git worktree add ../deskovky-memory      -b game/memory
git worktree add ../deskovky-minesweeper -b game/minesweeper
git worktree add ../deskovky-ludo        -b game/ludo
git worktree add ../deskovky-checkers    -b game/checkers
```
V každé složce spusť Claude Code s promptem:
> Přečti `docs/ZADANI-deskovky.md` (hlavně kap. 8, 13.2, 13.4 a kapitolu své hry) a `docs/GAME_MODULE_GUIDE.md`. Implementuj hru **`<id>`** podle kapitoly **13.x**. Dodržuj pravidla paralelní práce z 13.2 – měň jen soubory své hry. Postupuj podle milníků z 13.4, po každém spusť testy a pošli shrnutí. Na konci ověř Definition of Done a připrav PR.

**Varianta B – jedna session s podagenty:** „Spusť 5 podagentů, každý v izolovaném worktree na větvi `game/<id>`, každý implementuje jednu hru podle kap. 13 a pravidel 13.2. Ty jen koordinuj, sbírej `FRAMEWORK_REQUESTS.md` a hlídej, aby nikdo neměnil sdílené soubory.“

### 13.4 Společná osnova každé hry
Každá hra dodá:
- **Manifest** (`GameModule`): rozsah hráčů, obtížnosti, schéma voleb s výchozími hodnotami, orientace, hudba, efekty, odznaky, bodový násobič, `supportsSaveResume: true`.
- **Logiku podle pravidla „Tahy jako přenositelné zprávy“ (kap. 8)** – každá akce je `Move`, náhoda jen ze stavu. Hra pak ve fázi 3 funguje přes Wi-Fi bez úprav.
- **Čistou herní logiku** bez závislosti na UI (stav, legální tahy, provedení tahu, konec hry, pořadí) + unit testy pokrývající všechna pravidla včetně hraničních případů.
- **AI** ve třech obtížnostech přes `TurnController`/`GameSearch`, výpočet mimo UI vlákno, prodleva 400–900 ms. Lehká AI musí být porazitelná sedmiletým dítětem.
- **UI** pro telefon na výšku a tablet na šířku i na výšku (golden testy ve 3 velikostech), ovládání jen dotykem, cíle ≥ 48 dp (u malých polí pinch-zoom).
- **Napojení na HUD:** hráč na tahu, skóre, bublina s nápovědou („Na tahu: Kuba – hoď kostkou“).
- **Pravidla** ve 3 jazycích: krátký text + 2–4 ilustrované kroky (kreslené kódem), dostupné z pauzy a z nastavení hry. Při první hře profilu nenásilná nápověda k ovládání.
- **Hodnocení 0–3 ★**, statistiky partie, osobní rekordy (kde dává smysl), 4–5 odznaků.
- **Zvuky:** sdílené efekty + max. 3 vlastní (`<id>.*`), hudba `music/<id>.ogg`.
- **Uložení a obnovení** rozehrané partie (včetně stavu AI a stopek).
- Vizuál podle kap. 6: plsť, dřevo, papír, barvy hráčů 1–4.

**Milníky každé hry:** (1) logika + testy pravidel → (2) hratelné UI pro 2 lidi / 1 hráče → (3) AI → (4) volby, hodnocení, odznaky, ukládání → (5) animace, zvuky, pravidla, lokalizace → (6) Definition of Done.

**Definition of Done (každá hra):**
- [ ] Projde kontraktní testy (kap. 8, bod 4) a vlastní unit testy pravidel.
- [ ] AI na každé obtížnosti odehraje 100 partií sama se sebou bez pádu a bez nelegálního tahu; Těžká AI porazí Lehkou ve ≥ 80 % partií (u her s náhodou ≥ 60 %).
- [ ] Hratelné na 360×740, 412×915, 800×1280 a 1280×800; otočení displeje během hry nic nerozbije.
- [ ] Uložení/obnovení funguje i po zabití aplikace.
- [ ] Replay test: záznam celé partie (seed + tahy) přehraný znovu dá stejný výsledek.
- [ ] Body, ★, odznaky a statistiky se propíší do frameworku; nastavení hry se pamatuje.
- [ ] Všechny texty v CS/EN/ES, nic nepřetéká.
- [ ] Diff obsahuje jen povolené cesty, žádné nové závislosti.
- [ ] `games/<id>/README.md` popisuje pravidla, architekturu hry a AI.

---

### 13.5 Piškvorky (`tictactoe`)
| | |
|---|---|
| Hráči | 1–2 (1 = proti AI), hot-seat |
| Volby | **Deska:** 3×3 (3 v řadě) / 10×10 (5 v řadě) / 15×15 (5 v řadě); **Začíná:** střídavě / náhodně / vždy hráč 1 |
| Orientace | libovolná |

**Pravidla:** hráči střídavě kladou své symboly; vyhrává ten, kdo první vytvoří řadu (vodorovně, svisle, šikmo) požadované délky. Na velkých deskách platí „5 a více“. Plná deska = remíza.

**UI:** deska jako čtverečkovaný papír na plsti. Hráč 1 = ✕, hráč 2 = ◯, v barvách hráčů. Poslední tah zvýrazněný, vítězná řada se „přeškrtne“ animací. Na 15×15 na telefonu pinch-zoom + tlačítko „vycentrovat“. Tah se položí na tap; na velké desce volitelně potvrzení druhým tapem (proti překliknutí).

**AI:**
- 3×3 – Lehká: náhodný tah, v 50 % vezme výhru/blok; Střední: vyhraj → blokuj → střed → roh; Těžká: dokonalý minimax (neporazitelná).
- Velká deska – hodnoticí funkce vzorů (otevřená/polootevřená čtyřka, trojka…), kandidátní tahy jen do vzdálenosti 2 od kamenů. Lehká: 1 tah dopředu + náhodnost, občas přehlédne hrozbu; Střední: 2 tahy, vždy blokuje čtyřku; Těžká: alpha-beta hloubka 4+ s časovým limitem 700 ms a vyhledáváním vynucených výher (VCF).

**Hodnocení:** 3×3: výhra ★★★, remíza ★★, prohra ★ (pokud hráč aspoň jednou zablokoval hrozbu). Velká deska: výhra do 20 vlastních tahů ★★★, výhra ★★, remíza nebo prohra po ≥ 25 tazích ★.

**Odznaky:** `tictactoe.wall` Neprůstřelný (10× remíza proti Těžké na 3×3) · `tictactoe.five` Pětka (první výhra na 15×15) · `tictactoe.blitz` Blesk (výhra do 9 tahů na velké desce) · `tictactoe.master` Mistr piškvorek (výhra na Těžkou na 15×15).

**Zvuky:** `tictactoe.draw` (škrábnutí tužkou), `tictactoe.line` (přeškrtnutí řady). **Hudba:** `music/tictactoe.ogg`.

---

### 13.6 Pexeso (`memory`)
| | |
|---|---|
| Hráči | 1–4 (AI může obsadit libovolné sloty) |
| Volby | **Počet karet:** 12 / 16 / 24 / 36 (na tabletu i 48); **Sada obrázků:** Zvířátka, Ovoce a zelenina, Doprava, Vesmír |
| Orientace | libovolná, mřížka se přepočítá |

**Pravidla:** hráč otočí 2 karty. Shoda → pár si nechá a hraje znovu. Neshoda → karty se po 1,2 s otočí zpět (tap kamkoli to urychlí) a hraje další. Vyhrává nejvíc párů (při rovnosti sdílené pořadí). Hra pro 1 hráče = co nejméně tahů a nejkratší čas.

**Obrázky:** vektorové, jednotný styl. Doporučení: přibalené SVG z **Noto Emoji** (Apache 2.0) nebo **Twemoji** (CC BY 4.0 – uvést v CREDITS); ne systémová emoji (liší se podle telefonu). Každá sada min. 24 motivů. Rub karet = dřevo s logem aplikace.

**UI:** mřížka maximalizuje velikost karet podle poměru stran; 3D flip (game kit `FlipCard`); nalezené páry odletí k avataru hráče; počítadlo párů v HUD.

**Obtížnost:**
- Více hráčů – paměť AI: Lehká si pamatuje 25 % viděných karet a po 3 tazích je zapomíná, Střední 60 % / 8 tahů, Těžká 95 % bez zapomínání.
- 1 hráč – Lehká: náhled všech karet na 2 s na začátku; Střední: bez náhledu; Těžká: po každé 4. chybě se 2 neodkryté karty viditelně prohodí.

**Hodnocení (1 hráč):** tahy ≤ 1,5 × počet párů ★★★, ≤ 2 × ★★, dokončeno ★. **Více hráčů:** 1. místo ★★★, 2. místo ★★, jinak ★.

**Odznaky:** `memory.elephant` Paměť jako slon (bez chyby, ≥ 16 karet) · `memory.speed` Rychlík (16 karet pod 40 s) · `memory.streak` Série (5 párů v jednom tahu) · `memory.collector` Sběratel párů (celkem 200 párů).

**Zvuky:** `card_flip`, `memory.match` (cinknutí), `memory.miss` (jemné „hm“). **Hudba:** `music/memory.ogg`.

---

### 13.7 Miny (`minesweeper`)
| | |
|---|---|
| Hráči | 1 (klasika) nebo 2–4 (režim „Střídačka“) |
| Volby | **Otazníky:** zap/vyp; **Režim ovládání:** ťuk = odkrýt + dlouhý stisk = vlajka / přepínač ⛏/🚩 |
| Orientace | libovolná; deska se otočí podle orientace zařízení |

**Obtížnost = velikost desky:** Lehká 9×9 / 10 min · Střední 12×16 / 30 min · Těžká 16×24 / 70 min.

**Pravidla (1 hráč):** klasický Minesweeper. První tap je vždy bezpečný a otevře prázdnou oblast. Ťuk na číslo se správným počtem vlajek kolem odkryje sousedy (chording). Na Lehké a Střední se desky generují **bez nutnosti hádat** (ověří řešič; max. 300 ms, jinak běžná deska).

**Režim „Střídačka“ (2–4 hráči):** hráči se střídají v odkrývání jednoho pole (vlajky může dát kdokoli kdykoli). Kdo odkryje minu, vypadává (mina se označí, hra pokračuje). Body za odkrytá pole; vyhrává poslední, kdo zůstal, nebo při vyčištění desky ten s nejvíce odkrytými poli. AI v tomto režimu: Lehká odkrývá jen jistá pole, když je snadno vidí, jinak náhodně; Těžká používá řešič + pravděpodobnost.

**UI:** neodkrytá pole = dřevěné dlaždice, odkrytá = papír; čísla 1–8 v dostupné paletě (a odlišitelná i tvarem/tloušťkou). Mina je kreslená, ne strašidelná; výbuch = obláček kouře „puf“. Na Těžké pinch-zoom. Haptika při vlajce.

**Hodnocení:** výhra ★, pod cílovým časem ★★ (Lehká 60 s / Střední 180 s / Těžká 480 s), pod polovinou cílového času ★★★. Osobní rekordy časů pro každou obtížnost → žebříček.

**Odznaky:** `minesweeper.defuser` Odminovač (výhra na Těžkou) · `minesweeper.noflag` Bez vlajek · `minesweeper.blitz` Blesk (Lehká pod 20 s) · `minesweeper.sapper` Sapér (25 výher).

**Zvuky:** `minesweeper.dig`, `minesweeper.flag`, `minesweeper.puff`. **Hudba:** `music/minesweeper.ogg`.

---

### 13.8 Člověče, nezlob se (`ludo`)
| | |
|---|---|
| Hráči | 2–4 účastníci, z toho 1–4 lidé, zbytek AI (s 1 člověkem vždy min. 1 AI) |
| Volby | **Délka:** plná (4 figurky) / krátká (2 figurky); **Povinné vyhazování:** zap/vyp; **3 pokusy na nasazení:** zap/vyp; **Dohrát pořadí:** zap/vyp |
| Orientace | tablet: na šířku (deska uprostřed, hráči a kostka po stranách); telefon: na výšku (deska nahoře, kostka dole) |

**Pravidla (česká klasika):** okruh 40 polí, 4 domečky. Nasazení figurky jen při hodu 6. Když hráč nemá figurku na desce, má 3 pokusy hodit 6. Šestka = hod navíc. Doskok na soupeřovu figurku ji vyhodí zpět na start. Na vlastní figurku stoupnout nelze. Do domečku se musí vejít přesným hodem, figurky se v něm nepřeskakují. Pokud lze táhnout, táhnout se musí. Vyhrává, kdo má první všechny figurky v domečku. S volbou „Dohrát pořadí“ se pokračuje do určení 2. a 3. místa; tlačítko „Ukončit a seřadit podle postupu“ je k dispozici vždy.

**UI:** kříž z dřevěných polí na plsti, startovní a domácí pole v barvách hráčů s mini avatarem. Hod: tap na kostku (game kit `Dice`), volitelně zatřesení telefonem. Figurky, kterými lze táhnout, pulzují; tap → figurka „hopsá“ pole po poli. Vyhození: figurka odletí domů s „boing“. Při jediném možném tahu se táhne automaticky (lze vypnout).

**AI:** Lehká: náhodný legální tah; Střední: priority (vyhodit → nasadit → do domečku → utéct z ohrožení → postoupit nejzadnější); Těžká: hodnoticí funkce (ohrožení v dosahu 1–6 polí, bezpečnost, postup) + expectimax 1 hod dopředu.

**Hodnocení:** 1. místo ★★★, 2. ★★, 3. ★.

**Odznaky:** `ludo.calm` Nezlobím se (výhra, přestože mě vyhodili ≥ 3×) · `ludo.hunter` Lovec (5 vyhození v jedné hře) · `ludo.sixes` Tři šestky v řadě · `ludo.family` Rodinná hra (dohraná hra se 4 lidskými hráči).

**Zvuky:** `dice_roll`, `ludo.hop`, `ludo.boing`, `ludo.home`. **Hudba:** `music/ludo.ogg`. Hra bývá dlouhá → ukládání po každém tahu.

---

### 13.9 Dáma (`checkers`)
| | |
|---|---|
| Hráči | 1–2 (1 = proti AI), hot-seat |
| Volby | **Pravidla:** Česká dáma 8×8 (výchozí) / Mezinárodní 10×10; **Zpět tah:** zap/vyp (jen proti AI na Lehké a Střední, max. 3× za hru); **Nápověda povinného braní:** zap/vyp |
| Orientace | telefon: na výšku; tablet: libovolná. Při hře dvou lidí na tabletu volba „otáčet desku“ |

**Pravidla – Česká dáma:** 8×8, hraje se na tmavých polích, 12 kamenů na hráče. Kámen táhne i bere jen šikmo vpřed. Braní je povinné, vícenásobné braní se dokončí celé. Kámen, který skončí na poslední řadě, se mění v dámu. Dáma táhne a bere na libovolnou vzdálenost (létající dáma). Lze-li brát dámou i kamenem, má přednost braní dámou.

**Pravidla – Mezinárodní dáma:** 10×10, 20 kamenů. Kameny berou i vzad. Povinné je braní největšího počtu kamenů. Létající dámy. Proměna jen tehdy, když kámen na poslední řadě tah ukončí.

**Remíza:** nabídka a přijetí, trojí opakování pozice, 25 tahů každého hráče jen dámami bez braní.

> Pravidla ověř proti oficiálním pravidlům (Česká federace dámy, FMJD) a pokryj testy na známých pozicích (povinné braní, přednost dámy, maximální braní, proměna během braní).

**UI:** dřevěná deska, kameny jako žetony v barvách hráčů 1 a 2 (dáma = korunka na kameni). Tap na kámen → zvýrazní legální cíle; povinné braní pulzuje. Vícenásobné braní se animuje skok po skoku, sebrané kameny odletí k soupeřovu avataru. Počítadlo kamenů v HUD.

**AI:** `GameSearch` (alpha-beta, iterativní prohlubování, řazení tahů, transpoziční tabulka) v izolátu. Lehká: hloubka 2 + 25 % náhodný tah; Střední: hloubka 5 / 600 ms; Těžká: hloubka 8+ / 1,5 s. Hodnocení: materiál (dáma = 3 kameny), postup, centrum, bezpečné kameny, mobilita.

**Hodnocení:** výhra s ≥ 6 vlastními kameny ★★★, výhra ★★, remíza ★.

**Odznaky:** `checkers.queen` Dámou! (první proměna) · `checkers.combo` Kombinátor (3+ kameny jedním tahem) · `checkers.grandmaster` Velmistr (výhra na Těžkou) · `checkers.international` Světák (výhra na mezinárodní desce).

**Zvuky:** `piece_place`, `checkers.capture`, `checkers.crown`. **Hudba:** `music/checkers.ogg`.

## 14. Fáze 3 – hra na více zařízeních přes domácí Wi-Fi

### 14.1 Cíl
Hráči mohou zvolit, že **každý táhne na svém zařízení**. Zařízení musí být ve stejné Wi-Fi síti (domácí router, nebo hotspot z jednoho z telefonů). Internet není potřeba, nic se neposílá mimo místní síť. Funguje pro všech 5 her.

Kombinace jsou možné: např. 2 hráči na tabletu (předávají si ho) + 1 hráč na svém mobilu + 1 robot.

### 14.2 Průběh pro uživatele
1. Na obrazovce nastavení hry zvolím **Kde se hraje → Každý na svém (Wi-Fi)**.
2. Moje zařízení se stane **hostitelem** a otevře **místnost**: velký QR kód + 4místný kód místnosti + seznam míst (sloty 1–4).
3. Ostatní na svém zařízení zvolí na hlavní stránce **Připojit se ke hře** → aplikace sama najde místnosti v síti (seznam s avatarem hostitele a názvem hry), nebo naskenují QR / zadají kód.
4. Připojený hráč si vybere **svůj profil na svém zařízení**; jeho jméno a avatar (včetně vylepšení) se objeví ve slotu u hostitele.
5. Hostitel může do zbylých slotů přidat lidi ze svého zařízení nebo roboty; nastavuje obtížnost a volby hry. Ostatní vidí nastavení jen pro čtení.
6. Až jsou všichni „Připraveni“, hostitel spustí hru.
7. Během hry vidí všichni stejnou desku. **Zařízení hráče na tahu zavibruje a cinkne** a zobrazí „Jsi na tahu!“; ostatní vidí „Na tahu: Kuba (na svém telefonu)“. Kdo není na tahu, nemůže hrát.
8. Výsledky se ukážou na všech zařízeních současně; každý si může zvolit **Odveta** (stejná místnost, stejní hráči).

### 14.3 Technické řešení
- **Architektura hostitel–klient:** hostitel je jediný zdroj pravdy. Drží stav hry, ověřuje tahy (`legalMoves`), počítá tahy robotů a rozesílá výsledky.
- **Spojení:** WebSocket (TCP) server na hostiteli na volném portu. **Vyhledání:** mDNS/DNS-SD (Android NSD, služba `_deskovky._tcp`) s TXT záznamem (název hry, hostitel, verze protokolu, počet volných míst). **QR kód** obsahuje `ip:port`, kód místnosti a token. Záloha: ruční zadání IP:port v pokročilém nastavení.
- **Protokol** (JSON zprávy, `protocolVersion`):
  `hello` (profil: jméno, avatar JSON, verze aplikace) → `lobby_state` (sloty, nastavení) → `ready` → `start` (config, seed, počáteční stav) → `move_request` (klient → hostitel) → `move_applied` (pořadové číslo, tah, `stateHash`) → `turn` → `pause`/`resume` → `game_over` (`GameResult`) → `bye`.
  Plus `ping`/`pong` každé 3 s a volitelně `emote` (rychlé reakce 👍😮😂 nad avatarem).
- **Synchronizace:** klient aplikuje `move_applied` lokálně a porovná `stateHash`. Při nesouladu si vyžádá `state_snapshot` a pokračuje z něj.
- **Náhoda** (kostka, míchání karet, rozložení min) se počítá jen na hostiteli ze seedu. Hod kostkou na zařízení hráče = `move_request: roll`, hostitel pošle výsledek a všichni vidí stejnou animaci.
- **Verze:** jiná `protocolVersion` → připojení se odmítne s hláškou „Aktualizujte aplikaci na všech zařízeních na stejnou verzi“ (a nabídkou kontroly aktualizace).
- **Bezpečnost:** jen místní síť, token místnosti z QR/kódu, hostitel může hráče odebrat. Žádné osobní údaje kromě jména a avatara.
- Vše síťové je v `core/multiplayer` (`NetworkTransport` implementuje `MoveTransport` z kap. 8). **Hry se v této fázi nemění** – pokud nějaká hra potřebuje úpravu, je to chyba v dodržení kap. 8.

### 14.4 Výpadky a pauzy
- Klient ztratí spojení → hra se pozastaví u všech, u avatara se zobrazí „Odpojeno – čekám (0:30)“. Po návratu (stejný token) se hráč vrátí na své místo a dostane aktuální stav.
- Po 30 s hostitel volí: **Čekat dál** / **Nahradit robotem** / **Ukončit hru**. Pokud se hráč vrátí, může své místo převzít od robota zpět.
- Odejde-li hostitel (zavře aplikaci, ztratí Wi-Fi), hra se uloží na hostiteli a klientům se zobrazí „Hostitel se odpojil“. Po návratu hostitele lze partii obnovit, pokud se připojí stejní hráči.
- Pauzu může dát kdokoli, ukončit hru pro všechny jen hostitel. Klient může odejít sám – jeho místo převezme robot.
- Aplikace na pozadí (telefonát) = dočasné odpojení podle pravidel výše.

### 14.5 Body, statistiky, profily
- Každé zařízení ukládá body, odznaky a statistiky **jen svým vlastním profilům** (podle `GameResult`, který rozešle hostitel). Body se nepřenášejí mezi zařízeními.
- Hráči z jiných zařízení se v historii partií uloží jako **hosté** (snímek jména a avataru), v místních žebříčcích nejsou.
- Pravidlo proti farmení (5.6) se počítá zvlášť pro každý profil na jeho zařízení; síťová hra s 2+ lidmi se počítá jako hra více lidí.

### 14.6 UI navíc
- Hlavní stránka: tlačítko **Připojit se ke hře** (Wi-Fi ikona).
- Obrazovka **Místnost** (hostitel i klient): QR kód, kód místnosti, sloty s indikací 📱 „na svém zařízení“ / 🏠 „na tomto zařízení“ / 🤖 robot, stav Připraven, kvalita spojení (zelená/žlutá/červená tečka).
- HUD: u vzdálených hráčů malá ikona telefonu a tečka spojení.
- Bez Wi-Fi: volba „Každý na svém“ je neaktivní s vysvětlením „Připoj všechna zařízení ke stejné Wi-Fi (nebo k hotspotu jednoho z telefonů)“.

### 14.7 Testování
- `LoopbackTransport` v testech: 2–4 virtuální klienti v jednom procesu odehrají partii každé hry, včetně simulace zpoždění (0–500 ms), ztráty spojení a obnovení.
- Test nesouladu: úmyslně poškozený stav klienta se opraví přes `state_snapshot`.
- Ruční test: 2 emulátory + 1 skutečné zařízení ve stejné síti; tablet jako hostitel i jako klient.

### 14.8 Milníky fáze 3
1. `core/multiplayer`: server, klient, protokol, `NetworkTransport`, testy s loopbackem.
2. Vyhledání v síti (NSD), QR kód (zobrazení + sken), ruční zadání.
3. Obrazovka Místnost, výběr profilu na klientu, sloty, Připraven, start.
4. Hra přes síť pro **Pexeso** (referenční) – tahy, synchronizace, výsledky, body na každém zařízení.
5. Výpadky, obnovení, nahrazení robotem, odejití hostitele.
6. Ověření zbylých 4 her (lze **paralelně** po hrách – jen testy a případné opravy ve složce hry, pravidla 13.2).
7. Emotes, indikace spojení, doladění UI.

### 14.9 Akceptační kritéria fáze 3
- [ ] Na 2–4 zařízeních ve stejné Wi-Fi jde odehrát každou z 5 her; tahy se zobrazí na všech zařízeních do 300 ms.
- [ ] Funguje kombinace: lidé na hostiteli + lidé na vlastních zařízeních + roboti.
- [ ] Hra funguje i přes hotspot z telefonu, bez připojení k internetu.
- [ ] Zařízení hráče na tahu zavibruje; ostatní nemohou táhnout.
- [ ] Odpojení a návrat do 30 s pokračuje bez ztráty; po 30 s jde hráče nahradit robotem.
- [ ] Body a odznaky se připíšou každému hráči na jeho vlastním zařízení.
- [ ] Různé verze aplikace se odmítnou se srozumitelnou hláškou.
- [ ] Hry z fáze 2 nebylo nutné kvůli síťové hře měnit (kromě drobných oprav dodržení kap. 8).

## 15. Otevřené body pro Miloše
- Pro fázi 2: kolik paralelních session spustit najednou (doporučeno 5, nebo 2–3, pokud chceš hry průběžně testovat).
- GitHub `OWNER/REPO` a zda bude repozitář veřejný (nutné pro kontrolu aktualizací bez tokenu; alternativně veřejný repozitář jen pro releasy).
- Výběr konkrétních skladeb (tabulka 7.2) a jejich stažení do `assets/audio/music/`.
- Název aplikace a ikona (pracovně „Deskovky“) – v angličtině/španělštině ponechat stejný název, nebo lokalizovat?
- Překlady do španělštiny: Claude Code připraví návrh, doporučeno nechat zkontrolovat rodilým mluvčím.
- Ceny a bodové hodnoty v `rewards.json` / `shop_items.json` doladit po prvním týdnu hraní.
