import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/project_local_model.dart';

/// Firestore erişimi — DATABASE.md yolu: `users/{userId}/projects/{projectId}`.
/// Tasks feature'ının `TaskRemoteDatasource`'u ile birebir aynı desen: kalıcı
/// realtime listener yerine, Repository tarafından tetiklenen tek seferlik
/// "gönder"/"çek" işlemleri (ROADMAP.md — tam senkronizasyon sertleştirmesi
/// FAZ 14'te).
class ProjectRemoteDatasource {
  ProjectRemoteDatasource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _projectsRef =>
      _firestore.collection('users').doc(_uid).collection('projects');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  /// Firestore'un client-side doküman ID tahsisi — ağ çağrısı yapmaz, offline
  /// da çalışır.
  String newProjectId() => _projectsRef.doc().id;

  Future<void> setProject(ProjectLocalModel model) async {
    try {
      await _projectsRef.doc(model.projectId).set(model.toFirestoreJson());
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<List<ProjectLocalModel>> fetchAllProjects() async {
    try {
      final snapshot = await _projectsRef.where('isDeleted', isEqualTo: false).get();
      return snapshot.docs
          .map((doc) => ProjectLocalModel.fromFirestoreData(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
