# Požadavky Lodí na framework

## Která sedadla hrají na tomto zařízení

**Co:** `GameBoardView` by měl nést množinu sedadel, za která na tomto zařízení hraje člověk. Návrh API: `final Set<int> localSeats`.

**Proč:** Lodě mají tajnou informaci. Deska musí vědět, čí flotilu smí ukázat, i když na tahu není nikdo z tohoto zařízení: soupeř je robot, soupeř je na jiném zařízení, nebo jde o obnovenou hru na tahu robota. Pro dva lidi na jednom zařízení by z toho bylo jasné i to, kdy zakrýt desku.

**Dočasné řešení:** deska si pamatuje poslední `mySeat`. Dokud žádný není, bere hráče, který není na tahu. Při rozmisťování soupeře jen čeká. Pro člověka proti robotovi i pro síťovou hru to vychází správně. Protože deska nepozná, jestli obnovenou bitvu hrají dva lidé na jednom zařízení, začne obnovená bitva vždy zakrytá a hráč na tahu klepne na „Jsem na řadě“. Proti robotovi je to jedno klepnutí navíc.
