import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;
  Future<Result<AppUser>> call({required String name}) => _repository.updateProfile(name: name);
}
