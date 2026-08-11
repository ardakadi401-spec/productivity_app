# ARCHITECTURE.md
## Kişisel Üretkenlik Uygulaması — Yazılım Mimarisi Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Flutter Software Architect / Senior Mobile Architect / Clean Architecture Uzmanı
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`
**Doküman Durumu:** Teknik Referans Mimari — Tüm geliştirme bu dokümana uymalıdır

> Bu doküman yalnızca yazılım mimarisini tanımlar. Kod, widget, sayfa veya Firebase kurulum adımı içermez. Klasör yapısı bu aşamada oluşturulmamıştır; yalnızca organizasyon mantığı açıklanmıştır.

---

## 1. Genel Mimari

### 1.1 Mimari Yaklaşım
Uygulama, **Clean Architecture** prensipleri üzerine, **Feature-First** (özellik öncelikli) modüler yapı ile inşa edilir. Her özellik (feature), kendi içinde bağımsız çalışabilen, kendi katmanlarına sahip bir modül olarak tasarlanır. Bu yaklaşım şu üç temel bağımlılık kuralına dayanır:

1. **Bağımlılık Kuralı (Dependency Rule):** Bağımlılıklar her zaman dıştan içe doğru akar — Presentation → Domain, Data → Domain. Domain katmanı hiçbir dış katmana bağımlı değildir.
2. **Soyutlama Kuralı:** Üst katmanlar somut implementasyonlara değil, soyut arayüzlere (interface/abstract class) bağımlıdır.
3. **İzolasyon Kuralı:** Bir feature modülü, başka bir feature modülünün iç detaylarına (data/presentation katmanına) doğrudan erişemez; yalnızca `shared` veya `core` üzerinden paylaşılan sözleşmelere erişebilir.

### 1.2 Yüksek Seviye Katman Diyagramı (Kavramsal)

```
┌─────────────────────────────────────────────┐
│              PRESENTATION LAYER              │
│   (Screens, Widgets, Riverpod Providers/     │
│    Notifiers, State — UI mantığı)             │
└───────────────────┬───────────────────────────┘
                     │ bağımlı
                     ▼
┌─────────────────────────────────────────────┐
│                DOMAIN LAYER                   │
│  (Entities, UseCases, Repository Interfaces)  │
│         — Framework'ten bağımsız, saf Dart    │
└───────────────────┬───────────────────────────┘
                     ▲ implement eder
                     │
┌─────────────────────────────────────────────┐
│                 DATA LAYER                    │
│ (Repository Impl, Datasource, Model, Mapper)  │
└───────────────────┬───────────────────────────┘
                     │ kullanır
                     ▼
┌─────────────────────────────────────────────┐
│      CORE / SHARED / EXTERNAL SERVICES        │
│ (Firebase, Hive, Network Info, Notification)  │
└─────────────────────────────────────────────┘
```

Domain katmanı diyagramın merkezinde durur ve hiçbir oka **çıkış** vermez — yalnızca kendisine gelen implementasyonları (Data Layer üzerinden) kabul eder. Bu, Clean Architecture'ın "Dependency Inversion" ilkesinin somut uygulamasıdır.

### 1.3 Mimari Hedefler
- **Modülerlik:** Her feature bağımsız geliştirilebilir, test edilebilir ve gerekirse ayrı bir pakete taşınabilir.
- **Test Edilebilirlik:** Domain katmanı framework bağımsız olduğu için saf unit test ile test edilir; Data katmanı sahte (fake/mock) datasource'larla test edilir.
- **Ölçeklenebilirlik:** Yeni bir feature eklemek, mevcut modülleri değiştirmeden yeni bir dikey dilim (vertical slice) eklemekle sınırlıdır.
- **Bakım Kolaylığı:** Bir hata/değişiklik talebi, ilgili feature'ın sınırları içinde kalır; yan etkiler minimize edilir.

---

## 2. Kullanılan Teknolojiler

| Katman/Alan | Teknoloji | Rol |
|---|---|---|
| Framework | Flutter (son stabil sürüm) | UI ve platform katmanı |
| State Management | Riverpod | Reaktif durum yönetimi ve dependency injection |
| Mimari | Clean Architecture (Feature-First) | Katmanlı sorumluluk ayrımı |
| Dependency Injection | Riverpod Provider mekanizması | Servis/repository/usecase örneklerinin sağlanması |
| Uzak Veritabanı | Cloud Firestore | Bulut veri kalıcılığı ve senkronizasyon |
| Kimlik Doğrulama | Firebase Authentication | Google + E-posta girişi |
| Yerel Bildirim | Flutter Local Notifications | Görev/alışkanlık/pomodoro hatırlatmaları |
| Routing | Go Router | Deklaratif, guard destekli navigasyon |
| Yerel Depolama | Hive | Offline-first yerel veri katmanı |

Bu teknoloji seti, PRD'de tanımlanan **offline çalışma** ve **Firebase senkronizasyonu** gereksinimlerini doğrudan destekleyecek şekilde seçilmiştir: Hive hız ve offline erişilebilirlik sağlar, Firestore ise çok cihazlı senkronizasyon ve bulut yedekleme sağlar.

---

## 3. Katmanlar (Layers) — Sorumluluk Tanımları

Her feature modülü aşağıdaki 5 katmanı içerir. Katmanlar feature içinde dikey olarak tekrarlanır (her feature kendi Presentation/Domain/Data'sına sahiptir); Core ve Shared ise tüm feature'lar arasında yatay olarak paylaşılır.

### 3.1 Presentation Layer
**Sorumluluk:** Kullanıcıya görsel arayüzü sunmak ve kullanıcı etkileşimlerini Domain katmanına iletmek.
- Ekranlar (Screens) ve bunları oluşturan widget kompozisyonları,
- Riverpod Provider/Notifier tanımları (UI durumunu yönetir),
- UI-state modelleri (örn. `TaskListUiState`: loading/success/error/empty durumları),
- Kullanıcı girdisinin doğrulanması (form-level validation) — iş kuralı doğrulaması değil, yalnızca UI seviyesi doğrulama.
- **Bilmediği şeyler:** Presentation katmanı, verinin Firestore'dan mı yoksa Hive'dan mı geldiğini bilmez. Yalnızca Domain katmanının sunduğu UseCase'leri çağırır.

### 3.2 Domain Layer
**Sorumluluk:** Uygulamanın iş kurallarını (business logic) framework'ten tamamen bağımsız şekilde tanımlamak.
- **Entities:** Saf iş nesneleri (örn. `Task`, `Project`, `Habit`) — hiçbir Firebase/Hive anotasyonu içermez.
- **UseCases (Interactors):** Tek bir iş kuralını temsil eden sınıflar (örn. `CreateTaskUseCase`, `CompleteHabitUseCase`, `CalculateStreakUseCase`).
- **Repository Interfaces (Abstract Contracts):** Data katmanının uyması gereken sözleşmeler (örn. `TaskRepository` arayüzü).
- Bu katman, **hiçbir Flutter, Firebase veya Hive importu içermez** — tamamen saf Dart'tır. Bu, test edilebilirliğin ve framework bağımsızlığının garantisidir.

### 3.3 Data Layer
**Sorumluluk:** Domain katmanının tanımladığı repository sözleşmelerini somut veri kaynaklarıyla gerçeklemek.
- **Repository Implementation:** Domain'deki arayüzü implemente eder; hangi datasource'un (local/remote) ne zaman kullanılacağına karar verir (offline-first mantığı burada yaşar).
- **Datasource (Local/Remote):** `TaskLocalDatasource` (Hive) ve `TaskRemoteDatasource` (Firestore) gibi somut veri erişim sınıfları.
- **Model:** Datasource'a özel veri temsili (örn. `TaskModel` — Hive/Firestore serileştirme mantığını taşır).
- **Mapper:** Model ↔ Entity dönüşümünü yapan saf fonksiyonlar/sınıflar (Data katmanının detaylarının Domain'e sızmasını engeller).

### 3.4 Core Layer
**Sorumluluk:** Tüm uygulama genelinde kullanılan, feature'a özgü olmayan altyapısal bileşenleri barındırmak.
- Hata/Failure tanımları (bkz. Bölüm 9),
- Network durumu tespiti (connectivity),
- Firebase/Hive başlatma ve erişim sarmalayıcıları (yalnızca erişim mekanizması — kurulum bu doküman kapsamında değildir),
- Ortak sabitler (constants), tema/route sabitleri,
- Loglama ve genel amaçlı yardımcı (utility) sınıflar.

### 3.5 Shared Layer
**Sorumluluk:** Birden fazla feature tarafından ortak kullanılan, ancak Core kadar altyapısal olmayan bileşenleri barındırmak.
- Ortak UI bileşenleri (örn. genel `AppButton`, `EmptyStateView` — UI_GUIDELINES.md'deki component standartlarının paylaşılan implementasyon noktası, kod bu aşamada üretilmez),
- Feature'lar arası paylaşılan basit veri sözleşmeleri (örn. `Priority` enum'u — hem Tasks hem Calendar tarafından kullanılabilir),
- Ortak extension/formatter mantığı (tarih formatlama, süre formatlama gibi — yalnızca sorumluluk tanımı, implementasyon değil).

> **Kritik Kural:** Shared katmanı asla bir feature'ın Domain veya Data detaylarını içermez. Yalnızca gerçekten birden fazla feature'ın ihtiyaç duyduğu, feature-agnostik sözleşmeler burada yer alır. Aksi halde "gizli coupling" (örtük bağımlılık) oluşur.

---

## 4. Feature Yapısı (Feature-First Modülerlik)

Aşağıdaki 14 feature modülü, PRD'de tanımlanan kapsamla birebir örtüşecek şekilde planlanmıştır. Her biri kendi Presentation/Domain/Data üçlüsüne sahiptir.

| # | Feature | Temel Sorumluluk | Bağımlı Olduğu Feature'lar |
|---|---|---|---|
| 1 | **Authentication** | Google/E-posta girişi, oturum durumu, hesap silme | — (bağımsız, en temel modül) |
| 2 | **Dashboard** | Günlük özet, hızlı erişim, çoklu feature verisinin agregasyonu | Tasks, Habits, Goals (yalnızca Domain sözleşmeleri üzerinden) |
| 3 | **Projects** | Proje CRUD, proje-görev ilişkisi | Tasks (proje altındaki görev sayımı için) |
| 4 | **Tasks** | Görev + alt görev CRUD, tamamlanma mantığı | Projects (opsiyonel ilişki) |
| 5 | **Calendar** | Tarih bazlı görev/hedef görüntüleme | Tasks, Goals (salt okunur agregasyon) |
| 6 | **Habits** | Alışkanlık CRUD, streak hesaplama | — |
| 7 | **Goals** | Günlük/haftalık/aylık hedef CRUD, ilerleme hesaplama | Tasks (opsiyonel bağlama) |
| 8 | **Notes** | Not CRUD, proje/görev bağlama | Projects, Tasks (opsiyonel) |
| 9 | **Pomodoro** | Zamanlayıcı mantığı, oturum kaydı | Tasks (opsiyonel bağlama) |
| 10 | **Statistics** | Tüm feature'lardan veri agregasyonu ve görselleştirme | Tasks, Habits, Pomodoro, Goals (salt okunur) |
| 11 | **Search** | Feature'lar arası birleşik arama indeksleme/sorgu | Tasks, Projects, Notes, Habits (salt okunur) |
| 12 | **Settings** | Tema, kilit (PIN/biyometri), bildirim tercihleri | Notification, Authentication |
| 13 | **Profile** | Kullanıcı profil bilgisi, hesap yönetimi | Authentication |
| 14 | **Notification** | Yerel bildirim planlama/iptal altyapısı | Tasks, Habits, Pomodoro (tetikleyici olarak kullanılır, tersi değil) |

### 4.1 Cross-Feature İletişim Kuralı
Bir feature'ın başka bir feature'ın verisine ihtiyaç duyması durumunda (örn. Dashboard'un Tasks verisine ihtiyaç duyması), bu iletişim **yalnızca Domain katmanındaki UseCase/Repository arayüzleri üzerinden** yapılır — asla doğrudan başka bir feature'ın Data veya Presentation katmanına erişilmez. Bu, feature'ların birbirinden gerçek anlamda izole kalmasını sağlar.

**Kabul edilen:** Dashboard → `GetTodayTasksUseCase` (Tasks Domain'inden) çağırır.
**Kabul edilmeyen:** Dashboard → `TaskLocalDatasource`'a (Tasks Data katmanı) doğrudan erişir.

### 4.2 Notification Feature'ın Özel Konumu
Notification, diğer feature'lar tarafından **tüketilen bir altyapı servisi** gibi davranır ancak kendi zamanlama/iptal iş kurallarına sahip olduğu için tam bir feature modülü olarak (Core'a değil) konumlandırılmıştır. Diğer feature'lar (Tasks, Habits, Pomodoro), Notification'ın Domain katmanındaki `ScheduleNotificationUseCase` / `CancelNotificationUseCase` sözleşmelerini çağırır.

---

## 5. Riverpod Stratejisi

Riverpod, hem **state management** hem de **dependency injection** aracı olarak kullanılır. Provider tipi seçimi, verinin doğasına göre standardize edilmiştir:

| Provider Tipi | Ne Zaman Kullanılır | Örnek Kullanım Senaryosu |
|---|---|---|
| **Provider** | Değişmeyen bağımlılıkların (repository, usecase, service instance) sağlanması | `taskRepositoryProvider`, `authServiceProvider` |
| **StateNotifierProvider / NotifierProvider** | Karmaşık, çok adımlı kullanıcı etkileşimi olan senkron/asenkron durum yönetimi | Görev oluşturma formu, Pomodoro zamanlayıcı durumu, Onboarding akış durumu |
| **AsyncNotifierProvider** | Başlangıçta asenkron veri yüklemesi gerektiren ve sonrasında kullanıcı etkileşimiyle değişebilen durumlar | Görev listesi (yükle + ekle/sil/güncelle), Alışkanlık listesi |
| **FutureProvider** | Tek seferlik, yeniden hesaplanması nadir olan asenkron veri getirme işlemleri | Kullanıcı profil bilgisi getirme, uygulama ilk açılış konfigürasyonu |
| **StreamProvider** | Sürekli değişen, gerçek zamanlı veri kaynaklarının dinlenmesi | Firestore senkronizasyon durumu dinleme, oturum (auth) durumu dinleme, Hive kutu değişiklik dinleyicisi |

### 5.1 Karar Kriterleri
- Veri **bir kez okunup gösteriliyorsa** → `FutureProvider`.
- Veri **sürekli akan/canlı** bir kaynaktan geliyorsa (auth state, senkronizasyon durumu) → `StreamProvider`.
- Kullanıcı **karmaşık, çok adımlı etkileşimlerle durumu değiştiriyorsa** (ekle/sil/güncelle/filtrele) → `AsyncNotifierProvider` (asenkron başlangıç verisi varsa) veya `NotifierProvider` (senkron durum varsa, örn. Pomodoro sayaç durumu).
- Sabit, değişmeyen bağımlılıklar (repository/usecase örnekleri) → düz `Provider`.

### 5.2 Provider Katmanlama Kuralı
Her feature içinde provider'lar katman sınırlarına göre gruplanır:
- **Data katmanı provider'ları:** Datasource ve repository implementasyonlarını sağlar (örn. `taskRemoteDatasourceProvider` → `taskRepositoryProvider`).
- **Domain katmanı provider'ları:** UseCase örneklerini sağlar, ilgili repository provider'a bağımlıdır (örn. `createTaskUseCaseProvider`).
- **Presentation katmanı provider'ları:** Ekran durumunu yönetir, yalnızca Domain katmanı provider'larına (UseCase) bağımlıdır — Data katmanı provider'larını asla doğrudan çağırmaz.

Bu üç seviyeli provider zinciri, Clean Architecture'ın bağımlılık kuralının Riverpod içinde birebir yansımasıdır.

### 5.3 Provider Yaşam Döngüsü Yönetimi
- Ekran bazlı geçici durumlar (form state gibi) `autoDispose` ile işaretlenir — ekrandan çıkıldığında bellek serbest bırakılır.
- Uygulama genelinde kalıcı olması gereken durumlar (auth state, tema tercihi, senkronizasyon durumu) `autoDispose` kullanılmadan, kök seviyede tutulur.
- Liste ekranlarında `family` modifier'ı, parametreye bağlı sorgular için kullanılır (örn. proje ID'sine göre filtrelenmiş görev listesi).

---

## 6. Repository Pattern

### 6.1 Katmanlar Arası İlişki

```
UseCase  →  Repository (Interface, Domain)  ←  Repository (Implementation, Data)
                                                          │
                                                          ├── LocalDatasource (Hive)
                                                          └── RemoteDatasource (Firestore)
```

### 6.2 Sorumluluk Tanımları

| Bileşen | Katman | Sorumluluk |
|---|---|---|
| **Entity** | Domain | Saf iş nesnesi; framework bağımsız; iş kurallarının temel veri birimi |
| **UseCase** | Domain | Tek bir iş kuralını uygular; Repository arayüzünü çağırır; birden fazla repository'yi orkestre edebilir |
| **Repository (Interface)** | Domain | Data katmanının uyması gereken sözleşme; hangi veri işlemlerinin mümkün olduğunu tanımlar (CRUD + sorgular) |
| **Repository (Implementation)** | Data | Interface'i gerçekler; **offline-first karar mekanizmasının kalbi** — local/remote önceliklendirmesi burada yapılır |
| **Datasource** | Data | Tek bir veri kaynağına (Hive veya Firestore) özel ham veri erişimi |
| **Model** | Data | Datasource'a özel veri temsili; JSON/Hive serileştirme sorumluluğu Model'e aittir, Entity'ye asla sızmaz |
| **Service** | Core/Data | Firebase Auth, bildirim planlayıcı gibi üçüncü taraf SDK sarmalayıcıları; Datasource'lar tarafından kullanılır |

### 6.3 UseCase Tasarım Kuralı
Her UseCase, **tek bir sorumluluk** taşır (Single Responsibility). Örneğin "Görev Oluştur" ve "Görevi Tamamla" ayrı UseCase'lerdir; birleştirilmiş "TaskUseCase" gibi çok amaçlı sınıflar oluşturulmaz. Bu, hem test edilebilirliği artırır hem de iş kurallarının okunabilirliğini korur.

### 6.4 Repository Implementation'ın Offline-First Kararı
Repository implementasyonu, her çağrıda şu karar akışını izler (detay Bölüm 8'de):
1. Önce yerel (Hive) veriyi döndür/güncelle (kullanıcı deneyimi anında tepki verir),
2. Arka planda, bağlantı varsa, uzak (Firestore) ile senkronize et,
3. Senkronizasyon sonucu yerel veriye yansıtılır ve ilgili Stream/Provider üzerinden UI'a bildirilir.

---

## 7. Error Management (Hata Yönetimi Stratejisi)

### 7.1 Kavramsal Ayrım: Exception vs Failure
- **Exception:** Sistem seviyesinde, beklenmeyen/düşük seviye hatalardır (örn. Firestore bağlantı hatası, Hive okuma hatası, format hatası). Exception'lar **Data katmanında** fırlatılır ve **yakalanır**.
- **Failure:** İş mantığı seviyesinde, kullanıcıya/Presentation katmanına iletilecek, anlamlandırılmış hata temsilleridir (örn. `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `SyncConflictFailure`). Failure'lar **Domain katmanında** tanımlanır.

### 7.2 Hata Akışı
```
Datasource (Exception fırlatır)
        ↓
Repository Implementation (Exception'ı yakalar, ilgili Failure'a çevirir)
        ↓
UseCase (Failure'ı Result/Either tipiyle Domain sözleşmesi olarak döndürür)
        ↓
Presentation (Failure tipine göre kullanıcı dostu mesaj gösterir — UI_GUIDELINES.md'deki
              "hata mesajları kullanıcı dostu olmalı" ilkesiyle birebir uyumlu)
```

### 7.3 Result/Either Yaklaşımı
UseCase'ler, başarı/hata durumunu **exception fırlatarak değil**, açık bir dönüş tipi (başarı veya Failure taşıyan bir sarmalayıcı tip) ile ifade eder. Bu, Presentation katmanının hata yönetimini try-catch yerine **deterministik, tip-güvenli** şekilde yapmasını sağlar ve Riverpod'un `AsyncValue` (data/loading/error) yapısıyla doğal olarak uyumludur.

### 7.4 Failure Kategorileri (Standart Set)
| Failure Tipi | Kullanım Senaryosu |
|---|---|
| `NetworkFailure` | Bağlantı yok, timeout |
| `AuthFailure` | Giriş/kayıt/oturum hataları |
| `ValidationFailure` | Kullanıcı girdisi iş kuralına uymuyor |
| `CacheFailure` | Hive okuma/yazma hatası |
| `SyncConflictFailure` | Offline-online senkronizasyon çakışması |
| `PermissionFailure` | Firestore güvenlik kuralı reddi, biyometri izni reddi |
| `UnknownFailure` | Beklenmeyen/sınıflandırılamayan hatalar |

### 7.5 Global Hata Yakalama
Uygulama seviyesinde, yakalanmamış (uncaught) hatalar için bir üst seviye hata dinleyici tanımlanır; bu, hata loglama ve kullanıcıya genel bir "beklenmedik hata" bildirimi gösterme sorumluluğunu taşır — feature bazlı Failure yönetiminin yerini almaz, yalnızca son bir güvenlik ağıdır.

---

## 8. Offline Strategy (Offline-First Mimari)

### 8.1 Temel Prensip
Uygulama **local-first** çalışır: kullanıcı arayüzü **hiçbir zaman** doğrudan Firestore'u beklemez. Tüm okuma/yazma işlemleri önce Hive üzerinden gerçekleşir; Firestore senkronizasyonu arka planda, kullanıcı deneyimini bloklamadan yürütülür.

### 8.2 Veri Akış Modeli

**Yazma (Create/Update/Delete) Akışı:**
```
Kullanıcı Eylemi
   ↓
UseCase çağrılır
   ↓
Repository: Hive'a hemen yazılır (kayıt "pending_sync" olarak işaretlenir)
   ↓
UI anında güncellenir (Stream/Provider üzerinden)
   ↓
Arka planda: Bağlantı varsa Firestore'a gönderilir
   ↓
Başarılıysa: Hive kaydı "synced" olarak işaretlenir
   ↓
Başarısızsa: Kayıt "pending_sync" kalır, bir sonraki bağlantıda tekrar denenir
```

**Okuma Akışı:**
```
UI, Repository üzerinden veri ister
   ↓
Repository her zaman önce Hive'dan okur ve döner (anında yanıt)
   ↓
(Arka planda) Firestore dinleyicisi varsa, güncellemeler Hive'a yazılır
   ↓
Hive değişikliği, Stream üzerinden UI'a otomatik yansır
```

### 8.3 Senkronizasyon Tetikleyicileri
- Uygulama ön plana geldiğinde (app resume),
- Bağlantı durumu offline'dan online'a geçtiğinde (connectivity listener),
- Periyodik arka plan senkronizasyonu (opsiyonel, düşük öncelikli).

### 8.4 Çakışma Çözümleme (Conflict Resolution)
- Her kayıt bir `updatedAt` zaman damgası taşır.
- Senkronizasyon sırasında hem yerel hem uzak versiyonda değişiklik tespit edilirse, **"son yazan kazanır" (Last-Write-Wins)** kuralı uygulanır — daha yeni `updatedAt` değerine sahip versiyon kazanır.
- Kritik veri kaybı riskinin olduğu durumlar (örn. iki farklı cihazda aynı görevin farklı şekilde düzenlenmesi) için, çakışma `SyncConflictFailure` olarak loglanır ve gelecekte kullanıcıya bildirim gösterme opsiyonu için altyapı bırakılır (MVP'de sessiz LWW yeterlidir — PRD ile uyumlu).

### 8.5 Senkronizasyon Durumu Görünürlüğü
Her feature'ın Repository'si, senkronizasyon durumunu (`synced` / `pending` / `error`) bir Stream olarak Domain katmanına, oradan da Presentation katmanına sunacak şekilde tasarlanır — bu, PRD'deki "senkronizasyon durumu göstergesi" gereksinimini destekler.

### 8.6 Neden Hive?
Hive; şemasız, hızlı, saf Dart tabanlı bir key-value/box yapısı sunduğu için, karmaşık ORM kurulumu olmadan offline-first bir katman için idealdir. Her feature, kendi Hive kutularını (box) yönetir; kutu isimlendirmesi feature adına göre standardize edilir (örn. `tasks_box`, `habits_box`) — bu, feature izolasyonunu veri katmanında da korur.

---

## 9. Navigation (Go Router Stratejisi)

### 9.1 Genel Yaklaşım
Go Router, **deklaratif ve merkezi** bir route tanım yapısı sunar. Route tanımları feature bazlı gruplandırılır ancak tek bir merkezi router konfigürasyonunda birleştirilir (her feature kendi route parçasını tanımlar, kök router bunları derler).

### 9.2 Auth Guard
- Router seviyesinde bir **redirect mantığı** tanımlanır: kullanıcının auth durumu (`StreamProvider` ile dinlenen Authentication state) her navigasyon kararında kontrol edilir.
- Giriş yapılmamış kullanıcı, korumalı (Dashboard, Tasks, vb.) rotalara erişmeye çalışırsa otomatik olarak Login ekranına yönlendirilir.
- Giriş yapılmış kullanıcı, Login/Register ekranına erişmeye çalışırsa Dashboard'a yönlendirilir.
- Bu guard mantığı, Authentication feature'ının Domain katmanındaki auth-state sözleşmesine bağımlıdır — router doğrudan Firebase Authentication SDK'sını bilmez.

### 9.3 Nested Navigation
- Ana uygulama kabuğu (shell), Bottom Navigation'ı temsil eden bir **ShellRoute** ile tanımlanır.
- Her bottom navigation sekmesi (Dashboard, Projects/Tasks, Calendar, Habits/Goals, Settings gibi gruplamalar), kendi iç navigasyon yığınına (nested navigator) sahiptir — bu, bir sekme içinde detay ekranına gidildiğinde diğer sekmelerin durumunun korunmasını sağlar.
- Kilit ekranı (PIN/Biyometri) ve Onboarding, Shell dışında, tam ekran bağımsız rotalar olarak tanımlanır.

### 9.4 Deep Link Hazırlığı
- Route path'leri, gelecekte deep link desteğine (örn. bir bildirimden doğrudan ilgili göreve gitme) uyumlu olacak şekilde **anlamlı ve parametreli** tasarlanır (örn. `/tasks/:taskId`, `/projects/:projectId`).
- Yerel bildirimlerin `payload` alanı, ilgili route path'ini taşıyacak şekilde planlanır; bildirime dokunulduğunda router bu path'e programatik olarak yönlendirilir.
- Bu aşamada gerçek deep link (App Links/Universal Links) kurulumu yapılmaz; yalnızca route yapısının buna hazır olması sağlanır.

### 9.5 Route Erişim Kuralı
Bir feature'ın route tanımı, yalnızca kendi Presentation katmanındaki ekranlara referans verir. Route parametreleri (örn. `taskId`), ilgili ekranın Provider'ına iletilir; router asla iş mantığı içermez.

---

## 10. Dependency Management

### 10.1 Provider Bağımlılık Zinciri
Bağımlılıklar her zaman tek yönlü akar: `Datasource → Repository → UseCase → Presentation Provider`. Riverpod'un `ref.watch` / `ref.read` mekanizması, bu zinciri açık ve izlenebilir şekilde kurar.

### 10.2 Circular Dependency Önleme Kuralları
1. **Feature'lar birbirinin Presentation/Data katmanına asla bağımlı olamaz** — yalnızca Domain sözleşmelerine (UseCase/Repository interface) bağımlı olabilir (bkz. Bölüm 4.1).
2. **Domain katmanı hiçbir şeye bağımlı değildir** — bu, tanım gereği döngüsel bağımlılığı domain seviyesinde imkânsız kılar.
3. **Core/Shared katmanları, hiçbir feature'a bağımlı olamaz** — bağımlılık her zaman feature → shared/core yönündedir, tersi asla kurulmaz.
4. İki feature'ın birbirine ihtiyaç duyduğu (örn. Tasks ↔ Projects) durumlarda, ortak sözleşme **Shared katmanına** çıkarılır (örn. ortak bir `ProjectReference` value object'i) — feature'lar birbirine değil, ortak sözleşmeye bağımlı olur.
5. Provider tanımlarında, bir feature'ın provider dosyası başka bir feature'ın **iç (internal)** provider'ını değil, yalnızca o feature'ın Domain katmanında dışa açık (exported) UseCase provider'larını import edebilir.

### 10.3 Bağımlılık Yönü Özeti
```
Core/Shared  ←  Data  ←  Domain  ←  Presentation
(hiçbir şeye bağımlı değil, herkes buna bağımlı olabilir)
```

---

## 11. Dosya Organizasyonu (Klasör Yapısı Mantığı — Yalnızca Kavramsal)

> Bu bölümde gerçek klasör yapısı oluşturulmamaktadır; yalnızca organizasyon mantığı tanımlanmıştır. Gerçek dizin ağacı bir sonraki aşamada hazırlanacaktır.

### 11.1 Üst Seviye Organizasyon Mantığı
Proje kök seviyesinde iki ana bölge bulunur:
- **Core/Shared bölgesi:** Feature-agnostik, tüm uygulamanın paylaştığı altyapı ve ortak bileşenler.
- **Features bölgesi:** Bölüm 4'te listelenen 14 feature'ın her biri, kendi adını taşıyan bağımsız bir klasör altında yaşar.

### 11.2 Feature İçi Organizasyon Mantığı
Her feature klasörü, kendi içinde üç alt bölgeye ayrılır:
- **Presentation bölgesi:** Ekranlar, provider'lar, UI state modelleri buradadır; kendi içinde ekran bazlı alt gruplama yapılır (örn. liste ekranı, detay ekranı, form ekranı ayrı alt gruplarda organize edilir).
- **Domain bölgesi:** Entity, UseCase ve Repository arayüzleri buradadır; her biri kendi tipine göre alt gruplanır.
- **Data bölgesi:** Datasource (local/remote ayrımıyla), Model ve Mapper buradadır; repository implementasyonu bu bölgenin kök seviyesinde yer alır.

### 11.3 Organizasyon Prensipleri
- **"Feature by feature, layer by layer" kuralı:** Önce feature'a göre, feature içinde ise katmana göre gruplama yapılır — asla tersi (önce katman, içinde feature) değil. Bu, bir feature'ı bütünüyle anlamak/taşımak/silmek istendiğinde tek bir klasöre bakmanın yeterli olmasını sağlar.
- **Ortaklık eşiği:** Bir bileşen yalnızca **gerçekten 2 veya daha fazla feature tarafından kullanılıyorsa** Shared'a taşınır; "belki ileride lazım olur" gerekçesiyle erken paylaşıma gidilmez (erken soyutlama karmaşıklığı artırır).
- **İsimlendirme tutarlılığı:** Katman isimleri (`presentation`, `domain`, `data`) ve alt tip isimleri (`entities`, `usecases`, `repositories`, `datasources`, `models`, `providers`, `screens`) tüm feature'larda birebir aynı terminolojiyle kullanılır — bu, yeni bir geliştiricinin herhangi bir feature'a hızlıca adapte olmasını sağlar.

---

## 12. Performance Standards

### 12.1 Widget Rebuild Optimizasyonu
- Riverpod'da `select` kullanımı standarttır: bir widget, bir Notifier'ın **tamamına değil**, yalnızca ihtiyaç duyduğu spesifik alana abone olur (örn. bir görev kartı, tüm görev listesi state'i yerine yalnızca kendi görevinin tamamlanma durumuna abone olur).
- Liste öğeleri her zaman stabil `key` değerleriyle (örn. entity ID) render edilir — gereksiz widget yeniden oluşturmasını önler.
- Büyük widget ağaçları, değişmeyen alt ağaçların yeniden oluşturulmasını önlemek için mantıklı sınırlarda küçük, kompoze edilebilir widget'lara bölünür.

### 12.2 Memory Management
- `autoDispose` modifier'ı, ekrandan ayrılındığında artık ihtiyaç duyulmayan tüm geçici provider'larda kullanılır (bkz. 5.3).
- Stream aboneliklerinin (Firestore/Hive dinleyicileri) provider yaşam döngüsüyle birlikte otomatik olarak iptal edilmesi sağlanır — sızıntı (leak) önleme, Riverpod'un `ref.onDispose` mekanizmasıyla standardize edilir.
- Büyük listelerde (görevler, notlar) tüm veri seti yerine görünür alan + tampon bölge kadar veri bellekte tutulur (bkz. 12.4 Pagination).

### 12.3 Caching Stratejisi
- Hive, birincil önbellek katmanı olarak görev yapar (bkz. Bölüm 8) — Firestore her açılışta yeniden sorgulanmaz.
- Sık değişmeyen veriler (örn. kullanıcı profil bilgisi, tema tercihi) için ayrı, düşük-frekanslı yenilenen bir önbellek politikası uygulanır (yalnızca uygulama açılışında veya kullanıcı eylemiyle yenilenir).
- İstatistik hesaplamaları (Bölüm 4 — Statistics feature) gibi maliyetli agregasyonlar, ham veri her değiştiğinde değil, **belirli tetikleyicilerde** (ekrana giriş, gün değişimi) yeniden hesaplanır ve sonucu geçici olarak önbellekte tutulur.

### 12.4 Lazy Loading & Pagination
- Uzun listeler (görev geçmişi, not listesi, istatistik geçmişi) sayfalama (pagination) ile yüklenir; ilk yüklemede yalnızca görünür alanı dolduracak kadar veri çekilir, kullanıcı kaydırdıkça bir sonraki sayfa yüklenir.
- Firestore sorgularında `limit` ve imleç (cursor) tabanlı sayfalama standart olarak kullanılır — tüm koleksiyonun tek seferde çekilmesi hiçbir feature'da uygulanmaz.
- Sekme bazlı ekranlarda (Bottom Navigation), aktif olmayan sekmelerin ağır veri yüklemesi, sekme ilk kez görüntülenene kadar ertelenir (lazy initialization).

### 12.5 Image Optimization
- Uygulama, PRD kapsamında yoğun görsel içerik barındırmasa da (kullanıcı fotoğrafı, kapak görseli gibi öğeler MVP'de yoktur), gelecekte eklenebilecek her türlü görsel (profil fotoğrafı gibi) için: uygun çözünürlükte önbellekleme, disk önbellek limiti ve lazy image loading standardı baştan tanımlanır — böylece ileride bir görsel özelliği eklendiğinde mimari yeniden düşünülmez.

---

## 13. Security Architecture

### 13.1 Authentication Güvenliği
- Firebase Authentication, kimlik doğrulamanın tek kaynağıdır; şifreler veya token'lar hiçbir şekilde uygulama tarafında saklanmaz — bu tamamen Firebase SDK'sının sorumluluğundadır.
- Oturum durumu, Authentication feature'ının Domain katmanında bir `StreamProvider` ile dinlenir; token yenileme Firebase SDK tarafından otomatik yönetilir, uygulama seviyesinde manuel token saklama/yönetme yapılmaz.

### 13.2 Firestore Güvenlik Kuralları (Rules) — Mimari Prensip
- Her kullanıcının verisi, kendi `userId`'sine göre izole edilir; güvenlik kuralları seviyesinde **"bir kullanıcı yalnızca kendi verisine okuma/yazma erişimine sahiptir"** kuralı zorunlu kılınır (uygulama kodu bu izolasyona güvenmez, sunucu tarafında da garanti edilir — defense in depth).
- İstemci tarafı sorguları her zaman aktif kullanıcının `userId`'si ile filtrelenir; bu filtre hem performans hem güvenlik amacıyla veri katmanında (Remote Datasource) standardize edilir.
- Bu doküman kapsamında Firestore Rules'un gerçek yazımı (kurulum) yapılmadığı belirtilmiştir; yalnızca mimari prensip tanımlanmıştır.

### 13.3 PIN Güvenliği
- PIN kodu, düz metin olarak hiçbir yerde saklanmaz; PIN doğrulaması, güvenli yerel depolama mekanizması (platform seviyesinde şifrelenmiş depolama) üzerinden yapılacak şekilde mimari planlanır.
- PIN doğrulama mantığı, Settings feature'ının Domain katmanında bir UseCase (`VerifyPinUseCase`) olarak tanımlanır; Presentation katmanı PIN'i asla doğrudan karşılaştırmaz.

### 13.4 Biyometrik Güvenlik
- Biyometrik doğrulama, platformun kendi güvenli biyometrik API'sine devredilir; uygulama biyometrik veriye (parmak izi şablonu vb.) hiçbir şekilde erişmez veya saklamaz — yalnızca platformdan "doğrulandı/doğrulanmadı" sonucunu alır.
- Biyometri kullanılamayan/desteklenmeyen cihazlarda otomatik olarak PIN akışına düşülür (fallback mantığı Settings feature Domain katmanında tanımlanır).

### 13.5 Token ve Oturum Yönetimi
- Kimlik doğrulama token'ları, uygulama kodunda manuel olarak taşınmaz/saklanmaz; Firebase SDK'nın güvenli, platform-native depolama mekanizması esas alınır.
- Uygulama kilidi (PIN/Biyometri) aktifken, arka plana alınıp geri dönüldüğünde kilit ekranı zorunlu kılınır (bkz. PRD Bölüm 5.7) — bu, oturum açık kalsa dahi ek bir erişim katmanı sağlar.

### 13.6 Genel Güvenlik İlkesi
Güvenlik, tek bir katmanda değil, **defense in depth** yaklaşımıyla üç seviyede sağlanır: (1) Firebase Authentication ile kimlik doğrulama, (2) Firestore Rules ile sunucu tarafı yetkilendirme, (3) PIN/Biyometri ile cihaz seviyesi erişim kontrolü.

---

## 14. Best Practices

1. **SOLID prensiplerine bağlılık:**
   - *Single Responsibility:* Her UseCase, Repository, Datasource tek bir sorumluluk taşır.
   - *Open/Closed:* Yeni bir veri kaynağı (örn. gelecekte REST API) eklenmesi, mevcut Repository arayüzü değişmeden yeni bir Datasource implementasyonu ile mümkün olmalıdır.
   - *Liskov Substitution:* Herhangi bir Repository implementasyonu, Domain'deki arayüzün yerine sorunsuzca geçebilmelidir.
   - *Interface Segregation:* Repository arayüzleri, feature'ın gerçekten ihtiyaç duyduğu metotlarla sınırlı tutulur; "her şeyi yapan" dev arayüzler oluşturulmaz.
   - *Dependency Inversion:* Üst katmanlar somut sınıflara değil, soyut sözleşmelere bağımlıdır (bkz. Bölüm 1.1).
2. **Immutability:** Domain Entity'leri ve Presentation state modelleri değişmez (immutable) olarak tasarlanır; her güncelleme yeni bir örnek üretir — bu, Riverpod'un değişiklik tespitiyle doğal olarak uyumludur.
3. **Test edilebilirlik önceliği:** Domain katmanı, hiçbir mock framework gerektirmeden saf unit testlerle doğrulanabilir olmalıdır; bu, mimarinin kalite göstergesidir.
4. **Feature bağımsızlığı denetimi:** Kod incelemelerinde (code review), bir feature'ın başka bir feature'ın iç katmanına sızıp sızmadığı standart bir kontrol maddesidir.
5. **Sözleşme öncelikli geliştirme:** Yeni bir feature geliştirilirken önce Domain katmanı (Entity + UseCase + Repository arayüzü) tasarlanır, ardından Data ve Presentation buna göre şekillenir — "önce ekran, sonra mantık" yaklaşımı benimsenmez.

---

## 15. Geliştirme Kuralları (Development Rules)

1. Hiçbir Presentation bileşeni, Data katmanındaki bir sınıfı (Datasource, Model) doğrudan import edemez.
2. Hiçbir Domain sınıfı, `flutter`, `firebase_*` veya `hive` paketlerini import edemez — Domain katmanı saf Dart olarak kalır.
3. Her yeni feature, Bölüm 3'te tanımlanan 5 katman yapısını (Presentation/Domain/Data + paylaşılan Core/Shared erişimi) eksiksiz uygulamak zorundadır.
4. Bir feature'ın Repository arayüzü değişmeden, o feature'ın veri kaynağı (örn. Hive'dan başka bir yerel çözüme) değiştirilebilmelidir — bu, mimarinin doğrulama testi olarak kabul edilir.
5. Yeni bir Riverpod provider tanımlanırken, Bölüm 5'teki karar kriterleri zorunlu olarak uygulanır; kriter dışı ("çünkü öyle alışılmış") provider seçimi yapılmaz.
6. Her UseCase, başarı/hata durumunu Bölüm 7'de tanımlanan standart Result/Failure yaklaşımıyla döndürmek zorundadır; ham exception'lar Presentation katmanına asla sızdırılmaz.
7. Offline-first akışı (Bölüm 8) her feature için zorunludur; "bu feature için doğrudan Firestore'a yazalım" gibi istisnalar yapılmaz — tutarlılık, performanstan daha önceliklidir.
8. Yeni eklenen her ekran/route, Bölüm 9'daki Auth Guard ve Nested Navigation kurallarına uymak zorundadır.
9. Performans standartları (Bölüm 12), özellikle liste ekranlarında ve Statistics feature'ında, geliştirme sırasında değil **tasarım aşamasında** göz önünde bulundurulur — sonradan optimizasyon yerine baştan doğru mimari tercih edilir.
10. Güvenlik kuralları (Bölüm 13), MVP kapsamının dışına çıkılmadan, PRD ve UI_GUIDELINES dokümanlarıyla tam uyum içinde uygulanır.

---

## 16. Sonraki Adımlar

Bu mimari doküman, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Gerçek klasör/dizin yapısının oluşturulması (bu doküman kapsamında yapılmamıştır),
2. Firebase proje kurulumu ve Firestore Rules yazımı (ayrı teknik görev),
3. Feature bazlı geliştirme sprint planlaması,
4. Flutter paket/bağımlılık (pubspec) planlaması.

**Bu doküman kapsamında herhangi bir kod, widget, sayfa veya Firebase kurulumu üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
