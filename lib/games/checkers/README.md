# Dáma (`checkers`)

Hra pro dva: člověk proti člověku (na jednom zařízení nebo každý na svém přes Wi-Fi) nebo proti robotovi. Zadání: `docs/ZADANI-deskovky.md`, kap. 13.9. Plán: `docs/superpowers/plans/2026-11-06-dama.md`.

## Pravidla

Hraje se jen na tmavých polích (vlevo dole je tmavé pole). Hráč 1 (místo 0, červený) začíná dole a táhne nahoru, hráč 2 (místo 1, modrý) shora dolů. Hráč 1 vždy začíná.

**Společné (česká i mezinárodní):**
- Kámen táhne o jedno pole šikmo vpřed na volné pole.
- Braní je povinné: kámen přeskočí soupeřův kámen na volné pole hned za ním. Může-li skákat dál, skáče dál – vícenásobné braní se dokončí celé (jeden tah = celá cesta).
- Turecký úder: sebrané kameny zmizí až po celém tahu. Během tahu blokují cestu a žádný se nepřeskočí dvakrát.
- Kámen, který tah skončí na poslední řadě, se mění v dámu.
- Létající dáma: táhne šikmo o libovolný počet volných polí a bere na dálku – přeskočí jediný soupeřův kámen a přistane na kterémkoli volném poli za ním. Může-li z některého z nich brát dál, musí přistát tam.
- Kdo nemůže táhnout (nemá kámen nebo jsou všechny zablokované), prohrál.
- Remíza: nabídka a přijetí; trojí opakování pozice (stejná deska a stejný hráč na tahu); 25 tahů každého hráče (50 půltahů) jen dámami bez braní.

**Česká dáma (8×8, 12 kamenů, výchozí):** kameny berou jen vpřed. Smí se zvolit kterékoli braní (ne nutně nejdelší), ale může-li brát dáma, musí brát dáma. Kámen, který braním dojde na poslední řadu, už dál brát nemůže (bere jen vpřed), takže se vždy promění.

**Mezinárodní dáma (10×10, 20 kamenů, FMJD):** kameny berou i vzad. Povinné je braní s největším počtem sebraných kamenů (dáma i kámen se počítají stejně). Kámen, který při braní jen projde poslední řadou a skáče dál, se nepromění.

**Volby:**

| Volba | Výchozí | Co dělá |
|---|---|---|
| Pravidla | česká 8×8 | česká 8×8 / mezinárodní 10×10 |
| Zpět tah | zap | Jen proti robotovi na Lehkou a Střední, nejvýš 3× za hru: vrátí poslední tah hráče i odpověď robota. |
| Nápověda povinného braní | zap | Kameny, které musí brát, pulzují a bublina řekne „Musíš brát!“. Braní je povinné i bez nápovědy. |
| Otáčet desku | vyp | Dva lidé na jednom zařízení: deska se otočí k hráči na tahu. Bez volby je hráč 1 dole. Hraje-li na zařízení jen jeden člověk, je jeho strana vždy dole. |

**Hodnocení ★:** výhra s ≥ 6 vlastními kameny na desce ★★★, jiná výhra ★★, remíza ★, prohra 0. Skóre v HUD = počet vlastních kamenů na desce.

**Odznaky:**

| Odznak | Podmínka | Odměna |
|---|---|---|
| `checkers.queen` Dámou! | první proměna kamene v dámu | 20 |
| `checkers.combo` Kombinátor | 3 a více kamenů jedním tahem | 30 |
| `checkers.grandmaster` Velmistr | výhra proti robotovi na Těžkou | 50 |
| `checkers.international` Světák | výhra na mezinárodní desce | 30 |

## Ovládání (deska)

- Ťuknutí na vlastní kámen ukáže zlaté tečky na polích, kam smí. Ťuknutí na tečku tah zahraje.
- Vícenásobné braní: má-li cesta jen jedno pokračování, stačí ťuknout na první dopad a dohraje se celé. Rozvětvuje-li se, hráč ťuká pole po poli („Skákej dál“).
- Malá pole (10×10 na telefonu, 8×8 na 360 dp): deska se vejde celá, dvěma prsty se zvětší, tlačítko „Vycentrovat desku“ ji vrátí. Ťuknutí vedle malého pole vybere nejbližší pole, které něco znamená (kámen, který smí táhnout, nebo cíl) – cíle tak mají aspoň 48 dp.
- Tlačítka pod deskou (na šířku vedle): **Vrátit tah** (zbývá N) a **Nabídnout remízu** (s potvrzením). Nabídku soupeř přijme nebo odmítne na své desce; po odmítnutí smí hráč nabídnout znovu až po svém dalším tahu.
- Animace: kámen skáče pole po poli (`HoppingPiece`), sebrané kameny po přeskočení odletí z desky na stranu toho, kdo bral, a zmizí. Při omezení animací se vše jen přesune. Zvuky: `piece_place`, `checkers.capture`, `checkers.crown` (po doskoku).
- Zvuky, animace a události hraje deska ze změny stavu, takže i pro tahy robota a jiného zařízení.
- Při první hře profilu bublina „Ťukni na svůj kámen a pak na pole, kam má jít.“

## Architektura

| Soubor | Obsah |
|---|---|
| `checkers_rules.dart` | `CheckersState`, `CheckersRules` – deterministický stavový automat, generátor tahů (`generate`), remízy, ★, JSON. |
| `checkers_ai.dart` | `CheckersAi`, `CheckersNode` (lehká pozice pro hledání) a řazení tahů pro `GameSearch`. |
| `checkers_board.dart` | Deska: výběr, cíle, animace, tlačítka, nabídka remízy, otáčení, zoom. |
| `checkers_pieces.dart` | Kámen s korunkou (`PieceToken`), kresba polí. |
| `checkers_events.dart` | Události pro odznaky ze stavu a z tahu. |
| `checkers_rule_steps.dart` | 4 ilustrované kroky pravidel kreslené kódem. |
| `checkers_module.dart` | Manifest. |
| `checkers_texts.dart` | Texty cs/en/es. |

**Tahy** (`Move`):
- `move` `{path: "46-37-28"}` – pole, na která kámen dopadá, začátek první (index `řádek × velikost + sloupec`). Cesta je text, protože `Move` porovnává data hodnotou a seznam by se po JSON nerovnal.
- `offer` (hráč na tahu nabízí remízu) → na tahu je soupeř s `accept` / `decline`.
- `undo` – vrátí poslední dva tahy kamenem (přehráním partie od začátku bez nich).

`legalMoves` obsahuje jen tahy kamenem, nebo `accept`/`decline` při nabídce. `offer` a `undo` jsou legální (`isLegal`), ale nejsou v seznamu, aby je robot nikdy nezvolil (jako `stop` v Člověče).

**Stav** drží vše potřebné pro replay i síť: desku, hráče na tahu, výchozí pozici (pro zpět), seznam cest (`log`), pozice od posledního nevratného tahu (opakování), počítadlo tichých tahů dámami, nabídku remízy, souhrny pro odznaky (`stats`), počet vrácení a volby. Náhoda se nepoužívá vůbec.

## AI

`GameSearch` z game kitu (alpha-beta, iterativní prohlubování) nad `CheckersNode` (deska + hráč na tahu + tiché tahy), ne nad celým stavem – je to mnohem levnější. Běží v izolátu frameworku.

| Obtížnost | Hledání |
|---|---|
| Lehká | hloubka 2 / 300 ms, 25 % tahů náhodně |
| Střední | hloubka 5 / 600 ms |
| Těžká | hloubka 8 / 1,5 s |

- **Hodnocení:** materiál (kámen 100, dáma 300 = 3 kameny), postup kamenů, střed, bezpečné kameny (zadní řada, okraj), dámy na hlavních úhlopříčkách, mobilita hráče na tahu a při převaze výměny (stejný náskok má větší váhu při méně kamenech).
- **Řazení tahů:** `GameSearch` řadí jen tahy v kořeni. Hra proto řadí tahy každého uzlu aspoň 2 půltahy nad horizontem podle rychlého ohodnocení pozice po tahu a 3 a více půltahů nad horizontem prohledá jen 5 nejlepších (létající dámy mají desítky tahů). Horizont pozná z iterace: `GameSearch` zkusí každý tah kořene jednou za hloubku. Díky tomu Těžká dohledá hloubku 8 v průměru za ~50 ms (8×8) a vejde se do limitu.
- **Nabídka remízy:** Střední a Těžká přijmou, když prohrávají aspoň o kámen; Lehká, když nevede. Robot sám remízu nenabízí a tahy nevrací.
- **Síla (testy s limity hloubky místo času):** viz `checkers_ai_test.dart` – Těžká vs Lehká na 8×8 i 10×10, Střední vs Lehká, „dítě“ (bere nejvíc kamenů, nenechá kámen hned sebrat, jinak náhodně) vs Lehká; 100 partií samo se sebou na každé obtížnosti bez nelegálního tahu.

## Rozhodnutí

- **Hráči 1–2:** manifest má vždy 2 místa (`minPlayers = maxPlayers = 2`), „1 hráč“ = druhé místo je robot (jako Piškvorky).
- **Česká pravidla** podle ČFD: kameny berou jen vpřed, volné braní s předností dámy, dáma musí přistát tam, odkud může brát dál. Mezinárodní podle FMJD (maximální braní, proměna jen na konci tahu). Remízová pravidla podle zadání pro obě varianty (FMJD má navíc pravidlo 16 tahů ve vybraných koncovkách – vynecháno).
- **Přijetí remízy** je běžný tah hráče, kterému byla nabídnuta (vyžaduje souhlas obou), takže se v síťové hře nabízí každému, ne jen hostiteli (`canEndForAll` hlídá jednostranné ukončení, jaké Dáma nemá).
- **Otočení desky** se řídí tím, kdo na zařízení hraje (`mySeat`); robot jako hráč 1 → člověk hraje zdola modrými.
- **Násobič bodů** 1,5 (nejsložitější hra, zadání 13.1 ●●●●).
- **Odznak Světák** se hlásí na začátku mezinárodní partie (bez místa) s podmínkou „výhra“ – framework čte události hned po posledním tahu (FRAMEWORK_REQUESTS.md bod 1).
- **Hudba:** „Gymnopedie No 1“ (Kevin MacLeod, CC BY 4.0), OGG Vorbis ~96 kb/s, hlasitost −16 LUFS. Vlastní efekty `capture.ogg` a `crown.ogg` syntetizuje `test/games/checkers/sfx_source/make_sfx.py` (CC0).

## Testy

`test/games/checkers/`: pravidla na známých pozicích (`checkers_rules_test.dart`), AI a síla (`checkers_ai_test.dart`, `CHECKERS_FULL=1` přidá zápas s reálnými časovými limity), deska ve 4 velikostech a 3 jazycích (`checkers_board_test.dart`), golden testy desky ve 3 velikostech a kroků pravidel (`checkers_golden_test.dart`; kroky s textem jen na Windows), kontrakt (`contract_test.dart`).
