import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/habits/presentation/providers/habit_providers.dart';
import '../features/tasks/domain/entities/task_filter.dart';
import '../features/tasks/presentation/providers/task_providers.dart';

/// ROADMAP.md FAZ 13 — "boot sonrası yeniden planlama zorunlu" kullanıcı
/// kararı. Android'in kendi native boot receiver'ı (AndroidManifest.xml,
/// `ScheduledNotificationBootReceiver`) plugin'in KENDİ kalıcı deposundaki
/// planları otomatik geri kurar — bu, uygulama tekrar açılmasa bile çalışan
/// birinci savunma hattıdır. Bu fonksiyon İKİNCİ, tamamlayıcı hattır:
/// uygulama her SOĞUK başlatıldığında (yeniden başlatma sonrası ilk açılış
/// dahil), Isar'daki GÜNCEL Task/Habit verisinden tüm hatırlatmaları
/// sıfırdan tutarlı şekilde yeniden kurar — Goals/Statistics'in "ekrana
/// giriş anında lazy self-healing" ilkesiyle aynı, yalnızca tetikleyicisi
/// "uygulama açılışı"dır.
///
/// `main()` içinde, widget ağacı kurulmadan ÖNCE çağrılır — bu yüzden
/// `Ref` değil doğrudan `ProviderContainer.read` kullanılır. `app/`
/// katmanının kompozisyon kökü rolü gereği (FOLDER_STRUCTURE.md §1.1)
/// birden fazla feature'ı (Tasks, Habits) bir arada bilmesi burada
/// istisnai olarak kabul edilebilir — hiçbir feature'ın kendisi bunu
/// yapmaz.
Future<void> rescheduleAllNotifications(ProviderContainer container) async {
  try {
    final tasks =
        await container.read(watchTasksUseCaseProvider).call(filter: TaskFilter.none).first;
    for (final task in tasks) {
      await container.read(syncTaskReminderUseCaseProvider).call(task);
    }
  } catch (_) {
    // Sessiz — oturum açık değilse Task stream'i boş/hata verebilir, bu
    // beklenen bir durumdur; bir sonraki açılışta tekrar denenir.
  }

  try {
    final habits = await container.read(watchHabitsUseCaseProvider).call().first;
    for (final habit in habits) {
      await container.read(syncHabitReminderUseCaseProvider).call(habit);
    }
  } catch (_) {
    // Sessiz.
  }
}
