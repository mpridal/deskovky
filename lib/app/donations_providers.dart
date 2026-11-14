import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/donations/donors.dart';
import 'providers.dart';

/// Where the donors list comes from; tests swap in their own.
final donorsSourceProvider = Provider<DonorsSource>((ref) => GitHubDonorsSource());

/// The donors: the list kept from last time at once, then the fresh one
/// when the internet answers (each time the Dary tab opens).
final donorsProvider = StreamProvider.autoDispose<List<Donor>>((ref) async* {
  final repo = DonorsRepository(ref.watch(databaseProvider), ref.watch(donorsSourceProvider));
  yield await repo.cached();
  final fresh = await repo.refresh();
  if (fresh != null) yield fresh;
});
