import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/app_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Stream<AppUser?> get authStateChanges =>
      _datasource.authStateChanges.map((model) => model == null ? null : AppUserMapper.toEntity(model));

  @override
  Future<Result<AppUser?>> signInWithGoogle() => _guardNullable(() async {
        final model = await _datasource.signInWithGoogle();
        return model == null ? null : AppUserMapper.toEntity(model);
      });

  @override
  Future<Result<AppUser>> signInWithEmail({required String email, required String password}) {
    return _guard(() async {
      final model = await _datasource.signInWithEmail(email: email, password: password);
      return AppUserMapper.toEntity(model);
    });
  }

  @override
  Future<Result<AppUser>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final model = await _datasource.registerWithEmail(name: name, email: email, password: password);
      return AppUserMapper.toEntity(model);
    });
  }

  @override
  Future<Result<void>> resetPassword({required String email}) {
    return _guard(() => _datasource.resetPassword(email: email));
  }

  @override
  Future<Result<void>> signOut() => _guard(() => _datasource.signOut());

  @override
  Future<Result<void>> deleteAccount() => _guard(() => _datasource.deleteAccount());

  @override
  Future<Result<AppUser>> updateProfile({required String name}) {
    return _guard(() async {
      final model = await _datasource.updateProfile(name: name);
      return AppUserMapper.toEntity(model);
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Future<Result<T?>> _guardNullable<T>(Future<T?> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  /// Firebase hata kodlarını UI_GUIDELINES.md Bölüm 13 Kural 4'e uygun
  /// (suçlamayan, çözüm odaklı, jargonsuz) Türkçe mesajlarla `Failure`'a
  /// çevirir. `AuthException.message` alanı burada ham Firebase kodunu taşır.
  Failure _mapToFailure(AppException exception) {
    if (exception is! AuthException) {
      return UnknownFailure('Bir şeyler ters gitti. Lütfen tekrar dene.');
    }

    switch (exception.message) {
      case 'invalid-email':
        return const ValidationFailure('Geçerli bir e-posta adresi gir.');
      case 'weak-password':
        return const ValidationFailure('Şifre en az 6 karakter olmalı.');
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return const AuthFailure('E-posta veya şifre hatalı.');
      case 'email-already-in-use':
        return const AuthFailure('Bu e-posta adresi zaten kayıtlı.');
      case 'user-disabled':
        return const AuthFailure('Bu hesap devre dışı bırakılmış.');
      case 'too-many-requests':
        return const AuthFailure('Çok fazla deneme yapıldı. Lütfen daha sonra tekrar dene.');
      case 'requires-recent-login':
        return const AuthFailure('Bu işlem için tekrar giriş yapman gerekiyor.');
      case 'network-request-failed':
        return const NetworkFailure('Bağlantını kontrol edip tekrar dene.');
      default:
        return const AuthFailure('Bir şeyler ters gitti. Lütfen tekrar dene.');
    }
  }
}
