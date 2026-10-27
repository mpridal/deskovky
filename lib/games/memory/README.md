# Pexeso (`memory`)

Hra pro 1–4 hráče (lidé i roboti v libovolných místech) podle zadání, kap. 13.6. Smí se měnit jen `lib/games/memory/**`, `assets/games/memory/**`, `test/games/memory/**` a `assets/audio/music/memory.ogg`. Co chybí ve frameworku, je v `FRAMEWORK_REQUESTS.md`.

## Pravidla

- Hráč otočí dvě karty.
  - **Shoda:** pár si nechá a hraje znovu.
  - **Neshoda:** karty zůstanou 1,2 s otočené a hraje další hráč. Ťuknutí kamkoli (i na kartu) zakrytí urychlí.
- Vyhrává nejvíc párů. Při rovnosti mají hráči stejné místo (1, 1, 3…).
- **Hra pro 1 hráče:** co nejméně tahů. Tah = dvojice otočených karet.
  - Lehká: na začátku jsou 2 s vidět všechny karty (ťuknutí náhled ukončí).
  - Střední: bez náhledu.
  - Těžká: po každé 4. neshodě se dvě jiné zakryté karty s různými obrázky viditelně prohodí.
- **Volby:** počet karet 12 / 16 / 24 / 36 / 48 a sada obrázků (Zvířátka, Ovoce a zelenina, Doprava, Vesmír).
- **Hodnocení:**
  - sólo: tahy ≤ 1,5 × páry ★★★, ≤ 2 × páry ★★, jinak ★;
  - více hráčů: 1. místo ★★★, 2. místo ★★, jinak ★.
- **Odznaky:**
  - `memory.elephant` Paměť jako slon: celá partie bez chyby paměti, aspoň 16 karet; s ostatními navíc aspoň polovina všech dvojic;
  - `memory.speed` Rychlík: sám 16 karet pod 40 s;
  - `memory.streak` Série: 5 párů v jednom tahu;
  - `memory.collector` Sběratel párů: celkem 200 párů (počítadlo `memory.pairs`).
- **Zvuky:** `card_flip` (každé otočení), `memory.match`, `memory.miss`; hudba `music/memory.ogg`.

### Rozhodnutí, která zadání nechávalo otevřená

- **„Bez chyby“ (slon)** nemůže znamenat „bez neshody“ – první karty jsou vždy naslepo. Chyba = neshoda, kdy hráč už viděl partnera první karty, nebo jako druhou otočil kartu, kterou už znal (taková se shodovat nemůže). Hráč musí odehrát aspoň jeden tah a ve hře s ostatními najít aspoň polovinu dvojic – jinak by odznak dostal i ten, kdo měl jen jeden nebo dva šťastné tahy.
- **Rychlík** platí jen pro hru jednoho hráče. U více hráčů čas měří celou partii, ne jednoho hráče.
- **48 karet je i na telefonu.** Volby jsou pro všechna zařízení stejné. Na 360×740 se 48 karet vejde ve velikosti 49 dp, takže není potřeba posun ani zoom. Kdyby byla plocha menší, deska se posouvá (karty nikdy pod 48 dp).
- **Prohazování (Těžká sólo)** nebere dvě karty právě ukázané neshody (`neodkryté karty` ze zadání) a vždy prohodí dva různé obrázky. Animace začne, až se neshoda zakryje.
- **Neshoda robota** zůstane vidět celých 1,2 s, i když další robot už otáčí. Lidé si tak karty stihnou zapamatovat. Rámeček karty má barvu hráče, který ji otočil.
- **Začíná vždy hráč na 1. místě.** Pořadí určuje nastavení.
- **Žádné dva podobné motivy v jedné sadě.** Na malé kartě se různé hvězdy, měsíce nebo slunce slijí a dítě je vezme jako pár. Proto má každá sada nejvýš jeden motiv z „rodiny“ (hvězdy, měsíce, slunce, zeměkoule, lodě, citrusy…). Hlídá to test `no set has two look-alike motifs`. Vesmír má místo dalších hvězd a měsíců například kámen (meteorit), duhu, blesk, sopku, kompas nebo baterii.
- **Karty jsou čtvercové.** Obrázky jsou čtvercové a čtverec dává na všech poměrech stran největší obrázek.

## Architektura

| Soubor | Co dělá |
|---|---|
| `memory_rules.dart` | `MemoryState` + `MemoryRules`: deterministický stavový automat, čistý Dart bez UI |
| `memory_ai.dart` | `MemoryAi`: robot s pamětí |
| `memory_board.dart` | deska: mřížka `FlipCard`, náhled, zobrazení neshody, let párů, prohození, hlášení odznaků |
| `memory_layout.dart` | `MemoryGrid.fit`: počet sloupců a velikost karet pro danou plochu (čistá funkce) |
| `memory_card_art.dart` | rub (dřevo s logem aplikace, kreslený kódem) a líc karty (papír s obrázkem) |
| `memory_cards.dart` | sady obrázků: 4 × 24 Noto Emoji (`assets/games/memory/cards/<sada>/<kód>.png`) |
| `memory_rule_step.dart` | ilustrované kroky pravidel (`ruleSteps`) |
| `memory_texts.dart` | texty cs/en/es |
| `memory_module.dart` | manifest |

- **Tah** je jediný: `Move(type: 'flip', data: {'card': i, 't': ms})`. Deska posílá v `t` herní čas (`view.elapsed()`). Ve stavu se z něj uloží `timeMs` pro statistiky a odznak Rychlík. Robot čas neposílá.
- **Stav** obsahuje:
  - rozdání: `faces` – motiv na každé pozici; zamíchání ze seedu přes `SeededRandom`;
  - kdo co našel: `owner`;
  - otevřenou kartu tahu: `open`;
  - historii všech otočení: `reveals` – z ní robot odvozuje paměť;
  - počty tahů, neshod a chyb paměti a nejdelší sérii pro každého hráče;
  - poslední neshodu (`miss`) a poslední prohození (`swap`, `swaps`);
  - které pozice jsou „známé“ (`known`).
- **Náhoda během hry** (prohazování) je ze `SeededRandom(seed ^ počet neshod)`. Replay i uložení a obnovení dají stejný stav.
- **Animace** jsou jen na desce a nemění stav. Při „omezit animace“ se karty otáčejí okamžitě, páry nelétají a prohození se nepřehrává.
- **Odznaky** hlásí deska:
  - před odesláním tahu člověka: páry, série, rychlík (`MemoryRules.eventsAfter`);
  - ve chvíli, kdy zbývá poslední dvojice: slon (`MemoryRules.elephants`);
  - při obnovení partie: páry nalezené předtím a sérii 5 párů, pokud už padla. Proč takhle, vysvětluje `FRAMEWORK_REQUESTS.md`.

## AI

Robot napodobuje dětskou paměť (zadání 13.6). Pro každé otočení karty (pořadí `k` v `reveals`) se stabilním hashem ze seedu partie, místa robota a `k` rozhodne, jestli si ho robot zapamatoval:

| Obtížnost | Zapamatuje si | Zapomene po |
|---|---|---|
| Lehká | 25 % | 3 tazích |
| Střední | 60 % | 8 tazích |
| Těžká | 95 % | nikdy |

Karta otočená v právě probíhajícím tahu leží lícem nahoru, takže ji robot zná vždy. Paměť se počítá jen ze stavu, takže je po uložení a obnovení stejná a robot nepotřebuje vlastní stav.

**Strategie:**
1. Zná-li celý pár, otočí ho.
2. Jinak otočí kartu, kterou nezná.
3. Druhou kartou vezme zapamatovaného partnera, jinak opět neznámou kartu.

**Síla** (test `memory_ai_test.dart`, 200 partií 1 na 1, 16 a 24 karet, střídavě začíná):
- Těžká porazí Lehkou ve 100 % partií;
- Střední porazí Lehkou v 95 % partií.

Lehká zapomíná rychle a sedmiletý hráč ji porazí. Každá obtížnost odehraje 100 partií sama se sebou bez nelegálního tahu.

## Testy

- `contract_test.dart`: kontrakt frameworku.
- `memory_rules_test.dart`: všechna pravidla, hranice, chyby paměti a události odznaků.
- `memory_ai_test.dart`: paměť, strategie, 100 partií na každou obtížnost a síla.
- `memory_board_test.dart`:
  - mřížka ve 4 velikostech (360×740, 412×915, 800×1280, 1280×800) pro 12, 16 i 48 karet;
  - otočení displeje;
  - ovládání, neshoda, let párů, roboti, náhled, prohazování, nápověda a texty;
  - goldeny (`goldens/`).
- `memory_game_test.dart`: celá aplikace:
  - sólo partie až po výsledky a statistiky;
  - partie s robotem s otočením displeje;
  - uložení a obnovení po „restartu“.

## Obrázky

[Noto Emoji](https://github.com/googlefonts/noto-emoji) od Google (`2D/png/512`), zmenšené na 256 px. Licence je v `assets/games/memory/CREDITS.json` a text Apache 2.0 v `assets/games/memory/NOTO_EMOJI_LICENSE.txt`.

**Pozor:** README repozitáře uvádí pro obrázky Apache 2.0, ale kořenový `LICENSE` repozitáře teď obsahuje OFL 1.1 (licenci písma). Obě licence obrázky volně dovolují použít. Uvádíme Apache 2.0, jak ji schválil Miloš.
