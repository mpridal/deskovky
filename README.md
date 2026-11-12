# Deskovky

Rodinná kolekce klasických deskových a karetních her pro Android, pro telefony i tablety. Hraje se proti robotům, ve více lidech na jednom zařízení, nebo každý na svém přes domácí Wi-Fi. Bez reklam, bez účtů a bez internetu.

**Instalace:** APK z [GitHub Releases](https://github.com/mpridal/deskovky/releases/latest). Další verze aplikace sama nabídne a stáhne. Podrobnosti v [docs/INSTALACE.md](docs/INSTALACE.md).

## Hry

| Hra | Hráči | O co jde | Volby |
|---|---|---|---|
| **Piškvorky** | 2 | Kdo první složí řadu (3 na desce 3 × 3, 5 na větších). | deska 3 × 3 / 10 × 10 / 15 × 15, kdo začíná, potvrzení tahu |
| **Pexeso** | 1–4 | Najdi dvojice obrázků. Sólo na co nejméně tahů, ve více lidech na nejvíc párů. | 12–48 karet, sady Zvířátka, Ovoce a zelenina, Doprava, Vesmír |
| **Miny** | 1–4 | Klasické Miny na čas, ve více lidech „Střídačka“. | velikost desky podle obtížnosti, otazníky, ovládání vlajek |
| **Člověče, nezlob se** | 2–4 | Česká klasika s kostkou: dostaň figurky domů první. | délka hry, povinné vyhazování, 3 pokusy na nasazení, dohrát pořadí |
| **Sirky** | 2 | Řady 3, 5 a 7 sirek. Bere se jen z jedné řady a kdo vezme poslední sirku, prohrává. | kdo začíná |
| **Dáma** | 2 | Česká dáma 8 × 8 nebo mezinárodní 10 × 10 s létající dámou a povinným braním. | pravidla, vrácení tahu, nápověda braní, otáčení desky |
| **Válka** | 2–4 | Karetní hra: vyšší karta bere stůl, při shodě je válka. | balíček 32 / 52 karet, délka hry |
| **Lodě** | 2 | Námořní bitva: rozmísti flotilu a potop soupeřovu. Když hrají dva lidé na jednom zařízení, obrazovka se při předání zakryje. | moře 8 × 8 / 10 × 10, po zásahu střílíš znovu, nebo se střídá |
| **Hádej číslo** | 1–4 | Ukázková hra: kdo dřív uhodne tajné číslo. | rozsah čísel |

**Každá hra má:**
- pravidla s obrázkovými kroky v nastavení hry i v pauze;
- roboty (obtížnost Lehká, Střední, Těžká a rychlost robotů);
- uložení rozehrané partie a „Pokračovat“;
- vlastní hudbu a zvuky;
- odznaky;
- texty v češtině, angličtině a španělštině.

Pravidla a technické podrobnosti každé hry jsou v `lib/games/<id>/README.md`.

## Co aplikace umí

- **Hráči a avatary:** profil pro každého člena rodiny s vlastním avatarem (obličej, pleť, vlasy, oči, ústa, pozadí).
- **Body, Obchod a Šatník:**
  - za hry se sbírají body (víc za těžší soupeře, s ochranou proti „farmení“);
  - v Obchodě se za ně kupují čepice, klobouky, brýle, oblečení a další doplňky pro avatara;
  - v Šatníku si je hráč obléká.
- **Hvězdy, odznaky a statistiky:**
  - každá partie dává 0–3 hvězdy;
  - odznaky jsou společné i pro každou hru zvlášť;
  - osobní rekordy, série výher, historie her.
- **Žebříčky** celé rodiny.
- **Hra po Wi-Fi:**
  - každý hraje na svém zařízení;
  - jedno zařízení otevře místnost, ostatní se připojí ze seznamu nebo naskenováním QR kódu (i obyčejným fotoaparátem telefonu);
  - funguje ve všech hrách pro 2 a více hráčů.
- **Rodina (synchronizace):**
  - tablety a telefony v domácnosti se propojí přes Wi-Fi bez internetu;
  - profily, body, vybavení avatarů, historie her a žebříčky jsou pak všude stejné;
  - nové zařízení se připojí QR kódem a stejná jména z různých zařízení jde spárovat do jednoho profilu.
- **Rodičovská zóna** (otevře ji jen ten, kdo vypočítá příklad): darování bodů, vynulování bodů a vylepšení, správa rodiny.
- **Nastavení:**
  - jazyk (podle telefonu, čeština, angličtina, španělština);
  - hudba a efekty s hlasitostí, vibrace;
  - kontrola aktualizací;
  - Autoři a licence.
- **Aktualizace:** aplikace sama najde novou verzi na GitHubu, ukáže, co je nového, a stáhne ji. Přerušené stahování pokračuje tam, kde skončilo.
- **Přístupnost:**
  - dotykové cíle aspoň 48 dp, u velkých desek posun a zoom;
  - popisky pro čtečku obrazovky;
  - respektuje omezení animací;
  - značky pro barvoslepé.
- **Vzhled:** plsť, dřevo a papír. Rozložení pro telefon na výšku i pro tablet na výšku i na šířku.

## Hudba

Hudba her je od Kevina MacLeoda (incompetech.com) pod licencí CC BY 4.0. Seznam skladeb a licencí je v aplikaci v Nastavení → Autoři a licence, a také v `assets/audio/CREDITS.json` a `assets/games/<id>/CREDITS.json`.

## Dokumentace

- Zadání: [docs/ZADANI-deskovky.md](docs/ZADANI-deskovky.md)
- Architektura: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Jak přidat hru: [docs/GAME_MODULE_GUIDE.md](docs/GAME_MODULE_GUIDE.md)
- Instalace a vydávání: [docs/INSTALACE.md](docs/INSTALACE.md)
- Historie verzí: [CHANGELOG.md](CHANGELOG.md)

## Vývoj

Aplikace je ve Flutteru (Riverpod, go_router, Drift). Každá hra je samostatný modul v `lib/games/<id>/` napojený na společný herní framework.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter run --dart-define=GAME=<id>   # otevře rovnou nastavení jedné hry
```

**Vydání:** tag `vX.Y.Z` spustí GitHub Actions. Ty sestaví podepsané APK, vytvoří `latest.json` z `CHANGELOG.md` a založí vydání.
