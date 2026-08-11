import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_goals_by_date_usecase.dart';
import '../../domain/usecases/get_tasks_by_date_usecase.dart';
import '../../domain/usecases/get_tasks_by_month_usecase.dart';

// --- Domain katmanı (UseCase provider'ları) ---

final getTasksByDateUseCaseProvider = Provider<GetTasksByDateUseCase>((ref) {
  return GetTasksByDateUseCase(ref.watch(watchTasksUseCaseProvider));
});

final getTasksByMonthUseCaseProvider = Provider<GetTasksByMonthUseCase>((ref) {
  return GetTasksByMonthUseCase(ref.watch(watchTasksUseCaseProvider));
});

/// ARCHITECTURE.md §4 — Calendar, Goals Domain'ine (`WatchGoalsUseCase`) de
/// tek yönlü, salt okunur bağımlıdır (FAZ 7'de yalnızca Tasks vardı; FAZ 8
/// ile ROADMAP'in kendi notu gereği tamamlandı).
final getGoalsByDateUseCaseProvider = Provider<GetGoalsByDateUseCase>((ref) {
  return GetGoalsByDateUseCase(ref.watch(watchGoalsUseCaseProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Günlük ajanda (SCREENS.md §4.13) — görev VE hedef öğelerini (hedefler
/// yalnızca `periodEndDate` gününde, bkz. `GetGoalsByDateUseCase`) tek
/// listede birleştirir. `date` çağıran tarafından saat/dakika/saniyesi
/// sıfırlanmış olarak verilmelidir (family cache anahtarı tam `DateTime`
/// eşitliğine göre çalışır).
final calendarDayEventsProvider = StreamProvider.autoDispose.family<List<CalendarEvent>, DateTime>((
  ref,
  date,
) {
  final tasks = ref.watch(getTasksByDateUseCaseProvider).call(date);
  // Goals'ın tarafı (Calendar → Goals tek yönlü okuma) çökerse (örn. Goals
  // henüz yapılandırılmamışsa) Tasks tarafı bundan etkilenmemeli — bu
  // yalnızca Goals watch zincirinin SENKRON kurulumu sırasında (StreamProvider
  // create callback'i içinde) atılabilecek bir istisnayı yakalar; Goals
  // stream'inin kendi ASENKRON hatalarını `_combineLatest` zaten ele alır.
  Stream<List<CalendarEvent>> goals;
  try {
    goals = ref.watch(getGoalsByDateUseCaseProvider).call(date);
  } catch (_) {
    goals = Stream.value(const <CalendarEvent>[]);
  }
  return _combineLatest(tasks, goals);
});

/// Aylık grid işaretleyicileri — yalnızca Tasks (SCREENS.md §4.13'te
/// "Etkinlik İçeren" gün göstergesi görev bazlıdır; hedefler yalnızca
/// günlük ajandada, bkz. yukarısı). `month` yalnızca yıl/ay taşımalıdır.
final calendarMonthEventsProvider =
    StreamProvider.autoDispose.family<List<CalendarEvent>, DateTime>((ref, month) {
  return ref.watch(getTasksByMonthUseCaseProvider).call(month);
});

/// `rxdart` gibi ek bir paket eklemeden iki `Stream<List<CalendarEvent>>`'i
/// birleştirir — her iki kaynaktan da en az bir sonuç (değer VEYA hata)
/// geldiğinde, ikisinin son değerlerini birleştirerek yayınlar. Bir taraf
/// hata verirse (örn. Goals henüz yapılandırılmamışsa) o taraf boş liste
/// kabul edilir — diğer tarafın verisi sonsuza dek bloklanmaz.
Stream<List<CalendarEvent>> _combineLatest(
  Stream<List<CalendarEvent>> a,
  Stream<List<CalendarEvent>> b,
) {
  List<CalendarEvent> latestA = const [];
  List<CalendarEvent> latestB = const [];
  var hasA = false;
  var hasB = false;
  StreamSubscription<List<CalendarEvent>>? subA;
  StreamSubscription<List<CalendarEvent>>? subB;
  late final StreamController<List<CalendarEvent>> controller;

  void emit() {
    if (hasA && hasB) {
      controller.add([...latestA, ...latestB]);
    }
  }

  controller = StreamController<List<CalendarEvent>>(
    onListen: () {
      subA = a.listen(
        (value) {
          latestA = value;
          hasA = true;
          emit();
        },
        onError: (_) {
          hasA = true;
          emit();
        },
      );
      subB = b.listen(
        (value) {
          latestB = value;
          hasB = true;
          emit();
        },
        onError: (_) {
          hasB = true;
          emit();
        },
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}
