import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/tag_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/tags/{tagId}`.
class TagRemoteDatasource {
  TagRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tagsRef =>
      _firestore.collection('users').doc(_uid).collection('tags');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newTagId() => _tagsRef.doc().id;

  Future<void> setTag(TagLocalModel model) async {
    try {
      await _tagsRef.doc(model.tagId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<TagLocalModel>> fetchAllTags() async {
    try {
      final snapshot = await _tagsRef.get();
      return snapshot.docs.map((doc) => TagLocalModel.fromFirestoreData(doc.id, doc.data())).toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
