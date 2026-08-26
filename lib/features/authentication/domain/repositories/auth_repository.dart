import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
abstract interface class AuthRepository {
  /// Oturum durumu — STATE_MANAGEMENT.md Bölüm 4.2: kök seviyede,
  /// `autoDispose` olmadan dinlenen tek kaynak. `null` = oturum yok.
  Stream<AppUser?> get authStateChanges;

  /// Kullanıcı akışı iptal ederse `Ok(null)` döner — bu bir hata değildir
  /// (bkz. ROADMAP.md FAZ 3 test kriteri: iptalde uygulama Login'de kalır).
  Future<Result<AppUser?>> signInWithGoogle();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> resetPassword({required String email});

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount();

  /// Profil ekranından — şu an yalnızca görünen ad düzenlenebilir. E-posta/
  /// şifre değişikliği Firebase'in yeniden-kimlik-doğrulama gerektiren ayrı
  /// akışlarını gerektirir (`updateEmail`/`updatePassword`), bilinçli olarak
  /// bu ilk sürümün kapsamı dışında bırakıldı.
  Future<Result<AppUser>> updateProfile({required String name});
}
