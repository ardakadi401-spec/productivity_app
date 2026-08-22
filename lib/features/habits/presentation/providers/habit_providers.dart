import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/datasources/local/habit_local_datasource.dart';
import '../../data/datasources/remote/habit_remote_datasource.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_record.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/check_in_habit_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/get_habit_records_in_range_usecase.dart';
import '../../domain/usecases/sync_habit_reminder_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';
import '../../domain/usecases/watch_habit_records_usecase.dart';
import '../../domain/usecases/watch_habit_usecase.dart';
import '../../domain/usecases/watch_habits_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final habitLocalDatasourceProvider = Provider<HabitLocalDatasource>((ref) {
  return HabitLocalDatasource(ref.watch(isarProvider));
});

final habitRemoteDatasourceProvider = Provider<HabitRemoteDatasource>((ref) {
  return HabitRemoteDatasource();
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(
    ref.watch(habitLocalDatasourceProvider),
    ref.watch(habitRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchHabitsUseCaseProvider = Provider<WatchHabitsUseCase>((ref) {
  return WatchHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final watchHabitUseCaseProvider = Provider<WatchHabitUseCase>((ref) {
  return WatchHabitUseCase(ref.watch(habitRepositoryProvider));
});

final watchHabitRecordsUseCaseProvider = Provider<WatchHabitRecordsUseCase>((ref) {
  return WatchHabitRecordsUseCase(ref.watch(habitRepositoryProvider));
});

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  return CreateHabitUseCase(ref.watch(habitRepositoryProvider));
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  return UpdateHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  return DeleteHabitUseCase(ref.watch(habitRepositoryProvider));
});

final checkInHabitUseCaseProvider = Provider<CheckInHabitUseCase>((ref) {
  return CheckInHabitUseCase(ref.watch(habitRepositoryProvider));
});

final getHabitRecordsInRangeUseCaseProvider = Provider<GetHabitRecordsInRangeUseCase>((ref) {
  return GetHabitRecordsInRangeUseCase(ref.watch(habitRepositoryProvider));
});

/// ARCHITECTURE.md §10.2 — Habits; Settings VE Notification Domain'ine tek
/// yönlü bağımlıdır (ROADMAP.md FAZ 13).
final syncHabitReminderUseCaseProvider = Provider<SyncHabitReminderUseCase>((ref) {
  return SyncHabitReminderUseCase(
    ref.watch(watchNotificationPreferencesUseCaseProvider),
    ref.watch(scheduleNotificationUseCaseProvider),
    ref.watch(cancelNotificationUseCaseProvider),
  );
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Habits Screen listesi (SCREENS.md §4.15).
final habitListProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  return ref.watch(watchHabitsUseCaseProvider).call();
});

final habitDetailProvider = StreamProvider.autoDispose.family<Habit?, String>((ref, habitId) {
  return ref.watch(watchHabitUseCaseProvider).call(habitId);
});

final habitRecordsProvider = StreamProvider.autoDispose.family<List<HabitRecord>, String>((
  ref,
  habitId,
) {
  return ref.watch(watchHabitRecordsUseCaseProvider).call(habitId);
});

/// Dashboard'un "Alışkanlıklar" bölümü (ARCHITECTURE.md §4.1 örneği) —
/// yalnızca bugün için "hedef gün" olan aktif alışkanlıkları döner
/// (SCREENS.md §5 sıra 3 "Bugün için tanımlı tüm alışkanlıklar").
final todayHabitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final now = DateTime.now();
  return ref.watch(watchHabitsUseCaseProvider).call().map(
        (habits) => habits.where((h) => h.isScheduledOn(now)).toList(),
      );
});

/// Bir alışkanlığın bugün check-in yapılıp yapılmadığını canlı olarak
/// izler — ayrı bir repository/UseCase metodu eklemek yerine mevcut
/// `watchHabitRecordsUseCaseProvider`'ın çıktısından türetilir (Projects'in
/// `projectTaskStatsProvider`'ıyla aynı "ek sorgu yerine mevcut stream'i
/// filtrele" ilkesi).
final habitTodayCheckInProvider = StreamProvider.autoDispose.family<bool, String>((ref, habitId) {
  final today = DateTime.now();
  return ref.watch(watchHabitRecordsUseCaseProvider).call(habitId).map(
        (records) => records.any(
          (r) =>
              r.isCompleted &&
              r.date.year == today.year &&
              r.date.month == today.month &&
              r.date.day == today.day,
        ),
      );
});
