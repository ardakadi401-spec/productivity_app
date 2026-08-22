import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/welcome_page.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/habits_goals_page.dart';
import '../../features/dashboard/presentation/pages/projects_tasks_page.dart';
import '../../features/habits/presentation/pages/habit_detail_page.dart';
import '../../features/notes/presentation/pages/note_detail_page.dart';
import '../../features/notes/presentation/pages/notes_list_page.dart';
import '../../features/pomodoro/presentation/pages/pomodoro_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/pages/create_task_page.dart';
import '../../features/tasks/presentation/pages/edit_task_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../guards/auth_guard.dart';
import '../route_paths/route_paths.dart';
import 'app_shell.dart';
import 'component_gallery_screen.dart';
import 'placeholder_screen.dart';

/// FAZ 4 — 5 sekmeli `StatefulShellRoute.indexedStack` (bkz. `app_shell.dart`)
/// artık ana uygulama kabuğu; Dashboard/Settings/Calendar/Projects-Tasks/
/// Habits-Goals gerçek iskelet ekranları. Detay/oluşturma rotaları
/// (`taskDetail`, `createTask`, `editTask`, `noteDetail` vb.) SCREENS.md §2.2
/// gereği Shell dışı tam ekran push'lar olarak kalır. FAZ 5 ile Task
/// rotaları gerçek ekranlara bağlandı; henüz karşılığı olmayanlar
/// `PlaceholderScreen` ile kalır (ROADMAP.md FAZ 6 ve sonrası). Auth Guard
/// FAZ 3'ten beri aktif — bkz. `routes/guards/auth_guard.dart`.
final routerProvider = Provider<GoRouter>((ref) {
  // `ref.listen(authStateProvider, ...)` kullanılır — repository'nin ham
  // stream'ine AYRICA abone olmak (önceki tasarım), `authStateProvider`'ın
  // kendi güncellemesiyle yarışan BAĞIMSIZ bir ikinci abonelik yaratıyordu:
  // `notifyListeners()`, `ref.read(authStateProvider)` henüz eski değeri
  // döndürürken tetiklenebiliyor ve tek seferlik stream event'lerinde bu
  // geçiş bir daha asla yakalanamıyordu. `ref.listen`, Riverpod'un kendi
  // state güncelleme sırasına göre çalıştığından bu yarışı ortadan kaldırır.
  final refreshNotifier = _GoRouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authStateProvider, (previous, next) => refreshNotifier.refresh());

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      return authGuardRedirect(authState: authState, location: state.matchedLocation);
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: RoutePaths.welcome, builder: (context, state) => const WelcomePage()),
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.dashboard, builder: (context, state) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.projects,
              builder: (context, state) => const ProjectsTasksPage(initialTab: 0),
            ),
            GoRoute(
              path: RoutePaths.tasks,
              builder: (context, state) => const ProjectsTasksPage(initialTab: 1),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.calendar, builder: (context, state) => const CalendarPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.habits,
              builder: (context, state) => const HabitsGoalsPage(initialTab: 0),
            ),
            GoRoute(
              path: RoutePaths.goals,
              builder: (context, state) => const HabitsGoalsPage(initialTab: 1),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.settings, builder: (context, state) => const SettingsPage()),
          ]),
        ],
      ),
      // Shell dışı tam ekran push'lar — SCREENS.md §2.2.
      GoRoute(
        path: RoutePaths.projectDetail,
        builder: (context, state) =>
            ProjectDetailPage(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: RoutePaths.taskDetail,
        builder: (context, state) =>
            TaskDetailPage(taskId: state.pathParameters['taskId']!),
      ),
      GoRoute(
        path: RoutePaths.createTask,
        // Project Detail (proje önceden seçili, SCREENS.md §4.8) ve Calendar
        // (tarih önceden seçili, SCREENS.md §4.13) `extra` ile `CreateTaskArgs`
        // iletir.
        builder: (context, state) {
          final args = state.extra as CreateTaskArgs?;
          return CreateTaskPage(
            initialProjectId: args?.projectId,
            initialDueDate: args?.dueDate,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editTask,
        builder: (context, state) => EditTaskPage(
          taskId: state.pathParameters['taskId']!,
          initialTask: state.extra as Task?,
        ),
      ),
      GoRoute(
        path: RoutePaths.habitDetail,
        builder: (context, state) =>
            HabitDetailPage(habitId: state.pathParameters['habitId']!),
      ),
      GoRoute(
        path: RoutePaths.pomodoro,
        // Task Detail'in "Pomodoro ile Çalış" eylemi görev önceden seçili
        // olacak şekilde `extra` ile `taskId` iletir (SCREENS.md §4.10).
        builder: (context, state) => PomodoroPage(initialTaskId: state.extra as String?),
      ),
      GoRoute(path: RoutePaths.notes, builder: (context, state) => const NotesListPage()),
      GoRoute(
        path: RoutePaths.createNote,
        // Project Detail / Task Detail'in "Not Ekle" eylemi proje/görev
        // önceden bağlı `extra` ile `CreateNoteArgs` iletir (SCREENS.md §4.8/§4.10).
        builder: (context, state) {
          final args = state.extra as CreateNoteArgs?;
          return NoteDetailPage(initialProjectId: args?.projectId, initialTaskId: args?.taskId);
        },
      ),
      GoRoute(
        path: RoutePaths.noteDetail,
        builder: (context, state) => NoteDetailPage(noteId: state.pathParameters['noteId']!),
      ),
      GoRoute(path: RoutePaths.statistics, builder: (context, state) => const StatisticsPage()),
      GoRoute(path: RoutePaths.search, builder: (context, state) => const SearchPage()),
      _placeholderRoute(RoutePaths.profile),
      // Shell dışı bağımsız rota — ARCHITECTURE.md §9.3, tam işlevi FAZ 15'te.
      _placeholderRoute(RoutePaths.lock),
      // FAZ 2 doğrulama rotası — 23 resmi ekranın dışında, geçici/dev-only.
      GoRoute(
        path: '/dev/components',
        builder: (context, state) => const ComponentGalleryScreen(),
      ),
    ],
  );
});

GoRoute _placeholderRoute(String path) {
  return GoRoute(
    path: path,
    builder: (context, state) => PlaceholderScreen(routeName: path),
  );
}

/// GoRouter'ın `redirect`'ini `authStateProvider` değişikliklerine bağlayan
/// köprü — GoRouter kendisi yeniden oluşturulmadan (navigasyon geçmişi
/// korunarak) her auth değişikliğinde `redirect` yeniden değerlendirilir.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
