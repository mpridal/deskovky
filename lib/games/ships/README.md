# Lodě

Námořní bitva pro dva hráče, lidi i roboty, na jednom zařízení i po Wi-Fi. Návrh: `docs/superpowers/specs/2026-11-12-lode-design.md`.

## Pravidla

- **Moře:** 8 × 8 s flotilou 4, 3, 3, 2 (výchozí), nebo 10 × 10 s flotilou 5, 4, 3, 3, 2 (volba `size`).
- **Rozmístění:** nejdřív hráč 1, pak hráč 2 (tah `place`). Lodě jsou rovné a nesmí se dotýkat ani rohem.
- **Střelba:** tah `shoot` na pole, kam hráč ještě nestřílel a které není známá voda. Pole kolem potopené lodi jsou známá voda.
- **Po zásahu** střílí hráč znovu (volba `bonus`: `again`). Při `alternate` se střídá po každé ráně.
- **Konec:** kdo první zasáhne všechna pole soupeřovy flotily, vyhrává.
- **Hvězdy:** vítěz ★★★. Poražený ★★, když zasáhl aspoň polovinu polí soupeřových lodí, jinak ★.
- **Skóre:** počet zásahů. Ve statistikách jsou rány a zásahy obou hráčů.

## Architektura

- `ships_rules.dart`: stav a pravidla.
  - `Ship` je loď (první pole, délka, směr). V tahu se flotila posílá jako text `x,y,h;…` v pořadí flotily, aby tah prošel JSONem beze změny.
  - `legalMoves` při rozmisťování nabízí jedno náhodné platné rozmístění. Legální je ale každé platné.
- `ships_events.dart`: události pro odznaky (Ostrostřelec, Nepotopitelný), odvozené ze stavu.
- `ships_ai.dart`: robot. `ShipsSight` je to, co hráč ví: své rány, zásahy a potopené lodě. Nic víc, takže robot nešvindluje (hlídá to test).
- `ships_board.dart`: deska.
  - Moře soupeře (`BoardGrid`, klepnutí = výstřel) a malá mapa vlastní flotily.
  - Rozmisťovací editor: Zamíchat, vybrat loď, přesunout, otočit, Hotovo.
  - **Předání zařízení:** když se na jednom zařízení střídají dva lidé, deska při změně hráče všechno zakryje a ukáže jen výsledek poslední rány. Pokračuje se tlačítkem „Jsem na řadě“.
- `ships_art.dart`: moře a lodě kreslené kódem (`ShipsCell` pro mřížku, `ShipsSea` pro mapu, ikonu a kroky pravidel).

## Kdo se dívá (perspektiva)

Deska kreslí moře očima hráče, který na tomto zařízení naposledy hrál (`view.mySeat`). Dokud žádný nehrál, je to hráč, který není na tahu. Při rozmisťování soupeře deska jen čeká. Viz `FRAMEWORK_REQUESTS.md`.

## AI

- **Lehká:** náhodné pole. Po zásahu jen napůl ví, že má střílet vedle.
- **Střední:** hledá šachovnicově a zasaženou loď dorazí: kolem zásahu, při dvou zásazích v řadě po přímce.
- **Těžká:** hustota pravděpodobnosti. Pro každé pole spočítá, kolika způsoby ho mohou pokrýt zbylé lodě. Lodě, které vedou přes nepotopené zásahy, mají přednost.
- **Síla:** Těžká porazí Lehkou v ≥ 60 % her a Střední ji poráží častěji než naopak (testy).

## Odznaky

| Odznak | Podmínka | Body |
|---|---|---|
| První vítězství na moři | první výhra | 10 |
| Ostrostřelec | výhra s přesností aspoň 60 % | 20 |
| Nepotopitelný | výhra bez ztráty jediné lodě | 30 |
| Admirál | 20 výher | 40 |

## Zvuky a hudba

- **Vlastní efekty:** `ships.splash`, `ships.hit`, `ships.sunk`. Syntetizuje je `test/games/ships/sfx_source/make_sfx.py` (CC0).
- **Hudba:** „Captain Scurvy“ (Kevin MacLeod, CC BY 4.0), `assets/audio/music/ships.ogg` (64 kb/s), licence v `assets/games/ships/CREDITS.json`.
