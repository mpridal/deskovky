# Milník 7b – Obchod, šatník a vylepšení avatara: implementační plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Body z her jde utratit za vylepšení avatara. Katalog má **36 položek** v 6 slotech, každá je kreslená kódem ve stylu avatara a sedí na všech tvarech obličeje a účesech. Obchod má zkušební kabinku, šatník umožňuje nasazovat a sundávat. Nasazený vzhled je vidět všude a ve všech velikostech avatara.

**Architecture:**
- `assets/config/shop_items.json` + `ShopCatalog` (načtený jednou při startu jako `rewards.json`).
- Inventář ve schématu **v5** (`player_items`). Nasazené položky jsou součástí `AvatarSpec` (`equipped: {slot: {id, variant}}`), takže je `AvatarView` vykreslí všude bez dalšího napojování.
- Kreslení: registr `AccessoryPainter` (`lib/ui_kit/avatar/accessories/`) v souřadnicích 100×100 jako avatar.
- Vrstvy, odzadu dopředu: rámeček → pozadí → mazlíček → avatar → obličej → hlava (zkrácené vlasy) → ruka → efekt.
- `ShopRepository` hlídá cenu, úroveň a odznak a nákup provede v jedné transakci s účetní knihou bodů (`purchase`).

**Spec:** `docs/ZADANI-deskovky.md` – 5.3 (vylepšení, náhodný vzhled), 5.5 („Sběratel“), 5.6 (Sloty, Katalog, Obchod a šatník, Výsledky partie, Rodičovská zóna – reset), 5.1 (počítadlo bodů → obchod), 12 (akceptace). Předlohy korunky, svatozáře, klobouku, čarodějnického klobouku, brýlí, slunečních brýlí, masky, hůlky a mobilu jsou v `docs/design/deskovky-navrh-vizualu.html` (`ACC`).

## Global Constraints
- Rarita určuje barvu štítku a cenu:
  - běžné – šedohnědá, 30–60;
  - vzácné – `player2`, 100–200;
  - epické – `#8E5BC8`, 300–500;
  - legendární – `gold`, 800–1 200 a navíc **úroveň ≥ 8**;
  - za odznak – `player4`, nelze koupit.
- Na každý slot jedno vylepšení. Svatozář je ve slotu hlava (nejde tedy spolu s korunkou) a kreslí se nad hlavou.
- **28 dp:** bez mazlíčka a efektu. **Animace jen od 64 dp** a respektují „omezit animace“.
- Barevné varianty se kupují jednou, barva se pak v šatníku volí zdarma.
- Vlasy pod kloboukem/kšiltovkou/helmou se zkrátí, aby nevyčuhovaly.
- Utracení snižuje jen zůstatek, nikdy „celkem získáno“, úroveň ani pořadí v žebříčku.
- „Náhodně“ v editoru avatara míchá jen základní vzhled a **vlastněná** vylepšení.
- Bez skutečných peněz, reklam a nákupů v aplikaci.
- Texty CS/EN/ES, 360 dp nepřetéká, cíle ≥ 48 dp.

## Katalog (36 položek) – návrh k potvrzení
| Slot | Běžné (30–60) | Vzácné (100–200) | Epické (300–500) | Legendární (≥ úr. 8) | Za odznak |
|---|---|---|---|---|---|
| **Hlava** (9) | kšiltovka 40 (3 barvy), čelenka s oušky 50, věneček 45 | cylindr 150, vikinská helma 180, pirátský šátek 120 | čarodějnický klobouk 400 | **korunka** 1 000 (zlatá/stříbrná), **svatozář** 900 | – |
| **Obličej** (7) | brýle 40 (3 barvy), knírek 30, malování hvězda 35 | sluneční brýle 120, maska hrdiny 180, monokl 110 | karnevalová maska 350 | – | – |
| **Ruka** (7) | lízátko 35, balónek 45 (4 barvy), zmrzlina 40 | mobil 160, mikrofon 140 | kouzelná hůlka 380 (jiskří) | – | **trofej** (50 výher) |
| **Mazlíček** (5) | – | kočka 200, kuřátko 150, pejsek 190 | papoušek 450 | **dráček** 1 200 | – |
| **Rámeček** (5) | dřevěný 50 | zlatý 150 | duhový 400 | **plamenný** 800 | **hvězdný** (výhra na Těžkou v každé hře) |
| **Efekt** (3) | – | – | třpytky 350, bublinky 300, sněžení 320 | – | – |

Nové rámcové odznaky: `wins50` (50 výher, +50) a `all_hard` (výhra na Těžkou ve všech dostupných hrách, alespoň ve dvou, +50). „Sběratel“ (`collector`, 10 vylepšení, +30) se vyhodnotí při nákupu.

## Review Focus
1. Souběžné klepnutí na „Koupit“ nebo nákup z druhého zařízení stejného profilu nesmí strhnout body dvakrát ani dostat zůstatek pod nulu → test v Tasku 2.
2. Položka zamčená úrovní nebo odznakem nejde koupit ani přes zkušební kabinku → test v Tasku 2.
3. Avatar s každou položkou na všech 4 tvarech obličeje × 10 účesech nic nevykreslí mimo kruh a v 28 dp nic nepřetéká → golden test v Tasku 4.
4. Reset rodiče: zůstatek 0, inventář prázdný, nasazené sundané, „celkem získáno“ a úroveň beze změny → test v Tasku 7.
5. Smazaný hráč smaže inventář; avatar s neznámou nebo smazanou položkou (starší/novější JSON) se vykreslí bez ní → test v Tasku 3.

## Tasks (stručně)
1. **Katalog** – `shop_items.json` (36 položek), `ShopItem`/`ShopCatalog` (validace: jedinečná id, rarita↔cena↔úroveň, odznak existuje), texty názvů ve 3 jazycích, test „každá položka má painter a text“.
2. **Schéma v5 + ShopRepository** – `player_items(player_id → players cascade, item_id, acquired_at)`; `buy` v transakci (zůstatek, úroveň, odznak, už vlastní), `owned`, `equip/unequip` (zápis do `AvatarSpec`), `reset` pro rodiče; odznaky `wins50`, `all_hard`, `collector`; migrace + test.
3. **AvatarSpec.equipped + vrstvy** – serializace (neznámé položky se ignorují), `AvatarPainter` s vrstvami a zkrácením vlasů, pravidla velikostí, animace (`AnimatedAvatarView`), první várka painterů: 9 z mockupu.
4. **Zbylých 27 painterů** + golden „vzorník“ (každá položka na 2 tvarech × 3 účesech, 28/64/160 dp) a test, že nic nepřesahuje kruh.
5. **Obchod** – `/players/:id/shop`: kabinka (velký avatar + vyzkoušená položka), záložky slotů, mřížka karet (náhled, název, cena / Máš / Nasazeno / 🔒 Úroveň 8 / 🔒 Odznak), tlačítko „Koupit za N ●“ → potvrzení → animace a zvuk `purchase` → „Nasadit hned?“; při nedostatku bodů „Chybí ti N ●“ s ukazatelem.
6. **Šatník** – `/players/:id/wardrobe`: vlastněné položky po slotech, nasadit/sundat (zvuk `equip`), volba barvy varianty; „Náhodně“ v editoru avatara bere i vlastněné položky.
7. **Napojení** – počítadlo ● na domovské obrazovce → obchod aktivního hráče; tlačítka Obchod/Šatník u hráče a ve statistikách; rodičovská zóna → reset bodů a vylepšení (s potvrzením); výsledky: „Teď si můžeš koupit: Čaroděj!“, když hráč na položku nově dosáhne a dřív si ji zkoušel; historie bodů ukazuje nákupy.
8. **Ověření a dokumentace** – emulátor (telefon + tablet), snímky `docs/milestones/m7b/`, CLAUDE.md (jak přidat položku), nezávislá revize, oprava nálezů.

**Odhad:** 1,5–2 dny (nejvíc práce je v 36 kresbách). Vydání pak jako **v0.2.0** dohromady s opravou diakritiky z větve `fix/update-tap-encoding`.

## Co potřebuju od tebe
1. Schválit plán, zvlášť **seznam a ceny 36 položek** a nové odznaky `wins50`, `all_hard`, `collector`.
2. Po hotové práci se podívat na vzorník kreseb (snímky). Vzhled je hlavně na tobě.
