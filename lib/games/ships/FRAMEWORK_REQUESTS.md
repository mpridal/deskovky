# Požadavky Lodí na framework

## Která sedadla hrají na tomto zařízení

**Co:** `GameBoardView` by měl nést množinu sedadel, za která na tomto zařízení hraje člověk. Návrh API: `final Set<int> localSeats`.

**Proč:** Lodě mají tajnou informaci. Deska musí vědět, čí flotilu smí ukázat, i když na tahu není nikdo z tohoto zařízení: soupeř je robot, soupeř je na jiném zařízení, nebo jde o obnovenou hru na tahu robota. Pro dva lidi na jednom zařízení by z toho bylo jasné i to, kdy zakrýt desku.

**Dočasné řešení:** deska si pamatuje poslední `mySeat`. Dokud žádný není, bere hráče, který není na tahu. Při rozmisťování soupeře jen čeká. Pro člověka proti robotovi i pro síťovou hru to vychází správně. Jediný rozdíl nastane u dvou lidí na jednom zařízení: deska je zakryje až ve chvíli, kdy se na tahu vystřídají.
