import 'package:flutter/foundation.dart';

/// Maps music and effect ids (spec 7.2, 7.3) to asset paths. The one place
/// to change when Miloš's real recordings replace the placeholders.
@immutable
class AudioCatalog {
  const AudioCatalog({required this.music, required this.sfx});

  final Map<String, String> music;
  final Map<String, String> sfx;
}
