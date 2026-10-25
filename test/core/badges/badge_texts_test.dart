import 'package:deskovky/core/badges/framework_badges.dart';
import 'package:deskovky/games/badge_texts.dart';
import 'package:deskovky/games/registry.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final all = [...frameworkBadges, for (final m in gameModules) ...m.badges];

  test('game badges carry their game id as prefix; ids are unique', () {
    for (final m in gameModules) {
      for (final b in m.badges) {
        expect(b.id, startsWith('${m.id}.'));
      }
    }
    expect({for (final b in all) b.id}.length, all.length);
    expect(sampleBadgeIds(), contains('sample.bullseye'));
  });

  for (final code in ['cs', 'en', 'es']) {
    test('every badge has a title and description in $code', () async {
      final l10n = await AppLocalizations.delegate.load(Locale(code));
      for (final b in all) {
        expect(badgeText(l10n, b.titleKey), isNot(b.titleKey), reason: b.titleKey);
        expect(badgeText(l10n, b.descriptionKey), isNot(b.descriptionKey), reason: b.descriptionKey);
      }
    });
  }
}

List<String> sampleBadgeIds() => [for (final b in moduleById('sample')!.badges) b.id];
