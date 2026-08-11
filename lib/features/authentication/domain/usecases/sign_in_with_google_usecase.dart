import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  /// `Ok(null)` = kullanıcı akışı iptal etti (hata değil).
  Future<Result<AppUser?>> call() => _repository.signInWithGoogle();
}
