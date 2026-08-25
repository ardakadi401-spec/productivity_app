import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/features/settings/data/datasources/local/biometric_datasource.dart';
import 'package:productivity_app/features/settings/data/datasources/local/lock_secure_datasource.dart';
import 'package:productivity_app/features/settings/data/repositories/lock_repository_impl.dart';
import 'package:productivity_app/features/settings/domain/entities/lock_settings.dart';

class _MockSecure extends Mock implements LockSecureDatasource {}

class _MockBiometric extends Mock implements BiometricDatasource {}

void main() {
  late _MockSecure secure;
  late _MockBiometric biometric;
  late LockRepositoryImpl repository;

  setUp(() {
    secure = _MockSecure();
    biometric = _MockBiometric();
    when(() => secure.readMethod()).thenAnswer((_) async => null);
    when(() => secure.readPinHash()).thenAnswer((_) async => null);
    when(() => secure.readPinSalt()).thenAnswer((_) async => null);
    repository = LockRepositoryImpl(secure, biometric);
  });

  group('setPin / verifyPin', () {
    test('doğru PIN ile verifyPin true döner (hash+salt round-trip)', () async {
      String? storedHash;
      String? storedSalt;
      when(() => secure.writePin(hash: any(named: 'hash'), salt: any(named: 'salt')))
          .thenAnswer((invocation) async {
        storedHash = invocation.namedArguments[#hash] as String;
        storedSalt = invocation.namedArguments[#salt] as String;
      });

      final setResult = await repository.setPin('1234');
      expect(setResult, isA<Ok<void>>());

      when(() => secure.readPinHash()).thenAnswer((_) async => storedHash);
      when(() => secure.readPinSalt()).thenAnswer((_) async => storedSalt);

      final verifyResult = await repository.verifyPin('1234');
      expect((verifyResult as Ok<bool>).value, isTrue);
    });

    test('yanlış PIN ile verifyPin false döner', () async {
      String? storedHash;
      String? storedSalt;
      when(() => secure.writePin(hash: any(named: 'hash'), salt: any(named: 'salt')))
          .thenAnswer((invocation) async {
        storedHash = invocation.namedArguments[#hash] as String;
        storedSalt = invocation.namedArguments[#salt] as String;
      });

      await repository.setPin('1234');
      when(() => secure.readPinHash()).thenAnswer((_) async => storedHash);
      when(() => secure.readPinSalt()).thenAnswer((_) async => storedSalt);

      final verifyResult = await repository.verifyPin('9999');
      expect((verifyResult as Ok<bool>).value, isFalse);
    });

    test('hiç PIN ayarlanmamışsa verifyPin false döner (hata değil)', () async {
      final result = await repository.verifyPin('1234');

      expect((result as Ok<bool>).value, isFalse);
    });

    test('PIN düz metin olarak asla saklanmaz — yazılan değer PIN\'in kendisi değildir', () async {
      String? storedHash;
      when(() => secure.writePin(hash: any(named: 'hash'), salt: any(named: 'salt')))
          .thenAnswer((invocation) async {
        storedHash = invocation.namedArguments[#hash] as String;
      });

      await repository.setPin('1234');

      expect(storedHash, isNot('1234'));
      expect(storedHash, isNotNull);
      expect(storedHash!.length, greaterThan(32)); // SHA-256 hex = 64 karakter
    });

    test('storage hatası CacheFailure olarak döner', () async {
      when(() => secure.writePin(hash: any(named: 'hash'), salt: any(named: 'salt')))
          .thenThrow(const CacheException('disk dolu'));

      final result = await repository.setPin('1234');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('setLockMethod / disableLock', () {
    test('setLockMethod repository\'e yazar ve watchLockSettings\'i günceller', () async {
      when(() => secure.writeMethod('pin')).thenAnswer((_) async {});
      when(() => secure.readMethod()).thenAnswer((_) async => 'pin');
      when(() => secure.readPinHash()).thenAnswer((_) async => 'hash');

      final result = await repository.setLockMethod(LockMethod.pin);

      expect(result, isA<Ok<void>>());
      final settings = await repository.watchLockSettings().first;
      expect(settings.method, LockMethod.pin);
      expect(settings.hasPinSet, isTrue);
    });

    test('disableLock tüm kilit verisini temizler', () async {
      when(() => secure.clearAll()).thenAnswer((_) async {});
      when(() => secure.readMethod()).thenAnswer((_) async => null);
      when(() => secure.readPinHash()).thenAnswer((_) async => null);

      final result = await repository.disableLock();

      expect(result, isA<Ok<void>>());
      final settings = await repository.watchLockSettings().first;
      expect(settings.method, LockMethod.none);
      expect(settings.hasPinSet, isFalse);
    });
  });

  group('biyometrik', () {
    test('isBiometricAvailable datasource\'u sarmalar', () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => true);

      final result = await repository.isBiometricAvailable();

      expect(result, isTrue);
    });

    test('authenticateWithBiometric her zaman Ok döner (iptal dahil)', () async {
      when(() => biometric.authenticate()).thenAnswer((_) async => false);

      final result = await repository.authenticateWithBiometric();

      expect(result, isA<Ok<bool>>());
      expect((result as Ok<bool>).value, isFalse);
    });
  });
}
