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

  Future<void> deleteAccount() async {
    final uid = _authService.currentUser?.uid;
    try {
      if (uid != null) {
        await _firestore.collection('users').doc(uid).delete();
      }
      await _authService.deleteAccount();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } catch (e) {
      throw UnknownException(e.toString());
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
