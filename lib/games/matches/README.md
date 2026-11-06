# Sirky (`matches`)

Rychlá logická hra pro dva podle `docs/superpowers/specs/2026-11-06-sirky-design.md`.

## Pravidla

- Na stole leží tři řady sirek: **3, 5 a 7** (celkem 15).
- Hráči se střídají. V tahu hráč vezme libovolný počet sirek (aspoň 1), ale jen z **jedné řady**.
- **Kdo vezme poslední sirku, prohrává.** Remíza neexistuje.
- Volba **Začíná:** *náhodně* (výchozí, ze seedu) / *vždy hráč 1*.
- Skóre: vítěz 1, poražený 0 – v HUD i ve výsledcích (během partie 0 oběma).
- Hvězdy: výhra ★★★; prohra, když soupeř aspoň jednou nechal hráči vyhrávající pozici (výchozí pozice se nepočítá) ★★; jinak ★.
- Body: násobič 0,8 (krátká partie). Osobní rekord je nejrychlejší výhra (framework).

## Architektura

| Soubor | Co dělá |
|---|---|
| `matches_rules.dart` | `MatchesState` (řady, kdo začínal, historie `(řada, počet)`, příznaky `hadWin` a `flawless`), `MatchesRules` – tah `take {row, count}`, konec, výsledek, ★, JSON; `winning(rows)` = vyhrává hráč na tahu? (misère Nim) |
| `matches_ai.dart` | robot (viz níže) |
| `matches_events.dart` | události pro odznaky odvozené jen ze stavu |
| `matches_board.dart` | stůl: výběr sirek, tlačítko „Vzít (n)“, animace, zvuky, hlášení událostí |
| `matches_painters.dart` | kreslení sirky, plamínku, prázdného místa a hromádky (`MatchArt`) |
| `matches_rule_step.dart`, `matches_icon.dart` | 3 ilustrované kroky pravidel a ikona, kreslené kódem |
| `matches_texts.dart` | texty CS/EN/ES (`matches.*`) |
| `matches_module.dart` | manifest |

Vše je deterministické ze seedu a tahů, takže replay, uložení/obnovení i hra přes Wi-Fi fungují bez zvláštní práce (kontrakt odehraje síťovou partii).

### Deska

- Klepnutí sirku vybere (nadzvedne se a zazáří v barvě hráče), další klepnutí ve stejné řadě přidá/odebere, klepnutí v jiné řadě přesune výběr tam. Tah provede až „Vzít (n)“.
- Které místo v řadě je prázdné, si pamatuje jen deska (stav počítá sirky). Vlastní tah odebere přesně vybrané sirky, tah robota nebo jiného zařízení ty nejvíc vpravo. Čerstvá deska (obnovení, připojení) ukáže zbylé sirky vycentrované v řadě.
- Cizí tah se nejdřív ukáže jako výběr (0,5 s), pak sirky odletí na hromádku hráče (nahoře, na šířku po stranách); místa po posledním tahu dvakrát zablikají a zůstanou jemně obkreslená. Poslední sirka vzplane cestou k poraženému a zůstane na jeho hromádce ohořelá. S vypnutými animacemi vše okamžitě.
- Zvuky (`matches.pick` výběr, `matches.take` vzetí, `matches.strike` poslední sirka) a události se řídí změnou stavu, takže fungují i pro tahy z jiného zařízení.
- Rozměry: místo pro sirku je ≥ 48 dp široké i na telefonu 360 dp; když se 7 sirek nevejde, zmenší se všechny řady stejně.

### Odznaky a události

| Odznak | Podmínka |
|---|---|
| `matches.first` První zápalka | čítač `matches.win` ≥ 1 |
| `matches.master` Mistr sirek | výhra proti robotovi na Těžkou |
| `matches.flawless` Bez zaváhání | výhra + událost `matches.flawless` (každý vlastní tah nechal soupeře v prohrané pozici) |
| `matches.collector` Sirkař | čítač `matches.win` ≥ 25 |

Herní obrazovka si události zkopíruje hned po posledním tahu, dřív než se deska stihne překreslit. Proto deska hlásí výhru už ve chvíli, kdy je **rozhodnutá**: zbývá jediná sirka (soupeř ji musí vzít). To platí i pro tah robota a tah z jiného zařízení. Když hráč na tomto zařízení sám vezme poslední sirky, události se nahlásí před odesláním tahu. Zbývá jediný případ, kdy výhra nemusí být připsaná: soupeř na **jiném zařízení** vezme naráz několik posledních sirek (viz `FRAMEWORK_REQUESTS.md`). Každá událost se hlásí jednou (klíče `matches.win#<místo>`).

## AI

Dokonalý tah se počítá okamžitě: z nejvýš 15 možných tahů se vybere (náhodně ze seedu) ten, po kterém je soupeř v prohrané pozici podle misère Nim. To je totéž jako pravidla z návrhu (všechny řady ≤ 1 → nechat lichý počet jedniček; jediná řada > 1 → vzít ji celou, nebo nechat 1; jinak nim-součet 0).

- **Těžká:** vždy dokonalý tah; v prohrané pozici 1 sirka z nejdelší řady.
- **Střední:** 60 % dokonalý tah, jinak náhodný; při ≤ 3 sirkách vždy dokonalý.
- **Lehká:** 25 % dokonalý tah, jinak náhodný, který nebere poslední sirku (když může jinak).

Náhoda je jen ze `SeededRandom` (framework ho seeduje `seed + počet tahů`); rozhoduje `nextInt(100)`, protože první `nextDouble()` sousedních seedů vychází skoro stejně.

Testy (`test/games/matches/matches_ai_test.dart`): Těžká z každé vyhrané pozice ≤ 3-5-7 táhne do prohrané; začínající Těžká vyhraje 100 % partií proti Lehké, Střední, Těžké i náhodným tahům; Těžká porazí Lehkou ≥ 80 % při náhodném začátku; náhodný hráč („dítě“) Lehkou občas porazí.

## Hudba a zvuky

- `assets/audio/music/matches.ogg`: „Easy Lemon“, Kevin MacLeod (incompetech.com), CC BY 4.0, OGG Vorbis 96 kb/s, −16 LUFS.
- Efekty jsou zatím zástupné (`tool/generate_placeholder_audio.py`). Licence v `assets/games/matches/CREDITS.json`.
