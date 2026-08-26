import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/vault_folder_local_model.dart';

/// Firestore erişimi — yol: `users/{userId}/vaultFolders/{folderId}`
/// (`VaultRemoteDatasource` ile aynı desen).
class VaultFolderRemoteDatasource {
  VaultFolderRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _vaultFoldersRef =>
      _firestore.collection('users').doc(_uid).collection('vaultFolders');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newVaultFolderId() => _vaultFoldersRef.doc().id;

  Future<void> setVaultFolder(VaultFolderLocalModel model) async {
    try {
      await _vaultFoldersRef.doc(model.folderId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<VaultFolderLocalModel>> fetchAllVaultFolders() async {
    try {
      final snapshot = await _vaultFoldersRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => VaultFolderLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
