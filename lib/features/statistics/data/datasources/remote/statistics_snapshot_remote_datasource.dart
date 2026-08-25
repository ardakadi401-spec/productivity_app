import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/statistics_snapshot_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu:
/// `users/{userId}/statisticsSnapshots/{snapshotId}`.
class StatisticsSnapshotRemoteDatasource {
  StatisticsSnapshotRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _snapshotsRef =>
      _firestore.collection('users').doc(_uid).collection('statisticsSnapshots');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  Future<void> setSnapshot(StatisticsSnapshotLocalModel model) async {
    try {
      await _snapshotsRef.doc(model.snapshotId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<StatisticsSnapshotLocalModel>> fetchAllSnapshots() async {
    try {
      final snapshot = await _snapshotsRef.get();
      return snapshot.docs
          .map((doc) => StatisticsSnapshotLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// DATABASE.md §12.3 — 90 günlük yerel saklama penceresinin dışına
  /// düşmüş (yerelden budanmış) ama kullanıcının geçmiş dönem raporu için
  /// talep ettiği snapshot'ları isteğe bağlı olarak Firestore'dan çekmek
  /// için — `fetchAllSnapshots()`'ın aksine yalnızca istenen aralığı sorgular.
  Future<List<StatisticsSnapshotLocalModel>> fetchSnapshotsInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _snapshotsRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      return snapshot.docs
          .map((doc) => StatisticsSnapshotLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
