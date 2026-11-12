# Válka

Karetní hra pro 2–4 hráče, lidi i roboty, na jednom zařízení i po Wi-Fi.

## Pravidla

- **Rozdání:** balíček 32 karet (7–A) nebo 52 karet (2–A) se zamíchá ze seedu a rozdá rovným dílem. Co zbude, zůstane v krabici.
- **Bitva:** každý hráč, který je ještě ve hře, otočí svou horní kartu (v pořadí míst). Nejvyšší karta vyhrává; eso je nejvyšší.
- **Válka:** když mají dva nebo víc hráčů stejnou nejvyšší kartu, válčí jen oni. Každý položí jednu kartu rubem a jednu lícem a porovnává se znovu.
  - Hráč s poslední kartou ji položí lícem.
  - Hráč bez karet válku prohrává.
  - Když nemá kartu nikdo z nich, stůl bere první z nich.
- **Vzít karty:** vítěz bitvy vezme jedním tahem všechny karty ze stolu pod svůj balíček (v pořadí míst).
- **Konec hry:** hráč bez karet vypadává. Hra končí, když zbývá jeden hráč, nebo po zvoleném počtu kol: krátká hra 30 kol, dlouhá 100 kol, „do konce“ nejvýš 400 kol.
- **Pořadí:** hráči, kteří ještě mají karty, podle počtu karet (stejný počet = stejné místo); za nimi vyřazení, kdo vypadl později, je výš.
- **Hvězdy:** 1. místo ★★★, ve hře do konce ★★, vyřazený ★.

## Architektura

- `war_rules.dart`: stav a pravidla. Každá akce je tah `flip` (otoč kartu, ve válce rub + líc) nebo `collect` (vítěz bere stůl). Na tahu je vždy právě jeden hráč a má právě jeden legální tah.
- `war_events.dart`: události pro odznaky, odvozené ze stavu. Když bitva čeká na `collect`, vrací události stavu po něm, protože obrazovka sbírá události ve chvíli, kdy hra skončí.
- `war_board.dart`: deska. Každý hráč má svou zónu (balíček a karty na stole), uprostřed je pruh s kolem, nápisem „Válka!“ a tlačítkem „Vzít karty“.
- `war_card_art.dart`: líc a rub karty kreslené kódem.

## AI

Hra je čistá náhoda, robot hraje jediný legální tah. Proto má hra jen jednu obtížnost (Střední) a nastavení se na ni neptá. Body násobí 0,6.

## Odznaky

| Odznak | Podmínka | Body |
|---|---|---|
| První bitva | první výhra | 10 |
| Válka ve válce | výhra války hned po válce | 20 |
| Až do poslední karty | výhra poté, co hráči zbyly nejvýš 3 karty | 30 |
| Generál | 20 výher | 40 |

## Hudba

`assets/audio/music/war.ogg` je zatím zástupná smyčka z `tool/generate_placeholder_audio.py` (`MUSIC["war"]`). Skutečnou nahrávku vyměň podle CLAUDE.md (Zvuk) a uprav `assets/games/war/CREDITS.json`.
