import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/settings/domain/entities/lock_settings.dart';
import 'package:productivity_app/features/settings/domain/repositories/lock_repository.dart';
import 'package:productivity_app/features/settings/domain/usecases/biometric_usecases.dart';
import 'package:productivity_app/features/settings/domain/usecases/disable_lock_usecase.dart';
import 'package:productivity_app/features/settings/domain/usecases/set_lock_method_usecase.dart';
import 'package:productivity_app/features/settings/domain/usecases/set_pin_usecase.dart';
import 'package:productivity_app/features/settings/domain/usecases/verify_pin_usecase.dart';
import 'package:productivity_app/features/settings/domain/usecases/watch_lock_settings_usecase.dart';

class _MockLockRepository extends Mock implements LockRepository {}

void main() {
  late _MockLockRepository repository;

  setUpAll(() {
    registerFallbackValue(LockMethod.none);
  });

  setUp(() {
    repository = _MockLockRepository();
  });

  group('SetPinUseCase', () {
    test('4 haneli sayısal PIN repository\'ye iletilir', () async {
      when(() => repository.setPin('1234')).thenAnswer((_) async => const Ok(null));

      final result = await SetPinUseCase(repository).call('1234');

      expect(result, isA<Ok<void>>());
      verify(() => repository.setPin('1234')).called(1);
    });

    test('3 haneli PIN ValidationFailure döner, repository çağrılmaz', () async {
      final result = await SetPinUseCase(repository).call('123');

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => repository.setPin(any()));
    });

    test('rakam olmayan PIN ValidationFailure döner', () async {
      final result = await SetPinUseCase(repository).call('abcd');

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => repository.setPin(any()));
    });
  });

  group('VerifyPinUseCase', () {
    test('repository.verifyPin\'i çağırır ve sonucu iletir', () async {
      when(() => repository.verifyPin('1234')).thenAnswer((_) async => const Ok(true));

      final result = await VerifyPinUseCase(repository).call('1234');

      expect((result as Ok).value, isTrue);
    });
  });

  group('SetLockMethodUseCase', () {
    test('method=none iken PIN kontrolü yapılmadan doğrudan geçer', () async {
      when(() => repository.setLockMethod(LockMethod.none)).thenAnswer((_) async => const Ok(null));

      final result = await SetLockMethodUseCase(repository).call(LockMethod.none);

      expect(result, isA<Ok<void>>());
      verifyNever(() => repository.watchLockSettings());
    });

    test('method=pin ama PIN ayarlanmamışsa ValidationFailure döner', () async {
      when(() => repository.watchLockSettings())
          .thenAnswer((_) => Stream.value(const LockSettings(method: LockMethod.none, hasPinSet: false)));

      final result = await SetLockMethodUseCase(repository).call(LockMethod.pin);

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => repository.setLockMethod(any()));
    });

    test('method=pin ve PIN zaten ayarlıysa repository çağrılır', () async {
      when(() => repository.watchLockSettings())
          .thenAnswer((_) => Stream.value(const LockSettings(method: LockMethod.none, hasPinSet: true)));
      when(() => repository.setLockMethod(LockMethod.pin)).thenAnswer((_) async => const Ok(null));

      final result = await SetLockMethodUseCase(repository).call(LockMethod.pin);

      expect(result, isA<Ok<void>>());
      verify(() => repository.setLockMethod(LockMethod.pin)).called(1);
    });

    test('method=biometric ama PIN ayarlanmamışsa ValidationFailure döner (fallback güvencesi)', () async {
      when(() => repository.watchLockSettings())
          .thenAnswer((_) => Stream.value(const LockSettings(method: LockMethod.none, hasPinSet: false)));

      final result = await SetLockMethodUseCase(repository).call(LockMethod.biometric);

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => repository.setLockMethod(any()));
    });

    test('method=biometric ve PIN zaten ayarlıysa repository çağrılır', () async {
      when(() => repository.watchLockSettings())
          .thenAnswer((_) => Stream.value(const LockSettings(method: LockMethod.none, hasPinSet: true)));
      when(() => repository.setLockMethod(LockMethod.biometric))
          .thenAnswer((_) async => const Ok(null));

      final result = await SetLockMethodUseCase(repository).call(LockMethod.biometric);

      expect(result, isA<Ok<void>>());
      verify(() => repository.setLockMethod(LockMethod.biometric)).called(1);
    });
  });

  group('DisableLockUseCase', () {
    test('repository.disableLock\'u çağırır', () async {
      when(() => repository.disableLock()).thenAnswer((_) async => const Ok(null));

      final result = await DisableLockUseCase(repository).call();

      expect(result, isA<Ok<void>>());
      verify(() => repository.disableLock()).called(1);
    });
  });

  group('Biyometrik UseCase\'ler', () {
    test('IsBiometricAvailableUseCase repository\'i sarmalar', () async {
      when(() => repository.isBiometricAvailable()).thenAnswer((_) async => true);

      final result = await IsBiometricAvailableUseCase(repository).call();

      expect(result, isTrue);
    });

    test('AuthenticateWithBiometricUseCase iptal/başarısızlıkta Ok(false) döner (hata değil)', () async {
      when(() => repository.authenticateWithBiometric()).thenAnswer((_) async => const Ok(false));

      final result = await AuthenticateWithBiometricUseCase(repository).call();

      expect(result, isA<Ok<bool>>());
      expect((result as Ok).value, isFalse);
    });
  });

  test('WatchLockSettingsUseCase repository stream\'ini iletir', () async {
    when(() => repository.watchLockSettings())
        .thenAnswer((_) => Stream.value(const LockSettings(method: LockMethod.both, hasPinSet: true)));

    final result = await WatchLockSettingsUseCase(repository).call().first;

    expect(result.method, LockMethod.both);
    expect(result.hasPinSet, isTrue);
  });
}
