import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call({required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);
}
