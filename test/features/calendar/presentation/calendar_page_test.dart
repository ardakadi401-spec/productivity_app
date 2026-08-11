import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

const _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasksResult = const [];

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    var result = tasksResult;
    if (filter.dueOnDate != null) {
      final d = filter.dueOnDate!;
      result = result
          .where((t) =>
              t.dueDate != null &&
              t.dueDate!.year == d.year &&
              t.dueDate!.month == d.month &&
              t.dueDate!.day == d.day)
          .toList();
    }
    return Stream.value(result);
  }

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

Task _task({String taskId = 't1', required DateTime dueDate, String title = 'Görev'}) => Task(
      taskId: taskId,
      title: title,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: dueDate,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeTaskRepository fake) {
  return ProviderScope(
    overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const CalendarPage()),
  );
}

void main() {
  // Aylık grid (6 satır) + günlük ajanda tek kaydırılabilir listede;
  // varsayılan 800x600 test görünümünde ajanda bölümü viewport dışında
  // kalıp lazy-build edilmediğinden (create_task_page_test.dart'taki aynı
  // teknik) görünüm yükseklik büyütülür.
  void enlargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('seçili günde görev yoksa boş durum gösterir', (tester) async {
    enlargeViewport(tester);
    await tester.pumpWidget(_wrap(_FakeTaskRepository()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bu gün için planlanan bir şey yok'), findsOneWidget);
  });

  testWidgets('bugüne ait görev varsa günlük ajandada Event Card gösterir', (tester) async {
    enlargeViewport(tester);
    final now = DateTime.now();
    final fake = _FakeTaskRepository()
      ..tasksResult = [_task(dueDate: DateTime(now.year, now.month, now.day), title: 'Toplantı')];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();
    await tester.pump();

    expect(find.text('Toplantı'), findsOneWidget);
    expect(find.text('Bugün'), findsWidgets);
  });

  testWidgets('sonraki/önceki ay okları ay başlığını doğru günceller', (tester) async {
    await tester.pumpWidget(_wrap(_FakeTaskRepository()));
    await tester.pump();

    final now = DateTime.now();
    expect(find.textContaining(_monthNames[now.month - 1]), findsOneWidget);

    await tester.tap(find.byTooltip('Sonraki ay'));
    await tester.pump();

    final nextMonthDate = DateTime(now.year, now.month + 1);
    expect(find.textContaining(_monthNames[nextMonthDate.month - 1]), findsOneWidget);

    await tester.tap(find.byTooltip('Önceki ay'));
    await tester.tap(find.byTooltip('Önceki ay'));
    await tester.pump();

    final prevMonthDate = DateTime(now.year, now.month - 1);
    expect(find.textContaining(_monthNames[prevMonthDate.month - 1]), findsOneWidget);
  });
}
