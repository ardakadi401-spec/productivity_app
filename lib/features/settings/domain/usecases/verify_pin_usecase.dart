import '../../../../core/errors/result.dart';
import '../repositories/lock_repository.dart';

/// Presentation (kilit ekranı) girilen PIN'i asla doğrudan karşılaştırmaz —
/// yalnızca bunu çağırır (ARCHITECTURE.md §13.3).
class VerifyPinUseCase {
  const VerifyPinUseCase(this._repository);

  final LockRepository _repository;

  Future<Result<bool>> call(String pin) => _repository.verifyPin(pin);
}
