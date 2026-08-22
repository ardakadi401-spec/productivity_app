import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/habit_local_model.dart';
import '../../models/habit_record_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/habits/{habitId}`
/// ve alt koleksiyon `.../habitRecords/{recordId}`. Tasks'ın SubTask
/// desenindeki `TaskRemoteDatasource` ile aynı yapı: kalıcı realtime
/// listener yerine, Repository tarafından tetiklenen tek seferlik
/// "gönder"/"çek" işlemleri.
class HabitRemoteDatasource {
  HabitRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _habitsRef =>
      _firestore.collection('users').doc(_uid).collection('habits');

  CollectionReference<Map<String, dynamic>> _recordsRef(String habitId) =>
      _habitsRef.doc(habitId).collection('habitRecords');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  /// Firestore'un client-side doküman ID tahsisi — ağ çağrısı yapmaz.
  String newHabitId() => _habitsRef.doc().id;

  Future<void> setHabit(HabitLocalModel model) async {
    try {
      await _habitsRef.doc(model.habitId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<HabitLocalModel>> fetchAllHabits() async {
    try {
      final snapshot = await _habitsRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => HabitLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> setHabitRecord(HabitRecordLocalModel model) async {
    try {
      await _recordsRef(model.habitId).doc(model.recordId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteHabitRecord(String habitId, String recordId) async {
    try {
      await _recordsRef(habitId).doc(recordId).delete();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<HabitRecordLocalModel>> fetchHabitRecords(String habitId) async {
    try {
      final snapshot = await _recordsRef(habitId).get();
      return snapshot.docs
          .map((doc) => HabitRecordLocalModel.fromFirestoreData(habitId, doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
