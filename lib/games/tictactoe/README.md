# Piškvorky (`tictactoe`)

Hra pro dva: člověk proti člověku (hot-seat) nebo proti robotovi. Zadání: `docs/ZADANI-deskovky.md`, kap. 13.5.

## Pravidla

- Hráči střídavě kladou své značky: hráč 1 (místo 0) ✕ červeně, hráč 2 (místo 1) ◯ modře.
- Vyhrává, kdo první složí řadu vodorovně, svisle nebo šikmo:
  - na 3×3 tři v řadě;
  - na 10×10 a 15×15 pět v řadě; platí „5 a víc“, delší řada vyhrává taky a přeškrtne se celá.
- Plná deska bez řady je remíza. Remíza se nevyhlašuje dřív, ani když už řadu nikdo složit nemůže.

**Volby:**
- **Deska** 3×3 / 10×10 / 15×15.
- **Začíná:**
  - střídavě;
  - náhodně;
  - vždy hráč 1.
- **Velká deska: potvrdit tah druhým ťuknutím.** První ťuknutí ukáže průsvitnou značku a zlatý rámeček, druhé ťuknutí na totéž pole ji položí. Ťuknutí jinam značku přesune. Na 3×3 se volba nepoužije.

**Hodnocení ★:**

| Deska | ★★★ | ★★ | ★ | 0 |
|---|---|---|---|---|
| 3×3 | výhra | remíza | prohra, když hráč aspoň jednou zablokoval soupeřovu řadu | prohra bez bloku |
| velká | výhra nejvýš 20 vlastními kameny | pozdější výhra | remíza nebo prohra po ≥ 25 tazích partie (obou hráčů) | kratší prohra |

Skóre v HUD je počet položených vlastních kamenů.

**Odznaky:**

| Odznak | Podmínka | Odměna |
|---|---|---|
| `tictactoe.wall` Neprůstřelný | 10× remíza proti robotovi na Těžkou na 3×3 (počítadlo) | 40 |
| `tictactoe.five` Pětka | první výhra na 15×15 | 20 |
| `tictactoe.blitz` Blesk | výhra na velké desce nejvýš 9 vlastními kameny | 30 |
| `tictactoe.master` Mistr piškvorek | výhra proti robotovi na Těžkou na 15×15 | 50 |

## Rozhodnutí podle zadání

- **Hráči 1–2:** manifest má vždy 2 místa (`minPlayers = maxPlayers = 2`). „1 hráč“ znamená, že druhé místo je robot. Nastavení ho tak samo nabídne.
- **„Začíná: střídavě“:** zatím se určuje ze seedu jako „náhodně“. Pravidla nevědí, kdo začínal minulou partii (FRAMEWORK_REQUESTS.md, bod 1).
- **„Po ≥ 25 tazích“** u ★ za prohru nebo remízu na velké desce = tahy obou hráčů. Na rozdíl od „20 vlastních tahů“ u výhry zadání slovo „vlastních“ neuvádí.
- **Blesk „do 9 tahů“** = nejvýš 9 vlastních kamenů.
- **Těžká vs Lehká ≥ 80 %:**
  - Na velkých deskách splněno: s limitem 700 ms vyhrála 20/20 na 10×10 i na 15×15 (`TICTACTOE_FULL=1`), v běžné sadě s limitem 40 ms ≥ 16/20.
  - Na 3×3 to nejde: dokonalá hra výhru vynutit neumí a Lehká v polovině tahů vezme výhru nebo zablokuje. Těžká tu nikdy neprohraje (ověřeno vyčerpávajícím testem proti všem tahům) a proti Lehké vyhraje asi 75–77 %, zbytek jsou remízy. Test hlídá 0 proher a ≥ 70 výher ze 100.

## Architektura

| Soubor | Obsah |
|---|---|
| `tictactoe_rules.dart` | `TictactoeState` a `TictactoeRules` – deterministický stavový automat. |
| `tictactoe_ai.dart` | `TictactoeAi` a `BigBoardEval` (hodnocení vzorů, VCF). |
| `tictactoe_board.dart` | Deska. |
| `tictactoe_marks.dart` | Kresba čtverečkovaného papíru, ✕/◯ a přeškrtnutí. |
| `tictactoe_events.dart` | Události pro odznaky z tahu člověka (čistá funkce, testovaná bez UI). |
| `tictactoe_rule_step.dart` | 4 ilustrované kroky pravidel (minidesky kreslené kódem). |
| `tictactoe_module.dart` | Manifest. |
| `tictactoe_texts.dart` | Texty cs/en/es. |
| `tictactoe_icon.dart` | Ikona hry. |

**Stav:**
- `size`, `target`;
- `starter`;
- `history` – políčka v pořadí tahů;
- `cells` (index `řádek·size + sloupec`, −1 = volné);
- `blocks` – kolikrát který hráč zablokoval soupeřovu řadu, pro ★;
- `winner`, `line` (vítězná řada);
- `confirm`;
- `robots` a `difficulty` – kvůli odznaku `wall`.

Do JSON se ukládá `history`, `cells` se z ní při načtení dopočítají.

**Tah:** `Move(seat, 'place', {'c': sloupec, 'r': řádek})`. Legální je každé volné pole hráče na tahu. Náhoda je jen ve volbě začínajícího hráče (`SeededRandom(seed)`).

**Deska:**
- `BoardGrid` z game kitu; políčka mají aspoň 48 dp. 10×10 a 15×15 se na telefonu zoomují a posouvají; tlačítko „vycentrovat“ volá `BoardGridController.reset()`.
- Poslední tah má zlatý rámeček. Nová značka se nakreslí tahem pera (280 ms).
- Vítězná řada se přeškrtne čarou přes středy políček (520 ms). Každé políčko kreslí svůj úsek, takže to funguje i se zoomem.
- Při omezení pohybu jsou animace hned hotové.
- **Zvuky:** `tictactoe.draw` při každém novém kameni (i robotově), `tictactoe.line` při přeškrtnutí. Efekty jsou syntetizované: `test/games/tictactoe/sfx_source/make_sfx.py`, CC0.
- **Nápověda při první hře:** pilulka nahoře, dokud nejsou položené 2 kameny.

## AI

`chooseMove` je čistá synchronní funkce. Framework ji spouští v izolátu s prodlevou podle rychlosti robota.

**3×3:**

| Obtížnost | Jak hraje |
|---|---|
| Lehká | Náhodné pole; v polovině tahů vezme výhru, nebo zablokuje. |
| Střední | Vyhraj → blokuj → střed → roh → cokoli. |
| Těžká | Úplný minimax s pamětí (neporazitelná). Ze stejně dobrých polí vybírá to s největší šancí na výhru proti chybujícímu soupeři: modelem je soupeř, který hraje jako Lehká. Teprve pak rozhoduje seed. |

**Velké desky (`BigBoardEval`):**

- **Hodnocení pozice:** každé okno 5 polí v řadě, které obsahuje kameny jen jednoho hráče, má hodnotu podle počtu kamenů (0, 1, 12, 150, 2500). Otevřená čtyřka leží ve dvou takových oknech, polootevřená v jednom, trojky a dvojky obdobně. Hodnota pozice = moje okna − soupeřova, hráč na tahu má bonus.
- **Kandidátní tahy:** volná pole nejvýš 2 kroky od kamene. Řadí se podle přínosu pro útok i obranu (`delta`). Když jde vyhrát, je jediným kandidátem výhra; když soupeř hrozí pětkou, jen bloky.

| Obtížnost | Jak hraje |
|---|---|
| Lehká | 1 tah dopředu se šumem. V 70 % vezme výhru. Zhruba každý třetí tah přehlédne hrozbu (obranu skoro nebere v úvahu). |
| Střední | Vyhraj → zablokuj čtyřku → `GameSearch` do hloubky 2 přes 8 nejlepších kandidátů. |
| Těžká | Vyhraj → zablokuj → hledání vynucené výhry čtyřkami (VCF, až 12 vlastních tahů, nejvýš ¼ času) → `GameSearch` alfa-beta s iterativním prohlubováním do hloubky 6 přes 10 nejlepších kandidátů. Celý tah má limit 700 ms, typicky dosáhne hloubky 4–5. |

**Měřeno (testy):**
- 3×3: Těžká vs Lehká bez prohry, asi 76 % výher.
- Velké desky: Těžká vs Lehká 100 %, Těžká vs Střední na 15×15 9/10.
- Na 10×10 hrají Těžká a Střední spolu skoro vždy remízu.

## Testy (`test/games/tictactoe/`)

| Soubor | Co ověřuje |
|---|---|
| `contract_test.dart` | Kontrakt frameworku. |
| `tictactoe_rules_test.dart` | Všechna pravidla: řady ve všech směrech, „5 a víc“, okraje, remíza, výhra na posledním poli, ★, bloky, JSON. |
| `tictactoe_ai_test.dart` | Taktika; Těžká na 3×3 neprohraje proti žádné sérii tahů; síla podle obtížností; self-play bez nelegálního tahu: 3×3 100 partií na obtížnost, velké desky 100 (Lehká, Střední) a 30 (Těžká se zkráceným limitem); limit 700 ms. |
| `tictactoe_board_test.dart` | Ovládání, potvrzení druhým ťuknutím, nápověda, události odznaků, zvuky, 4 velikosti displeje × 3 desky, otočení displeje, goldeny. |
| `tictactoe_stats_test.dart` | Odznaky, ★ a body přes skutečný `StatsService`. |
| `tictactoe_flow_test.dart` | Celá aplikace: nastavení → partie s robotem → výsledky; uložení při odchodu a pokračování po „restartu“. |

Plná síla Těžké (700 ms, několik minut):

```bash
TICTACTOE_FULL=1 flutter test test/games/tictactoe/tictactoe_ai_test.dart
```

## Co zbývá

- Požadavky na framework: `FRAMEWORK_REQUESTS.md` (střídání začínajícího, události z tahu robota, viditelnost volby).
- Ruční vyzkoušení na zařízení (Miloš).
