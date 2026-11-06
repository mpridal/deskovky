# Sirky (`matches`) – zadání hry

> Stav: **návrh ke schválení** (Miloš). Vývoj začne až po schválení; pak z něj vznikne implementační plán (`docs/superpowers/plans/`).
> Navazuje na hlavní zadání `docs/ZADANI-deskovky.md`: kap. 13.4 (společná osnova každé hry a Definition of Done), kap. 8 (architektura her), kap. 14 (hra přes Wi-Fi) a `docs/GAME_MODULE_GUIDE.md`.

## 1. Proč a co

Sirky jsou rychlá logická hra pro dva: na stole leží sirky ve třech řadách, hráči je střídavě odebírají a prohrává ten, na koho zbude poslední sirka. Partie trvá 1–2 minuty, pravidla pochopí i malé dítě, a přitom má hra skutečnou strategii, kterou se dá postupně naučit. Do portfolia přináší krátkou „přemýšlivou“ hru pro dva.

**Rozhodl Miloš:**
- Hra se přidá k ostatním hrám a má **stejný design a stejné možnosti**: lidé i roboti, hra na jednom telefonu (předávání) i **každý na svém přes Wi-Fi**.
- **Pravidla** (viz kap. 2): 3 řady se 3, 5 a 7 sirkami; v tahu se bere libovolný počet (min. 1) z jediné řady; hráči se střídají; **prohrává ten, kdo vezme poslední sirku**.
- **Robot „Těžká“ hraje dokonale** – je v pořádku, že vždy vyhraje, když to jde (kdo začíná a zná systém, vyhraje). **Nižší úrovně dělají chyby**, aby živý hráč měl šanci vyhrát.
- **Vlastní hudba**, stylem zapadající mezi ostatní hry.

**Cíle:** krátká partie, čitelný stůl se sirkami na telefonu i tabletu, ovládání pro děti bez nedorozumění (je jasné, co beru), robot na Lehkou porazitelný sedmiletým dítětem, Těžká jako „mistr“, kterého porazí jen ten, kdo strategii pochopí.

**Mimo rozsah:** jiné varianty (kdo vezme poslední, vyhrává; jiný počet řad) – jen jako možné rozšíření v kap. 12. Žádné nové balíčky.

**Anti-cíle (selhání, i kdyby to technicky fungovalo):** dítě omylem vezme jiný počet sirek, než chtělo (proto výběr + potvrzení); robot na Lehkou, kterého dítě nedokáže porazit; robot na Těžkou, který zbytečně chybuje.

## 2. Pravidla

- Na začátku: **horní řada 3 sirky, prostřední 5, spodní 7** (celkem 15).
- Hráči se střídají. V tahu hráč vezme **libovolný počet sirek (alespoň 1) z jediné řady**. Z různých řad v jednom tahu brát nelze.
- **Kdo vezme poslední sirku, prohrává** (druhý vyhrává). Remíza neexistuje.
- Kdo začíná, určuje volba „Začíná“ (kap. 4).

*Poznámka pro implementaci (bez dopadu na pravidla):* jde o hru Nim v „misère“ variantě. Výchozí pozice 3-5-7 je pro začínajícího vyhraná (nim-součet 3⊕5⊕7 = 1 ≠ 0, přitom některá řada má více než 1 sirku).

## 3. Manifest

| | |
|---|---|
| Id / klíče textů | `matches` / `matches.*` |
| Název | cs „Sirky“, en „Matches“, es „Cerillas“ |
| Hráči | **přesně 2** (`minPlayers = maxPlayers = 2`); každé místo člověk nebo robot – stejně jako Piškvorky (1 člověk proti robotovi, 2 lidé, 2 roboti v ukázce) |
| Obtížnosti | Lehká, Střední, Těžká (jen když hraje robot; `difficultyWithoutRobots = false`) |
| Orientace | libovolná na telefonu i tabletu |
| Uložení / obnovení | ano (`supportsSaveResume = true`) |
| Síť | ano, automaticky (`supportsNetwork` výchozí `true`; `playableOnNetwork` platí, protože jde o 2 hráče) |
| Bodový násobič | **0,8** – partie je krátká (*můj návrh*; Člověče má 1,2, ostatní 1,0) |
| Hudba | `music/matches.ogg` (kap. 9) |
| Vlastní zvuky | max. 3 (kap. 9) |
| Pořadí na hlavní stránce | za Člověče, před Dámou (*můj návrh*) |

## 4. Volby hry

- **Začíná:** *Náhodně* (výchozí) / *Vždy hráč 1* – stejné hodnoty a texty jako u Piškvorek (`random` / `first`). Protože začínající hráč má výhodu, je výchozí náhodný začátek ze seedu. *(Můj návrh; „střídavě“ po partiích zatím ve frameworku není ani u Piškvorek.)*
- Žádné další volby v 1. verzi (*můj návrh*: rozložení je dané pravidly od Miloše).

## 5. Logika a tahy (kap. 8: tahy jako přenositelné zprávy)

- **Stav:** počty sirek v řadách `[3, 5, 7]`, kdo je na tahu, kdo začínal, seznam provedených odebrání (kvůli zvýraznění posledního tahu a statistikám), konec hry a poražený. Navíc pro hodnocení a odznaky: pro každé místo, zda bylo někdy ve vyhrávající pozici (kap. 7).
- **Tah:** `Move(seat, 'take', {row: 0..2, count: 1..n})`. Legální, když je hráč na tahu, řada existuje a `1 ≤ count ≤ zbývající v řadě`.
- **`legalMoves`:** všechny dvojice (řada, počet) – nejvýš 3 + 5 + 7 = 15 tahů.
- **Konec:** když po tahu nezbude žádná sirka; prohrál ten, kdo táhl. Výsledek: vítěz 1. místo, poražený 2. místo; **skóre: vítěz 1, poražený 0** (*můj návrh*). Počet vzatých sirek se jako skóre nepoužívá: framework by za „nejvyšší skóre“ vyplácel rekordní body i za prohranou partii, a v Sirkách víc vzatých sirek neznamená lepší hru. **`score()` (HUD) i `result.scores` dávají totéž** – během partie 0 oběma, po konci vítěz 1 –, aby hráč neviděl ve hře jiné číslo než ve výsledcích a statistikách (*můj návrh*). Kolik kdo vzal sirek, je vidět na jeho hromádce na stole.
- **Náhoda** jen ze seedu: kdo začíná (u volby Náhodně). Žádná jiná náhoda ve stavu není potřeba.
- Vše deterministické → replay, uložení i síť fungují bez úprav.

## 6. AI (robot)

Výpočet je okamžitý (nim-součet), přesto běží přes framework (`AiPlayer`, izolát) a s běžnou prodlevou robota.

- **Těžká – dokonalá hra (misère Nim):**
  - Když mají všechny neprázdné řady po 1 sirce: nechat soupeři lichý počet řad s 1 sirkou.
  - Když právě jedna řada má víc než 1 sirku: odebrat z ní tak, aby zbyl lichý počet řad po 1 sirce (tj. vzít celou řadu, nebo nechat 1).
  - Jinak: tah, po kterém je nim-součet 0.
  - Když je ve prohrané pozici (nemá vyhrávající tah): vezme **1 sirku z nejdelší řady** (prodlužuje hru a dává soupeři šanci chybovat).
  - → Když začíná, vždy vyhraje; když začíná člověk, vyhraje, kdykoli člověk udělá chybu.
- **Střední:** v každém tahu s pravděpodobností **60 %** dokonalý tah, jinak náhodný legální tah; v koncovce (zbývá ≤ 3 sirek) vždy dokonalý. *(Můj návrh.)*
- **Lehká:** s pravděpodobností **25 %** dokonalý tah, jinak náhodný legální tah; nikdy ale nevezme poslední sirku, pokud má jinou možnost (nesmí působit hloupě). *(Můj návrh.)*
- Náhoda AI jen z `SeededRandom` (ze seedu a počtu tahů), takže se partie dá přehrát.
- **Ověření (DoD):** Těžká porazí Lehkou ve ≥ 80 % partií při náhodném začátku; Těžká jako začínající vyhraje 100 % partií proti libovolnému soupeři; test, že Těžká z každé vyhrané pozice táhne do prohrané pozice soupeře (všechny pozice ≤ 3-5-7 se dají projít celé).

## 7. Hodnocení, statistiky a odznaky

**Hvězdy (0–3 ★) pro lidské hráče:**
- výhra: ★★★
- prohra, ale **soupeř mu aspoň jednou svým tahem nechal vyhrávající pozici** a on ji pustil (měl výhru na dosah): ★★. Výchozí pozice se nepočítá – jinak by každý začínající, který prohraje, dostal ★★ automaticky. „Vyhrávající pozice“ podle pravidel misère (ne prosté nim-součet ≠ 0: liší se, když mají všechny řady nejvýš 1 sirku). *(Můj návrh.)*
- jinak prohra: ★

**Statistiky:** framework (počet her, výhry, série, proti komu). Osobní rekord: **nejrychlejší výhra podle času**, kterou framework už umí (*můj návrh*; vlastní rekord „nejméně tahů“ by vyžadoval změnu frameworku).

**Odznaky (4):** *(všechny můj návrh – názvy i podmínky)*
- `matches.first` **První zápalka** – první výhra v Sirkách.
- `matches.master` **Mistr sirek** – výhra proti robotovi na Těžkou.
- `matches.flawless` **Bez zaváhání** – výhra, ve které každý tvůj tah nechal soupeře v prohrané pozici (platí bez ohledu na to, kdo začínal).
- `matches.collector` **Sirkař** – celkem 25 výher v Sirkách (počítadlo).

Události pro odznaky hlásí deska ze změny stavu (ne jen z vlastního klepnutí), aby se v síťové hře připsaly vítězi na jeho zařízení – viz `docs/GAME_MODULE_GUIDE.md`, „Síťová hra“.

## 8. UI

**Stůl:** plsť jako u ostatních her; tři řady sirek pod sebou, vycentrované (trojúhelník 3-5-7). Sirka = dřevěná tyčinka s červenou hlavičkou, kreslená kódem (bez obrázků). Sirky jsou svislé, dost velké na prst (cíl dotyku ≥ 48 dp i na telefonu 360 dp; když se 7 sirek nevejde vedle sebe, řada se zmenší rovnoměrně celá).

**Ovládání – výběr a potvrzení** (anti-cíl: omylem vzít jiný počet):
1. Klepnutí na sirku ji **vybere** (nadzvedne se a zazáří v barvě hráče). Další klepnutí na jinou sirku ve **stejné řadě** přidá ji do výběru; klepnutí na vybranou ji z výběru odebere.
2. Klepnutí na sirku v **jiné řadě** výběr přesune do té řady (začne znovu).
3. Pod stolem tlačítko **„Vzít (n)“** (n = počet vybraných); bez výběru je neaktivní. Teprve to provede tah.
4. Sirky ve výběru se berou v libovolném pořadí – v řadě jsou si rovné, záleží jen na počtu.

**Animace:** vzaté sirky odletí ke straně hráče, který je vzal (v jeho barvě) a vytvoří tam jeho hromádku; poslední tah zůstane jemně vidět (prázdná místa po sirkách krátce zablikají). Robot nejdřív viditelně „vybere“ sirky (~0,5 s), pak je vezme – dítě vidí, co udělal. Na konci **poslední sirka vzplane** (krátký plamínek) u poraženého, pak výsledky. S vypnutými animacemi vše okamžitě.

**HUD a bublina:** běžný HUD (hráči, skóre podle kap. 5: 0, po výhře 1). Nápověda v bublině: „{name}, vezmi sirky z jedné řady“; když zbývá jediná sirka: „{name}, zbyla poslední sirka…“ *(můj návrh)*.

**První hra profilu:** nenásilná nápověda „Klepni na sirky v jedné řadě a pak na Vzít“.

**Pravidla (z pauzy a z nastavení hry):** krátký text ve 3 jazycích + 3 ilustrované kroky kreslené kódem: (1) rozložení 3-5-7; (2) bereš z jedné řady kolik chceš; (3) kdo vezme poslední sirku, prohrává.

**Velikosti:** hratelné na 360×740, 412×915, 800×1280, 1280×800; otočení displeje nic nerozbije; golden testy ve 3 velikostech.

## 9. Zvuky a hudba

- **Hudba:** `music/matches.ogg`, Kevin MacLeod (incompetech.com), CC BY 4.0, OGG ~96 kb/s, −16 LUFS, jako ostatní. Nálada: **klidná, přemýšlivá, lehce hravá** (soustředění dvou hráčů). Kandidáti *(můj návrh)*: **„Easy Lemon“** (lehké piano), náhradník „Daily Beetle“. Zapsat do `assets/games/matches/CREDITS.json`. **Stažení skladby vyžaduje Milošův souhlas** (jako u ostatních skladeb).
- **Vlastní efekty (3):** `matches.pick` (cvaknutí při výběru), `matches.take` (dřevěné klapnutí při vzetí), `matches.strike` (škrtnutí a vzplanutí poslední sirky). Zatím zástupné zvuky ze skriptu `tool/generate_placeholder_audio.py`, jako u ostatních her.

## 10. Síťová hra

Bez zvláštní práce: tahy jsou zprávy, stav je deterministický, `playableOnNetwork` hru nabídne v „Kde se hraje“. Kontrakt her odehraje síťovou partii automaticky. Na desce platí pravidla z `GAME_MODULE_GUIDE.md`: zvuky, animace a události podle změny stavu (tahy přicházejí i z jiného zařízení); výběr sirek je jen na zařízení hráče na tahu, ostatní vidí až provedený tah.

## 11. Zásahy mimo složku hry

Jediné, co se změní mimo `lib/games/matches`, `test/games/matches` a `assets/games/matches`:
- `lib/games/registry.dart`: přidat `matchesModule` za Člověče a zvětšit `homeGridSlots` ze 6 na 7 (Dáma zůstane jako „Brzy“).
- `lib/core/audio/audio_catalog.dart`: do `AudioCatalog.standard.music` přidat `'matches': 'music/matches.ogg'` – hudbu her vyjmenovává katalog, bez záznamu by hra hrála bez hudby (kontraktní test to nezachytí, proto k tomu i test).
- `tool/generate_placeholder_audio.py`: zástupné efekty (a do stažení skladby zástupná hudba).
- `assets/audio/music/matches.ogg` (hudba; složka už je v `pubspec.yaml`) a v `pubspec.yaml` nové složky `assets/games/matches/` a `assets/games/matches/sfx/` (stejně jako u ostatních her).
- Testy, které vyjmenovávají hry (`test/games/skeletons_test.dart`, `test/games/network_games_test.dart`), dostanou Sirky do seznamu.

**Větev:** vývoj na větvi mimo `game/*` (např. `feature/matches`), protože `tool/check_scope.dart` na větvích `game/<id>` zakazuje změny mimo složky hry. *(Můj návrh.)* Vydání (verze, push, PR, tag) až s Milošovým souhlasem.

## 12. Hotovo (Definition of Done)

Podle kap. 13.4 hlavního zadání: kontraktní testy (včetně síťové partie), unit testy pravidel (hraniční případy: vzít celou řadu, poslední sirka, nelegální počet, cizí řada), AI testy z kap. 6, uložení/obnovení po zabití aplikace, replay, texty v CS/EN/ES bez přetečení (360 dp, 130 %), golden testy, `lib/games/matches/README.md` (pravidla, architektura, AI), body, ★, odznaky a statistiky ve frameworku, nastavení se pamatuje.

**Možná rozšíření později (mimo tuto verzi):** varianta „kdo vezme poslední, vyhrává“; jiná rozložení (např. 1-3-5-7); volba „Začíná: střídavě“ po partiích (až ji bude umět framework i pro Piškvorky).
