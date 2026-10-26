# Pexeso – požadavky na framework

Co by Pexesu pomohlo od frameworku (API v1.0 se během fáze 2 nemění). Každý bod je dočasně vyřešený ve složce hry.

## 1. Poloha hráče v HUD pro animaci „pár odletí k hráči“

- **Co:** deska nezná, kde v HUD je čip (avatar) hráče.
- **Proč:** zadání 13.6 – nalezené páry odletí k avataru hráče.
- **Návrh API:** `GameBoardView.seatAnchor(int seat) → Offset?` (střed čipu v globálních souřadnicích), nebo `GlobalKey` čipů v `GameHost`.
- **Dočasně:** páry letí nad horní okraj desky na odhadnuté místo čipu (čipy jsou v HUD vystředěné v pořadí míst) a cestou se zmenšují a mizí. Na telefonu i tabletu to míří zhruba správně, ale ne přesně na avatar.

## 2. Herní události se ztratí při obnovení partie

- **Co:** `GameScreen` sbírá `reportEvent` jen v paměti a zapíše je až na konci partie. Po zabití aplikace a obnovení jsou události z první části pryč.
- **Proč:** odznak Sběratel párů (200 párů celkem) počítá páry přes `reportEvent('memory.pairs', {'seat', 'count'})`.
- **Návrh API:** ukládat události se `SavedGame` (např. `SavedGame.events`), nebo hook `GameModule.eventsOf(state)`, který framework zavolá jednou na konci partie.
- **Dočasně:** deska při obnovení (`initState` s rozehranou partií) nahlásí páry nalezené před uložením. Stav se vždy obnoví jen jednou, takže se nic nezapočítá dvakrát (test `memory_game_test.dart`).

## 3. Události po posledním tahu přijdou pozdě

- **Co:** `_checkFinished` si zkopíruje události hned po posledním tahu, dřív než se deska znovu vykreslí. Událost, kterou deska zjistí až z nového stavu, se nezapočítá.
- **Proč:** Paměť jako slon (bez chyby do konce partie) a Rychlík (čas dokončení).
- **Návrh API:** stejný hook jako v bodě 2 (`eventsOf(finalState)`), nebo `GameRules.events(before, move, after)`, které framework zavolá u každého tahu (i robota).
- **Dočasně:** deska hlásí události před odesláním tahu člověka (`MemoryRules.eventsAfter`). Slona hlásí ve chvíli, kdy zbývá poslední dvojice – tehdy už nikdo chybu udělat nemůže.

## 4. Test `test/games/skeletons_test.dart` po vydání hry

- **Co:** test vyžaduje, aby všech 5 her fáze 2 mělo `available: false`. Hotové Pexeso má `available: true`, takže první test v tomto souboru selže (soubor je mimo rozsah herní větve).
- **Návrh:** integrační session odebere `memory` ze seznamu `coming` (stejně i další hotové hry).

## 5. Popis obtížnosti pro hru bez robotů (drobnost)

- **Co:** nastavení ukazuje Lehká / Střední / Těžká. U Pexesa sólo to znamená náhled 2 s / bez náhledu / prohazování karet, ale hráč to v nastavení nevidí.
- **Návrh API:** `GameModule.difficultyHintKey(Difficulty, {required bool robots})` → krátký popisek pod volbou.
- **Dočasně:** vysvětleno v pravidlech hry (`memory.rules`).
