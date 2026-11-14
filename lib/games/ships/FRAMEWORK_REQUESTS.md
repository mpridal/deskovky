# Požadavky Lodí na framework

## Která sedadla hrají na tomto zařízení – vyřešeno

`GameBoardView.localSeats` (2026-11-14) nese sedadla, za která na tomto zařízení hraje člověk. Když je to jediné sedadlo (síťová hra, hra proti robotovi), deska kreslí moře vždy jeho očima a nic nezakrývá. Dva lidé na jednom zařízení se dál zakrývají při každém předání.

## Tahy mimo pořadí – vyřešeno

`OutOfTurnMoves` (2026-11-14): rozmístění flotily je tah, který smí sedadlo udělat, i když není na tahu. Po Wi-Fi tak oba hráči rozmisťují současně; hostitel u takového tahu kontroluje jen legalitu. Robot rozmisťuje, až je na řadě (okamžitě).
