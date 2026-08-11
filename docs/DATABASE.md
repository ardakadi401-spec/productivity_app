# DATABASE.md
## Kişisel Üretkenlik Uygulaması — Veritabanı Mimarisi Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Firebase Architect / Senior Database Designer / Mobile Backend Architect
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`
**Doküman Durumu:** Teknik Veri Mimarisi Referansı

> Bu doküman yalnızca veritabanı tasarımını tanımlar. Kod, Flutter implementasyonu, Firebase kurulumu veya Firestore Rules yazımı içermez. Alan tabloları, şemayı tarif amaçlı sunulmuştur; gerçek şema/kural implementasyonu bu doküman kapsamında değildir.

---

## 1. Firestore Genel Yapısı

### 1.1 Mimari Yaklaşım
Veritabanı, `ARCHITECTURE.md`'de tanımlanan **offline-first** prensibiyle tam uyumlu, **kullanıcı-merkezli (user-scoped)** bir Firestore koleksiyon yapısı üzerine kurulur. Uygulama yalnızca kişisel kullanım için tasarlandığından (takım/paylaşım yok), tüm veri modeli **tek kullanıcı → kendi verisi** ilişkisi etrafında sadeleştirilmiştir; çoklu kullanıcı erişim senaryosu (paylaşılan proje, ortak görev vb.) hiçbir koleksiyonda modellenmez.

### 1.2 Ana Koleksiyon Stratejisi: Kullanıcı Alt Koleksiyonu Modeli
Firestore'da iki temel yaklaşım mümkündür: (a) tüm veriler kök seviyede düz koleksiyonlarda tutulup `userId` alanıyla filtrelenir, veya (b) her kullanıcıya ait veriler `users/{userId}` altında alt koleksiyon olarak tutulur. Bu proje için **(b) kullanıcı alt koleksiyonu modeli** tercih edilmiştir. Gerekçeler:

- **Güvenlik sadeliği:** Firestore güvenlik kurallarında "kullanıcı yalnızca kendi verisine erişebilir" prensibi, path bazlı izolasyonla (`users/{userId}/...`) çok daha basit ve hataya kapalı şekilde ifade edilir; kök seviye düz koleksiyonlarda her sorguda `userId == request.auth.uid` kontrolüne bağımlı kalmak, unutulmaya açık bir risk taşır.
- **Sorgu izolasyonu:** Kullanıcının kendi verisi zaten path ile izole olduğundan, sorgular doğal olarak yalnızca ilgili kullanıcının belgelerini tarar — gereksiz okuma/tarama maliyeti oluşmaz.
- **Kişisel kullanım uyumu:** Uygulamanın PRD'de tanımlanan "yalnızca bireysel kullanım" ilkesiyle birebir örtüşür; çoklu kullanıcı sorgusu (örn. "tüm kullanıcıların ortak görevi") hiçbir zaman gerekmez, bu nedenle düz koleksiyon modelinin sağladığı "koleksiyon grubu sorgusu" avantajına ihtiyaç yoktur.

### 1.3 Ana Koleksiyon Ağacı (Kavramsal)

```
users (root collection)
  └── {userId} (document)
        ├── settings (embedded/document field — alt koleksiyon değil)
        ├── projects (sub-collection)
        │     └── {projectId}
        ├── tasks (sub-collection)
        │     └── {taskId}
        │           └── subtasks (sub-collection)
        │                 └── {subtaskId}
        ├── categories (sub-collection)
        │     └── {categoryId}
        ├── tags (sub-collection)
        │     └── {tagId}
        ├── calendarEvents (sub-collection)
        │     └── {eventId}
        ├── notifications (sub-collection)
        │     └── {notificationId}
        ├── goals (sub-collection)
        │     └── {goalId}
        ├── habits (sub-collection)
        │     └── {habitId}
        │           └── habitRecords (sub-collection)
        │                 └── {recordId}
        ├── pomodoroSessions (sub-collection)
        │     └── {sessionId}
        ├── notes (sub-collection)
        │     └── {noteId}
        └── statisticsSnapshots (sub-collection)
              └── {snapshotId}
```

### 1.4 Alt Koleksiyon Kullanım Kararları
Alt koleksiyon kullanımı, şu üç kritere göre karar verilmiştir:

| Kriter | Alt Koleksiyon Kullan | Belge İçi Alan (Embedded) Kullan |
|---|---|---|
| Veri, ana kayıttan bağımsız büyüyebiliyor mu (sınırsız sayıda) | Evet → Alt koleksiyon (örn. Tasks, Notes) | Hayır → Embedded (örn. Settings) |
| Veri kendi başına sorgulanacak mı (filtre/sıralama) | Evet → Alt koleksiyon (örn. HabitRecords tarih aralığı sorgusu) | Hayır → Embedded |
| Veri, üst belge her okunduğunda her zaman birlikte mi gerekiyor | Hayır → Alt koleksiyon (gereksiz okuma maliyetini önler) | Evet → Embedded (örn. kullanıcı tercihleri) |

Bu kritere göre: **SubTasks** (Task altında), **HabitRecords** (Habit altında) alt koleksiyon olarak modellenmiştir çünkü bağımsız olarak büyür ve tarih bazlı sorgulanır. **Settings** ise Users belgesi içinde gömülü (embedded) bir alan olarak tutulur çünkü sabit boyutlu, tek parça halinde okunan/güncellenen bir veridir.

### 1.5 Categories ve Tags'in Konumu
Categories ve Tags, Task/Project/Note gibi birden fazla modül tarafından referans verilen **ortak sözlük (lookup) koleksiyonlarıdır**. Kullanıcı altında ayrı alt koleksiyonlar olarak tutulur (`users/{userId}/categories`, `users/{userId}/tags`) ve diğer belgeler bunlara **ID referansı** ile bağlanır (veri tekrarını önlemek için isim/renk gibi bilgiler kopyalanmaz, yalnızca ID tutulur — bkz. Bölüm 11).

---

## 2. Users Collection

### 2.1 Amaç
Kullanıcının kimlik ve profil bilgilerini, uygulama genelindeki tercihlerini (embedded settings) tutan kök belgedir. Firebase Authentication'ın ürettiği `uid`, bu koleksiyonun belge ID'si olarak birebir kullanılır (`users/{uid}`) — bu, kimlik doğrulama ile veri katmanı arasında ekstra bir eşleme tablosuna gerek bırakmaz.

### 2.2 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `userId` | string | Evet | Firebase Auth `uid` ile birebir aynı; belge ID'si olarak da kullanılır |
| `name` | string | Evet | Kullanıcı görünen adı |
| `email` | string | Evet | Firebase Auth ile senkron e-posta |
| `photoUrl` | string (nullable) | Hayır | Google girişinden gelen profil fotoğrafı URL'i |
| `authProvider` | string (enum: `google`, `email`) | Evet | Kullanıcının giriş yöntemi |
| `createdAt` | timestamp | Evet | Hesap oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son profil güncelleme zamanı |
| `settings` | map (embedded) | Evet | Bkz. 2.3 — tema, kilit, bildirim tercihleri |
| `onboardingCompleted` | boolean | Evet | İlk kurulum akışının tamamlanıp tamamlanmadığı |

### 2.3 Settings (Embedded Map) Alt Alanları

| Alan | Tip | Açıklama |
|---|---|---|
| `themeMode` | string (enum: `light`, `dark`, `amoled`, `system`) | UI_GUIDELINES.md Bölüm 12 ile uyumlu tema tercihi |
| `appLockEnabled` | boolean | PIN/Biyometri kilidinin aktif olup olmadığı |
| `appLockType` | string (enum: `pin`, `biometric`, `both`, `none`) | Aktif kilit türü |
| `notificationsEnabled` | boolean | Genel bildirim ana anahtarı |
| `pomodoroWorkDuration` | number (dakika) | Varsayılan Pomodoro çalışma süresi |
| `pomodoroBreakDuration` | number (dakika) | Varsayılan Pomodoro mola süresi |
| `weekStartDay` | string (enum: `monday`, `sunday`) | Takvim/haftalık hedef hesaplama başlangıcı |

> **Not:** PIN kodunun kendisi bu belgede **asla** saklanmaz (bkz. Bölüm 14 ve 16 — güvenlik prensipleri). Yalnızca kilit türü tercihi burada tutulur; PIN doğrulama mekanizması cihaz seviyesinde, güvenli yerel depolamada yaşar.

---

## 3. Project Model

### 3.1 Konum
`users/{userId}/projects/{projectId}`

### 3.2 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `projectId` | string | Evet | Belge ID ile birebir aynı |
| `title` | string | Evet | Proje adı (maks. 100 karakter — bkz. Bölüm 14) |
| `description` | string (nullable) | Hayır | Proje açıklaması (maks. 500 karakter) |
| `color` | string (hex kod) | Evet | UI_GUIDELINES.md renk paletinden seçilen etiket rengi |
| `icon` | string (icon key) | Hayır | İkon seti içindeki referans anahtar |
| `status` | string (enum: `active`, `archived`) | Evet | Arşivleme durumu (PRD Bölüm 6.3) |
| `taskCount` | number | Evet | Denormalize edilmiş toplam görev sayısı (bkz. 15.4) |
| `completedTaskCount` | number | Evet | Denormalize edilmiş tamamlanan görev sayısı (ilerleme yüzdesi hesaplamak için) |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |
| `isDeleted` | boolean | Evet | Soft delete bayrağı (bkz. Bölüm 13.4) |
| `syncStatus` | string (yalnızca Isar tarafında; Firestore'a yazılmaz) | — | Bkz. Bölüm 12 |

> `userId` alanı bu belgede ayrıca tutulmaz — belge zaten `users/{userId}/projects/...` path'i altında olduğu için üst kullanıcı bilgisi path'ten türetilir; bu, gereksiz veri tekrarını önler (Firestore path'i, ilişkiyi zaten taşır).

---

## 4. Task Model

### 4.1 Konum
`users/{userId}/tasks/{taskId}`

### 4.2 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `taskId` | string | Evet | Belge ID ile birebir aynı |
| `title` | string | Evet | Görev başlığı (maks. 200 karakter) |
| `description` | string (nullable) | Hayır | Görev açıklaması (maks. 1000 karakter) |
| `priority` | string (enum: `low`, `medium`, `high`) | Evet | Öncelik seviyesi |
| `status` | string (enum: `pending`, `completed`) | Evet | Tamamlanma durumu |
| `dueDate` | timestamp (nullable) | Hayır | Son tarih |
| `dueTime` | string (nullable, `HH:mm` formatı) | Hayır | Son saat (bildirim tetikleme için ayrı tutulur) |
| `projectId` | string (nullable) | Hayır | İlişkili proje referansı (projesiz görev desteklenir) |
| `categoryId` | string (nullable) | Hayır | İlişkili kategori referansı |
| `tagIds` | array\<string\> | Hayır | İlişkili etiket referansları (çoklu) |
| `recurrenceRule` | map (nullable) | Hayır | Bkz. 4.3 — tekrar kuralı |
| `subtaskCount` | number | Evet | Denormalize edilmiş toplam alt görev sayısı |
| `completedSubtaskCount` | number | Evet | Denormalize edilmiş tamamlanan alt görev sayısı (ilerleme % için) |
| `completedAt` | timestamp (nullable) | Hayır | Tamamlanma anı (istatistik hesaplamaları için) |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |
| `isDeleted` | boolean | Evet | Soft delete bayrağı |

### 4.3 `recurrenceRule` Alt Alanları

| Alan | Tip | Açıklama |
|---|---|---|
| `frequency` | string (enum: `daily`, `weekly`, `monthly`) | Tekrar sıklığı |
| `interval` | number | Kaç birimde bir tekrarlanacağı (örn. `2` + `weekly` = 2 haftada bir) |
| `daysOfWeek` | array\<number\> (nullable) | Haftalık tekrarda hangi günler (1–7) |
| `endDate` | timestamp (nullable) | Tekrarın biteceği tarih (sınırsızsa null) |

> Tekrarlanan görevler, her tekrar için ayrı bir belge **önceden oluşturulmaz** (bu, koleksiyonu gereksiz şişirir). Bunun yerine tek bir "şablon" görev belgesi `recurrenceRule` taşır; bir sonraki somut örneği (occurrence), yerel Isar katmanında hesaplanarak Calendar/Dashboard görünümüne yansıtılır (bkz. Bölüm 12).

---

## 5. Sub Task Model

### 5.1 Konum
`users/{userId}/tasks/{taskId}/subtasks/{subtaskId}`

### 5.2 Tasarım Kararı
Alt görevler, ana görevin **alt koleksiyonu** olarak modellenmiştir (embedded array değil). Gerekçe: Bir görev teorik olarak çok sayıda alt göreve sahip olabilir ve alt görevlerin her biri bağımsız olarak güncellenebilir (tamamlama işaretleme) — bunu embedded array olarak tutmak, her alt görev güncellemesinde **tüm array'in yeniden yazılmasını** gerektirir ve gereksiz yazma maliyeti + eşzamanlılık çakışma riski yaratır. Alt koleksiyon modeli, her alt görevin bağımsız, ucuz (tek alan) güncellenmesine izin verir.

### 5.3 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `subtaskId` | string | Evet | Belge ID ile birebir aynı |
| `title` | string | Evet | Alt görev başlığı (maks. 150 karakter) |
| `isCompleted` | boolean | Evet | Tamamlanma durumu |
| `order` | number | Evet | Kullanıcı tanımlı sıralama pozisyonu |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |

> Bir alt görev tamamlandığında/eklendiğinde, üst Task belgesindeki `subtaskCount`/`completedSubtaskCount` alanları (Bölüm 4.2) **atomik sayaç güncellemesiyle** senkron tutulur — bu, Task listesi ekranının her seferinde alt koleksiyonu okumadan ilerleme yüzdesini göstermesini sağlar (okuma maliyeti optimizasyonu, bkz. Bölüm 15.4).

---

## 6. Habit Model

### 6.1 Konum
`users/{userId}/habits/{habitId}` ve `users/{userId}/habits/{habitId}/habitRecords/{recordId}`

### 6.2 Habit Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `habitId` | string | Evet | Belge ID ile birebir aynı |
| `name` | string | Evet | Alışkanlık adı (maks. 100 karakter) |
| `icon` | string | Hayır | İkon referansı |
| `color` | string (hex) | Evet | Etiket rengi |
| `targetFrequency` | string (enum: `daily`, `specificDays`) | Evet | Hedef sıklık tipi |
| `targetDays` | array\<number\> (nullable) | Hayır | `specificDays` seçiliyse haftanın günleri (1–7) |
| `reminderTime` | string (nullable, `HH:mm`) | Hayır | Hatırlatma saati |
| `currentStreak` | number | Evet | Denormalize edilmiş güncel seri (bkz. 6.4) |
| `longestStreak` | number | Evet | Denormalize edilmiş en uzun seri |
| `status` | string (enum: `active`, `archived`) | Evet | Aktiflik durumu |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |
| `isDeleted` | boolean | Evet | Soft delete bayrağı |

### 6.3 HabitRecord Alan Tanımları
Her check-in, ayrı bir kayıt belgesi olarak tutulur — bu, tarih bazlı sorgulama (örn. "bu ayki tüm kayıtlar") ve istatistik hesaplamalarını (Bölüm 10) doğrudan destekler.

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `recordId` | string | Evet | Belge ID ile birebir aynı (önerilen format: `yyyy-MM-dd`, bkz. 13.1) |
| `date` | timestamp | Evet | Kaydın ait olduğu gün (saat bileşeni sıfırlanmış) |
| `isCompleted` | boolean | Evet | O gün alışkanlığın yapılıp yapılmadığı |
| `completedAt` | timestamp (nullable) | Hayır | İşaretlenme anı |

### 6.4 Streak Hesaplama Mantığı (Kavramsal)
`currentStreak` ve `longestStreak`, her yeni `HabitRecord` yazıldığında **istemci tarafında hesaplanıp** Habit belgesine denormalize edilir (Cloud Functions kullanılmaz — proje kapsamı yalnızca istemci taraflı mimaridir). Hesaplama mantığı: en güncel tarihten geriye doğru ardışık `isCompleted: true` kayıtları sayılır; bir gün atlanırsa seri sıfırlanır. Bu hesaplama, `ARCHITECTURE.md` Bölüm 4'te tanımlanan `CalculateStreakUseCase` sorumluluğundadır — bu doküman yalnızca hangi verinin bu hesaplamayı beslediğini tanımlar.

---

## 7. Goal Model

### 7.1 Konum
`users/{userId}/goals/{goalId}`

### 7.2 Tasarım Kararı
Günlük, haftalık ve aylık hedefler **tek bir koleksiyonda**, bir `periodType` ayırt edici alanıyla tutulur (üç ayrı koleksiyon açılmaz). Gerekçe: Üç hedef türü de aynı alan setini paylaşır; ayrı koleksiyonlara bölmek şema tekrarı ve sorgu karmaşıklığı yaratır, tek koleksiyon + filtre alanı ise hem basitlik hem gelecekte "tüm hedefleri birlikte listeleme" ihtiyacını (İstatistikler ekranı) doğrudan destekler.

### 7.3 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `goalId` | string | Evet | Belge ID ile birebir aynı |
| `title` | string | Evet | Hedef başlığı (maks. 150 karakter) |
| `description` | string (nullable) | Hayır | Açıklama (maks. 500 karakter) |
| `periodType` | string (enum: `daily`, `weekly`, `monthly`) | Evet | Hedefin zaman ölçeği |
| `periodStartDate` | timestamp | Evet | İlgili dönemin başlangıcı (gün/hafta/ay başı — bkz. 13.1) |
| `periodEndDate` | timestamp | Evet | İlgili dönemin bitişi |
| `linkedTaskIds` | array\<string\> (nullable) | Hayır | Opsiyonel görev bağlantıları |
| `progressType` | string (enum: `manual`, `linkedTasks`) | Evet | İlerlemenin manuel mi yoksa bağlı görevlerin tamamlanma oranına göre mi hesaplanacağı |
| `manualProgress` | number (0–100, nullable) | Hayır | `progressType: manual` ise kullanıcı tarafından girilen yüzde |
| `status` | string (enum: `inProgress`, `achieved`, `missed`) | Evet | Dönem sonu durumu |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |
| `isDeleted` | boolean | Evet | Soft delete bayrağı |

---

## 8. Notes Model

### 8.1 Konum
`users/{userId}/notes/{noteId}`

### 8.2 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `noteId` | string | Evet | Belge ID ile birebir aynı |
| `title` | string | Evet | Not başlığı (maks. 150 karakter) |
| `content` | string | Hayır | Not içeriği (maks. 10.000 karakter — PRD Bölüm 6.11'de belirtilen basit metin kapsamı) |
| `color` | string (hex, nullable) | Hayır | Not kartı rengi |
| `projectId` | string (nullable) | Hayır | Opsiyonel proje bağlantısı |
| `taskId` | string (nullable) | Hayır | Opsiyonel görev bağlantısı |
| `tagIds` | array\<string\> (nullable) | Hayır | Etiket referansları |
| `isPinned` | boolean | Evet | Sabitlenmiş not (hızlı erişim için) |
| `createdAt` | timestamp | Evet | Oluşturulma zamanı |
| `updatedAt` | timestamp | Evet | Son güncelleme zamanı |
| `isDeleted` | boolean | Evet | Soft delete bayrağı |

---

## 9. Pomodoro Model

### 9.1 Konum
`users/{userId}/pomodoroSessions/{sessionId}`

### 9.2 Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `sessionId` | string | Evet | Belge ID ile birebir aynı |
| `taskId` | string (nullable) | Hayır | Opsiyonel görev bağlantısı |
| `type` | string (enum: `work`, `break`) | Evet | Oturum türü |
| `plannedDuration` | number (saniye) | Evet | Planlanan süre |
| `actualDuration` | number (saniye) | Evet | Gerçekleşen süre (erken bitirme durumları için) |
| `startedAt` | timestamp | Evet | Başlangıç zamanı |
| `completedAt` | timestamp (nullable) | Hayır | Tamamlanma zamanı (yarıda bırakılırsa null) |
| `isCompleted` | boolean | Evet | Tam süre tamamlanıp tamamlanmadığı |

> Her Pomodoro oturumu ayrı bir belge olarak tutulur; bu, hem PRD'deki "toplam pomodoro süresi/oturum sayısı" istatistiğini doğrudan destekler hem de tarih aralığı sorgularına (`startedAt` üzerinden) izin verir.

---

## 10. Statistics Model

### 10.1 Tasarım Kararı: Hesaplanmış Anlık Görüntü (Snapshot) Yaklaşımı
İstatistikler, **her ekran açılışında ham veriden yeniden hesaplanmaz** (bu, özellikle uzun kullanım geçmişinde maliyetli ve yavaş olur). Bunun yerine iki katmanlı bir strateji izlenir:

1. **Gerçek zamanlı/güncel dönem istatistikleri** (bugün, bu hafta): İlgili ham koleksiyonlardan (Tasks, HabitRecords, PomodoroSessions) doğrudan, dar tarih aralığı sorgularıyla hesaplanır — veri hacmi küçük olduğu için maliyet düşüktür.
2. **Geçmiş dönem istatistikleri** (geçmiş aylar/haftalar): `users/{userId}/statisticsSnapshots/{snapshotId}` koleksiyonunda **önceden hesaplanmış, değişmez (immutable) özet belgeler** olarak saklanır. Bir dönem kapandığında (örn. gün sonu), o günün özeti bir snapshot olarak yazılır ve bir daha yeniden hesaplanmaz.

### 10.2 StatisticsSnapshot Alan Tanımları

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `snapshotId` | string | Evet | Önerilen format: `yyyy-MM-dd` (günlük snapshot) |
| `periodType` | string (enum: `daily`) | Evet | MVP kapsamında yalnızca günlük snapshot tutulur; haftalık/aylık özetler istemci tarafında günlük snapshot'lar toplanarak türetilir |
| `tasksCompleted` | number | Evet | O gün tamamlanan görev sayısı |
| `tasksCreated` | number | Evet | O gün oluşturulan görev sayısı |
| `habitsCompletedCount` | number | Evet | O gün tamamlanan alışkanlık sayısı |
| `habitsTotalCount` | number | Evet | O gün için hedeflenen toplam alışkanlık sayısı |
| `pomodoroSessionsCompleted` | number | Evet | O gün tamamlanan pomodoro oturum sayısı |
| `pomodoroTotalMinutes` | number | Evet | O gün toplam odaklanma süresi (dakika) |
| `createdAt` | timestamp | Evet | Snapshot oluşturulma zamanı |

### 10.3 Neden Bu Yaklaşım?
- **Maliyet optimizasyonu:** İstatistik ekranı her açıldığında binlerce Task/HabitRecord belgesini taramak yerine, sınırlı sayıda snapshot belgesi okunur.
- **Tutarlılık:** Geçmiş bir günün istatistiği, o gün kapandıktan sonra değişmez — bu, kullanıcıya tutarlı bir geçmiş sunar.
- **Offline uyum:** Snapshot hesaplama mantığı istemci tarafında (Isar üzerinde biriken günlük veriden) çalıştığı için sunucu tarafı (Cloud Functions) gereksinimi doğmaz — mimari yalnızca istemci taraflı kalır.

---

## 11. Relationship Design (İlişki Tasarımı)

### 11.1 Genel İlişki Stratejisi
Firestore, ilişkisel bir veritabanı olmadığından, ilişkiler **ID referansı + path hiyerarşisi** kombinasyonuyla kurulur. Hiçbir ilişkide tam nesne kopyalanmaz (yalnızca ID); bu, Bölüm 1'de belirtilen "gereksiz veri tekrarından kaçının" ilkesinin doğrudan uygulamasıdır. İstisna: performans kritik, sık okunan **sayaç alanları** (örn. `taskCount`) bilinçli olarak denormalize edilir (bkz. 15.4) — bu, veri tekrarı değil, kontrollü bir performans optimizasyonudur.

### 11.2 İlişki Haritası

| İlişki | Tip | Uygulama Şekli |
|---|---|---|
| User → Projects | 1-e-Çok | Path hiyerarşisi: `users/{userId}/projects` |
| User → Tasks | 1-e-Çok | Path hiyerarşisi: `users/{userId}/tasks` |
| Project → Tasks | 1-e-Çok | Task belgesinde `projectId` referans alanı (path değil, çünkü bir görev projesiz de olabilir — opsiyonel ilişki path zorunluluğuyla modellenemez) |
| Task → SubTasks | 1-e-Çok | Path hiyerarşisi: `users/{userId}/tasks/{taskId}/subtasks` |
| Task → Category | Çok-e-1 | Task belgesinde `categoryId` referans alanı |
| Task → Tags | Çok-e-Çok | Task belgesinde `tagIds` array alanı |
| User → Habits | 1-e-Çok | Path hiyerarşisi: `users/{userId}/habits` |
| Habit → HabitRecords | 1-e-Çok | Path hiyerarşisi: `users/{userId}/habits/{habitId}/habitRecords` |
| User → Goals | 1-e-Çok | Path hiyerarşisi: `users/{userId}/goals` |
| Goal → Tasks | Çok-e-Çok (opsiyonel) | Goal belgesinde `linkedTaskIds` array alanı |
| User → Notes | 1-e-Çok | Path hiyerarşisi: `users/{userId}/notes` |
| Note → Project / Task | Çok-e-1 (opsiyonel) | Note belgesinde `projectId` / `taskId` referans alanları |

### 11.3 Referans Bütünlüğü Yaklaşımı
Firestore, ilişkisel veritabanlarındaki gibi otomatik "foreign key" bütünlüğü sağlamaz. Bu nedenle:
- Bir Proje silindiğinde, ona bağlı Task'ların `projectId` alanı **null'a çekilir** (görev silinmez, yalnızca ilişkisi koparılır) — bu mantık istemci tarafında, Repository katmanında (ARCHITECTURE.md Bölüm 6) yürütülür.
- Bir Category/Tag silindiğinde, ona referans veren belgelerdeki ilgili alan/array elemanı temizlenir.
- Bu "referans temizleme" işlemleri, soft-delete stratejisiyle birlikte çalışır (bkz. Bölüm 13.4) — kullanıcı geri alma penceresi içindeyken referanslar korunur.

---

## 12. Offline Database (Isar Stratejisi ve Senkronizasyon)

### 12.1 Isar'ın Rolü
`ARCHITECTURE.md`'de tanımlanan offline-first prensibine uygun olarak, **Isar birincil okuma/yazma katmanıdır** — uygulama arayüzü hiçbir zaman doğrudan Firestore'u beklemez. Isar, Firestore'daki her koleksiyonun birebir yerel karşılığını tutar; şema olarak Firestore alan yapısıyla büyük ölçüde örtüşür, ek olarak yalnızca yerelde anlamlı olan senkronizasyon meta-alanları taşır.

### 12.2 Isar'da Tutulacak Ek Meta-Alanlar
Firestore modelinde bulunmayan, yalnızca Isar tarafında var olan alanlar:

| Alan | Tip | Açıklama |
|---|---|---|
| `syncStatus` | enum (`synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`, `error`) | Kaydın senkronizasyon durumu |
| `lastSyncedAt` | timestamp (nullable) | Son başarılı senkronizasyon zamanı |
| `localUpdatedAt` | timestamp | Yerelde son değişiklik zamanı (çakışma çözümü için `updatedAt` ile karşılaştırılır) |

### 12.3 Isar'da Tutulacak Veri Kapsamı
Tüm modüller (Users/Settings, Projects, Tasks, SubTasks, Categories, Tags, CalendarEvents, Goals, Habits, HabitRecords, PomodoroSessions, Notes) **tam kapsamlı olarak** Isar'da tutulur — kısmi/seçici önbellekleme uygulanmaz, çünkü uygulama kişisel kullanım ölçeğinde çalışır ve toplam veri hacmi (tek kullanıcı için) Isar'ın rahatlıkla yönetebileceği boyuttadır. İstisna: `statisticsSnapshots` gibi yalnızca geçmişe dönük, değişmez özet veriler, Isar'da yalnızca **son N dönem** (örn. son 90 gün) için tutulur; daha eskisi istenirse Firestore'dan talep üzerine (on-demand) çekilir — bu, yerel depolamanın sınırsız büyümesini önler.

### 12.4 Senkronizasyon Mantığı (Kavramsal Akış)
`ARCHITECTURE.md` Bölüm 8'de tanımlanan offline-first akışın veri modeli seviyesindeki karşılığı:

1. Kullanıcı bir eylem yapar (örn. görev oluşturur) → Isar'a `syncStatus: pendingCreate` ile hemen yazılır.
2. Bağlantı algılandığında, `pendingCreate`/`pendingUpdate`/`pendingDelete` durumundaki tüm kayıtlar sıraya alınır ve Firestore'a gönderilir.
3. Firestore yazması başarılı olursa, ilgili Isar kaydı `syncStatus: synced` ve `lastSyncedAt: now()` ile güncellenir.
4. Firestore'dan gelen (başka bir cihazdan yapılmış) değişiklikler bir dinleyici ile alınır; gelen belgenin `updatedAt` değeri, yerel `localUpdatedAt` değerinden yeniyse Isar kaydı güncellenir (Last-Write-Wins — ARCHITECTURE.md Bölüm 8.4 ile birebir uyumlu).
5. Silme işlemleri her zaman **soft delete** olarak yayılır (bkz. 13.4); bu, bir cihazda silinen kaydın diğer cihazda senkronizasyon sırasında "bulunamadı" hatası yerine tutarlı şekilde işlenmesini sağlar.

### 12.5 Neden Isar (Hive Yerine/İle Birlikte Değerlendirme Notu)
`ARCHITECTURE.md` Bölüm 2'de yerel depolama olarak Hive belirtilmiştir; bu doküman ise proje talimatı gereği Isar'ı esas alır. İki çözüm de NoSQL, şemasız/hafif-şemalı, saf Dart uyumlu yapıdadır ve bu dokümanda tanımlanan **veri modeli ve senkronizasyon mantığı her ikisiyle de birebir uygulanabilir** — çünkü tasarım, belirli bir paketin API'sine değil, kavramsal "yerel koleksiyon + syncStatus meta-alanı" desenine dayanır. Isar'ın ek avantajı, yerleşik indeksleme ve sorgu API'siyle tarih aralığı/filtreleme sorgularında (örn. HabitRecords, PomodoroSessions) daha zengin sorgu yeteneği sunmasıdır. Nihai paket seçimi teknik implementasyon aşamasında netleştirilecektir; bu doküman veri modelini paket bağımsız tanımlar.

---

## 13. Timestamp ve ID Yapısı

### 13.1 Belge ID Sistemi
- Firestore'un **otomatik oluşturduğu belge ID'leri** (auto-ID) standart olarak kullanılır — bu, yazma dağılımını (write distribution) optimize eder ve ID çakışma riskini ortadan kaldırır.
- İstisna: `HabitRecord` ve `StatisticsSnapshot` gibi **günlük periyodiklik taşıyan** koleksiyonlarda, belge ID'si anlamlı bir formatta (`yyyy-MM-dd`) elle atanır. Gerekçe: bu, "bugünün kaydı var mı?" sorgusunu bir `get()` çağrısına indirger (sorgu yerine doğrudan belge okuma — maliyet ve performans avantajı) ve aynı gün için yanlışlıkla iki kayıt oluşmasını doğal olarak engeller (idempotency).
- `users/{userId}` belgesinin ID'si her zaman Firebase Authentication `uid` değeridir (bkz. Bölüm 2.1).

### 13.2 Oluşturulma Tarihi (`createdAt`)
- Her koleksiyonda zorunlu alandır; belge oluşturulduğu anda, istemci saatine değil **sunucu zaman damgasına** göre atanır (Firestore server timestamp mekanizması) — bu, farklı cihaz saat ayarlarından kaynaklanabilecek tutarsızlıkları önler.
- `createdAt` bir belgenin ömrü boyunca **asla değiştirilmez**.

### 13.3 Güncelleme Tarihi (`updatedAt`)
- Her yazma işleminde (create hariç, update'lerde) sunucu zaman damgasıyla güncellenir.
- Bu alan, Bölüm 12.4'te açıklanan çakışma çözümleme mantığının **birincil karar kriteridir** — bu nedenle her koleksiyonda tutarlı biçimde bulunması zorunludur.

### 13.4 Silinme Mantığı: Soft Delete
Tüm kullanıcı içerik koleksiyonlarında (Projects, Tasks, SubTasks, Habits, Goals, Notes) **soft delete** stratejisi uygulanır:
- Silme işleminde belge fiziksel olarak kaldırılmaz; `isDeleted: true` ve `deletedAt: <timestamp>` alanları set edilir.
- Sorgular varsayılan olarak `isDeleted == false` filtresiyle çalışır.
- Soft-delete edilmiş kayıtlar, tanımlı bir bekleme süresi sonunda (örn. 30 gün — kesin değer ürün kararına bağlıdır) bir bakım işlemiyle fiziksel olarak temizlenebilir; bu, PRD Bölüm 6.3'teki "arşivleme geri getirilebilir" ve UI_GUIDELINES Bölüm 13'teki "geri alma her zaman mümkün olmalı" ilkelerini veri seviyesinde destekler.
- İstisna: `HabitRecord` ve `PomodoroSessions` gibi salt geçmiş-kaydı niteliğindeki koleksiyonlarda soft delete uygulanmaz — bu kayıtlar doğası gereği değiştirilmez geçmiş verilerdir; silme senaryosu yalnızca üst varlık (Habit) silindiğinde toplu olarak ele alınır.

---

## 14. Data Validation

### 14.1 Doğrulama Katmanı Sorumluluğu
Veri doğrulama, `ARCHITECTURE.md` Bölüm 3.1'de tanımlanan Presentation katmanının **form-level validation** sorumluluğu ile, Domain katmanının **iş kuralı doğrulaması** sorumluluğu arasında paylaşılır. Bu doküman, hangi alanların hangi kısıtlara tabi olduğunu (kuralın kendisini) tanımlar; kuralın nerede/nasıl kod olarak uygulanacağı ARCHITECTURE.md kapsamındadır.

### 14.2 Zorunlu Alan Kuralları
Her modelde "Zorunlu" olarak işaretlenen alanlar (Bölüm 2–10'daki tablolar), belge oluşturma anında boş/null olamaz. Boş bırakılamayan alanlar için, kullanıcı arayüzünde ilgili form gönderilmeden önce engellenir (UI_GUIDELINES Bölüm 7.12 — TextField hata durumu).

### 14.3 Maksimum Uzunluk Standartları

| Alan Tipi | Maksimum Uzunluk | Uygulandığı Modeller |
|---|---|---|
| Başlık (title/name) | 100–200 karakter (modele göre değişir, ilgili tabloda belirtilmiştir) | Project, Task, SubTask, Habit, Goal, Note |
| Açıklama (description) | 500–1000 karakter | Project, Task, Goal |
| Not içeriği (content) | 10.000 karakter | Note |
| Etiket/Kategori adı | 50 karakter | Category, Tag |

### 14.4 Boş Alan Politikası
- Opsiyonel alanlar (`nullable` işaretli), yokluğunda `null` olarak tutulur — boş string (`""`) ile `null` birbirinin yerine kullanılmaz (bu ayrım, sorgu filtrelerinde "alan hiç girilmemiş" ile "alan boş girilmiş" durumlarını netleştirir).
- Array tipi alanlar (`tagIds`, `linkedTaskIds`), veri yoksa boş array (`[]`) olarak tutulur, `null` olarak tutulmaz — bu, istemci tarafı iterasyon mantığının her yerde `null` kontrolü yapma zorunluluğunu ortadan kaldırır.

### 14.5 Enum Alan Politikası
Tüm enum tipi alanlar (`priority`, `status`, `periodType` vb.), bu dokümanda tanımlanan sabit değer kümesiyle sınırlıdır. Yeni bir değer eklenmesi, bu dokümanın güncellenmesini ve ilgili tüm istemci/güvenlik kuralı tanımlarının gözden geçirilmesini gerektirir.

---

## 15. Firestore Optimization

### 15.1 Index Kullanımı
- Firestore, tek alanlı sorgularda otomatik index oluşturur; bu proje kapsamında **çok alanlı (composite) index** gerektiren sorgular şunlardır ve önceden tanımlanmalıdır:
  - Tasks: `status` + `dueDate` (bugünün bekleyen görevlerini sıralı listelemek için),
  - Tasks: `projectId` + `status` (proje detay ekranındaki görev filtrelemesi için),
  - HabitRecords: `date` aralığı sorguları (varsayılan olarak tek alan, composite gerekmez ama aralık + sıralama birlikte kullanılırsa index gerekir),
  - PomodoroSessions: `startedAt` aralığı + `type` (istatistik ekranı için).
- Composite index'lerin kesin tanımı, gerçek sorgu implementasyonu sırasında Firestore konsolunun otomatik önerileriyle netleştirilecektir (bu doküman kapsamı, hangi sorgu desenlerinin index gerektireceğini işaretlemekle sınırlıdır).

### 15.2 Query Optimizasyonu
- Sorgular her zaman **alt koleksiyon seviyesinde, dar kapsamlı** çalışır (örn. `users/{userId}/tasks` — asla koleksiyon grubu sorgusuyla tüm kullanıcıların task'ları taranmaz; buna zaten ihtiyaç yoktur, bkz. 1.2).
- Liste ekranlarında, sunucu tarafında zaten filtrelenmiş minimum veri seti çekilir (örn. yalnızca `isDeleted == false` ve ilgili tarih aralığı) — istemci tarafında gereksiz post-filtering'den kaçınılır.
- Denormalize edilmiş sayaç alanları (`taskCount`, `completedSubtaskCount` vb.), listeleme ekranlarının **alt koleksiyonu ayrıca sorgulamadan** ilerleme göstermesini sağlar — bu, en önemli okuma-maliyeti optimizasyonudur (bkz. 15.4).

### 15.3 Pagination
- Tüm potansiyel olarak uzun listeler (Tasks geçmişi, Notes, PomodoroSessions, HabitRecords) **cursor-based pagination** ile çekilir (`startAfter` + `limit` deseni) — `ARCHITECTURE.md` Bölüm 12.4 ile birebir uyumlu.
- Sayfa başı belge sayısı, ekran tipine göre standardize edilir: liste ekranlarında 20, istatistik/geçmiş görünümlerinde 30.

### 15.4 Denormalizasyon ile Gereksiz Okuma Azaltma
Aşağıdaki alanlar, **bilinçli olarak** üst belgede denormalize edilmiştir; bu, Firestore'un "okuma başına ücretlendirme" maliyet modelinde kritik bir optimizasyondur:

| Denormalize Alan | Konum | Önlediği Maliyet |
|---|---|---|
| `taskCount`, `completedTaskCount` | Project | Proje listesi ekranında her proje için ayrı Tasks sorgusu yapılmasını önler |
| `subtaskCount`, `completedSubtaskCount` | Task | Görev listesi ekranında her görev için ayrı SubTasks sorgusu yapılmasını önler |
| `currentStreak`, `longestStreak` | Habit | Alışkanlık listesi ekranında her alışkanlık için tüm HabitRecords geçmişinin taranmasını önler |

Bu sayaçlar, ilgili alt koleksiyonda bir değişiklik olduğunda (istemci tarafında, Repository katmanında) atomik olarak güncellenir. Bu yaklaşım, "her zaman güncel ama pahalı" ile "ucuz ama hesaplanmış" arasında bilinçli bir denge kurar ve PRD Bölüm 2.4'teki "Firebase senkronizasyonu" gereksinimiyle çelişmez çünkü senkronizasyon her zaman kaynak veriyle (alt koleksiyon) birlikte, tutarlı şekilde yürütülür.

### 15.5 Cache Stratejisi
- Isar (Bölüm 12), birincil önbellek katmanı olduğu için Firestore'un kendi yerleşik disk önbelleği (offline persistence) **ikincil bir güvenlik ağı** olarak bırakılır, birincil offline stratejinin yerini almaz.
- Nadiren değişen sözlük verileri (Categories, Tags), uygulama açılışında bir kez çekilip Isar'da tutulur; her ekran geçişinde yeniden sorgulanmaz.

---

## 16. Security Düşüncesi (Firestore Güvenlik Mantığı)

> Bu bölüm, `ARCHITECTURE.md` Bölüm 13'te tanımlanan güvenlik mimarisinin **veri modeli seviyesindeki karşılığını** açıklar. Gerçek Firestore Rules yazımı bu doküman kapsamında değildir.

### 16.1 Temel Prensip
**Bir kullanıcı, yalnızca kendi `users/{userId}` alt ağacındaki belgelere erişebilir.** Bu, Bölüm 1.2'de açıklanan kullanıcı alt koleksiyonu modelinin doğrudan güvenlik faydasıdır: erişim kontrolü, her belge için ayrı ayrı `userId` alanı kontrol etmek yerine, **tek bir path segmenti karşılaştırmasına** (`request.auth.uid == path'teki userId`) indirgenir — bu, hem güvenlik kuralı yazımını basitleştirir hem de "unutulmuş kontrol" riskini ortadan kaldırır.

### 16.2 Veri Modelinin Güvenliğe Katkısı
- Hiçbir koleksiyon kök seviyede (`users` dışında) tanımlanmamıştır — bu, "kullanıcı ID'sini unutup düz koleksiyonu sorgulama" gibi bir mimari hatanın önünü tasarım seviyesinde keser.
- `userId` alanı belge içeriğinde ayrıca tutulmaz (Bölüm 3.2'de belirtildiği gibi) çünkü path zaten bu bilgiyi taşır — bu, "belge içindeki `userId` alanı ile path'teki `userId` birbirinden farklı olabilir mi" gibi bir tutarsızlık riskini de ortadan kaldırır.
- Kimlik doğrulama olmadan (`request.auth == null`) hiçbir koleksiyona erişim mümkün olmamalıdır — bu, tüm `users/{userId}/**` alt ağacı için geçerli, tek bir üst seviye kural olarak tanımlanacaktır (implementasyon ayrı görev).

### 16.3 Alan Seviyesi Güvenlik Düşünceleri
- `createdAt` gibi sistem tarafından atanan alanların istemci tarafından keyfi bir değere set edilmesi engellenmelidir (yalnızca sunucu zaman damgası kabul edilir) — bu, Bölüm 13.2 ile birlikte değerlendirilecek bir kural gereksinimidir.
- `settings` içindeki hassas olmayan tercihler (tema, bildirim açık/kapalı) dışında, PIN/biyometri doğrulama bilgisi Firestore'a hiçbir biçimde yazılmaz (Bölüm 2.3) — bu, veri modelinin en kritik güvenlik sınırıdır.

### 16.4 Kişisel Kullanım Kapsamının Güvenliğe Etkisi
Uygulamanın PRD'de tanımlanan "yalnızca bireysel kullanım, takım çalışması yok" ilkesi, güvenlik modelini önemli ölçüde sadeleştirir: hiçbir belgede "paylaşılan kullanıcılar listesi" veya "rol/izin" alanı bulunmaz; her belgenin erişim yetkilisi her zaman tektir (belgeyi barındıran path'in sahibi). Bu, gelecekte bir işbirliği özelliği eklenmediği sürece (ki PRD bunu kapsam dışı bırakmıştır) güvenlik modelinin en basit, en az hata yüzeyine sahip haliyle kalmasını sağlar.

---

## 17. Sonraki Adımlar

Bu veritabanı mimarisi dokümanı, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Gerçek Firestore Rules yazımı (bu doküman kapsamında yapılmamıştır),
2. Isar şema implementasyonu ve gerçek sınıf tanımları (kod aşaması),
3. Composite index'lerin Firestore konsolunda tanımlanması,
4. Migration/seed veri stratejisinin ayrı bir teknik görev olarak planlanması.

**Bu doküman kapsamında herhangi bir kod, Firebase kurulumu veya Firestore Rules üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
