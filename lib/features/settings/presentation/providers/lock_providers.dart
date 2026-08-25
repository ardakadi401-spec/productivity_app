import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/biometric_datasource.dart';
import '../../data/datasources/local/lock_secure_datasource.dart';
import '../../data/repositories/lock_repository_impl.dart';
import '../../domain/entities/lock_settings.dart';
import '../../domain/repositories/lock_repository.dart';
import '../../domain/usecases/biometric_usecases.dart';
import '../../domain/usecases/disable_lock_usecase.dart';
import '../../domain/usecases/set_lock_method_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../domain/usecases/watch_lock_settings_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---
// NOT: `LockRepository`, `SettingsRepository`'den bilinçli olarak ayrı
// (bkz. lock_repository.dart doc notu) — bu yüzden ayrı bir provider
// dosyasında yaşar, `settings_providers.dart`'a karıştırılmaz.

final lockSecureDatasourceProvider = Provider<LockSecureDatasource>((ref) {
  return LockSecureDatasource();
});

final biometricDatasourceProvider = Provider<BiometricDatasource>((ref) {
  return BiometricDatasource();
});

final lockRepositoryProvider = Provider<LockRepository>((ref) {
  return LockRepositoryImpl(
    ref.watch(lockSecureDatasourceProvider),
    ref.watch(biometricDatasourceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchLockSettingsUseCaseProvider = Provider<WatchLockSettingsUseCase>((ref) {
  return WatchLockSettingsUseCase(ref.watch(lockRepositoryProvider));
});

final setPinUseCaseProvider = Provider<SetPinUseCase>((ref) {
  return SetPinUseCase(ref.watch(lockRepositoryProvider));
});

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  return VerifyPinUseCase(ref.watch(lockRepositoryProvider));
});

final setLockMethodUseCaseProvider = Provider<SetLockMethodUseCase>((ref) {
  return SetLockMethodUseCase(ref.watch(lockRepositoryProvider));
});

final disableLockUseCaseProvider = Provider<DisableLockUseCase>((ref) {
  return DisableLockUseCase(ref.watch(lockRepositoryProvider));
});

final isBiometricAvailableUseCaseProvider = Provider<IsBiometricAvailableUseCase>((ref) {
  return IsBiometricAvailableUseCase(ref.watch(lockRepositoryProvider));
});

final authenticateWithBiometricUseCaseProvider = Provider<AuthenticateWithBiometricUseCase>((ref) {
  return AuthenticateWithBiometricUseCase(ref.watch(lockRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

final lockSettingsProvider = StreamProvider.autoDispose<LockSettings>((ref) {
  return ref.watch(watchLockSettingsUseCaseProvider).call();
});

/// Settings Screen'in "Güvenlik" bölümünün Biyometri/İkisi seçeneklerini
/// cihazda desteklenmiyorsa gizlemesi için.
final biometricAvailableProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(isBiometricAvailableUseCaseProvider).call();
});

/// ARCHITECTURE.md §13.5 — "şu an kilit ekranı gösterilmeli mi" durumu.
/// `LockSettings` yalnızca "bir kilit yöntemi YAPILANDIRILMIŞ mı" bilgisini
/// taşır; bu provider ise "bu OTURUMDA şu an kilitli mi" durumunu taşır —
/// ikisi kasıtlı olarak ayrı: yöntem yapılandırılı olsa bile kullanıcı zaten
/// doğrulama yapmışsa (örn. Settings'te PIN'i az önce girdiyse) uygulama
/// kilitlenmez; yalnızca `app.dart`'ın soğuk başlangıç/resume tetikleyicileri
/// bunu `true` yapar, `LockPage`'deki başarılı doğrulama `false` yapar.
final appLockStateProvider = StateProvider<bool>((ref) => false);
