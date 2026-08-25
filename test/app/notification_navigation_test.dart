import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

import '../features/authentication/fake_auth_repository.dart';

/// ROADMAP.md FAZ 13 — "Bildirim payload → route yönlendirmesini mevcut
/// GoRouter yapısına uygun şekilde uygula ve test et." Bu dosya `app.dart`'ın
/// `_wireNotificationNavigation`'ını iki senaryoda doğrular: (1) uygulama
/// zaten açıkken bir bildirime dokunma (`notificationTaps` akışı), (2)
/// uygulama bildirimle SOĞUK başlatıldığında (`getLaunchPayload`).
class _EmptyTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(const []);
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

class _FakeNotificationRepository implements NotificationRepository {
  final _tapController = StreamController<String>.broadcast();
  String? launchPayload;

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> areNotificationsEnabled() async => true;
  @override
  Future<void> scheduleNotification(NotificationRequest request) async {}
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  Stream<String> get notificationTaps => _tapController.stream;
  @override
  Future<String?> getLaunchPayload() async => launchPayload;
}

Widget _wrap(FakeAuthRepository fake, _FakeNotificationRepository notification) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fake),
      taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
      notificationRepositoryProvider.overrideWithValue(notification),
    ],
    child: const ProductivityApp(),
  );
}

void main() {
  testWidgets(
    'uygulama açıkken bildirime dokunma (notificationTaps) payload rotasına push eder',
    (tester) async {
      final fake = FakeAuthRepository()..authStateValue = testUser;
      final notification = _FakeNotificationRepository();
      await tester.pumpWidget(_wrap(fake, notification));
      await tester.pumpAndSettle();

      expect(find.text('Tema'), findsNothing);

      notification._tapController.add('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Tema'), findsOneWidget);
    },
  );

  testWidgets(
    'uygulama bildirimle SOĞUK başlatıldığında (getLaunchPayload) başlangıç payload\'ına push eder',
    (tester) async {
      final fake = FakeAuthRepository()..authStateValue = testUser;
      final notification = _FakeNotificationRepository()..launchPayload = '/settings';
      await tester.pumpWidget(_wrap(fake, notification));
      await tester.pumpAndSettle();

      expect(find.text('Tema'), findsOneWidget);
    },
  );
}
