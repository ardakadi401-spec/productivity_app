import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:productivity_app/core/errors/result.dart';

import '../features/authentication/fake_auth_repository.dart';

/// ROADMAP.md FAZ 16 tamamlanma kriteri — "Kritik kullanıcı akışlarının
/// (auth ...) her biri için en az bir entegrasyon testi mevcut."
/// `widget_test.dart` yalnızca STATİK başlangıç durumunu (unauthenticated ->
/// Welcome) doğrular; bu dosya Auth Guard'ın gerçek `authStateChanges`
/// STREAM'İNDEKİ bir DEĞİŞİME (oturum açma/kapatma) tepki olarak router'ı
/// gerçekten yeniden yönlendirdiğini uçtan uca doğrular (auth_guard_test.dart
/// bunu saf fonksiyon seviyesinde test eder; burada gerçek `ProductivityApp`
/// + gerçek `GoRouter` refresh mekanizması devrede).
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

void main() {
  testWidgets(
    'unauthenticated başlar (Welcome) -> authStateChanges kullanıcı yayınlar -> '
    'router otomatik Dashboard\'a yönlendirir',
    (tester) async {
      final fake = FakeAuthRepository()..authStateValue = null;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fake),
            taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
          ],
          child: const ProductivityApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Giriş Yap'), findsWidgets);
      expect(find.text('Dashboard'), findsNothing);

      // Gerçek Firebase'de `authStateChanges` yeni bir emisyon yayınlar;
      // burada bunu fake repository üzerinden simüle ediyoruz. Router'ın
      // `ref.listen(authStateProvider, ...)` ile bu akışa (bağımsız ham bir
      // stream aboneliği DEĞİL) bağlı olması gerekir — aksi halde bu test
      // sessizce takılı kalırdı (bkz. proje hafızası "Riverpod+GoRouter
      // refresh pitfall").
      fake.authStateValue = testUser;
      final container = ProviderScope.containerOf(tester.element(find.text('Giriş Yap').first));
      container.invalidate(authStateProvider);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Giriş Yap'), findsNothing);
    },
  );

  testWidgets(
    'authenticated başlar (Dashboard) -> authStateChanges null yayınlar -> '
    'router otomatik Welcome\'a yönlendirir (oturum kapatma)',
    (tester) async {
      final fake = FakeAuthRepository()..authStateValue = testUser;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fake),
            taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
          ],
          child: const ProductivityApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);

      fake.authStateValue = null;
      final container = ProviderScope.containerOf(tester.element(find.text('Dashboard').first));
      container.invalidate(authStateProvider);
      await tester.pumpAndSettle();

      expect(find.text('Giriş Yap'), findsWidgets);
      expect(find.text('Dashboard'), findsNothing);
    },
  );
}
