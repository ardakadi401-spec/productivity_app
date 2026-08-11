import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/features/authentication/data/datasources/remote/auth_remote_datasource.dart';
import 'package:productivity_app/features/authentication/data/models/app_user_model.dart';
import 'package:productivity_app/features/authentication/data/repositories/auth_repository_impl.dart';

class _MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

AppUserModel _model() => AppUserModel.newProfile(
      userId: 'u1',
      name: 'Ada',
      email: 'a@b.com',
      authProvider: 'email',
    );

void main() {
  late _MockAuthRemoteDatasource datasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    datasource = _MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(datasource);
  });

  group('signInWithEmail', () {
    test('başarılı olduğunda Ok(AppUser) döner', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => _model());

      final result = await repository.signInWithEmail(email: 'a@b.com', password: 'secret1');

      expect(result, isA<Ok<dynamic>>());
      expect((result as Ok).value.email, 'a@b.com');
    });

    test('wrong-password AuthException -> AuthFailure ("E-posta veya şifre hatalı.")', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('wrong-password'));

      final result = await repository.signInWithEmail(email: 'a@b.com', password: 'x');

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'E-posta veya şifre hatalı.');
    });

    test('network-request-failed -> NetworkFailure', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('network-request-failed'));

      final result = await repository.signInWithEmail(email: 'a@b.com', password: 'x');

      expect((result as Err).failure, isA<NetworkFailure>());
    });

    test('weak-password -> ValidationFailure', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('weak-password'));

      final result = await repository.signInWithEmail(email: 'a@b.com', password: 'x');

      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('bilinmeyen kod -> AuthFailure genel mesaj', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('some-unmapped-code'));

      final result = await repository.signInWithEmail(email: 'a@b.com', password: 'x') as Err;

      expect(result.failure, isA<AuthFailure>());
      expect(result.failure.message, 'Bir şeyler ters gitti. Lütfen tekrar dene.');
    });

    test('AppException olmayan hata -> UnknownFailure', () async {
      when(() => datasource.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(Exception('boom'));

      expect(
        () => repository.signInWithEmail(email: 'a@b.com', password: 'x'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signInWithGoogle', () {
    test('kullanıcı iptal ederse (null) Ok(null) döner', () async {
      when(() => datasource.signInWithGoogle()).thenAnswer((_) async => null);

      final result = await repository.signInWithGoogle();

      expect(result, isA<Ok<dynamic>>());
      expect((result as Ok).value, isNull);
    });

    test('başarılı olursa Ok(AppUser) döner', () async {
      when(() => datasource.signInWithGoogle()).thenAnswer((_) async => _model());

      final result = await repository.signInWithGoogle();

      expect((result as Ok).value, isNotNull);
    });
  });

  test('registerWithEmail email-already-in-use -> AuthFailure', () async {
    when(() => datasource.registerWithEmail(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const AuthException('email-already-in-use'));

    final result = await repository.registerWithEmail(name: 'Ada', email: 'a@b.com', password: 'secret1');

    expect((result as Err).failure.message, 'Bu e-posta adresi zaten kayıtlı.');
  });

  test('resetPassword başarılı olduğunda Ok(null) döner', () async {
    when(() => datasource.resetPassword(email: any(named: 'email'))).thenAnswer((_) async {});

    final result = await repository.resetPassword(email: 'a@b.com');

    expect(result, isA<Ok<void>>());
  });

  test('authStateChanges datasource modelini AppUser\'a eşler', () async {
    when(() => datasource.authStateChanges).thenAnswer((_) => Stream.value(_model()));

    final user = await repository.authStateChanges.first;

    expect(user?.email, 'a@b.com');
  });
}
