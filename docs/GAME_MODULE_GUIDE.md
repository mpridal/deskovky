# Jak napsat hru pro Deskovky

Návod pro session, která vyvíjí jednu hru (zadání kap. 8, 13.2–13.4). Hra je samostatný modul ve vlastní složce; framework zná jen její manifest.

**API v1.0 je zmrazené** (tag `framework-v1`). `GameModule`, `GameRules`, `AiPlayer`, `GameBoardView`, `GameHost`, `GameResult`, `GameTexts` a game kit se během vývoje her nemění. Když hra něco od frameworku potřebuje, viz „Požadavky na framework“ níže.

## Kde co je a co smíš měnit

| Smíš měnit (větev `game/<id>`) | Nesmíš měnit |
|---|---|
| `lib/games/<id>/**` – kód hry | `lib/core/`, `lib/ui_kit/`, `lib/features/`, `lib/app/` |
| `assets/games/<id>/**` – obrázky, efekty, `CREDITS.json` | `lib/games/registry.dart` (hra už je zaregistrovaná) |
| `test/games/<id>/**` – testy hry | `lib/l10n/*.arb`, `pubspec.yaml`, CI, `tool/` |
| `assets/audio/music/<id>.ogg` – hudba hry | ostatní hry |

CI na větvích `game/*` spouští `dart run tool/check_scope.dart <větev>`. Spusť si ho i sám před PR. Nové balíčky (závislosti) jen se schválením Miloše.

Kostra hry už existuje:
- `<id>_module.dart`: manifest s `available: false`;
- `<id>_rules.dart`: prázdná pravidla;
- `<id>_icon.dart`;
- `<id>_texts.dart`;
- `README.md`.

Kostru nahraď skutečnou hrou. `available: true` přepni až v PR, kdy je hra hotová podle Definition of Done (13.4).

## Manifest (`GameModule<S>`)

`S` je typ stavu tvé hry, neměnná třída. Doplň:

| Položka | Co do ní patří |
|---|---|
| `id`, `titleKey`, `descriptionKey`, `rulesKey` | Klíče začínají `<id>.` |
| `texts` | `GameTexts(cs: {...}, en: {...}, es: {...})`: všechny texty hry ve všech 3 jazycích, klíče `<id>.*`, placeholdery `{name}` |
| `minPlayers`, `maxPlayers`, `supportsAi`, `difficulties` | |
| `options` | `ChoiceOption`/`ToggleOption`. Popisky jsou klíče `<id>.option.*`, hodnoty voleb přijdou v `GameConfig.options` |
| `badges` | `BadgeDef(id: '<id>.xxx', titleKey: '<id>.badge.xxx.title', …, condition: …)`. Herní události hlásí deska přes `view.host.reportEvent('<id>.xxx')` a podmínka `BadgeCondition.event('<id>.xxx')` |
| `sfx` | Nejvýš 3 vlastní efekty: `{'<id>.boing': 'games/<id>/sfx/boing.ogg'}`. Přehraješ je přes `view.host.playSfx('<id>.boing')`. Sdílené efekty (`tap`, `card_flip`, `dice_roll`, `piece_place`, …) jsou vždy k dispozici |
| `musicTrack` | Je vždy `<id>`, hudba `assets/audio/music/<id>.ogg` už je připravená |
| `pointsMultiplier` | 0,5–2 |
| `phoneOrientation` | |
| `supportsSaveResume` | |
| `rules`, `ai`, `icon`, `board`, `turnHint` | Viz níže |

Texty v UI hry čti přes `<id>Texts.of(context, '<id>.klic', {'name': …})`.

## Pravidla (`GameRules<S>`) – deterministický stavový automat

- `initialState(config, seed)` → `currentSeat` → `legalMoves(state, seat)` → `apply(state, move)` → … → `isOver` / `result`.
- **Žádné `Random()`**. Náhoda (míchání karet, kostka, rozmístění min) jen přes `SeededRandom` ze seedu, a pokud je potřeba během hry, ze stavu (ulož si stav generátoru do stavu hry).
- **Každá akce hráče je `Move`** (malý JSON), i hod kostkou nebo otočení karty. Deska nikdy nemění stav sama, jen volá `view.submit(move)`.
- `legalMoves` je pro hráče na tahu vždy neprázdné (případně obsahuje tah „pas“). Framework z něj vybere tah, když AI selže.
- Stav i tahy musí projít `toJson`/`fromJson`. Hash stavu se počítá ze `stateToJson`.
- **Čas:** `view.elapsed()` vrací herní čas bez pauz a ukládá se s partií. Potřebuješ-li ho pro hodnocení (Miny, Pexeso), pošli ho v tahu (`data: {'t': view.elapsed().inMilliseconds}`). Replay pak dá stejný výsledek.

## AI (`AiPlayer<S>`)

- `chooseMove(state, seat, difficulty, random)` je čistá a synchronní funkce. Framework ji spouští v izolátu a dělá prodlevu podle rychlosti robota.
- Pro hry s tahy a protitahy použij **`GameSearch`** z game kitu:

```dart
final search = GameSearch<MyState>(
  moves: (s) => rules.legalMovesOfCurrent(s),
  apply: rules.apply,
  currentSeat: rules.currentSeat,
  evaluate: (s, seat) => myEvaluation(s, seat), // výhra = velké kladné číslo
);
final move = search.best(state, seat, maxDepth: 6, timeLimit: const Duration(milliseconds: 700), tieBreak: random);
```

- Lehká AI musí být porazitelná sedmiletým dítětem. Těžká musí porazit Lehkou v ≥ 80 % partií (u her s náhodou ≥ 60 %).

## Deska (`board(context, view)`)

`GameBoardView` obsahuje:
- `state` a `lastMove`;
- `mySeat` (člověk na tahu na tomto zařízení);
- `canAct`;
- `submit(move)`;
- `host` (efekty, haptika, události);
- `elapsed()`.

HUD (hráči, skóre, pauza, bublina s `turnHint`) i výsledky kreslí framework.

**Game kit** (`lib/core/game_kit/`):
- `BoardGrid(columns:, rows:, cellBuilder:, onTap:, highlighted:)`:
  - mřížka, tap → `(sloupec, řádek)`;
  - políčka ≥ 48 dp, a když se nevejdou, pinch-zoom a posun;
  - `BoardGridController.reset()` pro tlačítko „vycentrovat“.
- `PieceToken(seat:, size:, pulse:)`: figurka v barvě hráče se značkou pro barvoslepé. `HoppingPiece(path:, child:)` ji přesune po polích s poskokem.
- `FlipCard(faceUp:, front:, back:)`: karta s 3D otočením.
- `Dice(value:, rolling:, label:, onTap:)`: kostka. Hodnotu určuje stav hry, widget ji jen ukazuje.
- `GameSearch`: viz AI.

Všechny animace respektují omezení pohybu (`MediaQuery.disableAnimationsOf`). Vizuál podle kap. 6:
- plsť, dřevo, papír;
- barvy hráčů `AppColors.players[0..3]`;
- písmo `AppTypography`.

## Assety

- Obrázky a vlastní efekty dávej do `assets/games/<id>/…`. Složky jsou předem uvedené v `pubspec.yaml`:
  - `assets/games/<id>/`
  - `…/sfx/`
  - pro Pexeso `…/cards/{animals,food,transport,space}/`
- Novou podsložku přidat nesmíš. Když ji potřebuješ, napiš požadavek na framework.
- Licence cizích obrázků a zvuků zapiš do `assets/games/<id>/CREDITS.json` (stejný formát jako `assets/audio/CREDITS.json`). Obrazovka Autoři a licence je načte sama.
- Zástupné efekty hry vyrábí `tool/generate_placeholder_audio.py`. Skutečný zvuk prostě nahraď (OGG Vorbis kolem 64 kb/s) a uprav jeho záznam v `CREDITS.json` hry.

## Testy

- `test/games/<id>/contract_test.dart`:

```dart
import 'package:deskovky/games/<id>/<id>_module.dart';
import '../contract.dart';

void main() => runGameContract(<id>Module);
```

- Kontrakt ověří:
  - manifest a texty ve 3 jazycích;
  - efekty a hudbu;
  - start pro každý počet hráčů, kombinaci lidí a robotů a obtížnost;
  - AI samo se sebou bez nelegálního tahu;
  - platný výsledek;
  - JSON, replay a uložení a obnovení;
  - že se deska vykreslí.

  Dokud hra není hratelná, testuje ho `test/games/contract_all_test.dart` jen s `playable: false`.
- Dál piš unit testy pravidel (všechna pravidla včetně hraničních případů), AI (síla podle obtížností) a widget testy desky. Widget testy dělej ve velikostech 360×740, 412×915, 800×1280 a 1280×800.
- Testy UI s databází a assety: reálné I/O dokončuj smyčkou `tester.runAsync(() => Future.delayed(…))` + `pumpAndSettle()`.
- Rychlé spuštění jen tvé hry: `flutter run --dart-define=GAME=<id>` (debug build) otevře rovnou její nastavení.

## Požadavky na framework

Framework neupravuj. Když něco chybí, zapiš to do `lib/games/<id>/FRAMEWORK_REQUESTS.md`: co, proč a navržené API. Dočasně to vyřeš ve své složce a pokračuj. Požadavky zpracuje samostatná větev `framework/*`; po jejím sloučení se herní větve rebasují na `main`.

## Hotovo (Definition of Done, zadání 13.4)

Projdi seznam ve 13.4. Pak:
1. přepni `available: true`;
2. doplň `README.md` hry (pravidla, architektura, AI);
3. ověř `check_scope`;
4. otevři PR do `main`.

Vydání (tag) dělá jen Miloš nebo integrační session.
