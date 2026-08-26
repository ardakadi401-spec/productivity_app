import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// ARCHITECTURE.md Bölüm 6.2 "Service" katmanı — ham Firebase Auth ve
/// Google Sign-In SDK çağrılarını sarmalar. Yalnızca
/// `AuthRemoteDatasource` tarafından kullanılır; Domain/Presentation bu
/// sınıfı hiç bilmez.
///
/// Not: `google_sign_in` ^7.x event-driven API kullanır. `initialize()`,
/// `serverClientId` ile çağrılır — bu, Firebase Console'da Google
/// sağlayıcısı etkinleştirildiğinde `google-services.json`/
/// `GoogleService-Info.plist`'e eklenen "Web" tipi (client_type 3/2) OAuth
/// istemcisidir. Bu olmadan Android'de dönen idToken'ın audience'ı
/// Firebase'in beklediğiyle eşleşmeyebilir (native Android istemcisi ile
/// Firebase'in doğrulama istemcisi farklı türde olduğundan) — bu, Google
/// Sign-In + Firebase Auth entegrasyonunda bilinen, neredeyse her zaman
/// gereken bir adımdır, uç durum değildir.
class FirebaseAuthService {
  FirebaseAuthService({fb.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Firebase Console'da Google sağlayıcısı etkinleştirildiğinde otomatik
  /// oluşturulan "Web client" (`google-services.json` → `client_type: 3`,
  /// `GoogleService-Info.plist` → `CLIENT_ID` ile aynı proje altındaki Web
  /// istemcisi) — hem Android hem iOS için tek, ortak `serverClientId`.
  static const _serverClientId =
      '276808349193-kn21rjsj0cjtmbmfth6ascni6mmbb3j1.apps.googleusercontent.com';

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  fb.User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _googleSignInInitialized = true;
  }

  /// Kullanıcı akışı iptal ederse `null` döner (hata değildir — çağıran
  /// bunu sessizce Login ekranında kalma olarak yorumlar).
  Future<fb.UserCredential?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError('Bu platformda Google ile giriş desteklenmiyor.');
    }

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<fb.UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> updateDisplayName(String name) async {
    await _firebaseAuth.currentUser?.updateDisplayName(name);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_googleSignInInitialized) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }
}
