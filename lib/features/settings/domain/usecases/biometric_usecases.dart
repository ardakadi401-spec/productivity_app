import '../../../../core/errors/result.dart';
import '../repositories/lock_repository.dart';

class IsBiometricAvailableUseCase {
  const IsBiometricAvailableUseCase(this._repository);

  final LockRepository _repository;

  Future<bool> call() => _repository.isBiometricAvailable();
}

/// `Ok(false)` (iptal/başarısız doğrulama) çağıranın PIN akışına düşmesi
/// gereken, hata SAYILMAYAN bir sonuçtur (ARCHITECTURE.md §13.4 fallback).
class AuthenticateWithBiometricUseCase {
  const AuthenticateWithBiometricUseCase(this._repository);

  final LockRepository _repository;

  Future<Result<bool>> call() => _repository.authenticateWithBiometric();
}
