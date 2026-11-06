# Požadavky Dámy (`checkers`) na framework

Hra funguje i bez nich – každý bod má dočasné řešení ve složce hry.

## 1. Události pro odznaky z posledního tahu

- **Co:** `GameScreen._checkFinished` čte `host.events` hned po posledním tahu, dřív než deska uvidí konečný stav (stejně jako Člověče, bod 2). Událost hlášená ze změny stavu po vítězném tahu robota nebo jiného zařízení se ztratí.
- **Navržené API:** `GameRules.events(S state)` volané frameworkem v `_checkFinished`, nebo ukládat události s partií.
- **Dočasně:** vlastní tah hlásí své události už při ťuknutí (`CheckersEvents.ofMove`), ostatní deska hlásí ze stavu (`CheckersEvents.of`, jednou za život desky). `checkers.international` se hlásí na začátku partie bez místa a odznak k ní přidá podmínku „výhra“.

## 2. `GameSearch`: transpoziční tabulka a řazení tahů uvnitř stromu

- **Co:** zadání 13.9 chce alpha-beta s řazením tahů a transpoziční tabulkou. `GameSearch` řadí jen tahy v kořeni (podle předchozí hloubky) a tabulku nemá; nehlásí ani hloubku uzlu.
- **Navržené API:** volitelné `GameSearch(order: (S state, List<Move> moves, int depthLeft) → List<Move>, key: (S state) → Object?)` – hra seřadí (a případně zúží) tahy s vědomím zbývající hloubky a podle `key` se ukládají hodnoty a nejlepší tahy (transpoziční tabulka).
- **Dočasně:** Dáma pozná hloubku z počtu pokusů o tahy kořene (`_Search` v `checkers_ai.dart`), řadí tahy uzlů podle rychlého ohodnocení a daleko od horizontu prohledá jen 5 nejlepších. Transpoziční tabulka chybí.

## 3. Jména hráčů na desce

- **Co:** panel „Soupeř nabízí remízu“ a směr letu sebraných kamenů by mohly ukázat jméno a avatar soupeře (zadání: „sebrané kameny odletí k soupeřovu avataru“). `GameBoardView` hráče nezná a deska neví, kde HUD kreslí avatary.
- **Navržené API:** `GameBoardView.seats` (jméno, avatar, robot) a `Offset? avatarPosition(int seat)` v souřadnicích desky (stejný požadavek jako Člověče bod 1).
- **Dočasně:** sebrané kameny odletí z desky na stranu toho, kdo bral; panel nabídky je bez jména.
