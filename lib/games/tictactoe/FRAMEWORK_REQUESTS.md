# Požadavky Piškvorek na framework

Framework se v herní větvi nemění (zadání 13.2). Tady je, co Piškvorkám chybí, jak to hra zatím řeší sama a jaké API navrhuje.

## 1. „Začíná: střídavě“ – hra neví, kdo začínal minule

**Co:** volba `start = alternate` má střídat začínajícího hráče mezi partiemi. `GameRules.initialState(config, seed)` ale nedostane nic o předchozí partii a hra nesmí nic ukládat sama (replay musí z configu a seedu dát vždy totéž).

**Dočasně:** volba „střídavě“ je z nabídky odebraná (výchozí je „náhodně“). Starší uložené `alternate` se chová jako `random`. Po přidání API se volba vrátí.

**Navržené API:** framework si pamatuje pořadí partií dané hry se stejnými hráči a předá ho v configu, např. `GameConfig.round` (0, 1, 2, … pro „Hrát znovu“ a další partie se stejnou sestavou; ukládá se se `SavedGame`, takže replay zůstane deterministický). Hra pak začne `round % 2`.

## 2. Herní události z posledního tahu robota

**Co:** události pro odznaky hlásí deska (`view.host.reportEvent`) a herní obrazovka si je zkopíruje hned po posledním tahu. Když partii ukončí tah robota, deska už nemá kdy nic nahlásit. Rozehrané události se navíc neukládají se `SavedGame`, takže po obnovení partie zmizí.

**Dočasně:** `tictactoe.wall` (remíza s Těžkou na 3×3) hlásí deska už s tahem člověka, po kterém má robot jediné volné pole (`tictactoe_events.dart`). Ostatní odznaky Piškvorek rozhoduje vždy tah člověka.

**Navržené API:** `GameModule.finalEvents(S state) → List<(String, Map<String, Object?>)>` – framework ho zavolá při konci partie a přidá výsledek k událostem z desky. Hra pak může události počítat čistě ze stavu (i po obnovení).

## 3. Volba platná jen pro některé hodnoty jiné volby

**Co:** „potvrdit tah druhým ťuknutím“ dává smysl jen na velké desce, nastavení ji ale ukazuje i u 3×3.

**Dočasně:** popisek volby říká „Velká deska: …“ a 3×3 ji ignoruje.

**Navržené API:** `GameOption.visibleWhen: (Map<String, Object?> options) → bool`.

## 4. Pro integrační session (ne API)

- `test/games/skeletons_test.dart` čeká, že `tictactoe` je `available: false`. Hra je hotová a má `available: true`, takže tenhle test v herní větvi selže; při slučování je potřeba `tictactoe` vyřadit ze seznamu `coming`.
- `tool/generate_placeholder_audio.py` má Piškvorky pořád v `GAME_SFX`; nové spuštění by přepsalo skutečné efekty `draw.ogg` a `line.ogg` zástupnými. Záznam `"tictactoe"` z `GAME_SFX` je potřeba odebrat (efekty vyrábí `test/games/tictactoe/sfx_source/make_sfx.py`).
