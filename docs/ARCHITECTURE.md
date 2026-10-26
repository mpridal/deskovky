# Architektura – Deskovky

## Volba technologie: Flutter (Dart)

Kritéria z kap. 2 zadání a jak je Flutter splňuje:

| Kritérium | Řešení |
|---|---|
| Jeden kód pro telefon i tablet | Flutter vykresluje vlastní UI; rozložení řídí třídy šířky okna (`lib/ui_kit/layout/window_size.dart`). |
| Plynulé 60 fps animace | Vlastní renderovací engine (Impeller), animace bez mostu do nativních view. |
| Zvuk – smyčka hudby + víc efektů současně | Balíčky `just_audio` / `audioplayers` (milník 5). |
| Vektorová grafika kreslená kódem | `CustomPainter` (avatary, ikony her, herní prvky). |
| Lokální perzistence | SQLite přes Drift s verzovanými migracemi (milník 3). |
| Podepsaný APK v GitHub Actions | `flutter build apk --release` + keystore z GitHub Secrets (milník 8). |

Alternativa Capacitor + TypeScript by přinesla OTA aktualizace web-bundle. Nepotřebujeme je: aplikace se aktualizuje celým APK z GitHub Releases (kap. 4), a Flutter má lepší výkon animací a kreslení.

## Struktura

Dart kód musí ležet v `lib/`, proto adresáře z kap. 8 zadání žijí pod ním:

| Zadání | Repozitář |
|---|---|
| `/app` | `lib/app` – vstupní bod, routing (`go_router`), shell s navigací |
| `/core` | `lib/core` – modely, perzistence, služby, lokalizace |
| `/ui_kit` | `lib/ui_kit` – design tokeny, komponenty, layout |
| `/features/*` | `lib/features/*` – obrazovky frameworku |
| `/games/<id>` | `lib/games/<id>` – herní moduly |
| `/assets/...` | `assets/...` |

Pravidla rozsahu pro paralelní vývoj her (kap. 13.2) proto znamenají `lib/games/<id>/**`, `assets/games/<id>/**`, `test/games/<id>/**`, `assets/audio/music/<id>.ogg`.

## Klíčová rozhodnutí

- **Routing:** `go_router` se `StatefulShellRoute.indexedStack` – 4 záložky (Hry, Hráči, Žebříčky, Nastavení), každá si drží vlastní stav.
- **Lokalizace:** `flutter_localizations` + `gen-l10n`, ARB soubory v `lib/l10n`, šablona `app_en.arb` (klíče anglicky). Výchozí jazyk podle systému: `cs` → čeština, `es` → španělština, jinak angličtina.
- **Fonty:** Baloo 2 a Nunito jako variabilní TTF přibalené v `assets/fonts` (offline). Každý `TextStyle` nastavuje `fontWeight` i `FontVariation.weight`, aby se váha správně projevila.
- **Responzivita:** compact < 600 dp (spodní lišta, 2 sloupce), medium 600–839 (rail, 3 sloupce), expanded ≥ 840 (rail, 3–4 sloupce, pravý panel).

## Data a stav (milník 3)

- **Drift (SQLite)** – `lib/core/db/`. Typované dotazy, sledování změn jako `Stream`, verzované schéma se snapshoty v `drift_schemas/` a generovaným ověřovačem migrací (`test/core/db/generated/`). Soubor DB leží v adresáři aplikace (`drift_flutter`), aktualizace APK ho nemaže.
- **Repozitáře** – `PlayerRepository` (pravidla profilů z kap. 5.2), `SettingsRepository` (aktivní hráč, jazyk). UI k databázi nikdy nepřistupuje přímo.
- **Riverpod** – `lib/app/providers.dart`. Jediné místo, kde se skládají závislosti; v testech se `databaseProvider` přepíše paměťovou DB (`test/helpers/test_database.dart`). Proč Riverpod: testovatelné přepisování závislostí bez globálních singletonů a přímá podpora `Stream` → `AsyncValue`.

## Herní API (milník 4)

```
GameModule<S>  ── manifest hry: rozsah hráčů, volby, obtížnosti, rules, ai, board, icon
  rules: GameRules<S>   initialState(config, seed) → apply(state, Move) … isOver / result
  ai:    AiPlayer<S>    chooseMove(state, seat, difficulty, SeededRandom) – čistá funkce

Framework (lib/features/game_play):
  GameSession<S>  stav + log tahů + seed  →  toSave() = SavedGame (config, seed, moves)
  LocalTransport  ověří a aplikuje Move   (fáze 3: NetworkTransport, hry beze změny)
  TurnController  pořadí, roboti s prodlevou (RobotSpeed), AI přes AiRunner (izolát)
  GameScreen      HUD, pauza, ukládání při každém tahu a při odchodu z aplikace
```

- **Tok tahu:** deska → `GameBoardView.submit(Move)` → `TurnController.submitHuman` → `LocalTransport.submit` → `GameSession.apply` → listener uloží partii a překreslí HUD. Roboti posílají tahy stejnou cestou.
- **Náhoda** jen přes `SeededRandom` (vlastní xorshift32 se zamrzlou referenční posloupností), nikdy `dart:math Random` – uložená partie se musí přehrát stejně na každém zařízení i verzi.
- **Obnovení** = `GameSession.restore(rules, save)` přehraje tahy; neplatný tah nebo chybějící profil → partie se zahodí a otevře se nastavení.
- **Typ stavu:** framework zná jen `GameModule<Object?>`; `module.withType(<T>(m) => …)` vrátí typovaný kontext pro `GameSession<T>` a desku.
- **Registr:** `lib/games/registry.dart`. Texty her zatím ve sdílených ARB s prefixem hry (`sample…`), milník 9 je přesune do složek her.

## Statistiky, žebříčky a odznaky (m6)

- Schéma v3: `matches` (hra, čas v ms, délka, obtížnost robotů nebo NULL), `match_participants` (místo, skóre, hvězdy; robot/smazaný hráč), `player_counters` (součty událostí z `reportEvent`), `earned_badges`.
- `StatsService` (vrstva `app`, zná registr her) po konci partie zapíše záznam, spočítá statistiky každého člověka a vyhodnotí odznaky (rámcové `frameworkBadges` + `GameModule.badges`). Nové odznaky jdou do `GameOutcomeView.newBadges` → výsledky (vyjetí zespodu, fanfára `achievement`).
- Statistiky (`computePlayerStats`) a žebříčky (`leaderboard`) se počítají v paměti ze všech partií (`allMatchesProvider`) – rodinné zařízení jich má nejvýš tisíce; kdyby to zpomalilo, přejít na SQL agregace.
- Žebříček řadí podle výher (pak % výher); body z m7 ho doplní.

