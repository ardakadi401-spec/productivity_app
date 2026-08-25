import '../entities/lock_settings.dart';
import '../repositories/lock_repository.dart';

class WatchLockSettingsUseCase {
  const WatchLockSettingsUseCase(this._repository);

  final LockRepository _repository;

  Stream<LockSettings> call() => _repository.watchLockSettings();
}
