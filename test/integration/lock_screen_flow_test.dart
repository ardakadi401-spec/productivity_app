import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:productivity_app/features/settings/domain/entities/lock_settings.dart';
import 'package:productivity_app/features/settings/domain/repositories/lock_repository.dart';
import 'package:productivity_app/features/settings/presentation/providers/lock_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

import '../features/authentication/fake_auth_repository.dart';

/// ROADMAP.md FAZ 16 tamamlanma kriteri — "Kritik kullanıcı akışlarının
/// (... kilit ekranı) her biri için en az bir entegrasyon testi mevcut."
/// `lock_guard_test.dart` bu mantığı SAF bir fonksiyon olarak izole test
/// eder; bu dosya aynı davranışı gerçek `ProductivityApp` + gerçek
/// `GoRouter` + gerçek `LockPage` üzerinden, kimliği doğrulanmış bir
/// kullanıcının soğuk başlatmada kilit ekranıyla karşılaştığını ve doğru
/// PIN sonrası uygulamanın kaldığı yerden (Dashboard) devam ettiğini
/// uçtan uca doğrular.
class _FakeLockRepository implements LockRepository {
  _FakeLockRepository(this.current);

  LockSettings current;
  final _controller = StreamController<LockSettings>.broadcast();

  static const correctPin = '1234';

  @override
  Stream<LockSettings> watchLockSettings() => Stream<LockSettings>.multi((controller) {
        controller.add(current);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<Result<bool>> verifyPin(String pin) async => Ok(pin == correctPin);

  @override
  Future<Result<bool>> authenticateWithBiometric() async => const Ok(false);

  @override
  Future<bool> isBiometricAvailable() async => false;

  @override
  Future<Result<void>> setPin(String pin) async => const Ok(null);

  @override
  Future<Result<void>> setLockMethod(LockMethod method) async => const Ok(null);

  @override
  Future<Result<void>> disableLock() async => const Ok(null);
}

class _EmptyTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 't1';
  @override
  String newSubTaskId(String taskId) => 's1';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(const []);
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task t) => throw UnimplementedError();
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

Widget _wrap({required FakeAuthRepository auth, required _FakeLockRepository lock}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      lockRepositoryProvider.overrideWithValue(lock),
      taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
    ],
    child: const ProductivityApp(),
  );
}

void main() {
  testWidgets(
    'PIN kilidi etkinken soğuk başlatmada Lock ekranı gösterilir; doğru PIN sonrası '
    'Dashboard\'a devam edilir',
    (tester) async {
      final auth = FakeAuthRepository()..authStateValue = testUser;
      final lock = _FakeLockRepository(const LockSettings(method: LockMethod.pin, hasPinSet: true));
      await tester.pumpWidget(_wrap(auth: auth, lock: lock));
      await tester.pumpAndSettle();

      expect(find.text('Kilitli'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);

      await tester.enterText(find.byType(TextField).first, _FakeLockRepository.correctPin);
      await tester.pump();
      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(find.text('Kilitli'), findsNothing);
      expect(find.text('Dashboard'), findsWidgets);
    },
  );

  testWidgets('kilit devre dışıyken soğuk başlatmada doğrudan Dashboard gösterilir', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..authStateValue = testUser;
    final lock = _FakeLockRepository(LockSettings.disabled);
    await tester.pumpWidget(_wrap(auth: auth, lock: lock));
    await tester.pumpAndSettle();

    expect(find.text('Kilitli'), findsNothing);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
