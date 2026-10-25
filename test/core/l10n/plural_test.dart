import 'package:deskovky/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Czech plural has one / few / other forms', () {
    final cs = lookupAppLocalizations(const Locale('cs'));
    expect(cs.playersCount(1), '1 hráč');
    expect(cs.playersCount(3), '3 hráči');
    expect(cs.playersCount(5), '5 hráčů');
  });

  test('English plural', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.playersCount(1), '1 player');
    expect(en.playersCount(2), '2 players');
  });

  test('Spanish plural', () {
    final es = lookupAppLocalizations(const Locale('es'));
    expect(es.playersCount(1), '1 jugador');
    expect(es.playersCount(4), '4 jugadores');
  });
}
