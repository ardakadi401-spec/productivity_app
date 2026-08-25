import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/exceptions/app_exceptions.dart';

/// Platformun güvenli şifrelenmiş deposu (Android Keystore / iOS Keychain)
/// üzerinden PIN hash'i + tuzu (salt) + kilit yöntemini saklar.
///
/// DATABASE.md §16.3 — bu veri Isar'a/Firestore'a HİÇ yazılmaz, bu yüzden
/// diğer feature datasource'larından farklı olarak `getPendingSync()` gibi
/// bir senkronizasyon kuyruğu kavramı burada yoktur.
class LockSecureDatasource {
  LockSecureDatasource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _pinHashKey = 'lock_pin_hash';
  static const _pinSaltKey = 'lock_pin_salt';
  static const _methodKey = 'lock_method';

  Future<String?> readPinHash() => _guard(() => _storage.read(key: _pinHashKey));

  Future<String?> readPinSalt() => _guard(() => _storage.read(key: _pinSaltKey));

  Future<String?> readMethod() => _guard(() => _storage.read(key: _methodKey));

  Future<void> writePin({required String hash, required String salt}) => _guard(() async {
        await _storage.write(key: _pinHashKey, value: hash);
        await _storage.write(key: _pinSaltKey, value: salt);
      });

  Future<void> writeMethod(String method) =>
      _guard(() => _storage.write(key: _methodKey, value: method));

  Future<void> clearPin() => _guard(() async {
        await _storage.delete(key: _pinHashKey);
        await _storage.delete(key: _pinSaltKey);
      });

  Future<void> clearAll() => _guard(() async {
        await _storage.delete(key: _pinHashKey);
        await _storage.delete(key: _pinSaltKey);
        await _storage.delete(key: _methodKey);
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw CacheException('Güvenli depolama hatası: $e');
    }
  }
}
