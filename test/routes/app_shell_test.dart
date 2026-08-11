import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:productivity_app/routes/route_paths/route_paths.dart';
import 'package:productivity_app/shared/components/app_bottom_nav_bar.dart';

import '../features/authentication/fake_auth_repository.dart';

/// Shell testleri gerçek `ProductivityApp`'i kurduğundan (`isarProvider`
/// yalnızca `main.dart`'ta override edilir), Tasks feature'ının tüm
/// provider zinciri boş bir sahte repository ile kesilir — bu dosyanın
/// amacı navigasyon/shell davranışıdır, görev verisi değil.
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
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

Widget _wrap(FakeAuthRepository fake) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fake),
      taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
    ],
    child: const ProductivityApp(),
  );
}

/// Bottom nav bar'daki [label]'a sahip öğeyi bulur — sayfa içeriğindeki aynı
/// metinle (ör. AppTopBar başlığı, iç TabBar sekmesi) karışmaması için.
Finder _navItem(String label) =>
    find.descendant(of: find.byType(AppBottomNavBar), matching: find.text(label));

void main() {
  testWidgets('kimliği doğrulanmış kullanıcı Dashboard\'a iniyor, 5 sekme görünüyor', (
    tester,
  ) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets); // AppTopBar başlığı + bottom nav etiketi
    expect(_navItem('Projeler'), findsOneWidget);
    expect(_navItem('Takvim'), findsOneWidget);
    expect(_navItem('Alışkanlıklar'), findsOneWidget);
    expect(_navItem('Ayarlar'), findsOneWidget);
  });

  testWidgets('sekmeler arası geçiş çalışıyor ve iç sekme durumu korunuyor', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.tap(_navItem('Projeler'));
    await tester.pumpAndSettle();
    expect(find.text('Projeler & Görevler'), findsOneWidget);

    // İç TabBar'da "Görevler"e geç.
    await tester.tap(find.text('Görevler'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz görev eklemedin'), findsOneWidget);

    // Başka bir bottom-nav sekmesine geç (Ayarlar).
    await tester.tap(_navItem('Ayarlar'));
    await tester.pumpAndSettle();
    expect(find.text('Tema'), findsOneWidget);

    // Projeler & Görevler'e geri dön — IndexedStack widget ağacını canlı
    // tuttuğundan iç TabBar hâlâ "Görevler" sekmesinde olmalı (sıfırlanmamış).
    await tester.tap(_navItem('Projeler'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz görev eklemedin'), findsOneWidget);
  });

  testWidgets('Dashboard arama ikonu Search ekranına push eder', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text(RoutePaths.search), findsOneWidget);
  });

  testWidgets('Settings tema seçici gerçekten temayı değiştiriyor', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.tap(_navItem('Ayarlar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AMOLED'));
    await tester.pumpAndSettle();

    // `Theme.of` MaterialApp'in KENDİ elementinden çağrılırsa, MaterialApp'in
    // çocuklarına sağladığı temayı değil Flutter'ın varsayılanını döndürür
    // (Theme widget'ı MaterialApp'in bir ATASI değil, ÇOCUĞUdur) — bu yüzden
    // bir alt (descendant) context, burada Settings ekranındaki "Tema" metni,
    // kullanılır.
    final scaffoldBg = Theme.of(tester.element(find.text('Tema'))).scaffoldBackgroundColor;
    expect(scaffoldBg, const Color(0xFF000000));
  });
}
