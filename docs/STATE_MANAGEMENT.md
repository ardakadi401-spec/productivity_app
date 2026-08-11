# STATE_MANAGEMENT.md
## Kişisel Üretkenlik Uygulaması — State Management Mimarisi Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Flutter Architect / Riverpod State Management Uzmanı / Mobile Application Architect
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`, `DATABASE.md`, `FOLDER_STRUCTURE.md`
**Doküman Durumu:** Teknik Referans — Tüm state management geliştirmesi bu dokümana uymalıdır

> Bu doküman yalnızca state management mimarisini tanımlar. Kod, widget, Provider implementasyonu veya Firebase kurulum adımı içermez. Aşağıda geçen sınıf/provider isimleri (`taskListControllerProvider` gibi) yalnızca `FOLDER_STRUCTURE.md` Bölüm 12.3'te standardize edilen isimlendirme kuralına örnek teşkil eder; gerçek implementasyon bir sonraki aşamadadır.

---

## 0. Kapsam ve Sınırlar

- Bu doküman, `ARCHITECTURE.md` Bölüm 5 (Riverpod Stratejisi) ve Bölüm 6 (Repository Pattern)'da alınmış kararları **değiştirmez**, yalnızca bunları feature seviyesinde detaylandırır.
- `ARCHITECTURE.md` Bölüm 2'de yerel depolama olarak Hive belirtilmiş, `DATABASE.md` Bölüm 12.5'te ise proje talimatı gereği Isar esas alınmış ve nihai paket seçiminin implementasyon aşamasında netleşeceği, veri modelinin paket bağımsız olduğu belirtilmiştir. Bu doküman da aynı netleştirmeye uyar: state akışı **"birincil yerel koleksiyon (Isar) + syncStatus meta-alanı"** kavramına dayanır; anlatılan state mimarisi Hive ile de birebir uygulanabilir.
- PRD Bölüm 2.4 ve Bölüm 7'de tanımlanan ilkeler (AI yok, premium yok, reklam yok, takım çalışması yok) bu dokümanda da geçerlidir — hiçbir state akışı bu ilkelerle çelişmez.
- Bu doküman, `ARCHITECTURE.md` Bölüm 4'te tanımlanan **14 feature**'ın state yönetimini kapsar; yeni feature tanımlanmaz.

---

## 1. Riverpod Architecture

### 1.1 Riverpod Neden Kullanılacak?

`ARCHITECTURE.md` Bölüm 2'de Riverpod, state management ve dependency injection aracı olarak seçilmiştir. Bu seçimin gerekçeleri:

| Gerekçe | Açıklama |
|---|---|
| Compile-time güvenlik | Provider bağımlılıkları derleme zamanında doğrulanır; `BuildContext`'e bağımlı olmayan erişim (`ref`) runtime hatalarını azaltır. |
| Test edilebilirlik | Her provider, `ProviderContainer` ile widget ağacından bağımsız olarak override edilip test edilebilir — `ARCHITECTURE.md` Bölüm 3.2'deki "Domain katmanı framework bağımsız test edilir" ilkesiyle doğrudan uyumludur. |
| Clean Architecture ile doğal uyum | Riverpod'un katmanlı provider zinciri (Bölüm 1.3), `ARCHITECTURE.md` Bölüm 1.1'deki bağımlılık kuralının (Presentation → Domain, Data → Domain) birebir yansımasıdır. |
| AsyncValue soyutlaması | Riverpod'un `AsyncValue` (data/loading/error) yapısı, Bölüm 7'deki (Async State) dört durumlu standardı native olarak destekler. |
| Global state olmadan paylaşım | `Provider`/`Notifier` mekanizması, singleton/servis-locator gibi anti-pattern'lere ihtiyaç duymadan feature'lar arası (yalnızca Domain sözleşmeleri üzerinden — `ARCHITECTURE.md` Bölüm 4.1) veri paylaşımını mümkün kılar. |
| Yaşam döngüsü kontrolü | `autoDispose`, `family` gibi modifier'lar, Bölüm 9'daki performans kurallarının temelini oluşturur. |

### 1.2 Provider Tipleri — Ne Zaman Kullanılır?

`ARCHITECTURE.md` Bölüm 5'te tanımlanan karar kriterleri, bu bölümde her provider tipi için ayrı ayrı gerekçelendirilir:

#### 1.2.1 `Provider`
- **Amacı:** Değişmeyen, tek sefer oluşturulan bağımlılıkların (repository örneği, usecase örneği, service sarmalayıcısı) sağlanması.
- **Karakteristik:** Senkron, asenkron veri taşımaz, yalnızca "bağımlılık kablosu" görevi görür.
- **Kullanım alanı:** Üç seviyeli provider zincirinin (Bölüm 2) Data ve Domain seviyeleri — örn. repository ve usecase örneklerinin sağlanması.
- **Ne zaman kullanılmaz:** Kullanıcı etkileşimiyle değişmesi gereken herhangi bir veri için kullanılmaz.

#### 1.2.2 `FutureProvider`
- **Amacı:** Tek seferlik, nadiren yeniden hesaplanan asenkron veri getirme.
- **Karakteristik:** Otomatik `AsyncValue` sarmalaması sağlar; manuel loading/error state modellemesi gerektirmez.
- **Kullanım alanı:** Kullanıcı profil bilgisinin ilk yüklenmesi (Profile feature), uygulama ilk açılış konfigürasyonu (tema tercihi, kilit ayarı okunması — Settings feature), Statistics feature'ında dönemsel bir snapshot'ın tek seferlik getirilmesi.
- **Ne zaman kullanılmaz:** Kullanıcı ekle/sil/güncelle gibi eylemlerle veriyi değiştirebiliyorsa (bu durumda `AsyncNotifierProvider` tercih edilir — Bölüm 1.2.5).

#### 1.2.3 `StreamProvider`
- **Amacı:** Sürekli değişen, canlı veri kaynaklarının dinlenmesi.
- **Karakteristik:** Kaynak (Isar sorgu dinleyicisi, Firestore snapshot dinleyicisi, Firebase Auth durum dinleyicisi) her değiştiğinde otomatik olarak yeni bir `AsyncValue` yayınlar.
- **Kullanım alanı:** Authentication oturum durumu, senkronizasyon durumu göstergesi (`ARCHITECTURE.md` Bölüm 8.5), Isar kutu/koleksiyon değişiklik dinleyicileri (görev listesi, alışkanlık listesi gibi canlı listeler).
- **Ne zaman kullanılmaz:** Tek seferlik, statik veri için kullanılmaz (gereksiz dinleyici maliyeti yaratır).

#### 1.2.4 `StateProvider`
- **Amacı:** Tek bir ilkel (primitive) veya basit değeri tutan, karmaşık iş mantığı içermeyen, çok basit senkron durumlar.
- **Karakteristik:** Bu projede **sınırlı ve bilinçli** kullanılır; iş kuralı taşımaz, yalnızca UI'a özgü geçici bayrak/seçim durumlarını tutar.
- **Kullanım alanı:** Bir filtre panelinde seçili sekme/sıralama kriteri (örn. Görevler ekranında "aktif/tamamlanmış" filtre seçimi), bir form içinde seçili tarih/öncelik gibi henüz kaydedilmemiş geçici UI seçimleri.
- **Ne zaman kullanılmaz:** Birden fazla alanı olan, doğrulama gerektiren veya iş kuralı içeren hiçbir durum için kullanılmaz — bu durumlarda `NotifierProvider` tercih edilir.

#### 1.2.5 `NotifierProvider` / `AsyncNotifierProvider`
- **Amacı:** Karmaşık, çok adımlı kullanıcı etkileşimiyle değişen durumların yönetimi.
- **`NotifierProvider`:** Başlangıç durumu senkron olarak kurulabiliyorsa kullanılır (örn. Pomodoro zamanlayıcı durumu — başlangıçta sabit varsayılan süreyle kurulur, sonrasında start/pause/reset ile senkron olarak değişir).
- **`AsyncNotifierProvider`:** Başlangıç durumu asenkron veri yüklemesi gerektiriyorsa ve sonrasında kullanıcı etkileşimiyle değişebiliyorsa kullanılır (örn. görev listesi — önce Isar/Repository'den asenkron yüklenir, sonra ekle/sil/güncelle ile değişir).
- **Kullanım alanı:** Bölüm 2'de her feature için ayrı ayrı detaylandırılmıştır.

### 1.3 Provider Tipi Seçim Tablosu (Özet)

| Veri Karakteri | Provider Tipi |
|---|---|
| Değişmez bağımlılık (repository/usecase örneği) | `Provider` |
| Tek seferlik, nadiren tekrar hesaplanan asenkron veri | `FutureProvider` |
| Sürekli akan/canlı veri kaynağı | `StreamProvider` |
| Basit, iş kuralı içermeyen UI seçim/bayrak durumu | `StateProvider` |
| Senkron başlayan, çok adımlı kullanıcı etkileşimi | `NotifierProvider` |
| Asenkron başlayan, çok adımlı kullanıcı etkileşimi | `AsyncNotifierProvider` |

---

## 2. Provider Strategy — Üç Seviyeli Zincir

`ARCHITECTURE.md` Bölüm 5.2'de tanımlanan üç seviyeli provider zinciri, bu dokümanın tüm feature anlatımlarının temel iskeletidir. Her feature'da bu zincir birebir tekrarlanır:

```
[Data Seviyesi]           [Domain Seviyesi]              [Presentation Seviyesi]
xDatasourceProvider   →   xRepositoryProvider (interface  →   xUseCaseProvider   →   xControllerProvider
(local + remote)           implementasyonunu sağlar)                                  (Notifier/AsyncNotifier)
                                                                                              │
                                                                                              ▼
                                                                                        UI, yalnızca
                                                                                        xControllerProvider'ı
                                                                                        (veya onun türetilmiş
                                                                                        state provider'larını)
                                                                                        dinler
```

### 2.1 Katman Kuralları (FOLDER_STRUCTURE.md Bölüm 6.4 ile uyumlu)
1. **Data seviyesi provider'ları** (`xLocalDatasourceProvider`, `xRemoteDatasourceProvider`, `xRepositoryProvider`) yalnızca somut implementasyonları sağlar; Presentation katmanı bunlara **asla doğrudan** erişmez.
2. **Domain seviyesi provider'ları** (`xUseCaseProvider`) ilgili `xRepositoryProvider`'a bağımlıdır; her UseCase kendi provider'ına sahiptir (Bölüm 6.3, `ARCHITECTURE.md` — Single Responsibility).
3. **Presentation seviyesi provider'ları** (`xControllerProvider`, türetilmiş `xStateProvider`'lar) yalnızca Domain seviyesindeki UseCase provider'larına bağımlıdır.
4. Provider tanımlarının dosya konumu `FOLDER_STRUCTURE.md` Bölüm 6.3'teki gibidir: UseCase/Repository provider tanımları (yalnızca "wiring" sorumluluğu) `presentation/providers/` altında toplanır; Notifier/AsyncNotifier sınıflarının kendisi `presentation/controllers/` altında yaşar.

### 2.2 Cross-Feature Erişim (ARCHITECTURE.md Bölüm 4.1 ile uyumlu)
Bir feature'ın controller'ı, başka bir feature'ın verisine ihtiyaç duyduğunda yalnızca o feature'ın **dışa açık UseCase provider'ını** `ref.watch`/`ref.read` ile çağırır. Örnek: Dashboard'un `dashboardControllerProvider`'ı, Tasks feature'ının `getTodayTasksUseCaseProvider`'ını okur; Tasks feature'ının `taskLocalDatasourceProvider`'ına asla erişmez.

---

## 3. Feature Bazlı State Yapısı

`ARCHITECTURE.md` Bölüm 4'te tanımlanan 14 feature için, her biri aynı üç seviyeli zinciri (Bölüm 2) uygular. Aşağıdaki tablo, her feature'ın **State**, **Controller**, **Provider (baskın tip)** ve **Repository Bağlantısı**nı özetler; ardından PRD'de özellikle vurgulanan Authentication, Task ve Project akışları ayrı bölümlerde derinleştirilir (Bölüm 4, 5, 6).

| # | Feature | State İçeriği (kavramsal) | Controller Sorumluluğu | Baskın Provider Tipi | Repository Bağlantısı |
|---|---|---|---|---|---|
| 1 | Authentication | Oturum durumu (giriş yapılmamış/yapılmış/kontrol ediliyor), aktif kullanıcı kimliği | Giriş/kayıt/çıkış akışlarını UseCase'ler üzerinden orkestre eder | `StreamProvider` (oturum dinleme) + `AsyncNotifierProvider` (giriş/kayıt formu) | `AuthRepository` |
| 2 | Dashboard | Günün görevleri, günlük hedef özeti, alışkanlık özeti (salt okunur agregasyon) | Tasks/Habits/Goals UseCase'lerini çağırıp tek bir ekran state'inde birleştirir | `AsyncNotifierProvider` | Kendi repository'si yok; yalnızca diğer feature'ların UseCase'lerini orkestre eder (`ARCHITECTURE.md` Bölüm 4 satır 2) |
| 3 | Projects | Proje listesi, seçili proje detayı, proje formu durumu | Proje CRUD akışlarını yönetir, Tasks feature'ından proje altı görev sayısını okur | `AsyncNotifierProvider` (liste) + `NotifierProvider` (form) | `ProjectRepository` |
| 4 | Tasks | Görev listesi (filtreli), görev detayı, alt görev listesi, görev formu durumu | Görev/alt görev CRUD ve tamamlama mantığını yönetir (bkz. Bölüm 5) | `AsyncNotifierProvider` | `TaskRepository` |
| 5 | Calendar | Seçili tarih, aylık/günlük görünüm verisi (Tasks + Goals salt okunur agregasyonu) | Seçili tarih değiştiğinde ilgili görev/hedef verisini yeniden sorgular | `AsyncNotifierProvider` (`family` — tarih parametreli) | Kendi repository'si yok; Tasks/Goals UseCase'lerini okur |
| 6 | Habits | Alışkanlık listesi, günlük check-in durumu, streak verisi | Check-in eylemini işler, streak hesaplama UseCase'ini tetikler | `AsyncNotifierProvider` | `HabitRepository` |
| 7 | Goals | Zaman aralığına göre (günlük/haftalık/aylık) hedef listesi, ilerleme yüzdesi | Hedef CRUD'u yönetir, bağlı görev tamamlanma oranını izler | `AsyncNotifierProvider` (`family` — zaman aralığı parametreli) | `GoalRepository` |
| 8 | Notes | Not listesi, seçili not detayı, not formu durumu | Not CRUD'u yönetir, proje/görev bağlama seçimini tutar | `AsyncNotifierProvider` | `NoteRepository` |
| 9 | Pomodoro | Zamanlayıcı durumu (idle/running/paused/break), bağlı görev seçimi, oturum geçmişi | Zamanlayıcı tik mantığını ve oturum kayıt UseCase'ini yönetir | `NotifierProvider` (zamanlayıcı) + `AsyncNotifierProvider` (oturum geçmişi) | `PomodoroRepository` |
| 10 | Statistics | Dönemsel grafik verileri (görev/alışkanlık/pomodoro/hedef agregasyonu) | Statistics UseCase'lerini çağırıp görselleştirme için normalize eder | `FutureProvider` (`family` — dönem parametreli) | Kendi repository'si yok; ilgili feature'ların UseCase'lerini okur |
| 11 | Search | Arama sorgusu, birleşik sonuç listesi, son aramalar geçmişi | Sorgu değiştikçe debounce ile ilgili UseCase'leri tetikler | `AsyncNotifierProvider` | Kendi repository'si yok; Tasks/Projects/Notes/Habits'in arama UseCase'lerini okur |
| 12 | Settings | Tema tercihi, kilit (PIN/biyometri) durumu, bildirim tercihleri | Ayar değişikliklerini ilgili UseCase'lere iletir | `NotifierProvider` (tema, kilit tercihi — kalıcı) | `SettingsRepository` |
| 13 | Profile | Kullanıcı profil bilgisi, hesap yönetimi durumu | Profil güncelleme/hesap silme akışlarını yönetir | `FutureProvider` (ilk yükleme) + `AsyncNotifierProvider` (güncelleme) | `AuthRepository` (Profile, Authentication'a bağımlıdır — `ARCHITECTURE.md` Bölüm 4) |
| 14 | Notification | Planlanmış bildirim kayıtları (dahili durum) | Diğer feature'lardan gelen planlama/iptal isteklerini yürütür | `Provider` (servis sarmalayıcı) + `NotifierProvider` (planlama durumu) | `NotificationRepository` |

### 3.1 Kalıcı vs. Geçici State Ayrımı
`ARCHITECTURE.md` Bölüm 5.3 ile uyumlu olarak:
- **Kalıcı (autoDispose'suz) state'ler:** Authentication oturum durumu, tema tercihi, kilit durumu, senkronizasyon durumu — uygulama kök seviyesinde, tüm oturum boyunca yaşar.
- **Geçici (autoDispose'lu) state'ler:** Ekran/form bazlı state'ler (görev formu, proje formu, arama sorgusu, seçili filtre) — ilgili ekrandan çıkıldığında bellekten temizlenir.

---

## 4. Authentication State

PRD Bölüm 5.1 (Onboarding & Kimlik Doğrulama Akışı) ile birebir uyumlu olacak şekilde:

### 4.1 State Modeli (Kavramsal)
Authentication state'i dört ayrık durumdan oluşur:
- **Kontrol Ediliyor (`checking`):** Uygulama açılışında oturum bilgisinin okunduğu geçiş durumu (Splash Screen bu duruma bağlıdır).
- **Giriş Yapılmamış (`unauthenticated`):** Kullanıcı Login ekranına yönlendirilir.
- **Giriş Yapılmış (`authenticated`):** Kullanıcı Dashboard'a yönlendirilir; aktif kullanıcı kimliği tüm feature'ların veri sorgularında (`userId` filtresi — `ARCHITECTURE.md` Bölüm 13.2) kullanılabilir hale gelir.
- **Hata (`authError`):** Giriş/kayıt sırasında oluşan hata; Bölüm 7'deki Failure kategorileriyle eşlenir.

### 4.2 Provider Yapısı
- **Oturum dinleme:** `StreamProvider` — Firebase Authentication SDK'sının oturum değişikliklerini (`ARCHITECTURE.md` Bölüm 9.2'deki Auth Guard'ın doğrudan dayandığı kaynak) dinler. Bu provider, `autoDispose` kullanılmadan kök seviyede tutulur.
- **Giriş/Kayıt formu:** `AsyncNotifierProvider` — Google ile giriş ve e-posta ile giriş/kayıt eylemlerini yönetir; her eylem sırasında `loading` durumuna geçer, sonucunda `authenticated` state'ine geçişi tetikler veya Bölüm 7'deki `AuthFailure` ile sonuçlanır. Bu provider ekran bazlıdır, `autoDispose` ile işaretlenir.
- **Oturum kontrolü (session persistence):** Firebase Authentication'ın kendi kalıcı oturum mekanizması esas alınır (`ARCHITECTURE.md` Bölüm 13.1, 13.5); state katmanı yalnızca bu mekanizmanın sonucunu `StreamProvider` üzerinden yansıtır, oturum verisini kendi başına saklamaz.

### 4.3 Router Entegrasyonu
`ARCHITECTURE.md` Bölüm 9.2'deki Auth Guard mantığı, oturum `StreamProvider`'ının en güncel değerini okuyarak çalışır — router, Authentication feature'ının Domain sözleşmesi dışında hiçbir şey bilmez.

---

## 5. Task State

PRD Bölüm 5.2 ve 5.3 (Görev Oluşturma / Proje → Görev → Alt Görev Hiyerarşisi) ile uyumlu:

### 5.1 State Modeli (Kavramsal)
- **Görev Listesi:** Aktif filtreye (proje, tarih, öncelik, tamamlanma durumu) göre filtrelenmiş görev koleksiyonu; dört async durumdan biriyle temsil edilir (Bölüm 7).
- **Görev Detayı:** Seçili görevin tam alanları + bağlı alt görev listesi + hesaplanmış tamamlanma yüzdesi (`ARCHITECTURE.md` Bölüm 4, satır 4 — "alt görevlere göre otomatik güncellenir").
- **Görev Formu:** Oluşturma/düzenleme sırasında geçici, henüz kaydedilmemiş form alanları (başlık, proje, tarih, öncelik, alt görevler taslağı).

### 5.2 Provider Yapısı
- **Görev Listesi:** `AsyncNotifierProvider` (`family` modifier ile — aktif filtre parametresine göre; `ARCHITECTURE.md` Bölüm 5.3'teki "family, parametreye bağlı sorgular için kullanılır" kuralına birebir örnektir). Isar üzerinden dinlenen bir Stream'e abone olur (Bölüm 8), bu nedenle liste yalnızca Isar değiştiğinde değil, Firestore senkronizasyonu Isar'a yansıdığında da otomatik güncellenir.
- **Görev Detayı:** `AsyncNotifierProvider` (`family` — görev ID parametreli).
- **Görev Oluşturma/Güncelleme/Silme/Tamamlama:** Bu beş eylem, ayrı ayrı UseCase'lere karşılık gelir (`CreateTaskUseCase`, `UpdateTaskUseCase`, `DeleteTaskUseCase`, `CompleteTaskUseCase` — `ARCHITECTURE.md` Bölüm 6.3 Single Responsibility kuralı), ancak Presentation'da tek bir `taskListControllerProvider` (`AsyncNotifierProvider`) üzerinden orkestre edilir; controller ilgili UseCase'i çağırır ve sonucu liste state'ine yansıtır.
- **Görev Formu:** `NotifierProvider` — senkron, çok adımlı form durumu; kaydetme anında ilgili UseCase'i tetikler.

### 5.3 Alt Görev — Üst Görev İlişkisi
Alt görev tamamlama eylemi, üst görevin tamamlanma yüzdesi state'ini de tetikler: `CompleteSubTaskUseCase` çalıştıktan sonra, görev detay controller'ı üst görevin yüzdesini yeniden hesaplayan UseCase'i (`RecalculateTaskProgressUseCase`) sırayla çağırır — bu, `ARCHITECTURE.md` Bölüm 6.3'teki "bir UseCase birden fazla repository'yi orkestre edebilir" ilkesinin uygulamasıdır.

---

## 6. Project State

PRD Bölüm 5.3 ile uyumlu:

### 6.1 State Modeli (Kavramsal)
- **Proje Listesi:** Aktif/arşivlenmiş filtresine göre proje koleksiyonu; her proje kartı, Tasks feature'ından okunan (salt okunur) görev sayısı özetini taşır.
- **Proje Detayı:** Seçili projenin alanları + o projeye bağlı görev listesi (Tasks feature'ının `getTasksByProjectUseCase`'i üzerinden okunur — Projects, Tasks'ın iç datasource'una erişmez, yalnızca dışa açık UseCase'ine).

### 6.2 Provider Yapısı
- **Proje Listesi:** `AsyncNotifierProvider`.
- **Proje Detayı:** `AsyncNotifierProvider` (`family` — proje ID parametreli); bu provider dahili olarak Tasks feature'ının ilgili UseCase provider'ını `ref.watch` ile izler, böylece bir görev eklendiğinde proje detay ekranı otomatik güncellenir.
- **Proje Oluşturma/Güncelleme:** `NotifierProvider` (form) → ilgili UseCase (`CreateProjectUseCase`, `UpdateProjectUseCase`) çağrılır, başarı durumunda proje listesi provider'ı geçersiz kılınır (invalidate) ve yeniden veri çeker.

---

## 7. Offline State

`ARCHITECTURE.md` Bölüm 8 (Offline Strategy) ve `DATABASE.md` Bölüm 12'de tanımlanan offline-first mimarinin state katmanına yansıması:

### 7.1 İnternet Var Senaryosu
```
Firestore (uzak değişiklik dinleyicisi)
   ↓
Repository: gelen veri Isar'a yazılır (updatedAt karşılaştırması ile — Last-Write-Wins)
   ↓
Isar Stream dinleyicisi tetiklenir
   ↓
StreamProvider/AsyncNotifierProvider yeni AsyncValue.data yayınlar
   ↓
UI otomatik günceller (widget yeniden build edilir)
```

### 7.2 İnternet Yok Senaryosu
```
Kullanıcı eylemi (örn. görev oluşturma)
   ↓
UseCase çağrılır
   ↓
Repository: yalnızca Isar'a yazılır (syncStatus: pendingCreate — DATABASE.md Bölüm 12.4)
   ↓
Isar Stream dinleyicisi tetiklenir
   ↓
AsyncNotifierProvider state'i anında günceller (kullanıcı gecikme hissetmez)
   ↓
Firestore'a yazma denemesi yapılmaz / başarısız olur, kayıt "pendingCreate" kalır
```

### 7.3 Bağlantı Geri Geldiğinde
- Bağlantı durumu, Core katmanındaki network dinleyicisi tarafından bir `StreamProvider` (`connectivityStatusProvider`) üzerinden yayınlanır.
- Bu provider `pending` durumdaki kayıtları olan feature repository'lerine bir senkronizasyon tetikleyicisi iletir (`ARCHITECTURE.md` Bölüm 8.3).
- Senkronizasyon tamamlandığında ilgili Isar kayıtları `synced` olarak güncellenir; bu güncelleme, Isar Stream'i üzerinden otomatik olarak ilgili tüm provider'lara yansır — Presentation katmanı senkronizasyonu **tetiklemez**, yalnızca sonucunu izler.

### 7.4 Senkronizasyon Durumu Görünürlüğü (Settings/Dashboard)
`ARCHITECTURE.md` Bölüm 8.5 ile uyumlu olarak, her feature repository'si `synced`/`pending`/`error` durumunu bir `StreamProvider` ile dışa açar; bu, PRD'deki "senkronizasyon durumu göstergesi" gereksinimini karşılamak üzere ilgili ekranlarda (örn. Settings, Dashboard) tüketilir.

### 7.5 Offline State'in Async State ile İlişkisi
Offline durumda veri **her zaman mevcuttur** (Isar'dan anında okunur) — bu nedenle offline olmak, Bölüm 8'deki `Error` durumuyla karıştırılmaz. `Error` yalnızca Isar okuma hatası (`CacheFailure`) gibi gerçek arıza durumlarında tetiklenir; bağlantısızlık başlı başına bir hata değildir.

---

## 8. Async State Yönetimi

`ARCHITECTURE.md` Bölüm 7.3'te belirtilen Riverpod `AsyncValue` uyumu esas alınarak, tüm veri-bağımlı ekranlarda beş durumluk standart bir UI-state sözleşmesi kullanılır. Bu, UI_GUIDELINES.md Bölüm 372–374'teki "boş durumlar asla boş bırakılmaz" ve "yükleme durumları skeleton ile gösterilir, jenerik spinner kullanılmaz" ilkeleriyle doğrudan eşlenir.

| Durum | Ne Zaman Oluşur | UI Karşılığı (UI_GUIDELINES.md ile uyum) |
|---|---|---|
| **Loading** | Provider ilk kez veri yüklüyor (henüz hiç veri yok) | İskelet (skeleton) yükleme deseni — jenerik spinner kullanılmaz |
| **Success** | Veri başarıyla yüklendi ve en az bir kayıt var | Normal liste/içerik görünümü |
| **Empty** | Veri başarıyla yüklendi ancak koleksiyon boş | İllüstrasyon/ikon + kısa açıklama + birincil eylem butonu (UI_GUIDELINES.md Bölüm 372) |
| **Error** | UseCase bir Failure döndürdü (Bölüm 9) | Kullanıcı dostu hata mesajı + yeniden dene eylemi |
| **Refreshing** | Zaten veri var, arka planda (örn. senkronizasyon veya pull-to-refresh ile) yenileniyor | Mevcut veri ekranda kalır, üstte ince bir ilerleme göstergesi (mevcut içerik gizlenmez) |

### 8.1 Empty ile Loading/Success Ayrımı
`AsyncValue.data` bir liste döndürdüğünde, Presentation katmanı listenin uzunluğunu kontrol ederek `Success` ile `Empty` durumunu ayırt eder — bu ayrım Domain katmanında değil, UI-state eşleme mantığında (controller'ın state'i UI-state modeline çevirdiği noktada) yapılır; Domain yalnızca ham veri/Failure döndürür.

### 8.2 Refreshing ile Loading Ayrımı
`AsyncValue`'nun `isRefreshing`/önceki veri taşıma özelliği kullanılır: yeniden veri çekilirken önceki başarılı veri ekranda tutulur, yalnızca ince bir gösterge eklenir — bu, `ARCHITECTURE.md` Bölüm 8.1'deki "UI hiçbir zaman doğrudan Firestore'u beklemez" ilkesiyle uyumludur; kullanıcı zaten Isar'dan gelen veriyi görmeye devam eder.

---

## 9. Error Management

### 9.1 State Tarafında Hata Akışı
`ARCHITECTURE.md` Bölüm 7'de tanımlanan Exception → Failure dönüşümü, state katmanında şu şekilde tüketilir:

```
UseCase, Result<Success, Failure> tipinde bir sonuç döndürür
   ↓
Controller (Notifier/AsyncNotifier), sonucu inceler
   ↓
Başarılıysa → state, ilgili veriyle Success/Empty durumuna geçer
Başarısızsa → state, Failure tipini taşıyan Error durumuna geçer
   ↓
Presentation, Failure tipine göre (Bölüm 9.2) kullanıcı dostu mesaj seçer
```

### 9.2 Failure Tipi → State Davranışı Eşlemesi

| Failure Tipi (ARCHITECTURE.md Bölüm 7.4) | State Katmanındaki Davranış |
|---|---|
| `NetworkFailure` | Offline-first mimari nedeniyle **veri okuma** akışlarında bu neredeyse hiç tetiklenmez (Isar'dan okunur); yalnızca senkronizasyon tetikleyici eylemlerinde (örn. manuel "şimdi senkronize et" varsa) görünür olabilir. |
| `AuthFailure` | Authentication controller'ı `authError` durumuna geçer (Bölüm 4.1); form alanları korunur, kullanıcı tekrar deneyebilir. |
| `ValidationFailure` | Form controller'ı (`NotifierProvider`) ilgili alanın yanında hata mesajı taşıyan bir state alanı günceller; kaydetme eylemi UseCase'e gitmeden **önce** de form-seviyesi doğrulama yapılabilir (UI_GUIDELINES.md'deki form hata durumu ile uyumlu), ancak iş kuralı doğrulaması her zaman UseCase'de tekrar yapılır. |
| `CacheFailure` | Isar okuma/yazma hatası; ilgili liste/detay provider'ı `Error` durumuna geçer — bu, gerçek bir arıza sinyalidir (offline olmaktan farklı, bkz. 7.5). |
| `SyncConflictFailure` | MVP'de sessiz Last-Write-Wins uygulanır (`ARCHITECTURE.md` Bölüm 8.4); state katmanı bu durumu kullanıcıya bloklayıcı bir hata olarak göstermez, yalnızca loglar — senkronizasyon durumu göstergesinde (Bölüm 7.4) `error` olarak yansıtılabilir. |
| `PermissionFailure` | Biyometri izni reddi → Settings/kilit controller'ı otomatik olarak PIN akışına düşer (`ARCHITECTURE.md` Bölüm 13.4); Firestore güvenlik kuralı reddi → ilgili feature'ın state'i `Error` durumuna geçer. |
| `UnknownFailure` | İlgili feature'ın `Error` durumuna geçer; ayrıca uygulama seviyesindeki global hata dinleyicisine (`ARCHITECTURE.md` Bölüm 7.5) loglanır. |

### 9.3 Hata Durumunda State Kalıcılığı
Bir eylem (örn. görev güncelleme) hata ile sonuçlandığında, controller mevcut listedeki veriyi **kaybetmez** — yalnızca ilgili eylemin sonucu (örn. form gönderimi) hata olarak işaretlenir. Liste/detay state'i her zaman en son başarılı Isar verisini yansıtmaya devam eder; bu, `ARCHITECTURE.md` Bölüm 8.1'deki local-first ilkesinin doğal bir sonucudur.

---

## 10. Cache Yönetimi

### 10.1 Birincil Önbellek Katmanı
`ARCHITECTURE.md` Bölüm 12.3 ve `DATABASE.md` Bölüm 12.1 ile uyumlu olarak, Isar **birincil ve tek gerçek önbellek katmanıdır** — state katmanı, Firestore'u kendi başına bir önbellek olarak görmez, yalnızca Isar'ı okur/dinler.

### 10.2 Ne Zaman Yeniden Veri Çekilir?
| Veri Türü | Yeniden Çekme Tetikleyicisi |
|---|---|
| Görev/Proje/Alışkanlık/Not/Hedef listeleri (canlı) | Yeniden çekilmez — Isar Stream'i sürekli dinlenir, her değişiklik otomatik yansır (Bölüm 7.1). |
| Kullanıcı profil bilgisi, tema tercihi | Yalnızca uygulama açılışında veya kullanıcının doğrudan ilgili ayarı değiştirdiği eylemde yenilenir (`ARCHITECTURE.md` Bölüm 12.3). |
| Statistics agregasyonları | Ham veri her değiştiğinde değil; ekrana giriş anında veya gün değişiminde yeniden hesaplanır ve geçici olarak önbellekte tutulur (`ARCHITECTURE.md` Bölüm 12.3). |
| Categories/Tags gibi az değişen sözlük verileri | Uygulama açılışında bir kez çekilip tutulur; her ekran geçişinde yeniden sorgulanmaz (`DATABASE.md` Bölüm 12.6 ile uyumlu). |
| Statistics geçmişi (90 günden eski) | Yalnızca kullanıcı talep ettiğinde (on-demand) Firestore'dan çekilir — `DATABASE.md` Bölüm 12.3. |

### 10.3 Gereksiz Çağrıların Önlenmesi
- Aynı parametreyle (`family`) çağrılan bir provider, Riverpod tarafından otomatik olarak önbelleğe alınır; aynı ekran birden fazla widget'ta aynı `family` parametresiyle dinlendiğinde tek bir alt çağrı yapılır.
- Statistics ve Search gibi maliyetli agregasyon/sorgu işlemlerinde, kullanıcı girdisi değişse bile (örn. arama kutusuna yazarken) UseCase her tuş vuruşunda değil, kısa bir gecikme (debounce) sonrasında tetiklenir — bu, controller seviyesinde yönetilir, Domain katmanına sızmaz.
- `keepAlive`/`autoDispose` kararı (Bölüm 3.1) yanlış kullanılmaz: kalıcı olması gerekmeyen bir provider'ın `autoDispose` olmadan bırakılması, gereksiz bellek ve dinleyici maliyetine yol açar; bu, kod incelemesinde standart kontrol maddesidir.

---

## 11. UI ve State İlişkisi

### 11.1 Temel Kurallar
1. **Widget içinde business logic olmaz.** Bir widget, yalnızca state'i okur ve kullanıcı eylemini ilgili controller metoduna iletir; hiçbir doğrulama, hesaplama veya veri dönüştürme widget içinde yapılmaz.
2. **UI sadece state dinler.** Widget'lar `ref.watch` ile ilgili provider'ın (veya `select` ile provider'ın belirli bir alanının — Bölüm 12.1) güncel `AsyncValue`'sunu okur; state'i doğrudan mutasyona uğratmaz.
3. **İş mantığı controller/usecase tarafındadır.** Bir kullanıcı eylemi (örn. "Görevi Tamamla" butonuna basma), widget'tan doğrudan `ref.read(taskListControllerProvider.notifier).completeTask(...)` gibi bir controller metoduna iletilir; controller ilgili UseCase'i çağırır.

### 11.2 UI-State Modeli Ayrımı
Presentation katmanındaki UI-state modelleri (`ARCHITECTURE.md` Bölüm 3.1 — örn. `TaskListUiState`), Domain Entity'lerinden ayrıdır: UI-state modeli, Bölüm 8'deki beş durumu (loading/success/empty/error/refreshing) ve varsa ekran-özel meta bilgiyi (örn. aktif filtre) taşır; Entity ise yalnızca saf iş verisidir. Bu ayrım, `ARCHITECTURE.md` Bölüm 3.1'deki "Presentation katmanı verinin nereden geldiğini bilmez" ilkesini korur.

### 11.3 Tek Yönlü Veri Akışı
```
Kullanıcı Eylemi (widget)
   ↓
Controller metodu çağrılır (ref.read(...).notifier)
   ↓
Controller, ilgili UseCase'i çağırır
   ↓
UseCase, Repository üzerinden veriyi değiştirir/okur
   ↓
Isar Stream değişikliği yayınlar
   ↓
Controller'ın state'i güncellenir (AsyncValue)
   ↓
Widget, ref.watch ile otomatik yeniden build edilir
```
Bu akışta hiçbir adımda widget, state'i "geriye doğru" değiştirmez — akış her zaman tek yönlüdür.

---

## 12. Performans Kuralları

`ARCHITECTURE.md` Bölüm 12.1–12.2'de tanımlanan standartların state management'a özgü detaylandırması:

### 12.1 Select Kullanımı
- Bir widget, bir Notifier'ın **tamamına değil**, yalnızca ihtiyaç duyduğu alana `select` ile abone olur. Örnek: bir görev kartı widget'ı, tüm `taskListControllerProvider` state'i yerine yalnızca kendi görev ID'sine karşılık gelen tamamlanma durumuna abone olur — listenin başka bir öğesi değiştiğinde bu kart yeniden build edilmez.
- `select` kullanımı özellikle büyük listelerde (Bölüm 12.4) ve sık güncellenen state'lerde (Pomodoro zamanlayıcı saniye sayacı gibi) zorunludur.

### 12.2 Gereksiz Rebuild Önleme
- Liste öğeleri her zaman stabil `key` (entity ID) ile render edilir.
- Zamanlayıcı gibi saniyede bir değişen state'ler (Pomodoro), yalnızca geri sayım metnini gösteren en küçük widget'a `select` ile izole edilir; ekranın geri kalanı bu değişiklikten etkilenmez.

### 12.3 Provider Yaşam Döngüsü
- Ekran bazlı geçici state'ler (form, filtre, arama sorgusu) `autoDispose` ile işaretlenir (Bölüm 3.1).
- Kalıcı state'ler (auth, tema, senkronizasyon durumu) `autoDispose` kullanılmadan kök seviyede tutulur.
- `family` modifier'ı, parametreye bağlı sorgularda (proje ID'sine göre görev listesi, tarihe göre takvim verisi, dönem'e göre istatistik) standart olarak kullanılır; bu, aynı provider tanımının farklı parametrelerle bağımsız önbelleklenmesini sağlar.

### 12.4 AutoDispose Kullanımı
- Her `family` + `autoDispose` kombinasyonunda, ilgili ekrandan çıkıldığında o parametreye özel state tamamen bellekten temizlenir — özellikle Görev Detayı, Proje Detayı gibi çok sayıda farklı ID ile açılabilen ekranlarda bellek birikimini önler.
- Stream aboneliklerinin (Isar/Firestore dinleyicileri) provider `dispose` edildiğinde otomatik iptal edilmesi standarttır (`ARCHITECTURE.md` Bölüm 12.2).

### 12.5 Büyük Listelerin Yönetimi
- `ARCHITECTURE.md` Bölüm 12.4'teki sayfalama (pagination) stratejisi, state katmanında şu şekilde yansır: liste controller'ı, tüm veri setini tek seferde state'e yüklemez; `AsyncNotifierProvider` başlangıçta yalnızca ilk sayfayı yükler, kullanıcı kaydırdıkça controller ek sayfaları mevcut listeye ekler (state, biriken bir liste olarak güncellenir, yeniden yaratılmaz — immutability ile birlikte yalnızca yeni bir liste referansı üretilir).
- Aktif olmayan sekmelerin (Bottom Navigation) `AsyncNotifierProvider`'ları, sekme ilk kez görüntülenene kadar tetiklenmez (lazy initialization — `ARCHITECTURE.md` Bölüm 12.4).

---

## 13. Test Stratejisi

`ARCHITECTURE.md` Bölüm 3.2 ve Bölüm 14.3'teki test edilebilirlik önceliği, state management katmanında üç seviyede uygulanır:

### 13.1 Provider Testleri
- Her Data/Domain seviyesi provider (`xRepositoryProvider`, `xUseCaseProvider`), `ProviderContainer` üzerinde, gerçek Isar/Firestore bağımlılığı yerine sahte (fake/mock) implementasyonlarla override edilerek test edilir.
- Test edilen: doğru bağımlılığın enjekte edildiği (örn. `createTaskUseCaseProvider`'ın doğru `taskRepositoryProvider`'a bağlı olduğu), `family` parametrelerinin doğru izole önbelleklendiği.

### 13.2 Controller Testleri
- Her `Notifier`/`AsyncNotifier` (örn. `taskListControllerProvider`), ilgili UseCase provider'ları sahte sonuçlar (başarı/Failure) döndürecek şekilde override edilerek test edilir.
- Test edilen: Bölüm 8'deki beş durumun (loading/success/empty/error/refreshing) doğru sırayla ve doğru koşullarda üretildiği; Bölüm 9'daki her Failure tipinin doğru `Error` state'ine eşlendiği; eylem sonrası state'in beklenen şekilde güncellendiği (örn. görev tamamlandığında listedeki ilgili öğenin durumu).

### 13.3 Repository Bağlantı Testleri
- Repository implementasyonlarının offline-first karar mekanizması (Bölüm 7 — önce Isar, sonra Firestore) sahte Local/Remote Datasource'larla test edilir.
- Test edilen: bağlantı yokken yalnızca Isar'a yazıldığı ve `pendingCreate` işaretlendiği; bağlantı geldiğinde senkronizasyonun tetiklendiği; Last-Write-Wins kuralının (`ARCHITECTURE.md` Bölüm 8.4) doğru çalıştığı.

### 13.4 Test Kapsamı Dışında Kalanlar (Bu Doküman İçin)
Widget testleri (UI render doğrulaması) ve entegrasyon testleri (uçtan uca akış), bu dokümanın kapsamı dışındadır — bu doküman yalnızca state/provider/controller/repository seviyesindeki test stratejisini tanımlar; gerçek test kodu bir sonraki implementasyon aşamasında yazılır.

---

## 14. Sonraki Adımlar

Bu doküman, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Gerçek Riverpod provider/Notifier/AsyncNotifier sınıflarının kod implementasyonu (bu doküman kapsamında yapılmamıştır),
2. Isar şema implementasyonu ile state katmanının somut entegrasyonu,
3. Firebase kurulumu sonrası Authentication/senkronizasyon state akışlarının gerçek koda dökülmesi,
4. Widget ve entegrasyon test planlarının ayrı bir aşamada detaylandırılması.

**Bu doküman kapsamında herhangi bir kod, widget, Provider implementasyonu veya Firebase kurulumu üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
