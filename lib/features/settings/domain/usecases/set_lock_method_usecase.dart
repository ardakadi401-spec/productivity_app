import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/lock_settings.dart';
import '../repositories/lock_repository.dart';

/// `pin`/`both`/`biometric` yöntemlerinin HEPSİ PIN'in ÖNCEDEN ayarlanmış
/// olmasını gerektirir — bu iş kuralı burada, Domain katmanında zorunlu
/// kılınır (Presentation'ın unutabileceği bir kontrole güvenilmez,
/// ARCHITECTURE.md §14.1). `biometric` de dahil edilir çünkü
/// ARCHITECTURE.md §13.4 "biyometri kullanılamayan/desteklenmeyen
/// cihazlarda otomatik olarak PIN akışına düşülür" kuralı, yalnızca bir PIN
/// her zaman ayarlanmışsa mümkündür — aksi halde biyometrik başarısız
/// olduğunda kullanıcı kilit ekranında çıkış yolu olmadan sıkışır.
class SetLockMethodUseCase {
  const SetLockMethodUseCase(this._repository);

  final LockRepository _repository;

  Future<Result<void>> call(LockMethod method) async {
    if (method != LockMethod.none) {
      final current = await _repository.watchLockSettings().first;
      if (!current.hasPinSet) {
        return const Err(
          ValidationFailure('Bu yöntem için önce bir PIN belirlemelisin.'),
        );
      }
    }
    return _repository.setLockMethod(method);
  }
}
