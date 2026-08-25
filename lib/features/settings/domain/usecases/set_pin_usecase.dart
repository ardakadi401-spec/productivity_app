import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/lock_repository.dart';

/// PRD Bölüm 6.15 — PIN en az 4 hane. Presentation, bu kuralı UI seviyesinde
/// (form validasyonu) de gösterir; burada tekrarı Domain'in kendi iş
/// kuralını asla dışarıya güvenmemesi ilkesidir (ARCHITECTURE.md §14.1).
class SetPinUseCase {
  const SetPinUseCase(this._repository);

  final LockRepository _repository;

  static const minLength = 4;

  Future<Result<void>> call(String pin) {
    if (pin.length < minLength || int.tryParse(pin) == null) {
      return Future.value(
        const Err(ValidationFailure('PIN en az 4 haneli rakamlardan oluşmalı.')),
      );
    }
    return _repository.setPin(pin);
  }
}
