import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String name,
    required String email,
    required String password,
  }) =>
      _repository.registerWithEmail(name: name, email: email, password: password);
}
