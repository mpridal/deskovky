import 'dart:convert';

import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/donations/donors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/test_database.dart';

class _Source implements DonorsSource {
  _Source(this.result);

  List<Donor>? result;
  Object? error;
  var calls = 0;

  @override
  Future<List<Donor>?> fetch() async {
    calls++;
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('the list file is read leniently: newest first, broken entries skipped', () {
    final donors = Donor.listFromJson([
      {'name': 'Babička Jana', 'amount': 25, 'currency': 'EUR', 'date': '2026-11-02'},
      {'name': 'Rodina Novákových', 'amount': 5, 'currency': 'EUR', 'date': '2026-11-10'},
      {'name': '', 'amount': 5, 'date': '2026-11-11'},
      {'name': 'Bez data', 'amount': 2},
      'nonsense',
      {'name': 'Strýc Pepa', 'amount': 'deset', 'date': '2026-11-12'},
    ]);
    expect([for (final d in donors) d.name], ['Rodina Novákových', 'Babička Jana', 'Bez data']);
    expect(donors.first.amount, 5);
    expect(donors.first.currency, 'EUR');
    expect(donors.last.currency, 'EUR', reason: 'euro by default');
    expect(Donor.listFromJson({'not': 'a list'}), isEmpty);
  });

  test('the amount reads as a sum: "25 €", "2,50 €"', () {
    expect(const Donor(name: 'A', amount: 25, currency: 'EUR').amountText, '25 €');
    expect(const Donor(name: 'A', amount: 2.5, currency: 'EUR').amountText, '2,50 €');
    expect(const Donor(name: 'A', amount: 10, currency: 'CZK').amountText, '10 CZK');
  });

  test('the list is kept for offline; a failed fetch keeps the last one', () async {
    final source = _Source([const Donor(name: 'Babička Jana', amount: 25, currency: 'EUR')]);
    final repo = DonorsRepository(db, source);
    expect(await repo.cached(), isEmpty);
    expect((await repo.refresh())!.single.name, 'Babička Jana');
    expect((await DonorsRepository(db, _Source(null)).cached()).single.name, 'Babička Jana');

    source.error = http.ClientException('offline');
    expect(await repo.refresh(), isNull);
    expect((await repo.cached()).single.name, 'Babička Jana', reason: 'nothing lost offline');
  });

  test('the GitHub source reads donors.json of the repository as UTF-8', () async {
    late Uri asked;
    final client = MockClient((request) async {
      asked = request.url;
      // Raw files come without a charset: must not turn into "BabiÄka".
      return http.Response.bytes(
        utf8.encode('[{"name": "Babička Jana", "amount": 25, "currency": "EUR", "date": "2026-11-02"}]'),
        200,
      );
    });
    final donors = await GitHubDonorsSource(client: client).fetch();
    expect(asked.toString(), 'https://raw.githubusercontent.com/mpridal/deskovky/main/donors.json');
    expect(donors!.single.name, 'Babička Jana');
    final missing = await GitHubDonorsSource(client: MockClient((_) async => http.Response('', 404))).fetch();
    expect(missing, isEmpty, reason: 'no file yet: nobody yet');
  });
}
