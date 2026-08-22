import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}` Firestore doküman temsili — DATABASE.md Bölüm 2.2, 2.3.
class AppUserModel {
  const AppUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.onboardingCompleted,
    this.photoUrl,
  });

  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final String authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;
  final bool onboardingCompleted;

  /// Yeni kullanıcı için DATABASE.md Bölüm 2.3 varsayılan `settings` değerleri.
  factory AppUserModel.newProfile({
    required String userId,
    required String name,
    required String email,
    required String authProvider,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return AppUserModel(
      userId: userId,
      name: name,
      email: email,
      photoUrl: photoUrl,
      authProvider: authProvider,
      createdAt: now,
      updatedAt: now,
      onboardingCompleted: false,
      settings: const {
        'themeMode': 'system',
        'appLockEnabled': false,
        'appLockType': 'none',
        'notificationsEnabled': true,
        'taskRemindersEnabled': true,
        'habitRemindersEnabled': true,
        'pomodoroNotificationsEnabled': true,
        'pomodoroWorkDuration': 25,
        'pomodoroBreakDuration': 5,
        'weekStartDay': 'monday',
      },
    );
  }

  factory AppUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUserModel(
      userId: data['userId'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      photoUrl: data['photoUrl'] as String?,
      authProvider: data['authProvider'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      onboardingCompleted: data['onboardingCompleted'] as bool,
      settings: Map<String, dynamic>.from(data['settings'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'onboardingCompleted': onboardingCompleted,
      'settings': settings,
    };
  }
}
