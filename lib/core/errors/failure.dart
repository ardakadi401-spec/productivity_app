/// Domain katmanı hata temsilleri — ARCHITECTURE.md Bölüm 7.1, 7.4.
///
/// Failure'lar, Data katmanında fırlatılan ham Exception'ların (bkz.
/// `core/exceptions/app_exceptions.dart`) Repository implementasyonu
/// tarafından çevrildiği, Presentation katmanına iletilecek anlamlandırılmış
/// hata tipleridir. Her Failure kullanıcı dostu bir [message] taşır.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Bağlantı yok, timeout — ARCHITECTURE.md Bölüm 7.4.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Giriş/kayıt/oturum hataları.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Kullanıcı girdisi iş kuralına uymuyor.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Yerel depolama (Isar) okuma/yazma hatası.
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Offline-online senkronizasyon çakışması.
final class SyncConflictFailure extends Failure {
  const SyncConflictFailure(super.message);
}

/// Firestore güvenlik kuralı reddi, biyometri izni reddi.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Beklenmeyen/sınıflandırılamayan hatalar.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
