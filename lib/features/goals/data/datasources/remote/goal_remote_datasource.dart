import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/goal_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/goals/{goalId}`.
/// Tasks/Projects'in kendi remote datasource'larıyla birebir aynı desen:
/// kalıcı realtime listener yerine, Repository tarafından tetiklenen tek
/// seferlik "gönder"/"çek" işlemleri.
class GoalRemoteDatasource {
  GoalRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection('users').doc(_uid).collection('goals');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  String newGoalId() => _goalsRef.doc().id;

  Future<void> setGoal(GoalLocalModel model) async {
    try {
      await _goalsRef.doc(model.goalId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<GoalLocalModel>> fetchAllGoals() async {
    try {
      final snapshot = await _goalsRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => GoalLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
