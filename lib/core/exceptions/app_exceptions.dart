/// Data katmanı hata tipleri — ARCHITECTURE.md Bölüm 7.1, 7.2.
///
/// Datasource'lar (Isar/Firestore) bu tipleri fırlatır; Repository
/// implementasyonu bunları yakalayıp ilgili `Failure`'a çevirir (bkz.
/// `core/errors/failure.dart`). Bu tipler Data katmanının dışına
/// (Domain/Presentation) asla sızmaz.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class PermissionException extends AppException {
  const PermissionException(super.message);
}

final class SyncConflictException extends AppException {
  const SyncConflictException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException(super.message);
}
