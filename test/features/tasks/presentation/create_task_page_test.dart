import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/pages/create_task_page.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

/// Yalnızca doğrulama-engelleme akışını test eder (SCREENS.md §4.11 "form
/// gönderilmeden önce UI seviyesinde de engellenir") — bu yol repository'ye
/// hiç ulaşmadığından `go_router`/`context.pop()` gerekmez.
class _UnusedTaskRepository implements TaskRepository {
  @override
  String newTaskId() => throw UnimplementedError();
  @override
  String newSubTaskId(String taskId) => throw UnimplementedError();
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => const Stream.empty();
  @override
  Stream<Task?> watchTask(String taskId) => const Stream.empty();
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => const Stream.empty();
  @override
  Stream<List<Task>> watchTodayTasks() => const Stream.empty();
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
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

void main() {
  testWidgets('boş başlıkla Kaydet basılırsa alan altı hata gösterir, repository çağrılmaz', (
    tester,
  ) async {
    // Sayfa (AppBar + form + taslak alt görev listesi) varsayılan 800x600
    // test görünümünden uzun; buton görünür alanda kalsın diye büyütülür.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(_UnusedTaskRepository())],
        child: MaterialApp(theme: AppTheme.light, home: const CreateTaskPage()),
      ),
    );

    await tester.tap(find.text('Görevi Kaydet'));
    await tester.pump();

    expect(find.text('Görev başlığı boş olamaz.'), findsOneWidget);
  });

  testWidgets('form alanları render olur', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(_UnusedTaskRepository())],
        child: MaterialApp(theme: AppTheme.light, home: const CreateTaskPage()),
      ),
    );

    expect(find.text('Başlık'), findsOneWidget);
    expect(find.text('Proje'), findsOneWidget);
    expect(find.text('Öncelik'), findsOneWidget);
    expect(find.text('Düşük'), findsOneWidget);
    expect(find.text('Orta'), findsOneWidget);
    expect(find.text('Yüksek'), findsOneWidget);
  });

  testWidgets(
    'initialDueDate verilirse (Calendar\'dan "Bu Güne Görev Ekle") tarih alanı önceden dolu gelir',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [taskRepositoryProvider.overrideWithValue(_UnusedTaskRepository())],
          child: MaterialApp(
            theme: AppTheme.light,
            home: CreateTaskPage(initialDueDate: DateTime(2026, 3, 10)),
          ),
        ),
      );

      expect(find.text('10.3.2026'), findsOneWidget);
    },
  );
}
