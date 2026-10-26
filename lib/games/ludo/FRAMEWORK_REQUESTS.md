# Požadavky Člověče (`ludo`) na framework

Hra funguje i bez nich – každý bod má dočasné řešení ve složce hry.

## 1. Kdo sedí na kterém místě (mini avatar na startu)

- **Co:** zadání 13.8 chce na startovních a domácích polích mini avatar hráče. `GameBoardView` ale nezná hráče (jména, `AvatarSpec`, robot/člověk).
- **Navržené API:** `GameBoardView.seats` – seznam `SeatInfo(name, avatar: AvatarSpec?, robot: bool)` podle `SeatIdentity` z herní obrazovky; nebo hotový widget `Widget seatAvatar(int seat, double size)`.
- **Dočasně:** pole a rohy jsou jen v barvě hráče; robota pozná hra z `GameConfig.seats` uložených ve stavu (`LudoState.robots`).

## 2. Události pro odznaky ztracené při posledním tahu a po obnovení

- **Co:** `GameScreen._checkFinished` čte `host.events` hned po posledním tahu, dřív než deska uvidí konečný stav – událost nahlášená z desky až po posledním tahu se do statistik nedostane. Po obnovení uložené hry je `_Host` nový a dřívější události chybí.
- **Navržené API:** `GameRules.events(S state) → List<(String, Map)>` (čistá funkce nad konečným stavem), kterou framework zavolá v `_checkFinished`; nebo ukládat události s partií (`SavedGame.events`).
- **Dočasně:** stav hry drží souhrny (`LudoSeatStats`: vyhození, vyhozen, nejdelší řada šestek). Deska hlásí událost, jakmile ji souhrn ve stavu dovolí (`LudoEvents.of`), jednou za život desky – po obnovení se tedy nahlásí znovu. Žádný odznak Člověče nevzniká až posledním tahem (do domečku se nedá vyhazovat).

## 3. „Ukončit a seřadit podle postupu“ v pauze

- **Co:** zadání chce tlačítko „vždy k dispozici“. Hra ho může ukázat jen na desce a poslat jen jako tah člověka na tahu (`submitHuman`).
- **Navržené API:** `GameModule.endEarlyMove(S state, int seat) → Move?` – framework nabídne v pauze „Ukončit a seřadit“ a pošle ten tah mimo pořadí.
- **Dočasně:** tlačítko „Ukončit a seřadit“ pod kostkou, když je na tahu člověk; tah `stop` je legální (`isLegal`), ale není v `legalMoves`, aby ho robot nikdy nezvolil.

## 4. Hod zatřesením

- Viz „Známá omezení“ v `docs/GAME_MODULE_GUIDE.md` – kostka se hází ťuknutím.
