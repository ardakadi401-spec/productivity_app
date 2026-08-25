import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/lock_settings.dart';
import '../../domain/repositories/lock_repository.dart';
import '../datasources/local/biometric_datasource.dart';
import '../datasources/local/lock_secure_datasource.dart';

/// ARCHITECTURE.md §13.3 — PIN düz metin olarak HİÇ saklanmaz; yalnızca
/// rastgele bir tuz (salt) ile SHA-256 hash'i saklanır. `watchLockSettings`,
/// güvenli depolamanın kendisi reaktif olmadığından, her yazma sonrası
/// yeniden okuyup bir `StreamController`'a ileten basit bir desendir (Isar
/// Stream'lerinin sağladığı reaktiviteyi burada elle taklit eder).
class LockRepositoryImpl implements LockRepository {
  LockRepositoryImpl(this._secure, this._biometric) {
    unawaited(_refresh());
  }

  final LockSecureDatasource _secure;
  final BiometricDatasource _biometric;
  final _controller = StreamController<LockSettings>.broadcast();
  LockSettings _current = LockSettings.disabled;

  @override
  Stream<LockSettings> watchLockSettings() async* {
    yield _current;
    yield* _controller.stream;
  }

  Future<void> _refresh() async {
    try {
      final methodName = await _secure.readMethod();
      final hash = await _secure.readPinHash();
      final method = LockMethod.values.firstWhere(
        (m) => m.name == methodName,
        orElse: () => LockMethod.none,
      );
      _current = LockSettings(method: method, hasPinSet: hash != null);
      _controller.add(_current);
    } catch (_) {
      // Sessiz — bir sonraki yazma/okuma denemesinde tekrar denenir.
    }
  }

  @override
  Future<Result<void>> setPin(String pin) => _guard(() async {
        final salt = _generateSalt();
        final hash = _hashPin(pin, salt);
        await _secure.writePin(hash: hash, salt: salt);
        await _refresh();
      });

  @override
  Future<Result<bool>> verifyPin(String pin) => _guard(() async {
        final hash = await _secure.readPinHash();
        final salt = await _secure.readPinSalt();
        if (hash == null || salt == null) return false;
        return _hashPin(pin, salt) == hash;
      });

  @override
  Future<Result<void>> setLockMethod(LockMethod method) => _guard(() async {
        await _secure.writeMethod(method.name);
        await _refresh();
      });

  @override
  Future<Result<void>> disableLock() => _guard(() async {
        await _secure.clearAll();
        await _refresh();
      });

  @override
  Future<bool> isBiometricAvailable() => _biometric.isAvailable();

  @override
  Future<Result<bool>> authenticateWithBiometric() async {
    final result = await _biometric.authenticate();
    return Ok(result);
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Failure _mapToFailure(AppException exception) {
    return switch (exception) {
      CacheException(:final message) => CacheFailure(message),
      PermissionException(:final message) => PermissionFailure(message),
      _ => UnknownFailure(exception.message),
    };
  }
}
