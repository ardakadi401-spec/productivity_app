import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/pomodoro_session_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu:
/// `users/{userId}/pomodoroSessions/{sessionId}`.
class PomodoroRemoteDatasource {
  PomodoroRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection('users').doc(_uid).collection('pomodoroSessions');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newSessionId() => _sessionsRef.doc().id;

  Future<void> setSession(PomodoroSessionLocalModel model) async {
    try {
      await _sessionsRef.doc(model.sessionId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Repository init'teki tek seferlik "aç ve senkronize et" akışı için —
  /// diğer feature'ların `fetchAllX()`'iyle aynı desen.
  Future<List<PomodoroSessionLocalModel>> fetchAllSessions() async {
    try {
      final snapshot = await _sessionsRef.get();
      return snapshot.docs
          .map((doc) => PomodoroSessionLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
