import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// ARCHITECTURE.md Bölüm 6.2 "Service" katmanı — ham Firebase Auth ve
/// Google Sign-In SDK çağrılarını sarmalar. Yalnızca
/// `AuthRemoteDatasource` tarafından kullanılır; Domain/Presentation bu
/// sınıfı hiç bilmez.
///
/// Not: `google_sign_in` ^7.x event-driven API kullanır. `initialize()`
/// burada `serverClientId` vermeden çağrılıyor — Android'de bu genelde
/// `google-services.json`'daki OAuth istemcisinden otomatik çözülür. Eğer
/// Firebase, dönen idToken'ın audience'ını reddederse (Firebase Console'da
/// Google sağlayıcısı etkinleştirildikten sonra ilk gerçek denemede ortaya
/// çıkabilecek bir uyumsuzluk), `initialize(serverClientId: <Web client ID>)`
/// olarak güncellenmesi gerekir.
class FirebaseAuthService {
  FirebaseAuthService({fb.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  fb.User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
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
