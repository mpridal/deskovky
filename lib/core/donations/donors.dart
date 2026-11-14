import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../db/app_database.dart';

/// One person who supported the game, as listed in `donors.json` of the
/// repository (kept by hand, only with the donor's consent: Google Play
/// tells the developer no names).
@immutable
class Donor {
  const Donor({required this.name, required this.amount, required this.currency, this.date});

  final String name;
  final num amount;
  final String currency;
  final DateTime? date;

  /// "25 €", "2,50 €", "10 CZK".
  String get amountText {
    final whole = amount == amount.roundToDouble();
    final number = whole ? '${amount.round()}' : amount.toStringAsFixed(2).replaceAll('.', ',');
    return currency == 'EUR' ? '$number €' : '$number $currency';
  }

  static Donor? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final name = json['name'], amount = json['amount'], currency = json['currency'], date = json['date'];
    if (name is! String || name.trim().isEmpty || amount is! num) return null;
    return Donor(
      name: name.trim(),
      amount: amount,
      currency: currency is String && currency.isNotEmpty ? currency : 'EUR',
      date: date is String ? DateTime.tryParse(date) : null,
    );
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'amount': amount,
    'currency': currency,
    if (date != null) 'date': date!.toIso8601String().substring(0, 10),
  };

  /// The donors of a list file, newest first (undated ones last); entries
  /// that are not a donor are skipped.
  static List<Donor> listFromJson(Object? json) {
    if (json is! List) return const [];
    final donors = [for (final e in json) ?fromJson(e)];
    final dated = donors.where((d) => d.date != null).toList()..sort((a, b) => b.date!.compareTo(a.date!));
    return [...dated, ...donors.where((d) => d.date == null)];
  }
}

/// Where the list of donors comes from.
abstract interface class DonorsSource {
  /// The donors, or null when there is nothing to say; throws when offline.
  Future<List<Donor>?> fetch();
}

/// `donors.json` in the public repository – the same place the app already
/// asks for new versions. Nothing about the player is sent.
class GitHubDonorsSource implements DonorsSource {
  GitHubDonorsSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final url = Uri.https('raw.githubusercontent.com', '/mpridal/deskovky/main/donors.json');

  @override
  Future<List<Donor>?> fetch() async {
    final response = await _client.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) throw http.ClientException('HTTP ${response.statusCode}', url);
    // Raw files come without a charset: always UTF-8.
    return Donor.listFromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }
}

/// The donors as last seen, kept for offline, and refreshed from [source].
class DonorsRepository {
  DonorsRepository(this._db, this.source);

  final AppDatabase _db;
  final DonorsSource source;

  static const _key = 'donors.cache';

  Future<List<Donor>> cached() async {
    final row = await (_db.select(_db.appSettings)..where((s) => s.key.equals(_key))).getSingleOrNull();
    if (row == null) return const [];
    try {
      return Donor.listFromJson(jsonDecode(row.value));
    } on FormatException {
      return const [];
    }
  }

  /// The fresh list (also kept), or null when it could not be had.
  Future<List<Donor>?> refresh() async {
    final List<Donor>? got;
    try {
      got = await source.fetch();
    } on Object catch (e) {
      debugPrint('Donors: $e');
      return null;
    }
    if (got == null) return null;
    final json = [for (final d in got) d.toJson()];
    // Newest first, whatever order the source had.
    final fresh = Donor.listFromJson(json);
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(AppSettingsCompanion.insert(key: _key, value: jsonEncode(json)));
    return fresh;
  }
}
