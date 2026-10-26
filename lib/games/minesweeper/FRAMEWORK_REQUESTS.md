# Požadavky Min na framework

Framework se v herní větvi nemění; tyto body prosím zpracovat ve větvi `framework/*` nebo při integraci.

## 1. Kontrakt: hra pro 1 hráče může skončit neúspěchem (místo 2)

- **Co:** `test/games/contract.dart`, test „a finished game gives a valid result“, vyžaduje `places` v rozsahu `1..n` a `contains(1)`. Pro `n == 1` tedy povoluje jen místo 1.
- **Proč:** zadání 5.6 a CLAUDE.md: „Hra pro 1 hráče: úspěšné dokončení = místo 1, neúspěch = místo 2“. Prohraná partie Min (šlápnutí na minu) musí být místo 2, jinak by se počítala jako výhra (body, série, odznaky „výhra“).
- **Navržená změna:**
  ```dart
  final maxPlace = n == 1 ? 2 : n;
  for (final place in result.places) expect(place, inInclusiveRange(1, maxPlace));
  if (n > 1) expect(result.places, contains(1));
  ```
- **Dočasně:** Miny vracejí místo 2 podle zadání; tento jeden test kontraktu pro Miny do opravy padá.

## 2. Sdílené testy čekají `available: false` u všech her

- **Co:** selžou, jakmile hotová hra přepne `available: true` (Definition of Done to vyžaduje):
  - `test/games/skeletons_test.dart`, test „every phase-2 game is registered now, not yet available“;
  - `test/features/home/home_screen_test.dart`, test „the sample game comes first and is playable, the other five say "Brzy"“.
- **Návrh:** testovat jen registraci a texty; `available` ověřovat jen u her, které ještě nejsou hotové (např. seznam `coming` zmenšovat při integraci).

## 3. Odznak „počet výher v jedné hře“

- **Co:** `BadgeCondition.gameWins(String gameId, int count)` nad `stats.byGame[gameId].wins`.
- **Proč:** Sapér = 25 výher v Minách. `BadgeCondition.wins` počítá výhry ve všech hrách. **Dočasně** deska hlásí událost `minesweeper.win` a odznak používá `counter('minesweeper.win', 25)`. Ve Střídačce se tak nezapočítá výhra, kterou rozhodl tah robota (deska hlásí události jen před tahem člověka).

## 4. Tahy mimo pořadí (vlajky „kdykoli“ ve Střídačce)

- **Co:** zadání 13.7: „vlajky může dát kdokoli kdykoli“. `TurnController.submitHuman` přijme jen tah hráče na tahu.
- **Dočasně:** vlajku dává hráč na tahu (tah `mark` nepředává tah dalšímu). Pro hot-seat na jednom zařízení to stačí.

## 5. Osobní rekordy času podle obtížnosti

- **Co:** `GameBest.fastestWin` je jeden pro celou hru; zadání 13.7 chce rekord pro každou obtížnost (velikost desky). Partie už ukládá `difficulty`, stačí rekord seskupit i podle ní.
