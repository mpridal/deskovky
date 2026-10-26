# Milník 6 – Statistiky, žebříčky, odznaky: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Stav schválení:** plán napsán a proveden přes noc bez Milošova schválení (pokyn „pokračuj bez dotazu do 6:30“). Vše jen lokálně na větvi `milestone/6-stats` (z `milestone/5-audio`), nic se nepushuje.

**Goal:** Každá dohraná partie se uloží (hra, datum, obtížnost, účastníci vč. robotů, pořadí, skóre, hvězdy, délka). Z nich žebříčky (podle hry, obtížnosti, období týden/měsíc/vše), statistiky hráče (odehráno, výhry, % výher, nejlepší skóre/čas, série) a odznaky (deklarativní definice, vyhodnocovač nad statistikami + události hlášené hrou). Nově získané odznaky ve výsledcích s animací a zvukem; nejlepší ★ aktivního hráče na kartě hry; na tabletu „Žebříček tento týden“ a „Poslední odměna“.

**Architecture:** `lib/core/stats/` – `MatchRecord`, `StatsRepository` (Drift, schéma v3: `matches`, `match_participants`, `player_counters`, `earned_badges`), čisté výpočty statistik a žebříčků. `lib/core/badges/` – `BadgeDef` + `BadgeCondition` (deklarativní stavebnice), `BadgeEvaluator`, rámcové odznaky; hra přidá vlastní přes `GameModule.badges`. `GameScreen` při konci partie zavolá `StatsService.recordFinished(...)`, výsledek (nové odznaky) jde do `GameOutcomeView`.

**Tech Stack:** Flutter, Drift (migrace v2→v3), Riverpod, gen-l10n. Žádné nové balíčky.

**Spec:** `docs/ZADANI-deskovky.md` – kap. 5.1 (★ na kartě, pravý panel), 5.4, 5.5, 5.7.1 (roboti bez bodů/odznaků/žebříčků), 5.9, 8 (`reportEvent`, `GameResult.stats`), 12.

## Global Constraints

- Platí vše z milníků 1–5.
- Roboti se ukládají jako účastníci partie (pro pořadí ve výsledcích/historii), ale **nejsou v žebříčcích, nemají statistiky ani odznaky**.
- **Výhra** = samostatně 1. místo; sdílené 1. místo = remíza (série přeruší, výhrou není).
- Období: týden = od pondělí 00:00 místního času, měsíc = od 1. dne 00:00, vše. Čas přes injektovatelné `now()`.
- Žebříček v m6 řadí podle počtu výher, pak % výher, pak méně odehraných; **body (m7) sloupec nahradí/doplní** – ruling, mockup ukazuje mince.
- Odznak má: `id` (hra s prefixem `<id>.`), klíč názvu a popisu, ikonu, odměnu v bodech (+15 až +50, vyplácí m7), podmínku.
- Odznak se získá jednou za profil; vyhodnocuje se po každé partii pro každého lidského účastníka.
- Ukládání časů a dat jako int ms (konvence z m4).
- Texty CS/EN/ES, 360 dp při 130 % nic nepřetéká.

## Review Focus

1. **Partie dohraná po obnovení** (uložená, zabitá aplikace, dokončená) – zapíše se právě jednou → test v Task 4.
2. **Remíza a všechno roboti kromě jednoho člověka** – výhra/série/odznaky správně, robot nikde v žebříčku → testy v Task 2/3.
3. **Hranice období** (neděle 23:59 vs. pondělí 00:00, přelom měsíce) → test v Task 2.
4. **Smazaný profil** – jeho záznamy nezpůsobí pád žebříčku ani výsledků (účastník s neexistujícím `playerId` se přeskočí) → test v Task 2.
5. **Více nových odznaků naráz** pro více hráčů – výsledky je ukážou všechny, zvuk zazní jednou → test v Task 4.

## Tasks (stručně)

1. **Schéma v3 + zápis partie** – tabulky `Matches(id, gameId, playedAt, durationMs, difficulty?, robots)`, `MatchParticipants(matchId, seat, playerId?, place, score, stars)`, `PlayerCounters(playerId, key, value)`, `EarnedBadges(playerId, badgeId, earnedAt)`; migrace v2→v3 + migrační test (postup z CLAUDE.md). `StatsRepository.recordMatch(MatchRecord, {events})` v transakci; události z `reportEvent` zvýší čítače lidských hráčů (`data['count'] ?? 1`).
2. **Výpočty** – `PlayerStats` (odehráno, výhry, remízy, % výher, aktuální a nejlepší série, nejlepší skóre a nejrychlejší výhra podle hry, nejlepší ★ podle hry), `leaderboard(LeaderboardQuery(gameId?, difficulty?, period))`, `watch…` streamy. Testy: remíza, roboti, hranice období, smazaný profil.
3. **Odznaky** – `BadgeDef`, `BadgeCondition` (`wins(n)`, `winStreak(n)`, `played(n)`, `counter(key, n)`, `winAgainst(Difficulty)`, `eventInMatch(id)`, `and`), `BadgeEvaluator`; rámcové: `first_win` (+15), `streak5` (+30), `games10` (+15), `hard_win` (+30), `all_games` (zahrát každou dostupnou hru, +20). `GameModule.badges` (výchozí prázdné); `_sample`: `sample.bullseye` – uhodnout napoprvé (hra hlásí událost `sample.bullseye`, +15). Texty přes `badgeText(l10n, key)`.
4. **Zápis při konci partie + výsledky** – `GameScreen` měří čas partie (od otevření obrazovky, bez pauzy), na konci `StatsService.recordFinished(config, result, events, duration)` → nové odznaky do `GameOutcomeView.newBadges`; výsledky: odznak vyjede zespodu (300 ms, `reduce motion` bez animace), efekt `achievement` s duckingem jednou. Zápis právě jednou i po obnovení.
5. **Obrazovka Žebříčky** – filtry hra (Vše + hry), obtížnost (Vše/Lehká/Střední/Těžká), období (Týden/Měsíc/Vše); řádky: pořadí, avatar, jméno, výhry, odehráno, %; prázdný stav. Tap na řádek → statistiky hráče.
6. **Statistiky hráče** – `/players/:id/stats` (z karty hráče i žebříčku): přehled čísel, po hrách nejlepší skóre/čas a ★, mřížka odznaků (získané barevně s datem, nezískané šedě s popisem podmínky).
7. **Domů a tablet** – nejlepší ★ aktivního hráče na kartě hry; pravý panel: „Žebříček tento týden“ (top 4 podle výher) a „Poslední odměna“ (poslední získaný odznak na zařízení).
8. **Ověření a dokumentace** – emulátor telefon + tablet (screenshoty `docs/milestones/m6/`), CLAUDE.md (jak přidat odznak hry), ARCHITECTURE.md (Statistiky a odznaky).
