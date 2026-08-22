import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notification/presentation/providers/notification_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/sync_habit_reminder_usecase.dart';
import '../providers/habit_providers.dart';

/// `SyncHabitReminderUseCase`'in cross-feature (Settings/Notification)
/// bağımlılıkları testte yapılandırılmamışsa senkron fırlatabilir — Tasks'ın
/// aynı "cross-feature-test-safety" deseni (bkz. proje hafızası).
void syncHabitReminderSafely(Ref ref, Habit habit) {
  try {
    unawaited(ref.read(syncHabitReminderUseCaseProvider).call(habit).catchError((_) {}));
  } catch (_) {
    // Sessiz — bir sonraki yazma işleminde tekrar denenir.
  }
}

/// Alışkanlık silindiğinde — artık senkronize edilecek bir [Habit] nesnesi
/// yoktur, yalnızca olası TÜM planlanmış hatırlatmaların (daily + 7 gün)
/// iptali gerekir.
void cancelHabitReminderSafely(Ref ref, String habitId) {
  try {
    unawaited(
      SyncHabitReminderUseCase.cancelAllFor(ref.read(cancelNotificationUseCaseProvider), habitId)
          .catchError((_) {}),
    );
  } catch (_) {
    // Sessiz.
  }
}
