import '../../../../core/errors/result.dart';
import '../entities/lock_settings.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md §13.3-13.4.
///
/// Bilinçli olarak `SettingsRepository`'den AYRI (Interface Segregation,
/// ARCHITECTURE.md §14 madde 1): PIN/kilit verisi Isar/Firestore'a değil
/// yalnızca platformun güvenli yerel deposuna yazılır (DATABASE.md §16.3 —
/// "PIN/biyometri doğrulama bilgisi Firestore'a hiçbir biçimde yazılmaz"),
/// bu yüzden `SyncableRepository` da İMPLEMENTE ETMEZ; FAZ 14'ün
/// senkronizasyon kapsamının tamamen dışındadır.
abstract interface class LockRepository {
  Stream<LockSettings> watchLockSettings();

  /// PIN'i güvenli (hash'lenmiş) şekilde saklar; mevcut PIN'in üzerine yazar.
  Future<Result<void>> setPin(String pin);

  /// Girilen PIN'i saklanan hash ile karşılaştırır — Presentation katmanı
  /// PIN'i asla doğrudan karşılaştırmaz (ARCHITECTURE.md §13.3).
  Future<Result<bool>> verifyPin(String pin);

  /// Kilit yöntemini değiştirir. `pin`/`both` için PIN'in daha önce
  /// `setPin` ile ayarlanmış olması çağıranın (Presentation/UseCase)
  /// sorumluluğudur.
  Future<Result<void>> setLockMethod(LockMethod method);

  /// Kilidi tamamen kapatır: yöntemi `none` yapar VE saklanan PIN'i siler.
  Future<Result<void>> disableLock();

  Future<bool> isBiometricAvailable();

  /// Platformun biyometrik promptunu tetikler. `Ok(false)` dönerse (iptal
  /// veya başarısız doğrulama) çağıran PIN akışına düşer (ARCHITECTURE.md
  /// §13.4 fallback mantığı).
  Future<Result<bool>> authenticateWithBiometric();
}
