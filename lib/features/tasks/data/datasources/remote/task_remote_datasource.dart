import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/sub_task_local_model.dart';
import '../../models/task_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/tasks/{taskId}` ve
/// alt koleksiyon `.../subtasks/{subtaskId}`. FAZ 5 kapsamı (ROADMAP'in
/// kendi ayrımı, tam senkronizasyon sertleştirmesi FAZ 14'te): kalıcı
/// realtime listener yerine, Repository tarafından tetiklenen tek seferlik
/// "gönder"/"çek" işlemleri.
class TaskRemoteDatasource {
  TaskRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection('users').doc(_uid).collection('tasks');

  CollectionReference<Map<String, dynamic>> _subtasksRef(String taskId) =>
      _tasksRef.doc(taskId).collection('subtasks');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  /// Firestore'un client-side doküman ID tahsisi — ağ çağrısı yapmaz, offline
  /// da çalışır. Aynı ID hem Isar'a hem (senkronize olunca) Firestore'a
  /// yazılır.
  String newTaskId() => _tasksRef.doc().id;

  String newSubTaskId(String taskId) => _subtasksRef(taskId).doc().id;

  Future<void> setTask(TaskLocalModel model) async {
    try {
      await _tasksRef.doc(model.taskId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<TaskLocalModel>> fetchAllTasks() async {
    try {
      final snapshot = await _tasksRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => TaskLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> setSubTask(String taskId, SubTaskLocalModel model) async {
    try {
      await _subtasksRef(taskId).doc(model.subtaskId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<SubTaskLocalModel>> fetchSubTasks(String taskId) async {
    try {
      final snapshot = await _subtasksRef(taskId).get();
      return snapshot.docs
          .map((doc) => SubTaskLocalModel.fromFirestoreData(taskId, doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
