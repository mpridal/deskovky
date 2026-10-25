# Ukázková hra „Hádej číslo“ (`_sample`)

Ověřuje celé herní API frameworku (zadání kap. 8 a 12). Není to jedna z pěti her fáze 2.

## Pravidla

Hra skryje číslo v rozsahu 1–20, 1–50 nebo 1–100 (volba `range`). Hráči se střídají v tipování. Po každé netrefě všichni uvidí, jestli je tajné číslo větší, nebo menší, a možný rozsah se zúží. Kdo číslo trefí, vyhrává; ostatní sdílí druhé místo.

Hodnocení: hra pro 1 hráče – nejvýš ⌈log2(rozsah)⌉ tipů ★★★, o 3 víc ★★, jinak ★. Hra více hráčů – vítěz ★★★, ostatní ★.

## Architektura

- `sample_rules.dart` – stavový automat (`GameRules<SampleState>`), tah `Move(seat, 'guess', {'value': n})`, tajné číslo ze seedu přes `SeededRandom`.
- `sample_ai.dart` – Těžká půlí interval (vždy do ⌈log2(rozsah+1)⌉ tipů), Střední míří ke středu ± čtvrtina rozpětí, Lehká tipuje náhodně v možném rozsahu.
- Deska, ikona a manifest: `sample_board.dart`, `sample_icon.dart`, `sample_module.dart`.
