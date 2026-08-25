import '../../../../core/errors/result.dart';
import '../repositories/lock_repository.dart';

class DisableLockUseCase {
  const DisableLockUseCase(this._repository);

  final LockRepository _repository;

  Future<Result<void>> call() => _repository.disableLock();
}
