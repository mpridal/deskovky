import 'dart:math';

import 'package:flutter/foundation.dart';

/// A hybrid logical clock stamp (family sync): wall time in ms, a counter
/// for events within the same ms or after a clock went back, and the device
/// that made it. Orders every operation of the family the same way on every
/// device, and never goes backwards on one device.
@immutable
class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter, this.deviceId);

  final int millis;
  final int counter;
  final String deviceId;

  /// The stamp for a new local event at wall time [nowMillis].
  Hlc tick(int nowMillis) => nowMillis > millis ? Hlc(nowMillis, 0, deviceId) : Hlc(millis, counter + 1, deviceId);

  /// How far ahead of this device another one may be and still move its
  /// clock; more is a wrong date (a tablet with a flat battery), not time.
  static const maxDriftMillis = 24 * 3600 * 1000;

  /// This device's clock after seeing [remote] at wall time [nowMillis]. A
  /// stamp more than [maxDriftMillis] ahead is not followed (review R-010):
  /// its op still counts, but this device's next ops keep the real time.
  Hlc receive(Hlc remote, int nowMillis) {
    if (remote.millis > nowMillis + maxDriftMillis) return tick(nowMillis);
    final m = max(nowMillis, max(millis, remote.millis));
    final int c;
    if (m == millis && m == remote.millis) {
      c = max(counter, remote.counter) + 1;
    } else if (m == millis) {
      c = counter + 1;
    } else if (m == remote.millis) {
      c = remote.counter + 1;
    } else {
      c = 0;
    }
    return Hlc(m, c, deviceId);
  }

  @override
  int compareTo(Hlc other) {
    final byTime = millis.compareTo(other.millis);
    if (byTime != 0) return byTime;
    final byCounter = counter.compareTo(other.counter);
    if (byCounter != 0) return byCounter;
    return deviceId.compareTo(other.deviceId);
  }

  /// `millis:counter:device`, with millis and counter zero-padded so packed
  /// stamps also sort as text.
  String pack() => '${millis.toString().padLeft(15, '0')}:${counter.toString().padLeft(6, '0')}:$deviceId';

  static Hlc? unpack(String text) {
    final first = text.indexOf(':');
    final second = first < 0 ? -1 : text.indexOf(':', first + 1);
    if (second < 0) return null;
    final millis = int.tryParse(text.substring(0, first));
    final counter = int.tryParse(text.substring(first + 1, second));
    final device = text.substring(second + 1);
    if (millis == null || counter == null || device.isEmpty) return null;
    return Hlc(millis, counter, device);
  }

  @override
  bool operator ==(Object other) =>
      other is Hlc && other.millis == millis && other.counter == counter && other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(millis, counter, deviceId);

  @override
  String toString() => 'Hlc($millis, $counter, $deviceId)';
}
