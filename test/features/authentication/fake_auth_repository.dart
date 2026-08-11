import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/domain/entities/app_user.dart';
import 'package:productivity_app/features/authentication/domain/repositories/auth_repository.dart';

const testUser = AppUser(
  uid: 'u1',
  email: 'a@b.com',
  name: 'Ada',
  authProvider: AuthProviderType.email,
);

/// Widget testlerinde gerçek Firebase'e dokunmadan `authRepositoryProvider`'ı
/// override etmek için kullanılan sahte implementasyon. Her metodun sonucu
/// testten önce alan olarak ayarlanır.
class FakeAuthRepository implements AuthRepository {
  Result<AppUser?> googleResult = const Ok(null);
  Result<AppUser> emailResult = const Ok(testUser);
  Result<AppUser> registerResult = const Ok(testUser);
  Result<void> voidResult = const Ok(null);

  /// Test öncesi ayarlanacak "mevcut" oturum durumu — `null` = unauthenticated.
  AppUser? authStateValue;

  /// Gerçek topolojide `authStateProvider` VE router'ın refresh listener'ı
  /// bu stream'e birbirinden bağımsız olarak, FARKLI zamanlarda abone olur
  /// (tıpkı üretimde Firebase'in `authStateChanges()`'i gibi). `Stream.value(
  /// ...).asBroadcastStream()` burada YETERSİZ kalır: tek emisyon yalnızca
  /// İLK aboneye ulaşır, ikinci abone (hangisi geç kalırsa) hiçbir zaman
  /// veri almaz ve `AsyncLoading` durumunda sonsuza dek takılı kalır.
  /// `Stream.multi`, her yeni dinleyici için `onListen` callback'ini TAZE
  /// çalıştırır — böylece abone olma zamanından bağımsız olarak her tüketici
  /// [authStateValue]'nun o anki değerini alır.
  @override
  Stream<AppUser?> get authStateChanges =>
      Stream<AppUser?>.multi((controller) => controller.add(authStateValue));

  @override
  Future<Result<AppUser?>> signInWithGoogle() async => googleResult;

  @override
  Future<Result<AppUser>> signInWithEmail({required String email, required String password}) async =>
      emailResult;

  @override
  Future<Result<AppUser>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async =>
      registerResult;

  @override
  Future<Result<void>> resetPassword({required String email}) async => voidResult;

  @override
  Future<Result<void>> signOut() async => voidResult;

  @override
  Future<Result<void>> deleteAccount() async => voidResult;
}
