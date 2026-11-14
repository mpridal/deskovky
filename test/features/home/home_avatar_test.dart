import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/features/home/active_player_bar.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }
}

AvatarSpec _homeAvatar(WidgetTester tester) =>
    tester.widget<AvatarView>(find.descendant(of: find.byType(ActivePlayerBar), matching: find.byType(AvatarView))).spec;

void main() {
  testWidgets('the home screen shows the active player as edited in Hráči', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    final kuba = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)))!;
    await tester.runAsync(() => SettingsRepository(db).setActivePlayerId(kuba.id));
    await pumpApp(tester, size: const Size(412, 915), db: db);
    await _settle(tester);
    expect(_homeAvatar(tester), AvatarSpec.defaults);

    final changed = AvatarSpec.defaults.copyWith(skin: 3, hairColor: 2, background: 4);
    await tester.runAsync(() => PlayerRepository(db).update(kuba.id, avatar: changed));
    await _settle(tester);
    expect(_homeAvatar(tester), changed);

    // Edited from the players tab and back home.
    await tester.tap(find.text('Hráči'));
    await _settle(tester);
    final again = changed.copyWith(skin: 1);
    await tester.runAsync(() => PlayerRepository(db).update(kuba.id, avatar: again));
    await _settle(tester);
    await tester.tap(find.text('Hry'));
    await _settle(tester);
    expect(_homeAvatar(tester), again);
  });

  testWidgets('a bought frame is not hidden under the ring of the home bar', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    final framed = AvatarSpec.defaults.copyWith(equipped: {AccessorySlot.frame: const EquippedItem('gold_frame')});
    final milos = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Miloš', avatar: framed)))!;
    await tester.runAsync(() => SettingsRepository(db).setActivePlayerId(milos.id));
    await pumpApp(tester, size: const Size(412, 915), db: db);
    await _settle(tester);
    expect(_homeAvatar(tester), framed);
    Finder ring() => find.descendant(
      of: find.byType(ActivePlayerBar),
      matching: find.byWidgetPredicate((w) => w is DecoratedBox && w.position == DecorationPosition.foreground),
    );
    expect(ring(), findsNothing, reason: 'the frame is the ring');

    await tester.runAsync(() => PlayerRepository(db).update(milos.id, avatar: AvatarSpec.defaults));
    await _settle(tester);
    expect(ring(), findsOneWidget, reason: 'without a frame the bar draws its own ring');
  });
}
