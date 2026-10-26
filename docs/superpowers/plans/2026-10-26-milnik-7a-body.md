# Milník 7a – Body, úrovně, účetní kniha, rozpis ve výsledcích: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

> **Stav schválení:** napsáno a provedeno přes noc bez Milošova schválení (pokyn „pokračuj bez dotazu do 6:30“). Jen lokálně, větev `milestone/7-points` z `milestone/6-stats`. Milník 7 je rozdělen: **7a** (tento plán) = body a úrovně; **7b** (samostatný plán, až po schválení) = katalog ≥ 30 vylepšení s vektorovou grafikou, obchod, šatník, sloty na avataru.

**Goal:** Lidští hráči dostávají po každé dohrané partii body podle tabulky 5.6 (základ podle obtížnosti × násobič hry, bonusy za ★, série, první hru dne, osobní rekord, odznaky; ochrana proti farmení). Každý pohyb je záznam v `points_ledger`; zůstatek a „celkem získáno“; úroveň podle celkem získaných bodů. Výsledky ukazují rozpis bodů a novou úroveň. Žebříčky řadí podle získaných bodů. Rodič může darovat body.

**Architecture:** `assets/config/rewards.json` + `RewardsConfig`; čistý `computeMatchPoints(...)` vrací řádky rozpisu; `PointsRepository` nad tabulkou `points_ledger` (schéma v4); `levelFor(totalEarned)`. `StatsService.recordFinished` v téže transakci zapíše partii, odznaky i body a vrátí `MatchRewards` (odznaky + body na hráče).

**Spec:** `docs/ZADANI-deskovky.md` – 5.1 (počítadlo bodů), 5.4 (žebříček podle bodů), 5.5, 5.6 (tabulka bodů, bonusy, pravidla, úrovně, výsledky partie, rodičovská zóna – dárek), 12.

## Global Constraints
- Body jen lidem; robotům nic. Předčasně ukončená hra se nezapisuje = 0 bodů.
- Základ: výhra 10/20/35, remíza 5/10/15, 2. místo (3–4 hráči) 4/8/12, účast 2/3/4 (Lehká/Střední/Těžká). Partie jen lidí = sloupec Střední (ruling).
- Násobič hry `GameModule.pointsMultiplier` 0,5–2 (výchozí 1) jen na základ.
- Bonusy: +2 za ★; série 3/5/10 → +5/+10/+25 (v partii, kdy série dosáhne přesně 3/5/10); první dohraná hra dne +5; nový osobní rekord (lepší skóre nebo rychlejší výhra než dosud, ne u první partie) +5; odznak = jeho odměna.
- Ochrana: Lehká, 1 člověk v partii, stejná hra, 11. a další výhra téhož dne → celá partie za 1 bod (odměny za odznaky zůstávají).
- Body se nikdy neodečítají za prohru. Zůstatek = součet knihy; celkem získáno = součet kladných záznamů.
- Úroveň n vyžaduje `50 × n × (n+1) / 2` celkem získaných bodů; max 30.
- Žebříček = body získané z partií v období (dárky se do žebříčku nepočítají, do úrovně ano).
- Vše v `assets/config/rewards.json`, kód má jen výchozí hodnoty pro případ chyby souboru.

## Review Focus
1. Hranice farmení (10. vs. 11. výhra dne, půlnoc, 2 lidé v partii) → test v Task 1.
2. Série přes remízu a přes jinou hru; série 10 dává jen +25, ne i +5 a +10 → test v Task 1.
3. Smazaný hráč / robot nedostane body; partie bez lidí nic → test v Task 3.
4. Poškozený `rewards.json` → výchozí hodnoty, žádný pád → test v Task 1.
5. Rozpis bodů ve výsledcích pro 4 lidi na 360 dp ve 3 jazycích nepřetéká → test v Task 3.

## Tasks (stručně)
1. **RewardsConfig + výpočet** – `rewards.json`, parsování s výchozími hodnotami, `computeMatchPoints` (řádky `PointsLine(reason, amount)`), testy celé tabulky a pravidel.
2. **Schéma v4 + PointsRepository + úrovně** – `points_ledger(id, player_id → players cascade, amount, reason, match_id → matches set null, at)`, migrace + test, `balance`, `totalEarned`, `history`, `gift`, `levelFor/levelProgress`.
3. **Body na konci partie + výsledky** – `StatsService` spočítá a zapíše body v transakci, `GameOutcomeView.points`; výsledky: rozpis u každého člověka (řádky postupně, souhrn, „Nová úroveň!“), test 4 lidé na 360 dp.
4. **Žebříčky podle bodů** – řazení podle bodů v období (pak výhry), řádek ukazuje ● body; panel tabletu taky.
5. **Domů a statistiky** – zůstatek ● a štítek úrovně v horním pruhu; ve statistikách hráče úroveň s progress barem, zůstatek, celkem získáno a „Historie bodů“.
6. **Rodičovská zóna** – Nastavení → Rodičovská zóna (kontrolní příklad násobilky) → darovat hráči 10/50/100 bodů (záznam „dárek od rodiče“).
7. **Ověření a dokumentace** – emulátor, CLAUDE.md (jak ladit body), ARCHITECTURE.md, screenshoty `docs/milestones/m7a/`, revize.
