# Lodě – návrh hry

Miloš 2026-11-12: „Teď bych chtěl doplnit další hru – lodě.“ Otázky přeskočil („Začni“), takže všechna rozhodnutí níže jsou moje a jsou tak označená.

## Proč a co

Klasická námořní bitva pro dva. Každý má tajnou flotilu a střílí na políčka soupeřova moře. Hra je jednoduchá i pro děti, ale robot na Těžké už vyžaduje přemýšlení. Hra musí zapadat do stávajícího rámce (`GameModule`, kontrakt her, síťová hra, odznaky, uložení a obnovení).

## Hráči a způsob hry (moje rozhodnutí)

- **Přesně 2 hráči**, lidé nebo robot.
- **Člověk proti robotovi** na jednom zařízení: hlavní případ.
- **Dva lidé na jednom zařízení:** při změně hráče deska všechno zakryje obrazovkou „Předej zařízení“. Zobrazí přitom výsledek posledního výstřelu. Další hráč pokračuje tlačítkem „Jsem na řadě“. Bez toho by flotila nebyla tajná.
- **Každý na svém (Wi-Fi):** funguje jako ostatní hry, protože stav plyne jen ze seedu a tahů. Obě zařízení stav znají celý, deska ale soupeřovy lodě neukáže. V rodině to stačí; skutečné utajení před podvodem neřeším.
- Id hry je `ships`. Názvy: Lodě / Sea Battle / Batalla naval (vlastní obchodní název nepoužívám).

## Pravidla

- **Moře:** volba `size`:
  - `8` (výchozí): 8 × 8, flotila 4, 3, 3, 2. Na telefonu se vejde s velkými políčky.
  - `10`: klasických 10 × 10, flotila 5, 4, 3, 3, 2. Na malém telefonu je posun a zoom přes `BoardGrid`.
- **Lodě** jsou rovné (vodorovně nebo svisle) a **nesmí se dotýkat**, ani rohem (česká pravidla).
- **Rozmístění:** nejdřív hráč 1, pak hráč 2 (tah `place`). Deska nabídne náhodné rozmístění:
  - „Zamíchat“ dá nové rozmístění;
  - klepnutí na loď ji vybere, další klepnutí na ni ji otočí, klepnutí na volné pole ji tam přesune;
  - neplatná pozice se nepřijme.
  - Pak „Hotovo“.
- **Střelba:** tah `shoot` na pole, kam ten hráč ještě nestřílel a které není známá voda. Výsledek je voda, zásah, nebo potopeno.
- **Potopená loď** se ukáže celá a pole kolem ní se samy označí jako voda, protože tam loď být nemůže.
- **Volba `bonus`:**
  - `again` (výchozí): po zásahu střílíš znovu (jak se to u nás hraje);
  - `alternate`: střídá se po každé ráně.
- **Začíná** hráč 1.
- **Konec:** kdo první potopí celou soupeřovu flotilu, vyhrává.

## Výsledky, body, odznaky

- **Pořadí a hvězdy:**
  - vítěz: 1. místo, ★★★;
  - poražený: ★★, když zasáhl aspoň polovinu polí soupeřových lodí, jinak ★.
- **Skóre** v HUD a ve výsledcích je počet zásahů. Statistiky: rány a zásahy.
- **Body:** ×1,0 (hra má náhodu i úvahu).
- **Odznaky:**
  - `ships.first` – První vítězství (1 výhra, 10);
  - `ships.sharp` – Ostrostřelec: výhra s přesností aspoň 60 % (20);
  - `ships.untouched` – Nepotopitelný: výhra bez ztráty jediné lodě (30);
  - `ships.admiral` – Admirál: 20 výher (40).
- **Události** (`ShipsEvents`) plynou jen ze stavu, jako u Války. Hlásí je deska, a to i před vlastním posledním výstřelem.

## Robot (nikdy nevidí soupeřovy lodě, jen výsledky svých ran)

- **Rozmístění:** náhodné platné.
- **Lehká:** náhodné pole. Po zásahu jen napůl ví, že má střílet vedle.
- **Střední:** hledá a dorazí. Hledá šachovnicově a po zásahu střílí kolem, při dvou zásazích v řadě po přímce.
- **Těžká:** hustota pravděpodobnosti. Počítá, kolika způsoby se do moře vejdou zbylé lodě se známou vodou a zásahy, a střílí na nejpravděpodobnější pole.
- **Požadavek:** Těžká porazí Lehkou v ≥ 60 % her.

## Deska

- **Na výšku:** nahoře velké soupeřovo moře (cíl, `BoardGrid`), pod ním menší „tvoje flotila“ se soupeřovými ranami (jen ukazuje, nejde na ni klepnout). **Na šířku** vedle sebe.
- **Perspektiva:** deska kreslí moře očima hráče, který na tomto zařízení naposledy hrál (`mySeat`). Dokud žádný nehrál (soupeř rozmisťuje), ukáže jen čekání.
  - `GameBoardView` neříká, které sedadlo patří tomuto zařízení. Zapíšu to jako požadavek na framework (`FRAMEWORK_REQUESTS.md`).
- **Kresba:** moře z papíru a modři, lodě dřevěné.
  - voda: kroužek;
  - zásah: červený křížek;
  - potopená loď: tmavá s křížky.
- Poslední rána je zvýrazněná zlatě.
- **Zvuky:** vlastní `ships.splash`, `ships.hit`, `ships.sunk` (vyrobené skriptem, jako u Dámy). K tomu haptika při zásahu.
- **Nápověda v první hře:** „Klepni do moře soupeře“.
- **Pravidla:** obrázkové kroky:
  1. rozmísti lodě;
  2. střílej, voda nebo zásah;
  3. potop celou flotilu.

## Hudba

Skutečná skladba (Kevin MacLeod, CC BY), námořní nálada. Limit hudby 15 MB je téměř plný, proto zvednu limit testu na 17 MB. APK tím naroste asi o 1–2 MB.

## Co nedělám

- 3–4 hráči;
- jiné tvary lodí;
- speciální zbraně;
- utajení proti podvodu v síťové hře.
