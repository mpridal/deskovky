# Člověče, nezlob se (`ludo`)

Česká klasika pro 2–4 hráče (zadání 13.8): lidé i roboti, na telefonu na výšku (kostka pod deskou), na tabletu na šířku (kostka vedle desky).

## Pravidla

- Okruh 40 polí ve tvaru kříže, každý hráč má roh (4 čekající figurky), startovní pole a 4 domácí pole. Dva hráči sedí naproti sobě.
- Hráč hodí kostkou (ťuknutím) a posune jednu figurku o hozený počet polí po směru hodinových ručiček.
- Figurka se nasadí na start jen šestkou. Šestka = hod navíc (i když se s ní nedá táhnout).
- Hráč bez figurky na okruhu (všechny v rohu nebo v domečku) má 3 pokusy hodit šestku (volba „3 pokusy na nasazení“, vypnutá = 1 pokus).
- Doskok na soupeřovu figurku ji vyhodí zpět do rohu, i na startovním poli a i při nasazení. Na vlastní figurku stoupnout nelze. Přes figurky na okruhu se skáče.
- Do domečku jen přesným hodem; v domečku se figurky nepřeskakují, ale smí v něm postoupit dál (bez přeskakování).
- Když lze táhnout, táhnout se musí (žádný „pas“). Když nelze, hod propadne a hraje další.
- Vyhrává, kdo má první všechny figurky doma. S volbou „Dohrát pořadí“ se hraje, dokud nezbude jediný hráč.
- „Ukončit a seřadit“ (pod kostkou, když je na tahu člověk, po potvrzení; nabídne se, až má kdokoli aspoň jednu figurku v domečku): hra skončí, dohraní hráči drží svá místa, ostatní se seřadí podle postupu (součet polí, která jejich figurky ušly); stejný postup = sdílené místo. Ukončená partie nedává hvězdy (★ 0) a ve výsledku má `stats['endedEarly'] = true`.
- **Volby:** délka plná (4 figurky) / krátká (2 figurky), povinné vyhazování (když lze vyhodit, musí se vyhodit – i nasazením), 3 pokusy, dohrát pořadí, „Jediný tah zahrát samo“ (zadání: „lze vypnout“).
- **Hodnocení:** 1. místo ★★★, 2. ★★, 3. ★, 4. bez hvězdy; předčasně ukončená partie ★ 0 všem. Skóre v HUD = figurky doma. Body ×1,2 (dlouhá hra).
- **Odznaky:** `ludo.calm` Nezlobím se (výhra a aspoň 3× vyhozen), `ludo.hunter` Lovec (5 vyhození v jedné hře), `ludo.sixes` Tři šestky za sebou, `ludo.family` Rodinná hra (dohraná hra se 4 lidmi).

### Rozhodnutí, která zadání nechávalo otevřená
- Tři šestky za sebou nemají žádný trest (česká klasika), jen odznak.
- Šestka, se kterou nelze táhnout, dává hod navíc; tři pokusy se počítají jen při hodech bez šestky.
- Figurky v domečku se nepočítají jako „na desce“ – hráč s figurkami jen v rohu a v domečku má 3 pokusy.
- Hráč, který dohrál, už nehází; po jeho posledním tahu hraje další, i kdyby padla šestka.
- „Ukončit a seřadit“ může jen člověk na tahu (tah `stop`), a to až když je nějaká figurka v domečku – jinak by šlo hned na začátku „vyhrát“ zadarmo (zadání 5.6: předčasně ukončená hra je bez bodů). Body za samostatné 1. místo ve frameworku zatím zůstávají – viz `FRAMEWORK_REQUESTS.md`, bod 4.
- „Rodinná hra“ (4 lidé) se hlásí až od první figurky v domečku, ne hned na začátku.
- **K potvrzení Milošem:** pořadí priorit Střední AI se liší od zadání (nasazení až jako poslední) – viz AI níže.
- Mini avatar na startovních polích chybí – deska nezná hráče (`FRAMEWORK_REQUESTS.md`).

## Architektura

- `ludo_rules.dart` – stavový automat `GameRules<LudoState>`. Tahy: `roll` (hod; hodnota z generátoru xorshift32, jehož stav `rng` je součástí stavu – replay i přenos přes Wi-Fi dají stejné hody), `move {piece}` (figurka), `stop`. Pozice figurky je relativní k jejímu startu: −1 roh, 0–39 okruh, 40–43 domeček; pole okruhu = `(roh·10 + pozice) mod 40`. `rollWith(state, hodnota)` provede hod se zadanou hodnotou (pro AI). Stav nese i souhrny pro odznaky (`LudoSeatStats`) a kdo je robot.
- `ludo_geometry.dart` – kde co leží na desce 11 × 11 (okruh, domečky, rohy).
- `ludo_board.dart` – deska (`CustomPainter`: dřevěná pole na plsti, start a domeček v barvě hráče, zlaté kroužky na cílových polích), figurky `PieceToken` v `HoppingPiece` (pohyb pole po poli, vyhozená figurka počká, až útočník doskočí, a odletí domů), kostka `Dice`, nápověda při první hře, „Nedá se táhnout“, „Ukončit a seřadit“. Deska jen ukazuje stav a posílá tahy; animace a zvuky (`dice_roll`, `ludo.hop`, `ludo.boing`, `ludo.home`) odvozuje ze změny stavu, takže hrají i u robotů. Ťuknutí kamkoli vybere nejbližší táhnoucí figurku do vzdálenosti max(pole, 28 dp) – i na malém telefonu je cíl ≥ 48 dp bez zoomu. Jediný možný tah zahraje deska sama po 0,7 s (volba `autoMove`).
- `ludo_events.dart` – události odznaků ze souhrnů ve stavu; deska je hlásí jednou za život desky.
- `ludo_rule_steps.dart` – 3 ilustrované kroky pravidel; `ludo_texts.dart` – texty cs/en/es; `ludo_icon.dart` – ikona.
- Ukládání: framework ukládá po každém tahu (seed + tahy); AI nemá vlastní stav.

## AI (`ludo_ai.dart`)

- **Lehká:** náhodná legální figurka.
- **Střední:** priority vyhodit → do domečku → utéct z ohrožení → posunout nejpřednější figurku, která zůstane v bezpečí → nasadit. Zadání uvádí nasazení hned za vyhozením a posun nejzadnější figurky; tak ale Střední prohrávala s Lehkou (22 % výher), protože se 3 pokusy je brzké nasazení nevýhodné. Takto vyhrává 53 %. **Rozhodne Miloš** – vrátit pořadí ze zadání je jedna úprava v `_byPriority`.
- **Těžká:** hodnoticí funkce (postup figurek, domeček, riziko – kolik soupeřových figurek může příštím hodem doskočit, včetně nasazení na jejich start – minus 0,6 × nejlepší soupeř) a expectimax o 1 hod dopředu: pro každý tah zprůměruje 6 možných hodů toho, kdo hraje dál, který zvolí svůj nejlepší tah.
- Testy (`test/games/ludo/ludo_ai_test.dart`, 2 hráči, střídá se začínající): Těžká vs Lehká 77 % (200 partií), Těžká vs Střední 71,5 %, 100 partií na každé obtížnosti s různými volbami bez nelegálního tahu.

## Testy

`flutter test test/games/ludo`: kontrakt, pravidla (34 testů včetně hraničních případů), AI, deska ve 4 velikostech (360×740, 412×915, 800×1280, 1280×800) a ve 3 jazycích, golden obrázky (`goldens/`), celá partie v aplikaci až po výsledky a statistiky, uložení a pokračování.
