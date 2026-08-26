import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../../../../services/authentication_service/firebase_auth_service.dart';
import '../../models/app_user_model.dart';

/// Firebase Auth SDK çağrılarını `FirebaseAuthService` üzerinden yapan,
/// `AppException` fırlatan ve `users/{uid}` profil dokümanını yöneten
/// Remote Datasource — ARCHITECTURE.md Bölüm 7.2 hata akışının başlangıcı.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  Stream<AppUserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      return await _fetchProfile(user.uid) ?? _minimalProfileFrom(user);
    });
  }

  Future<AppUserModel?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential?.user;
      if (user == null) return null;
      return _ensureProfile(user, authProvider: 'google');
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmail(email: email, password: password);
      final user = credential.user!;
      return await _fetchProfile(user.uid) ?? _minimalProfileFrom(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AppUserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
      final user = credential.user!;
      return await _ensureProfile(user, authProvider: 'email', nameOverride: name);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// `users/{uid}` üst dokümanının altındaki, doğrudan bir alt-belgeye
  /// sahip alt koleksiyonlar — DATABASE.md Bölüm 3'teki path hiyerarşisi.
  /// `subCollections`, iki seviyeli olanlar için (örn. her `tasks/{taskId}`
  /// kendi `subtasks` alt koleksiyonunu taşır) o dokümanın altındaki ek
  /// koleksiyon adını belirtir.
  static const _topLevelCollections = <String, String?>{
    'tasks': 'subtasks',
    'projects': null,
    'notes': null,
    'habits': 'habitRecords',
    'goals': null,
    'pomodoroSessions': null,
    'statisticsSnapshots': null,
    'tags': null,
    'vaultItems': null,
    'vaultFolders': null,
  };

  /// Bir kullanıcının hesabını sildiğinde Firestore'da yalnızca `users/{uid}`
  /// üst dokümanını silmek YETERLİ DEĞİLDİR — Firestore, bir dokümanı
  /// sildiğinde onun alt koleksiyonlarını OTOMATİK SİLMEZ; aksi halde bu alt
  /// koleksiyonlar erişilemez ("yetim") halde kalıcı olarak Firestore'da
  /// kalırdı (Privacy Policy'nin "tüm verileriniz kalıcı silinir" sözüne ve
  /// KVKK/GDPR "unutulma hakkı"na aykırı olurdu). Bu yüzden önce TÜM alt
  /// koleksiyonlar (ve varsa onların kendi alt koleksiyonları) topluca
  /// silinir, ardından üst doküman ve Auth hesabı silinir.
  ///
  /// İstemci SDK'sında bir "recursive delete" yardımcı fonksiyonu
  /// bulunmadığından bu manuel olarak, `WriteBatch`'in 500 işlemlik
  /// limitine uyacak şekilde parça parça yapılır.
  Future<void> deleteAccount() async {
    final uid = _authService.currentUser?.uid;
    try {
      // Firebase, hassas işlemler için (hesap silme dahil) YAKIN ZAMANDA
      // giriş yapılmış olmasını şart koşar — geç kalırsa `deleteAccount()`
      // çağrısı `requires-recent-login` ile başarısız olur. Bu kontrol
      // olmadan önce Firestore verisi silinip SONRA Auth silme adımı bu
      // hatayla başarısız olabiliyordu: kullanıcının tüm verileri gitmiş
      // ama hesabı hâlâ duruyor oluyordu (yarım/tutarsız silme). Bu yüzden
      // veri silme işlemine hiç başlamadan ÖNCE oturumun tazeliği kontrol
      // edilir — taze değilse hiçbir veri silinmeden erken çıkılır.
      if (!_hasRecentLogin()) {
        throw AuthException('requires-recent-login');
      }
      if (uid != null) {
        await _deleteAllUserData(uid);
      }
      await _authService.deleteAccount();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Firebase'in hassas işlemler için beklediği "yakın zamanda giriş"
  /// penceresi belgelenmiş sabit bir değer değildir; gözlemlenen ~5 dakikalık
  /// eşiğin altında güvenli bir pay bırakmak için 4 dakika kullanılır.
  bool _hasRecentLogin() {
    final lastSignIn = _authService.currentUser?.metadata.lastSignInTime;
    if (lastSignIn == null) return false;
    return DateTime.now().difference(lastSignIn) < const Duration(minutes: 4);
  }

  Future<void> _deleteAllUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    for (final entry in _topLevelCollections.entries) {
      final docs = await userRef.collection(entry.key).get();
      final subCollectionName = entry.value;
      if (subCollectionName != null) {
        // Yüzlerce doküman olabileceğinden (ör. `tasks`), her birinin alt
        // koleksiyonunu SIRALI değil PARALEL sorgulamak gerekir — aksi halde
        // her doküman ayrı bir network round-trip'i bekletir ve işlem
        // dokümanlarla orantılı şekilde onlarca saniyeye çıkabilir.
        await Future.wait(docs.docs.map((doc) async {
          final subDocs = await doc.reference.collection(subCollectionName).get();
          await _deleteInBatches(subDocs.docs.map((d) => d.reference).toList());
        }));
      }
      await _deleteInBatches(docs.docs.map((d) => d.reference).toList());
    }
    await userRef.delete();
  }

  Future<void> _deleteInBatches(List<DocumentReference<Map<String, dynamic>>> refs) async {
    const batchLimit = 500;
    for (var i = 0; i < refs.length; i += batchLimit) {
      final chunk = refs.skip(i).take(batchLimit);
      final batch = _firestore.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  Future<AppUserModel?> _fetchProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUserModel.fromFirestore(doc);
  }

  /// Profil dokümanı varsa döndürür; yoksa DATABASE.md Bölüm 2.3
  /// varsayılanlarıyla oluşturur (ilk Google girişi / kayıt akışı).
  Future<AppUserModel> _ensureProfile(
    fb.User user, {
    required String authProvider,
    String? nameOverride,
  }) async {
    final existing = await _fetchProfile(user.uid);
    if (existing != null) return existing;

    final model = AppUserModel.newProfile(
      userId: user.uid,
      name: nameOverride ?? user.displayName ?? user.email!.split('@').first,
      email: user.email!,
      photoUrl: user.photoURL,
      authProvider: authProvider,
    );
    await _firestore.collection('users').doc(user.uid).set(model.toJson());
    return model;
  }

  /// Firestore profili henüz oluşmamışken (ör. `authStateChanges` yarışı)
  /// oturum akışının kesintiye uğramaması için Firebase `User`'dan türetilen
  /// geçici, kalıcı olmayan bir model.
  AppUserModel _minimalProfileFrom(fb.User user) {
    return AppUserModel.newProfile(
      userId: user.uid,
      name: user.displayName ?? user.email!.split('@').first,
      email: user.email!,
      photoUrl: user.photoURL,
      authProvider: user.providerData.any((p) => p.providerId == 'google.com')
          ? 'google'
          : 'email',
    );
  }
}
