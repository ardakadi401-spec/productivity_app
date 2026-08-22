/// `flutter_local_notifications` bildirim kimliği olarak 32-bit pozitif
/// `int` bekler; Task/Habit kimlikleri Firestore doküman ID'si (`String`)
/// olduğundan buradan deterministik bir `int` türetilir. Saf, bağımsız
/// fonksiyon — Notification'ın hiçbir feature'a bağımlı olmadan (yalnızca
/// `String` alır) kimlik üretebilmesini sağlar.
int notificationIdFor(String sourceId) => sourceId.hashCode & 0x7fffffff;

/// Habit'in `specificDays` frekansında HER seçili haftanın günü için ayrı
/// bir tekrarlayan bildirim gerekir (`NotificationRepeatMode.weekly`) —
/// bu yüzden `habitId` tek başına yeterli değildir, gün de kimliğe girer.
int notificationIdForWeekday(String sourceId, int weekday) =>
    notificationIdFor('$sourceId::weekday$weekday');
