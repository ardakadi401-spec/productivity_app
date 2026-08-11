import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

Task _task(String id, String title) => Task(
      taskId: id,
      title: title,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  testWidgets('DashboardPage SCREENS.md §5\'teki 5 bölümü de gösterir (bugün görev yok)', (
    tester,
  ) async {
    // Varsayılan test görüntü alanı (800x600), Dashboard'un tüm ListView
    // içeriğini sığdırmaya yetmiyor — büyütülmezse alt bölümler render
    // edilmez (ListView tembel/lazy inşa eder).
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayTasksProvider.overrideWith((ref) => Stream.value(const []))],
        child: MaterialApp(theme: AppTheme.light, home: const DashboardPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Bugünkü Görevler'), findsOneWidget);
    expect(find.text('Bugün için planlanan bir şey yok'), findsOneWidget);
    expect(find.text('Alışkanlıklar'), findsOneWidget);
    expect(find.text('Henüz alışkanlık eklemedin'), findsOneWidget);
    expect(find.text('Haftalık İlerleme'), findsOneWidget);
    expect(find.text('Hızlı Erişim'), findsOneWidget);
    expect(find.text('Yeni Görev'), findsOneWidget);
    expect(find.text('Yeni Not'), findsOneWidget);
    expect(find.text('Pomodoro'), findsOneWidget);
  });

  testWidgets('bugün görev varsa Empty State yerine görev kartlarını gösterir', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayTasksProvider.overrideWith(
            (ref) => Stream.value([_task('t1', 'Sunuma hazırlan')]),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const DashboardPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Sunuma hazırlan'), findsOneWidget);
    expect(find.text('Bugün için planlanan bir şey yok'), findsNothing);
  });
}
