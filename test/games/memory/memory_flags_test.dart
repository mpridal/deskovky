import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/games/memory/memory_card_art.dart';
import 'package:deskovky/games/memory/memory_flags.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:deskovky/core/game/game_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';

const rules = MemoryRules();

GameConfig flags(int cards) => GameConfig(
  gameId: 'memory',
  seats: const [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'cards': cards, 'set': memoryFlagsSet},
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('golden: flag cards, big and small', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 260);
    addTearDown(tester.view.reset);
    final codes = ['cz', 'np', 'vc', 'gb', 'br', 'st'];
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('cs'),
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            child: ColoredBox(
              color: const Color(0xFF2F5D50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final side in [96.0, 60.0])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final c in codes)
                          SizedBox(
                            width: side,
                            height: side,
                            child: MemoryCardFace(set: memoryFlagsSet, motif: memoryFlags.indexWhere((f) => f.code == c)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await tester.pump();
    await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('goldens/flags.png'));
  }, skip: !Platform.isWindows);

  test('every state: 195 different codes, a name in each language, a picture', () {
    expect(memoryFlags, hasLength(195));
    expect({for (final f in memoryFlags) f.code}, hasLength(195));
    for (final (i, f) in memoryFlags.indexed) {
      for (final name in [f.cs, f.en, f.es]) {
        expect(name.trim(), isNotEmpty, reason: f.code);
      }
      expect(File(memoryFlagAsset(i)).existsSync(), isTrue, reason: memoryFlagAsset(i));
    }
    expect(memoryFlags.firstWhere((f) => f.code == 'cz').name('cs'), 'Česko');
    expect(memoryFlags.firstWhere((f) => f.code == 'cz').name('es'), 'Chequia');
  });

  test('the set is offered in the setup', () {
    final set = memoryModule.options.whereType<ChoiceOption>().firstWhere((o) => o.id == 'set');
    expect([for (final (v, _) in set.choices) v], contains(memoryFlagsSet));
  });

  test('a game deals pairs of flags from all the states, never two look-alikes', () {
    for (final cards in MemoryRules.cardCounts) {
      for (var seed = 0; seed < 30; seed++) {
        final s = rules.initialState(flags(cards), seed);
        expect(s.set, memoryFlagsSet);
        final motifs = s.faces.toSet();
        expect(motifs, hasLength(cards ~/ 2));
        expect(motifs.every((m) => m >= 0 && m < memoryFlags.length), isTrue);
        final families = [
          for (final m in motifs)
            if (memoryFlags[m].family != null) memoryFlags[m].family,
        ];
        expect(families.toSet(), hasLength(families.length), reason: 'seed $seed: two look-alike flags');
      }
    }
  });

  test('the flags rotate: other games deal other states', () {
    final seen = <int>{};
    final games = <Set<int>>{};
    for (var seed = 0; seed < 20; seed++) {
      final motifs = rules.initialState(flags(16), seed).faces.toSet();
      seen.addAll(motifs);
      games.add(motifs);
    }
    expect(games, hasLength(20), reason: 'every game a different selection');
    expect(seen.length, greaterThan(80), reason: 'over 20 games most of the world turns up');
  });

  testWidgets('a flag card shows the flag and the state name in the app language', (tester) async {
    final cz = memoryFlags.indexWhere((f) => f.code == 'cz');
    for (final (locale, name) in const [(Locale('cs'), 'Česko'), (Locale('en'), 'Czechia'), (Locale('es'), 'Chequia')]) {
      await tester.pumpWidget(
        Localizations(
          locale: locale,
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: SizedBox(width: 90, height: 90, child: MemoryCardFace(set: memoryFlagsSet, motif: cz))),
          ),
        ),
      );
      expect(find.text(name), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    }
  });

  testWidgets('the longest names fit even a small card', (tester) async {
    for (final code in ['vc', 'st', 'cd', 'cf']) {
      final m = memoryFlags.indexWhere((f) => f.code == code);
      for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
        await tester.pumpWidget(
          Localizations(
            locale: locale,
            delegates: const [DefaultWidgetsLocalizations.delegate],
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(child: SizedBox(width: 56, height: 56, child: MemoryCardFace(set: memoryFlagsSet, motif: m))),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$code $locale');
        final text = tester.getRect(find.byType(Text));
        final card = tester.getRect(find.byType(MemoryCardFace));
        expect(card.contains(text.topLeft) && card.contains(text.bottomRight - const Offset(0.01, 0.01)), isTrue, reason: '$code $locale');
      }
    }
  });
}
