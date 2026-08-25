# FAZ 18 — Release build R8/ProGuard kuralları. Flutter Gradle Plugin,
# `io.flutter.**` için gerekli kuralları kendisi ekler; burada yalnızca bu
# projenin kullandığı native/reflection tabanlı üçüncü taraf paketler için
# bilinen ek kurallar tutulur.

# flutter_local_notifications — zamanlanmış bildirimleri Gson ile
# serileştirir (boot recovery, bkz. `reschedule_all_notifications.dart`);
# R8 bu sınıfları küçültürse cihaz yeniden başlatıldığında bildirimler geri
# yüklenemez (paketin kendi README'sindeki resmi öneri).
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# isar_community — JNI üzerinden native (Rust) kütüphaneye bağlanır.
-keep class dev.isar.** { *; }
