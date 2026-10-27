# Miny (`minesweeper`)

Klasické Miny pro jednoho hráče a „Střídačka“ pro 2–4 hráče (zadání 13.7).

## Pravidla

**Obtížnost = velikost desky** (platí i bez robotů, `difficultyWithoutRobots: true`):

| Obtížnost | Deska | Miny | Cílový čas ★★ / ★★★ |
|---|---|---|---|
| Lehká | 9 × 9 | 10 | 60 s / 30 s |
| Střední | 12 × 16 | 30 | 180 s / 90 s |
| Těžká | 16 × 24 | 70 | 480 s / 240 s |

**1 hráč (klasika)**
- Miny se rozmístí až po prvním ťuknutí. První pole ani jeho sousedé minu nemají, takže první ťuknutí vždy otevře prázdnou oblast.
- Prázdná oblast se otevírá až k číslům a zastaví se o vlajky; otazníky otevře.
- Ťuk na odkryté číslo, kolem kterého je právě tolik vlajek, kolik ukazuje, odkryje ostatní pole kolem (chording). Špatná vlajka = šlápnutí na minu.
- Vlajka chrání pole před odkrytím, otazník ne. Značka se mění vlajka → (otazník, je-li volba zapnutá) → nic.
- Výhra = odkrytá všechna pole bez min → místo 1. Mina → konec, místo 2 (zadání 5.6).
- **Hodnocení:** výhra ★, pod cílovým časem ★★, pod polovinou ★★★; prohra 0 ★. Čas posílá deska v tahu (`data.t` = `view.elapsed()`), takže replay hodnotí stejně. Tah bez času (např. záložní tah frameworku) dá jen ★.

**Střídačka (2–4 hráči)**
- Hráči se střídají, každý odkryje jedno pole (chording ve Střídačce není).
- Bod = každé pole, které hráč odkryl (i celá otevřená oblast).
- Kdo odkryje minu, vypadává. Mina zůstane označená obláčkem a kroužkem v jeho barvě a hra pokračuje.
- Konec: zbyl jediný hráč (vyhrává), nebo je deska vyčištěná.
- **Pořadí:** hráči ve hře podle bodů (stejný počet = sdílené místo), pod nimi vyřazení – kdo vydržel déle, je výš. ★: 1. místo ★★★, 2. ★★, jinak ★.

**Deska bez hádání:** na Lehké a Střední generátor zkouší desky ze seedu, dokud řešič neprokáže, že jde vyčistit bez hádání. Těžká je běžná náhodná deska.

## Architektura

| Soubor | Co dělá |
|---|---|
| `minesweeper_state.dart` | neměnný stav (`MinesweeperLevel`, miny, kdo odkryl které pole, značky, výbuchy, čas dokončení), JSON |
| `minesweeper_rules.dart` | `GameRules`: tahy `reveal`, `chord`, `mark`; konec, pořadí, ★ |
| `minesweeper_generator.dart` | rozmístění min po prvním tahu, deska bez hádání |
| `minesweeper_solver.dart` | řešič bez hádání (jedno číslo, dvojice čísel, celkový počet min) a odhad pravděpodobnosti min |
| `minesweeper_ai.dart` | robot pro Střídačku |
| `minesweeper_board.dart` | deska přes `BoardGrid`, ovládání, zvuky, obláček, hlášení událostí pro odznaky |
| `minesweeper_art.dart` | kresba polí, vlajky, miny a obláčku (jen kód, žádné bitmapy) |
| `minesweeper_rule_step.dart` | ilustrované kroky pravidel (výřez 3 × 3 desky) |
| `minesweeper_texts.dart` | texty cs/en/es |

- **Determinismus:** veškerá náhoda je `SeededRandom(seed)` ze stavu. Generátor má místo časového limitu pevný počet pokusů (40). Pokus trvá na počítači ~0,6 ms (Střední), na telefonu odhadem 3–5×, takže nejhorší případ je pod 300 ms. Časový limit by rozbil replay: stejné tahy by na pomalejším zařízení daly jinou desku. Pravděpodobnost, že žádný ze 40 pokusů neprojde, je ~10⁻¹⁸ (projde 65–80 % pokusů); pak se použije běžná deska a stav má `noGuess: false`.
- **Deska:**
  - Neodkrytá pole jsou dřevěné dlaždice, odkrytá papír. Ve Střídačce má papír jemný nádech barvy hráče, který pole odkryl.
  - Čísla mají barvy z palety, tloušťka písma roste s číslem a pod číslem jsou tečky (1–4) nebo proužek (5–8). Čísla jsou tak odlišitelná i bez barev.
  - Mina je kulatá s odleskem, ne strašidelná. Výbuch je obláček kouře (900 ms, při omezení animací se nekreslí).
  - Odkrytí pole má krátký přechod. Ve Střídačce je zlatě orámované poslední odkryté pole.
- **Ovládání:**
  - Ťuk = odkrýt / chording.
  - Vlajka: dlouhý stisk (vlastní `GestureDetector` v `cellBuilder`) nebo přepínač ⛏/🚩, podle volby. Dlouhý stisk funguje i s přepínačem.
  - Při vlajce haptika.
- **Velikost polí:**
  - Každé pole má aspoň 48 dp (zadání 13.4).
  - Když se deska nevejde, zvětšuje se prsty (pinch-zoom), začíná vycentrovaná a v liště je tlačítko „vycentrovat“. Tlačítko se ukáže, jen když se deska nevejde.
  - Na telefonu se tak zvětšují všechny tři desky. Na tabletu se Lehká a Střední vejdou celé, Těžká se zvětšuje.
  - Deska je na výšku; na širokém prostoru (tablet na šířku, telefon na šířku) se zobrazí otočená. Otočení displeje uprostřed hry jen přepočítá zobrazení, stav se nemění.
- **Čtečka obrazovky:** každé pole má popisek, např. „C4, 2“, „A1, vlajka“, „B7, skryté pole“ (sloupec písmenem, řádek číslem).
- **Zvuky:** `minesweeper.dig` (odkrytí), `.flag` (změna vlajek), `.puff` (mina). Hraje je deska při každé změně stavu, tedy i u tahů robotů. Soubory jsou zatím zástupné.
- **Odznaky:** deska je hlásí těsně před tahem, který hru ukončí (u prvního tahu kontrolu přeskakuje, aby se deska nestavěla dvakrát; první tah hru prakticky nikdy neukončí – kdyby jedno ťuknutí vyčistilo celou desku, odznaky z té partie se nezapočítají):
  - `minesweeper.defuser` – výhra na Těžkou;
  - `.noflag` – výhra bez jediné vlajky;
  - `.blitz` – Lehká pod 20 s;
  - `.sapper` – 25 výher, přes čítač události `minesweeper.win`.

  Defuser, Bez vlajek a Blesk platí jen pro hru jednoho hráče.
- **Nápověda při první hře:** před prvním ťuknutím „první je vždy bezpečné“, potom „číslo = počet min kolem“ + jak dát vlajku, dokud hráč nepoloží první vlajku.
- **Hodiny:** v sólo hře tikají každou sekundu, když hráč může hrát. Při omezení animací se posunou jen s každým tahem (tikání by jinak brzdilo testy s `pumpAndSettle`).

## AI (Střídačka)

- **Lehká:** ve 2 ze 3 tahů hledá jisté pole podle jediného čísla („kolem 1 je jen jedno skryté pole“). Jinak odkryje náhodné neodkryté pole.
- **Střední:** celý řešič (jednotlivá čísla, dvojice překrývajících se čísel, celkový počet min). Když nic jistého není, odkryje náhodné pole, které řešič nevyloučil.
- **Těžká:** řešič. Když nic jistého není, odhadne pravděpodobnost miny pro každé pole a vybere nejbezpečnější. Odhad: u čísel nejhorší místní poměr chybějících min a skrytých polí, jinde hustota zbývajících min. První tah dává doprostřed.
- **Vlajky:** robot nevěří cizím vlajkám, počítá jen s odkrytými čísly a nalezenými minami. Chce-li odkrýt pole s vlajkou, nejdřív vlajku sundá (tah zůstává jemu).
- **Testy:** Těžká porazí Lehkou ve ≥ 60 % ze 100 partií na Střední desce (hra s náhodou). Každá obtížnost odehraje 100 partií sama se sebou bez nelegálního tahu.

## Rozhodnutí, kde zadání nebylo jednoznačné

- **Vlajky ve Střídačce:** „kdykoli kdokoli“ framework neumí (tah smí poslat jen hráč na tahu). Vlajku tedy dává hráč na tahu a tah se tím nepředává. Viz `FRAMEWORK_REQUESTS.md`.
- **Chording** je jen pro 1 hráče: Střídačka je „jedno pole za tah“.
- **Pořadí ve Střídačce** po vyčištění desky: vyřazení jsou vždy pod hráči, kteří ve hře zůstali.
- **Prohra sólo = místo 2** podle zadání 5.6, i když to sdílený kontrakt zatím nepovoluje (viz `FRAMEWORK_REQUESTS.md`).
- **Volba ovládání** se ukládá do stavu partie (`switchControls`), aby ji měla i obnovená hra.

## Zbývá / známá omezení

- Zvukové efekty jsou zástupné (vygenerované). Skutečné zvuky se musí stáhnout se souhlasem Miloše a zapsat do `assets/games/minesweeper/CREDITS.json`.
- Požadavky na framework: `FRAMEWORK_REQUESTS.md` (kontrakt pro sólo prohru, `skeletons_test`, odznak výher jedné hry, vlajky mimo tah, rekordy podle obtížnosti).

## Testy

`test/games/minesweeper/`:
- `contract_test.dart` – kontrakt frameworku;
- `minesweeper_rules_test.dart` – všechna pravidla včetně hraničních případů a generátoru;
- `minesweeper_ai_test.dart` – řešič, AI, 100 partií, síla Těžké;
- `minesweeper_board_test.dart` – deska ve 4 velikostech, ovládání, události, golden obrázky v `goldens/`;
- `minesweeper_flow_test.dart` – celá partie přes aplikaci (výsledky, čítač výher, odznak) a uložení/obnovení.
