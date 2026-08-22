import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/settings_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{uid}` belgesinin `settings`
/// alt-alanı. Bu belgenin sahibi Authentication feature'ıdır (ARCHITECTURE.md
/// §4 bağımlılık tablosu: Settings → Authentication); Settings yalnızca
/// `settings.*` alt alanlarını kısmi (`update`) günceller, belgenin diğer
/// alanlarına (ad, e-posta vb.) hiç dokunmaz.
class SettingsRemoteDatasource {
  SettingsRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  Future<void> updatePreferences(SettingsLocalModel model) async {
    try {
      await _userDoc.update(model.toFirestoreSettingsPatch());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// `users/{uid}` belgesi henüz yoksa (örn. ilk senkronizasyondan önceki
  /// bir yarış durumu) `null` döner — çağıran taraf varsayılanlarda kalır.
  Future<Map<String, dynamic>?> fetchSettingsMap() async {
    try {
      final doc = await _userDoc.get();
      if (!doc.exists) return null;
      final settings = doc.data()?['settings'] as Map?;
      return settings == null ? null : Map<String, dynamic>.from(settings);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
