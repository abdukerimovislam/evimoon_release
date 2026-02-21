import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Encrypted backup envelope (version 2):
/// {
///   "version": 2,
///   "alg": "AES-GCM-256",
///   "kdf": "PBKDF2-HMAC-SHA256",
///   "iter": 200000,
///   "salt": "<base64>",
///   "nonce": "<base64>",
///   "ciphertext": "<base64>",
///   "mac": "<base64>"
/// }
class BackupCrypto {
  static const int version = 2;
  static const int _saltBytes = 16;
  static const int _nonceBytes = 12;
  static const int _keyBytes = 32;
  static const int _iterations = 200000;

  static final AesGcm _cipher = AesGcm.with256bits();

  static String encryptToEnvelopeJson({
    required String plaintext,
    required String password,
  }) {
    final envelope = encryptToEnvelope(
      plaintext: plaintext,
      password: password,
    );
    return jsonEncode(envelope);
  }

  static Map<String, dynamic> encryptToEnvelope({
    required String plaintext,
    required String password,
  }) {
    final rnd = Random.secure();
    final salt = Uint8List.fromList(List<int>.generate(_saltBytes, (_) => rnd.nextInt(256)));
    final nonce = Uint8List.fromList(List<int>.generate(_nonceBytes, (_) => rnd.nextInt(256)));

    // PBKDF2 derive key
    return _encryptSync(
      plaintext: plaintext,
      password: password,
      salt: salt,
      nonce: nonce,
    );
  }

  static String decryptEnvelopeJsonToPlaintext({
    required String envelopeJson,
    required String password,
  }) {
    final Map<String, dynamic> env = jsonDecode(envelopeJson);
    return decryptEnvelopeToPlaintext(envelope: env, password: password);
  }

  static String decryptEnvelopeToPlaintext({
    required Map<String, dynamic> envelope,
    required String password,
  }) {
    if (envelope['version'] != version ||
        envelope['alg'] != 'AES-GCM-256' ||
        envelope['kdf'] != 'PBKDF2-HMAC-SHA256' ||
        envelope['salt'] == null ||
        envelope['nonce'] == null ||
        envelope['ciphertext'] == null ||
        envelope['mac'] == null) {
      throw const FormatException('Invalid encrypted backup format');
    }

    final int iter = (envelope['iter'] is int) ? envelope['iter'] as int : _iterations;

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final cipherText = base64Decode(envelope['ciphertext'] as String);
    final macBytes = base64Decode(envelope['mac'] as String);

    return _decryptSync(
      password: password,
      salt: Uint8List.fromList(salt),
      nonce: Uint8List.fromList(nonce),
      cipherText: Uint8List.fromList(cipherText),
      macBytes: Uint8List.fromList(macBytes),
      iterations: iter,
    );
  }

  static Map<String, dynamic> _encryptSync({
    required String plaintext,
    required String password,
    required Uint8List salt,
    required Uint8List nonce,
  }) {
    // NOTE: cryptography is async-first, but for simplicity we use sync wrappers via Future.wait below.
    // In Dart VM, calling async is fine; we keep outer API sync by blocking with .then style not available.
    // So we implement a minimal async wrapper exposed by BackupService (which is async).
    // This private method is used by encryptToEnvelope which can be called from async context anyway.
    throw UnimplementedError('Use encryptEnvelopeAsync() instead');
  }

  static Future<Map<String, dynamic>> encryptEnvelopeAsync({
    required String plaintext,
    required String password,
  }) async {
    final rnd = Random.secure();
    final salt = Uint8List.fromList(List<int>.generate(_saltBytes, (_) => rnd.nextInt(256)));
    final nonce = Uint8List.fromList(List<int>.generate(_nonceBytes, (_) => rnd.nextInt(256)));

    final secretKey = await _deriveKey(password: password, salt: salt, iterations: _iterations);

    final secretBox = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return <String, dynamic>{
      'version': version,
      'alg': 'AES-GCM-256',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iter': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<String> decryptEnvelopeAsyncToPlaintext({
    required Map<String, dynamic> envelope,
    required String password,
  }) async {
    if (envelope['version'] != version ||
        envelope['alg'] != 'AES-GCM-256' ||
        envelope['kdf'] != 'PBKDF2-HMAC-SHA256') {
      throw const FormatException('Invalid encrypted backup format');
    }

    final int iter = (envelope['iter'] is int) ? envelope['iter'] as int : _iterations;

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final cipherText = base64Decode(envelope['ciphertext'] as String);
    final macBytes = base64Decode(envelope['mac'] as String);

    final secretKey = await _deriveKey(
      password: password,
      salt: Uint8List.fromList(salt),
      iterations: iter,
    );

    final secretBox = SecretBox(
      Uint8List.fromList(cipherText),
      nonce: Uint8List.fromList(nonce),
      mac: Mac(Uint8List.fromList(macBytes)),
    );

    final clearBytes = await _cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearBytes);
  }

  static Future<SecretKey> _deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _keyBytes * 8,
    );

    final baseKey = SecretKey(utf8.encode(password));
    return pbkdf2.deriveKey(secretKey: baseKey, nonce: salt);
  }

  // --- NOTE ---
  // The sync-only methods above are intentionally unused; keeping them prevents accidental usage.
  static String _decryptSync({
    required String password,
    required Uint8List salt,
    required Uint8List nonce,
    required Uint8List cipherText,
    required Uint8List macBytes,
    required int iterations,
  }) {
    throw UnimplementedError('Use decryptEnvelopeAsyncToPlaintext() instead');
  }
}
