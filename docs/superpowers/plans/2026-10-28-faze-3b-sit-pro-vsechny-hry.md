# Fáze 3b – síťová hra pro všechny hry (implementační plán)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Každá hra pro 2+ hráče (Hádej číslo, Piškvorky, Pexeso, Miny, Člověče) jde hrát „Každý na svém (Wi-Fi)“. Každá další hra to umí automaticky a kontrakt her to u ní ověří. Dáma zatím ne.

**Architecture:** Místo seznamu `networkGames` rozhoduje manifest hry: `GameModule.supportsNetwork` (výchozí `true`). Volba se nabízí jen hrám pro 2+ hráče. `runGameContract` přidá síťovou partii přes loopback (hostitel + klient + robot) do konce se shodným hashem a výsledkem. Hry se neliší ničím, co by síť potřebovala vědět – stav je deterministický ze seedu a tahů.

**Spec:** `docs/ZADANI-deskovky.md` kap. 14 (14.1 „Funguje pro všech 5 her“, 14.8 bod 6).

## Global Constraints
- Hry se nemění kvůli síti, pokud to nevyžaduje test. Kód síťové vrstvy zůstává v `lib/core/multiplayer`.
- Nová hra = síť zdarma: výchozí `supportsNetwork => true`, hra se může vyřadit `false`.
- Texty ve 3 jazycích, 360 dp při 130 %.

## Review Focus
1. Hra, která v pravidlech čte `RobotSeat` (Piškvorky, Člověče): zástupný robot nesmí rozbít hash ani výsledek; ovlivní jen odznaky.
2. Miny ve Střídačce: tahy jen hráče na tahu; odpočet času a výsledek stejný na všech zařízeních.
3. Člověče: kostka a „hoď znovu“ – stav ze seedu, žádná náhoda na zařízení.
4. Hry pro 1 hráče: volba „Každý na svém“ se neukáže tam, kde nedává smysl (Dáma nedostupná).
5. Nová hra bez úprav projde síťovým kontraktem; hra, která síť neumí, ji vypne v manifestu.

---

### Task 1: Manifest a kontrakt
**Files:** `lib/core/game/game_module.dart` (`bool get supportsNetwork => true`), `lib/app/multiplayer_providers.dart` (`networkGames` nahradí `canPlayOnNetwork(module)` = `supportsNetwork && available && maxPlayers >= 2`), `lib/features/game_setup/game_setup_screen.dart`, `test/games/contract.dart` (síťová partie přes `LoopbackChannel`: hostitel + 1 klient + robot, kde hra robota umí; náhodné legální tahy ze seedu; hash a `result` shodné; limit tahů).
- [ ] RED: kontrakt pro všechny registrované hry; `canPlayOnNetwork` (Pexeso ano, Dáma ne, hra pro 1 hráče ne).
- [ ] Zelené, commit.

### Task 2: Hry v síti – testy po hrách
**Files:** `test/features/multiplayer/network_games_test.dart`: pro každou hru z registru, která jde po síti, widget test: hostitel otevře místnost z nastavení hry, virtuální klient se připojí, hra začne na obou a tah klienta se ukáže u hostitele; bublina „Na tahu: … (na svém zařízení)“.
- [ ] RED → opravy toho, co se ukáže (např. hra čte místa přes `HumanSeat`) → zelené → commit.

### Task 3: Ověření a vydání
- [ ] Celá sada, `--fatal-infos`, emulátor (místnost Člověče, připojení přes `adb forward`), revize (opus), CHANGELOG, verze. Push/PR/tag jen s Milošovým souhlasem.
