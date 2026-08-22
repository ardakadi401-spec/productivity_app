import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../data/datasources/local/pomodoro_local_datasource.dart';
import '../../data/datasources/remote/pomodoro_remote_datasource.dart';
import '../../data/repositories/pomodoro_repository_impl.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../../domain/usecases/complete_pomodoro_session_usecase.dart';
import '../../domain/usecases/get_pomodoro_sessions_in_range_usecase.dart';
import '../../domain/usecases/link_session_to_task_usecase.dart';
import '../../domain/usecases/start_pomodoro_session_usecase.dart';
import '../../domain/usecases/watch_pomodoro_sessions_by_task_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final pomodoroLocalDatasourceProvider = Provider<PomodoroLocalDatasource>((ref) {
  return PomodoroLocalDatasource(ref.watch(isarProvider));
});

final pomodoroRemoteDatasourceProvider = Provider<PomodoroRemoteDatasource>((ref) {
  return PomodoroRemoteDatasource();
});

final pomodoroRepositoryProvider = Provider<PomodoroRepository>((ref) {
  return PomodoroRepositoryImpl(
    ref.watch(pomodoroLocalDatasourceProvider),
    ref.watch(pomodoroRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

/// Zamanlayıcının wall-clock kaynağı — ROADMAP.md FAZ 11 "wall-clock hedef
/// zaman" mitigasyonu bu tek noktadan enjekte edilir; testler bunu sahte
/// (kontrol edilebilir) bir saatle override ederek arka plan/gece yarısı
/// senaryolarını gerçek zaman beklemeden simüle edebilir.
final pomodoroClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// --- Domain katmanı (UseCase provider'ları) ---

final startPomodoroSessionUseCaseProvider = Provider<StartPomodoroSessionUseCase>((ref) {
  return StartPomodoroSessionUseCase(ref.watch(pomodoroRepositoryProvider));
});

final completePomodoroSessionUseCaseProvider = Provider<CompletePomodoroSessionUseCase>((ref) {
  return CompletePomodoroSessionUseCase(ref.watch(pomodoroRepositoryProvider));
});

final linkSessionToTaskUseCaseProvider = Provider<LinkSessionToTaskUseCase>((ref) {
  return LinkSessionToTaskUseCase(ref.watch(pomodoroRepositoryProvider));
});

final watchPomodoroSessionsByTaskUseCaseProvider = Provider<WatchPomodoroSessionsByTaskUseCase>((ref) {
  return WatchPomodoroSessionsByTaskUseCase(ref.watch(pomodoroRepositoryProvider));
});

final getPomodoroSessionsInRangeUseCaseProvider = Provider<GetPomodoroSessionsInRangeUseCase>((ref) {
  return GetPomodoroSessionsInRangeUseCase(ref.watch(pomodoroRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

/// Task Detail Screen'in Pomodoro oturum geçmişi (SCREENS.md §4.10).
final pomodoroSessionsByTaskProvider =
    StreamProvider.autoDispose.family<List<PomodoroSession>, String>((ref, taskId) {
  return ref.watch(watchPomodoroSessionsByTaskUseCaseProvider).call(taskId);
});
