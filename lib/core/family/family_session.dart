import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The family sync after both devices proved they know the family key
/// (review R-007): every message is encrypted and signed, so nobody on the
/// Wi-Fi reads the children's names or the games, and a message changed,
/// dropped, repeated or reordered on the way stops the sync.
///
/// Built only from HMAC-SHA256 (package `crypto`): keys derived from the
/// family key and both nonces (as in HKDF), a keystream from HMAC in
/// counter mode, and encrypt-then-MAC over a message number per direction.
class FamilySession {
  FamilySession({required List<int> familyKey, required String firstNonce, required String secondNonce, required String me, required String peer})
    : _sendEnc = _derive(familyKey, firstNonce, secondNonce, 'enc', me),
      _sendMac = _derive(familyKey, firstNonce, secondNonce, 'mac', me),
      _readEnc = _derive(familyKey, firstNonce, secondNonce, 'enc', peer),
      _readMac = _derive(familyKey, firstNonce, secondNonce, 'mac', peer);

  final List<int> _sendEnc, _sendMac, _readEnc, _readMac;
  var _sent = 0;
  var _read = 0;

  static List<int> _derive(List<int> key, String first, String second, String use, String device) {
    final prk = Hmac(sha256, key).convert(utf8.encode('deskovky-session|$first|$second')).bytes;
    return Hmac(sha256, prk).convert(utf8.encode('$use|$device')).bytes;
  }

  /// [body] as `{'t': 'sealed', 'n': number, 'c': ciphertext, 'm': mac}`.
  Map<String, Object?> seal(Map<String, Object?> body) {
    final n = _sent++;
    final cipher = _xor(_sendEnc, n, utf8.encode(jsonEncode(body)));
    return {'t': 'sealed', 'n': n, 'c': base64.encode(cipher), 'm': _mac(_sendMac, n, cipher)};
  }

  /// The message inside [sealed]; null when it was changed, repeated, left
  /// out or is not sealed at all.
  Map<String, Object?>? open(Map<String, Object?> sealed) {
    final n = sealed['n'], c = sealed['c'], m = sealed['m'];
    if (sealed['t'] != 'sealed' || n is! int || c is! String || m is! String || n != _read) return null;
    final List<int> cipher;
    try {
      cipher = base64.decode(c);
    } on FormatException {
      return null;
    }
    if (!_same(_mac(_readMac, n, cipher), m)) return null;
    _read++;
    try {
      final body = jsonDecode(utf8.decode(_xor(_readEnc, n, cipher)));
      return body is Map<String, Object?> ? body : null;
    } on FormatException {
      return null;
    }
  }

  static String _mac(List<int> key, int n, List<int> cipher) =>
      Hmac(sha256, key).convert([..._u64(n), ...cipher]).toString();

  /// [data] xor the keystream HMAC(key, n ‖ block) for message number [n].
  static Uint8List _xor(List<int> key, int n, List<int> data) {
    final out = Uint8List(data.length);
    final hmac = Hmac(sha256, key);
    final prefix = _u64(n);
    for (var block = 0; block * 32 < data.length; block++) {
      final stream = hmac.convert([...prefix, ..._u64(block)]).bytes;
      for (var i = 0; i < 32 && block * 32 + i < data.length; i++) {
        out[block * 32 + i] = data[block * 32 + i] ^ stream[i];
      }
    }
    return out;
  }

  static List<int> _u64(int v) => [for (var i = 7; i >= 0; i--) (v >> (8 * i)) & 0xff];

  /// Compares in constant time.
  static bool _same(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
