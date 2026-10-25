/// Deterministic xorshift32 generator. Game logic uses this instead of
/// `dart:math` `Random`, whose sequence is not guaranteed across platforms or
/// SDK versions – a seed must replay the same game everywhere (spec 8).
class SeededRandom {
  SeededRandom(int seed) : _state = _initial(seed);

  int _state;

  static int _initial(int seed) {
    final mixed = (seed ^ 0x9E3779B9) & 0xFFFFFFFF;
    return mixed == 0 ? 1 : mixed;
  }

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  /// Integer in `[0, max)`.
  int nextInt(int max) {
    assert(max > 0);
    return _next() % max;
  }

  /// Double in `[0, 1)`.
  double nextDouble() => _next() / 4294967296.0;
}
