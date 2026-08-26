import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/domain/entities/app_user.dart';
import 'package:productivity_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:productivity_app/features/authentication/domain/usecases/delete_account_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/register_with_email_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:productivity_app/features/authentication/domain/usecases/update_profile_usecase.dart';

const _user = AppUser(
  uid: 'u1',
  email: 'a@b.com',
  name: 'Ada',
  authProvider: AuthProviderType.email,
);

class _FakeAuthRepository implements AuthRepository {
  Result<AppUser?>? googleResult;
  Result<AppUser>? emailResult;
  Result<AppUser>? registerResult;
  Result<void>? voidResult;

  ({String email, String password})? lastSignInArgs;
  ({String name, String email, String password})? lastRegisterArgs;
  String? lastResetEmail;
  bool signOutCalled = false;
  bool deleteAccountCalled = false;
  Result<AppUser>? updateProfileResult;
  String? lastUpdatedName;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<Result<AppUser?>> signInWithGoogle() async => googleResult!;

  @override
  Future<Result<AppUser>> signInWithEmail({required String email, required String password}) async {
    lastSignInArgs = (email: email, password: password);
    return emailResult!;
  }

  @override
  Future<Result<AppUser>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    lastRegisterArgs = (name: name, email: email, password: password);
    return registerResult!;
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    lastResetEmail = email;
    return voidResult!;
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return voidResult!;
  }

  @override
  Future<Result<void>> deleteAccount() async {
    deleteAccountCalled = true;
    return voidResult!;
  }

  @override
  Future<Result<AppUser>> updateProfile({required String name}) async {
    lastUpdatedName = name;
    return updateProfileResult!;
  }
}

void main() {
  late _FakeAuthRepository repo;

  setUp(() => repo = _FakeAuthRepository());

  test('SignInWithGoogleUseCase Ok(null) döner (iptal senaryosu)', () async {
    repo.googleResult = const Ok(null);
    final result = await SignInWithGoogleUseCase(repo)();
    expect(result, isA<Ok<AppUser?>>());
    expect((result as Ok<AppUser?>).value, isNull);
  });

  test('SignInWithGoogleUseCase hata durumunda Err döner', () async {
    repo.googleResult = const Err(AuthFailure('hata'));
    final result = await SignInWithGoogleUseCase(repo)();
    expect(result, isA<Err<AppUser?>>());
  });

  test('SignInWithEmailUseCase argümanları repository\'ye doğru iletir', () async {
    repo.emailResult = const Ok(_user);
    final result = await SignInWithEmailUseCase(repo)(email: 'a@b.com', password: 'secret1');
    expect(repo.lastSignInArgs, (email: 'a@b.com', password: 'secret1'));
    expect((result as Ok<AppUser>).value, _user);
  });

  test('RegisterWithEmailUseCase argümanları repository\'ye doğru iletir', () async {
    repo.registerResult = const Ok(_user);
    await RegisterWithEmailUseCase(repo)(name: 'Ada', email: 'a@b.com', password: 'secret1');
    expect(repo.lastRegisterArgs, (name: 'Ada', email: 'a@b.com', password: 'secret1'));
  });

  test('ResetPasswordUseCase e-postayı iletir', () async {
    repo.voidResult = const Ok(null);
    await ResetPasswordUseCase(repo)(email: 'a@b.com');
    expect(repo.lastResetEmail, 'a@b.com');
  });

  test('SignOutUseCase repository.signOut\'u çağırır', () async {
    repo.voidResult = const Ok(null);
    await SignOutUseCase(repo)();
    expect(repo.signOutCalled, isTrue);
  });

  test('DeleteAccountUseCase repository.deleteAccount\'u çağırır', () async {
    repo.voidResult = const Ok(null);
    await DeleteAccountUseCase(repo)();
    expect(repo.deleteAccountCalled, isTrue);
  });

  test('UpdateProfileUseCase adı repository\'ye iletir', () async {
    repo.updateProfileResult = const Ok(_user);
    final result = await UpdateProfileUseCase(repo).call(name: 'Yeni Ad');
    expect(repo.lastUpdatedName, 'Yeni Ad');
    expect(result, isA<Ok<AppUser>>());
  });
}
