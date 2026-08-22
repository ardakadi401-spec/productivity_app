import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notification/domain/utils/notification_id.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// `SyncTaskReminderUseCase`'in cross-feature (Settings/Notification)
/// bağımlılıkları testte yapılandırılmamışsa (`isarProvider` override
/// edilmemiş vb.) senkron fırlatabilir — bu, çağıran controller eyleminin
/// asıl sonucunu (görev kaydedildi/tamamlandı) etkilememeli. Goals/Notes'un
/// aynı "cross-feature-test-safety" deseniyle (bkz. proje hafızası)
/// try/catch içinde `unawaited` çağrılır.
void syncTaskReminderSafely(Ref ref, Task task) {
  try {
    // `.catchError` — provider zincirinin senkron fırlatmasını dıştaki
    // try/catch, usecase'in kendi asenkron gövdesindeki hatayı ise bu
    // yakalar (aksi halde işlenmemiş bir Future hatası olarak yükselirdi).
    unawaited(ref.read(syncTaskReminderUseCaseProvider).call(task).catchError((_) {}));
  } catch (_) {
    // Sessiz — bir sonraki yazma işleminde tekrar denenir.
  }
}

/// Görev silindiğinde — artık senkronize edilecek bir [Task] nesnesi yoktur,
/// yalnızca olası planlanmış hatırlatmanın iptali gerekir.
void cancelTaskReminderSafely(Ref ref, String taskId) {
  try {
    unawaited(ref.read(cancelNotificationUseCaseProvider).call(notificationIdFor(taskId)).catchError((_) {}));
  } catch (_) {
    // Sessiz.
  }
}
