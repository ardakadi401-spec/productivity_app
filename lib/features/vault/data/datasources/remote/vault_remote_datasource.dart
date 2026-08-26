import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/vault_item_local_model.dart';

/// Firestore erişimi — yol: `users/{userId}/vaultItems/{itemId}` (Notes ile
/// aynı desen).
class VaultRemoteDatasource {
  VaultRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _vaultItemsRef =>
      _firestore.collection('users').doc(_uid).collection('vaultItems');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newVaultItemId() => _vaultItemsRef.doc().id;

  Future<void> setVaultItem(VaultItemLocalModel model) async {
    try {
      await _vaultItemsRef.doc(model.itemId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<VaultItemLocalModel>> fetchAllVaultItems() async {
    try {
      final snapshot = await _vaultItemsRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => VaultItemLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
