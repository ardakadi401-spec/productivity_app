/// Merkezi route path sabitleri — SCREENS.md Bölüm 1 (23 ekran) ve
/// ARCHITECTURE.md Bölüm 9.4 (deep link hazırlığı) ile uyumlu.
///
/// Onboarding tamamlama rotası bilinçli olarak burada değildir; SCREENS.md
/// Bölüm 0'a göre 23 ekranlık listenin dışında kalır. `/lock` ise
/// ROADMAP.md FAZ 4 kapsamında eklendi (iskelet; tam işlevi FAZ 15'te).
class RoutePaths {
  RoutePaths._();

  // Authentication (Public) — SCREENS.md Bölüm 1.1
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Application (Protected) — SCREENS.md Bölüm 1.2
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:projectId';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:taskId';
  static const String createTask = '/tasks/new';
  static const String editTask = '/tasks/:taskId/edit';
  static const String calendar = '/calendar';
  static const String goals = '/goals';
  static const String habits = '/habits';
  static const String habitDetail = '/habits/:habitId';
  static const String pomodoro = '/pomodoro';
  static const String notes = '/notes';
  static const String noteDetail = '/notes/:noteId';
  static const String statistics = '/statistics';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Shell dışı bağımsız rota — ARCHITECTURE.md Bölüm 9.3.
  static const String lock = '/lock';
}
