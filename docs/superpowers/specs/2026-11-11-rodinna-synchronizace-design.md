# Rodinná synchronizace profilů – zadání

> Stav: **návrh ke schválení** (Miloš). Vývoj začne až po schválení; pak z něj vznikne implementační plán (`docs/superpowers/plans/`).
> Navazuje na `docs/ZADANI-deskovky.md` (kap. 5 profily, body, obchod, odznaky, statistiky; kap. 14 síťová hra) a na síťovou vrstvu z fáze 3 (`lib/core/multiplayer/`).

## 1. Proč

Rodina hraje na více zařízeních, která se střídají: někdy ve více lidech na tabletu, jindy každý na svém mobilu přes Wi-Fi. Dcera Viky má profil na všech zařízeních, ale na každém je to jiný profil s jinými body, odměnami a vzhledem. Děti to mate: na tabletu si koupí klobouk, na mobilu ho nemají, body „zmizí“ a žebříčky se liší.

**Cíl:** každý člen rodiny má **jeden profil, který je stejný na všech rodinných zařízeních** – body, odměny, odznaky, vzhled avatara, historie her i žebříčky. Bez internetu, jen přes domácí Wi-Fi.

## 2. Co rozhodl Miloš

- Synchronizace **jen přes domácí Wi-Fi**, bez internetu, bez účtů a bez cloudu (stejný princip jako síťová hra).
- Synchronizuje se **celý profil**: body, koupené odměny, odznaky a vzhled avatara.
- Sdílí se i **historie her a žebříčky** celé rodiny.
- **Všechny profily rodiny jsou na všech rodinných zařízeních** (i babička vytvořená jen na tabletu).
- Stávající zdvojené profily (Viky na tabletu i na mobilu) se **jednou spárují a sečtou**.
- **Nové zařízení se do rodiny přidá naskenováním QR kódu.**
- Rodinné profily má jít využít k **jednoduššímu pozvání do síťové hry**.

## 3. Moje návrhy (k odsouhlasení při čtení)

- Rodinný QR kód ukazuje **Rodičovská zóna** (je chráněná rodičovskou otázkou). Dítě tak do rodiny nepřidá telefon kamaráda.
- Telefony kamarádů na návštěvě zůstávají **mimo rodinu**: hrají síťovou hru přes kód místnosti jako dnes. Nic z rodiny se jim neposílá a jejich hráči jsou u nás hosté.
- V Rodičovské zóně jde zařízení **z rodiny odebrat** (prodaný nebo ztracený telefon); ostatní mu pak nic nepošlou.
- **Nesdílí se nastavení zařízení**: hudba, efekty, hlasitost, vibrace, jazyk, automatická kontrola aktualizací, kdo je na zařízení přihlášený (aktivní hráč), rozehrané uložené partie a poslední nastavení her.
- **Body se slučují po jednotlivých zápisech**, ne jako zůstatek. Nikdy se tak neztratí ani nezdvojí, i když dítě hraje na dvou zařízeních zároveň bez spojení.
- U **jména a vzhledu avatara platí poslední změna**.
- Koupí-li si dítě **stejnou věc na dvou zařízeních** (než se spojila), zůstane jedna a **body za druhou se vrátí** zápisem „vráceno – koupeno dvakrát“.
- Kdyby nákupy na dvou zařízeních dohromady přesáhly body dítěte, **pozdější nákup se zruší** a body se vrátí (rozhodl Miloš, viz kap. 6).
- **Síťová partie se v historii zapíše jen jednou** se všemi hráči. Body a odznaky za ni dál zapisuje každé zařízení jen svým hráčům, jak je tomu dnes.

## 4. Cíle, ne-cíle a anti-cíle

**Cíle**
- Po setkání na Wi-Fi mají všechna rodinná zařízení stejné profily, zůstatky, odměny, odznaky, úrovně, historii a žebříčky, a to bez jakéhokoli klepnutí.
- Synchronizace probíhá sama, když jsou zařízení spolu na domácí Wi-Fi a aplikace je otevřená. Při síťové hře se synchronizuje automaticky.
- Zařízení může být libovolně dlouho offline. Po návratu se doplní, co se mezitím stalo na obou stranách.
- Nové zařízení: naskenovat QR kód, počkat chvilku a má celou rodinu.

**Ne-cíle (teď ne)**
- Záloha mimo dům, internet, cloud, účty.
- Synchronizace mimo domácí Wi-Fi (Bluetooth apod.).
- Synchronizace nastavení zařízení a rozehraných partií.
- Řešení současných úprav vlastními dialogy (stačí „poslední změna platí“).

**Anti-cíle (selhání, i kdyby to technicky fungovalo)**
- **Body se ztratí nebo zdvojí**, odznak zmizí, koupená věc zmizí bez náhrady.
- Data rodiny **odejdou na cizí zařízení** (kamarád ve stejné Wi-Fi).
- **Smazaný profil se „vrátí“** ze zařízení, které bylo dlouho offline.
- Dítě musí něco nastavovat nebo potvrzovat, aby synchronizace fungovala.
- Hraní se zpomalí nebo zasekne kvůli synchronizaci (běží na pozadí).

## 5. Jak to bude fungovat pro uživatele

### 5.1 Založení rodiny a přidání zařízení
1. Rodič otevře na tabletu **Nastavení → Rodičovská zóna → Rodina** (nová sekce). Napoprvé se tím rodina založí z dat tohoto zařízení.
2. Klepne na **Přidat zařízení**. Zobrazí se **rodinný QR kód**.
3. Na novém telefonu zvolí **Nastavení → Připojit se k rodině** (také za rodičovskou otázkou) a naskenuje kód. *(Varianta: rodinný QR kód naskenovaný skenerem „Připojit se ke hře“ to rozpozná a nabídne totéž.)*
4. Telefon se připojí k tabletu, stáhne všechny profily, historii a body a ukáže „Hotovo – jsi v rodině“.
5. Měl-li telefon vlastní profily, následuje **spárování profilů** (5.2).

Sekce Rodina dál ukazuje **seznam rodinných zařízení** (název, kdy byla naposledy vidět) a u každého **Odebrat z rodiny**.

### 5.2 Spárování profilů
- Po připojení zařízení s vlastními profily (a kdykoli z Rodičovské zóny) aplikace nabídne dvojice **se stejným jménem**: „Viky (tento telefon) + Viky (rodina) – je to stejná osoba?“. Rodič potvrdí, nebo odmítne.
- Rodič může ručně spárovat i profily s různým jménem (např. „Viki“ a „Viky“).
- **Po spojení** má profil:
  - všechny body z obou stran (zůstatek je součet),
  - všechny koupené věci (duplicitní nákup = jedna věc a vrácené body),
  - všechny odznaky (s nejstarším datem získání),
  - součty počítadel pro odznaky,
  - celou historii her.
  - Jméno, vzhled a oblíbenou barvu přebírá z novější úpravy; rodič může vybrat ručně. *(Můj návrh.)*
- Odmítnutá dvojice se stejným jménem: jeden profil se přejmenuje na „Viky 2“, protože jména musí být v rodině jedinečná.
- Profily bez dvojice se prostě přidají do rodiny.

### 5.3 Každodenní použití
- Nic se nemusí dělat. Když jsou rodinná zařízení spolu na Wi-Fi a aplikace je na nich otevřená, do pár sekund se vymění, co je nového.
- Drobná ikona v horní liště ukáže, že synchronizace proběhla *(můj návrh: ikona se šipkami na 2 s; žádná hláška, která by děti rušila)*.
- Rodičovská zóna → Rodina ukazuje u každého zařízení „naposledy synchronizováno“.

### 5.4 Pozvání do síťové hry
- V místnosti hostitele je u každého volného místa nabídka **„Pozvat z rodiny“**: seznam profilů rodiny.
- Klepnutí na „Viky“ pošle pozvánku na rodinné zařízení, kde je Viky právě aktivní hráč. Když takové zařízení není, pošle ji všem rodinným zařízením na Wi-Fi.
- Na zařízení vyskočí: **„Táta tě zve do Pexesa – hrát?“** → **Hrát** / **Teď ne**.
- Po „Hrát“ se zařízení připojí do místnosti s profilem Viky, bez kódu a bez výběru profilu. Je rovnou „Připraven“ *(můj návrh)*.
- Pozvánka platí 60 s a zmizí, když hra začne nebo místnost skončí.
- Připojení přes kód a QR kód místnosti zůstává pro kamarády.

## 6. Pravidla slučování dat

Každý záznam dostane **globální identitu** platnou na všech zařízeních. Zařízení si vyměňují **změny** a každé si z nich samo sestaví stejný výsledek. Výsledek nesmí záviset na pořadí, ve kterém změny dorazí.

| Data | Jak se slučují |
|---|---|
| Profil (jméno, avatar, oblíbená barva) | poslední změna platí (časové razítko + id zařízení pro shodu) |
| Smazání profilu | trvalý „náhrobek“: smazaný profil se už nikdy neobnoví. **Smazání má přednost** i před body a partiemi, které mu jiné zařízení mezitím zapsalo offline; zahodí se jako dnes při smazání. Platí i pro profil, do kterého byl jiný spojen. Historie ukazuje smazaného jako „smazaný hráč“, jako dnes. *(Můj návrh.)* |
| Spojení profilů (5.2) | záznam „B je teď A“. Všechny záznamy B (i ty, které dorazí později) patří A. |
| Zápisy bodů | sjednocení všech zápisů; zůstatek, celkem získané a úroveň se počítají ze zápisů |
| Koupené věci | sjednocení. Duplicitní nákup téže věci → jedna věc + zápis bodů „vráceno – koupeno dvakrát“, vytvořený deterministicky jen jednou. |
| Utracení víc bodů, než dítě mělo (nákupy na dvou zařízeních offline) | **rozhodl Miloš: pozdější nákup se zruší.** Když po sloučení klesne zůstatek pod 0, ruší se nákupy od nejpozdějšího (čas nákupu, při shodě id), dokud zůstatek není ≥ 0. Zrušená věc zmizí a body se vrátí zápisem „vráceno – nedostatek bodů“. Rozhodnutí musí vyjít stejně na všech zařízeních bez ohledu na pořadí synchronizace. Dítěti to aplikace vysvětlí jednou hláškou při jeho příštím přihlášení: „Brýle se vrátily – na obě věci nebylo dost bodů.“ *(Text hlášky je můj návrh.)* |
| Vynulování (Rodičovská zóna) | zápis „vynulováno“: odebere věci a body, **které resetující zařízení v tu chvíli znalo** (pevná částka a seznam věcí v zápisu, ne podle času – hodiny zařízení se mohou lišit). Body a věci, které dorazí později z jiného zařízení, zůstanou. Úroveň, odznaky a historie zůstávají (jako dnes). *(Můj návrh.)* |
| Odznaky | sjednocení; datum = nejstarší. **Odměna (body) za odznak má pevnou identitu (profil + odznak)**, takže se vyplatí jen jednou, i když dítě odznak získá na dvou zařízeních (dnes např. „Sběratel“ +30). Totéž u odznaku uděleného po synchronizaci. *(Můj návrh.)* |
| Počítadla pro odznaky | každé zařízení vede svůj díl, celkem = součet dílů |
| Partie (historie) | sjednocení. Síťová partie má jednu identitu od hostitele (7.3). |
| Stejné jméno vzniklé na dvou zařízeních offline | nikdy se tiše nespojí (mohou to být dvě osoby). Druhý profil (deterministicky) dostane jméno „Babička 2“ a Rodičovská zóna nabídne spárování (5.2). *(Můj návrh.)* |
| Nasazené vylepšení avatara | součást vzhledu avatara (poslední změna) |

**Odznaky po synchronizaci:** když součet počítadel nebo historie po sloučení splní podmínku odznaku, který profil ještě nemá, zařízení ho udělí. Kvůli shodě má odznak deterministickou identitu (profil + odznak), takže se neudělí dvakrát. *(Můj návrh: oslavu odznaku ukázat jen na zařízení, kde je dítě aktivní.)*

## 7. Technické řešení (rámec, detaily na staviteli)

### 7.1 Identity a rodina
- **Zařízení:** náhodné id (UUID) vytvořené při prvním spuštění nové verze, název zařízení (výchozí model, šlo by přejmenovat).
- **Rodina:** id rodiny a **tajný klíč rodiny** (náhodný, ≥ 128 bitů). Rodinný QR kód obsahuje id rodiny, klíč a adresu zařízení, které ho ukazuje (IP, port). Přenáší se jen v QR kódu, nikdy po síti.
- Profily, partie, zápisy bodů a další záznamy dostanou globální id (UUID). Současná místní čísla zůstanou jako interní klíče databáze.

### 7.2 Synchronizace
- **Vyhledání:** rodinná zařízení se oznamují v síti podobně jako místnosti (UDP). Oznámení obsahuje jen otisk id rodiny a id zařízení, žádná data profilů.
- **Spojení:** WebSocket jako u síťové hry. Obě strany se ověří výzvou a odpovědí s tajným klíčem rodiny (HMAC). Klíč se po síti neposílá. Cizí zařízení se nespojí.
- **Výměna:** každé zařízení vede **záznam změn** s pořadovým číslem. Strany si vymění, co od koho už mají (u každého zařízení nejvyšší číslo), a pošlou si jen chybějící změny. Výměna je idempotentní: stejná změna dvakrát nic nezmění.
- **Kdy:** při spuštění a návratu do aplikace, po každé dohrané partii, nákupu a úpravě profilu (pokud je partner v síti), periodicky během otevřené aplikace (*můj návrh: oznámení každých ~10 s, výměna jen když je co poslat*) a vždy kolem síťové hry. Neběží během partie, kdy by mohla zpomalit hru (*můj návrh*; síťová hra má přednost).
- **Verze:** synchronizace má vlastní číslo verze protokolu. Zařízení s jinou verzí se nespojí a Rodičovská zóna ukáže „Aktualizujte aplikaci na všech zařízeních“.
- **Odebrání zařízení:** id odebraného zařízení se zapíše do rodinného seznamu odebraných (synchronizuje se jako ostatní změny) a rodinná zařízení s ním spojení odmítnou. Klíč rodiny se nemění, takže zařízení, které bylo zrovna offline, nemusí nic znovu skenovat. Data, která na odebraném zařízení zůstala, zůstanou, ale nic nového nedostane. (Domácí hrozba je nízká; plná výměna klíče by vyžadovala znovu skenovat QR na všech zařízeních.) *(Můj návrh.)*
- **Zařízení z jiné rodiny:** připojení k nové rodině znamená opuštění staré (s varováním). Profily na zařízení se nabídnou ke spárování s novou rodinou; slučování dvou celých rodin není. *(Můj návrh.)*

### 7.3 Síťová hra
- Hostitel přidělí každé partii **globální id** (místnost + pořadí partie). Pošle ho ve zprávě `Start` spolu s globálními id rodinných profilů u míst.
- Každé zařízení zapíše partii pod tímto id. Při synchronizaci se záznamy sloučí do jedné partie se všemi hráči. Hosté mimo rodinu zůstanou hosté.
- Body a odznaky dál zapisuje každé zařízení jen svým hráčům (beze změny). Synchronizace je pak rozdá ostatním.
- **Pozvánka** (5.4) jde přes rodinné spojení. Obsahuje odkaz na místnost (`JoinTicket`) a profil. Přijetí použije existující připojení do místnosti s tímto profilem.

### 7.4 Převod existujících dat
- Při aktualizaci (nová verze schématu databáze) dostanou všechny existující záznamy globální id a vznikne id zařízení. Body, odměny, odznaky a historie se nesmí změnit.
- Bez rodiny se aplikace chová přesně jako dnes.

## 8. Omezení
- Žádné nové balíčky, pokud nejsou nezbytné. HMAC je v balíčku `crypto`, který už používáme. Skener QR kódu (`mobile_scanner`) a QR kód (`qr_flutter`) už máme.
- Vše v rámci domácí sítě; žádné připojení mimo ni.
- Texty v CS/EN/ES; obrazovky na 360 dp při 130 % bez přetečení.
- Síťová hra a hraní na jednom zařízení se nesmí zhoršit.
- Výkon: první synchronizace celé historie (stovky partií) do ~10 s; běžná výměna nepostřehnutelná.

## 9. Ověření
- Testy slučování: 2–4 virtuální zařízení přes loopback, náhodné pořadí a zdvojení zpráv, výpadky. Všechna zařízení skončí se stejným stavem a zůstatky se rovnají součtu zápisů.
- Testy spárování profilů včetně duplicitního nákupu, smazaného profilu a profilu spojeného na jednom zařízení, zatímco jiné zařízení dál zapisuje body „starému“ profilu.
- Test, že cizí zařízení bez klíče se nespojí a nic nedostane.
- Test převodu databáze ze stávající verze beze ztráty dat.
- Ruční test u Miloše: tablet a dva mobily, přidání přes QR kód, spárování Viky, hraní offline na dvou zařízeních a pak setkání, pozvánka do síťové hry.

## 10. Návrh postupu (pro plán)
1. Datový model a převod databáze (globální id, záznam změn, rodina) + čisté slučování s testy.
2. Rodina: QR kód, připojení zařízení, ověření klíčem, výměna změn přes Wi-Fi, odebrání zařízení.
3. Spárování profilů (UI v Rodičovské zóně, duplicitní nákupy).
4. Síťová hra: společné id partie, pozvánky z rodiny.
5. Ověření, revize, vydání.
