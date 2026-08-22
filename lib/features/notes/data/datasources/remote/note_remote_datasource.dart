import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/note_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/notes/{noteId}`.
class NoteRemoteDatasource {
  NoteRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _notesRef =>
      _firestore.collection('users').doc(_uid).collection('notes');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newNoteId() => _notesRef.doc().id;

  Future<void> setNote(NoteLocalModel model) async {
    try {
      await _notesRef.doc(model.noteId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<NoteLocalModel>> fetchAllNotes() async {
    try {
      final snapshot = await _notesRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => NoteLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
