# FOLDER_STRUCTURE.md
## Kişisel Üretkenlik Uygulaması — Klasör Yapısı ve Dosya Organizasyonu Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Flutter Architect / Clean Architecture Uzmanı
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`, `DATABASE.md`
**Doküman Durumu:** Flutter Geliştirme Aşaması Ana Referansı

> Bu doküman yalnızca klasör yapısını ve dosya organizasyon mantığını tanımlar. Kod, widget, ekran veya Firebase implementasyonu içermez. Aşağıdaki dizin ağaçları, gerçek dosya içerikleri değil, **organizasyon şemalarıdır**.

---

## 1. Genel Klasör Yapısı

`ARCHITECTURE.md` Bölüm 1'de tanımlanan **Feature-First Clean Architecture** yaklaşımının, gerçek `lib/` dizini seviyesindeki karşılığı aşağıdaki gibidir:

```
lib/
├── main.dart                      (yalnızca uygulama giriş noktası — minimal tutulur)
├── app/                           (uygulama kök widget'ı ve genel kurulum organizasyonu)
├── config/                        (ortam, Firebase, uygulama genel ayarları)
├── core/                          (feature-agnostik altyapı — bkz. Bölüm 2)
├── routes/                        (Go Router organizasyonu — bkz. Bölüm 9)
├── services/                      (global, feature-bağımsız servisler — bkz. Bölüm 10)
├── shared/                        (feature'lar arası paylaşılan UI/veri sözleşmeleri — bkz. Bölüm 7)
└── features/                      (14 bağımsız özellik modülü — bkz. Bölüm 3)

assets/                            (lib/ dışında, proje kökünde — bkz. Bölüm 11)
test/                              (lib/ yapısını birebir yansıtan test ağacı — bkz. Bölüm 13)
```

### 1.1 Üst Seviye Klasörlerin Sorumluluk Özeti

| Klasör | Sorumluluk | ARCHITECTURE.md Referansı |
|---|---|---|
| `app/` | Uygulama kök widget'ı, tema/route/provider scope kurulumunun toplandığı nokta | Bölüm 1 |
| `config/` | Ortam (dev/prod), Firebase ve uygulama sabiti konfigürasyonları | Bölüm 3.4 (Core) |
| `core/` | Feature-agnostik, tüm uygulamanın paylaştığı altyapı | Bölüm 3.4 |
| `routes/` | Go Router route tanımları ve guard mantığı organizasyonu | Bölüm 9 |
| `services/` | Firebase/Isar/Notification gibi üçüncü taraf SDK sarmalayıcı servisler | Bölüm 3.4, 6.7 |
| `shared/` | Feature'lar arası gerçekten ortak UI ve sözleşmeler | Bölüm 3.5 |
| `features/` | 14 bağımsız özellik modülü, her biri kendi Presentation/Domain/Data'sına sahip | Bölüm 4 |

### 1.2 Genel Organizasyon İlkesi
`ARCHITECTURE.md` Bölüm 11.3'te tanımlanan **"feature by feature, layer by layer"** kuralı bu dokümanın da temel ilkesidir: en üst seviyede feature'a göre ayrım yapılır, feature içinde ise katmana göre ayrım yapılır. Bu sıralama asla tersine çevrilmez (yani proje genelinde "tüm data'lar bir arada, tüm presentation'lar bir arada" şeklinde bir üst-seviye ayrım yapılmaz).

---

## 2. Core Organization

`core/`, hiçbir feature'a bağımlı olmayan, tüm uygulamanın üzerine inşa edildiği temel yapı taşlarını barındırır (`ARCHITECTURE.md` Bölüm 10.3 — "Core/Shared hiçbir feature'a bağımlı olamaz" kuralı burada dosya sisteminde de yansıtılır).

```
core/
├── constants/          → Uygulama genelinde sabit değerler
├── errors/             → Failure sınıf tanımlarının organizasyonu
├── exceptions/         → Exception sınıf tanımlarının organizasyonu
├── extensions/         → Dart tip uzantıları (DateTime, String, vb. için yardımcı uzantı organizasyonu)
├── network/            → Bağlantı durumu tespiti, network bilgisi sağlayıcı organizasyonu
├── storage/            → Isar kutu/koleksiyon erişim sarmalayıcılarının organizasyonu (yalnızca altyapı, feature'a özel şema değil)
├── theme/              → UI_GUIDELINES.md'deki design token'ların (renk, tipografi, spacing) organizasyonu
└── utils/              → Genel amaçlı, feature bağımsız yardımcı fonksiyon organizasyonu
```

### 2.1 Alt Klasör Sorumlulukları

| Klasör | Görevi | Neden Burada, Feature İçinde Değil |
|---|---|---|
| `constants/` | Uygulama genelinde sabitler (örn. maksimum karakter sınırları — `DATABASE.md` Bölüm 14.3, animasyon süreleri — `UI_GUIDELINES.md` Bölüm 9.2) | Birden fazla feature aynı sabitlere ihtiyaç duyar (örn. karakter limiti hem Tasks hem Notes'ta kullanılır) |
| `errors/` | `ARCHITECTURE.md` Bölüm 7.4'te tanımlanan standart Failure kategorilerinin (`NetworkFailure`, `ValidationFailure` vb.) organizasyon noktası | Failure tipleri tüm feature'ların Domain katmanı tarafından ortak kullanılır |
| `exceptions/` | Data katmanında fırlatılan düşük seviye exception türlerinin organizasyonu | Datasource'ların ürettiği hatalar, feature bağımsız bir sözleşimle standardize edilmelidir |
| `extensions/` | Tarih formatlama, süre formatlama gibi tüm feature'ların ihtiyaç duyduğu uzantı mantığının organizasyonu | Örn. hem Calendar hem Statistics `DateTime` uzantılarına ihtiyaç duyar |
| `network/` | `DATABASE.md` Bölüm 12.4'teki senkronizasyon tetikleyicisi olan bağlantı durumu tespitinin organizasyonu | Offline-first akışı tüm feature'larda ortak bir bağlantı sinyaline ihtiyaç duyar |
| `storage/` | Isar veritabanı örneğinin başlatılması ve genel erişim sarmalayıcılarının organizasyonu (feature'a özel kutu/şema tanımları burada değil, ilgili feature'ın `data/` katmanında yer alır) | Tek bir Isar örneği tüm uygulama tarafından paylaşılır; başlatma mantığı merkezi olmalıdır |
| `theme/` | `UI_GUIDELINES.md`'deki renk paleti, tipografi skalası, spacing sisteminin design token organizasyonu | Tema, tanım gereği feature-agnostiktir ve her ekran tarafından tüketilir |
| `utils/` | Hiçbir feature'a özgü olmayan, saf yardımcı mantığın organizasyonu (örn. ID üretimi, genel doğrulama yardımcıları) | Birden fazla feature'ın ihtiyaç duyduğu, iş kuralı taşımayan yardımcı mantık |

---

## 3. Features Yapısı — Genel Şablon

`ARCHITECTURE.md` Bölüm 4'te tanımlanan 14 feature modülünün her biri, `features/` altında kendi adını taşıyan bir klasörde yaşar ve aşağıdaki **standart iç şablonu** izler:

```
features/
└── <feature_name>/
    ├── data/               → bkz. Bölüm 4
    ├── domain/             → bkz. Bölüm 5
    └── presentation/       → bkz. Bölüm 6 (controllers/state/providers dahil)
```

> **Not:** Talimatta örnek olarak verilen `feature/data/domain/presentation/providers` şablonundaki `providers/` klasörü, bu dokümanda ayrı bir üst klasör olarak değil, **`presentation/` katmanının bir alt klasörü** olarak konumlandırılmıştır (bkz. Bölüm 6.4). Gerekçe: Riverpod provider'ları, Presentation katmanının durum yönetimi sorumluluğunun bir parçasıdır (`ARCHITECTURE.md` Bölüm 3.1 ve 5.2) — ayrı bir üst-seviye klasör olarak çıkarılması, katman sınırını gereksiz yere bulanıklaştırır.

### 3.1 14 Feature Modülünün Listesi

```
features/
├── authentication/
├── dashboard/
├── projects/
├── tasks/
├── calendar/
├── habits/
├── goals/
├── notes/
├── pomodoro/
├── statistics/
├── search/
├── settings/
├── profile/
└── notifications/
```

Her feature, Bölüm 4–6'da tanımlanan üç katman şablonunu eksiksiz uygular. `tasks/` feature'ı, alt görev desteği nedeniyle ek bir iç organizasyon detayı taşır (bkz. Bölüm 3.2).

### 3.2 Özel Durum: Tasks Feature (SubTasks Organizasyonu)
`DATABASE.md` Bölüm 5'te SubTasks, Task'ın alt koleksiyonu olarak tanımlanmıştır. Bu ilişki, klasör yapısında **ayrı bir feature olarak değil**, `tasks/` feature'ının kendi katmanları içinde bir alt kavram olarak organize edilir (örn. `domain/entities/` altında hem `task_entity` hem `subtask_entity` birlikte bulunur; ayrı bir `subtasks/` feature'ı açılmaz). Gerekçe: SubTasks, Task'tan bağımsız bir yaşam döngüsüne veya ekranına sahip değildir — her zaman bir Task bağlamında var olur, bu nedenle ayrı bir feature modülü olmayı gerektirecek düzeyde bağımsız değildir.

---

## 4. Data Layer (Feature İçi)

```
features/<feature_name>/data/
├── models/            → Datasource'a özel veri temsili (Isar/Firestore serileştirme)
├── datasources/
│   ├── local/          → Isar tabanlı local datasource organizasyonu
│   └── remote/          → Firestore tabanlı remote datasource organizasyonu
├── repositories/       → Domain'deki repository arayüzünün implementasyon organizasyonu
└── mappers/            → Model ↔ Entity dönüşüm mantığının organizasyonu
```

### 4.1 Sorumluluklar

| Klasör | Sorumluluk | DATABASE.md / ARCHITECTURE.md Referansı |
|---|---|---|
| `models/` | `DATABASE.md` Bölüm 2–10'da tanımlanan alan yapılarının Dart veri temsili organizasyonu; Isar ve Firestore serileştirme etiketlerini taşır | DATABASE.md ilgili model bölümleri |
| `datasources/local/` | Isar üzerinden ham veri okuma/yazma organizasyonu; `DATABASE.md` Bölüm 12'deki `syncStatus` meta-alan yönetimi burada yaşar | DATABASE.md Bölüm 12 |
| `datasources/remote/` | Firestore üzerinden ham veri okuma/yazma organizasyonu; `DATABASE.md` Bölüm 1.3'teki koleksiyon path'lerine erişim burada yaşar | DATABASE.md Bölüm 1.3 |
| `repositories/` | `ARCHITECTURE.md` Bölüm 6.4'teki offline-first karar mekanizmasının (önce local, arka planda sync) somutlaştığı organizasyon noktası | ARCHITECTURE.md Bölüm 6.4, 8.2 |
| `mappers/` | Model'in Data katmanına özgü detaylarının (Isar/Firestore anotasyonları) Domain'e sızmasını engelleyen dönüşüm mantığının organizasyonu | ARCHITECTURE.md Bölüm 3.3 |

### 4.2 Local/Remote Ayrımının Gerekçesi
`datasources/` altında `local/` ve `remote/` ayrımı, `ARCHITECTURE.md` Bölüm 8.6'daki "her feature kendi Isar kutularını yönetir" ve `DATABASE.md` Bölüm 1'deki Firestore path yapısının feature bazlı izolasyonuyla birebir örtüşür — bu ayrım, hangi datasource'un hangi teknolojiye ait olduğunu dosya sisteminde de netleştirir.

---

## 5. Domain Layer (Feature İçi)

```
features/<feature_name>/domain/
├── entities/            → Framework bağımsız saf iş nesneleri
├── repositories/         → Data katmanının uyması gereken soyut sözleşmeler
└── usecases/            → Tek sorumluluklu iş kuralı sınıflarının organizasyonu
```

### 5.1 Sorumluluklar

| Klasör | Sorumluluk | ARCHITECTURE.md Referansı |
|---|---|---|
| `entities/` | `DATABASE.md`'deki alan tanımlarının, framework'ten (Isar/Firestore anotasyonlarından) arındırılmış saf Dart temsili | ARCHITECTURE.md Bölüm 3.2 |
| `repositories/` | Yalnızca **arayüz (abstract contract)** tanımları — implementasyon burada değil, `data/repositories/` altındadır | ARCHITECTURE.md Bölüm 6.2 |
| `usecases/` | Her biri tek bir iş kuralını temsil eden sınıfların organizasyonu (örn. görev oluşturma, tamamlama, alışkanlık streak hesaplama gibi ayrı ayrı organize edilen birimler) | ARCHITECTURE.md Bölüm 6.3 |

### 5.2 Domain Katmanının Saflık Kuralı
`ARCHITECTURE.md` Bölüm 15'te tanımlanan "Domain katmanı `flutter`, `firebase_*` veya `isar` paketlerini import edemez" kuralı, bu klasör yapısının en kritik denetim noktasıdır. Kod incelemelerinde, `domain/` klasörü altındaki hiçbir dosyanın bu tür bir bağımlılık taşımadığı standart bir kontrol maddesi olarak uygulanır.

---

## 6. Presentation Layer (Feature İçi)

```
features/<feature_name>/presentation/
├── pages/              → Tam ekran sayfa organizasyonu
├── widgets/             → Feature'a özel, yalnızca o feature içinde kullanılan widget organizasyonu
├── controllers/         → Riverpod Notifier/AsyncNotifier sınıflarının organizasyonu (iş akışı orkestrasyonu)
├── states/              → UI durum modellerinin organizasyonu (loading/success/error/empty temsilleri)
└── providers/           → Provider tanımlarının toplandığı organizasyon noktası
```

### 6.1 Sorumluluklar

| Klasör | Sorumluluk | ARCHITECTURE.md Referansı |
|---|---|---|
| `pages/` | Bir route'a karşılık gelen tam ekranların organizasyonu (örn. görev listesi ekranı, görev detay ekranı, görev oluşturma ekranı ayrı ayrı organize edilir) | ARCHITECTURE.md Bölüm 3.1 |
| `widgets/` | Yalnızca bu feature içinde tekrar kullanılan, feature'a özgü bileşenlerin organizasyonu (örn. `TaskCard` yalnızca Tasks feature'ında kullanılıyorsa burada; birden fazla feature'da kullanılıyorsa `shared/` altına taşınır — bkz. Bölüm 7) | UI_GUIDELINES.md Bölüm 7 (Component Standards) |
| `controllers/` | `ARCHITECTURE.md` Bölüm 5'teki Riverpod karar kriterlerine göre seçilen Notifier/AsyncNotifier sınıflarının organizasyonu; UseCase'leri çağıran, ekran akışını yöneten orkestrasyon mantığı burada yaşar | ARCHITECTURE.md Bölüm 5.1, 5.2 |
| `states/` | Her ekranın olası durumlarını (yükleniyor/başarılı/hata/boş) temsil eden immutable state modellerinin organizasyonu | ARCHITECTURE.md Bölüm 14.2 |
| `providers/` | Feature'ın tüm provider tanımlarının (Data katmanı provider'larından Presentation katmanı provider'larına kadar üç seviyeli zincirin — bkz. ARCHITECTURE.md Bölüm 5.2) toplandığı organizasyon noktası | ARCHITECTURE.md Bölüm 5.2 |

### 6.2 Pages Alt Organizasyonu
Her feature'ın `pages/` klasörü, kendi içinde ekran amacına göre alt gruplanır (örn. Tasks feature'ında liste, detay ve form ekranlarının her biri ayrı, isimlendirmeyle netleşen dosyalar olarak organize edilir — bkz. Bölüm 12 isimlendirme standardı).

### 6.3 Widgets: Feature-Local vs Shared Kararı
Bir widget'ın `features/<feature>/presentation/widgets/` altında mı yoksa `shared/widgets/` altında mı organize edileceği, `ARCHITECTURE.md` Bölüm 11.3'teki **"ortaklık eşiği"** kuralına göre belirlenir: yalnızca **gerçekten 2 veya daha fazla feature tarafından kullanılan** bileşenler `shared/`'a taşınır; tek feature'a özgü bileşenler o feature'ın kendi `widgets/` klasöründe kalır.

### 6.4 Providers'ın Presentation Altında Konumlanması
Bölüm 3'te belirtildiği gibi, `providers/` klasörü Presentation katmanının bir alt organizasyonudur. Bu klasör, üç seviyeli provider zincirinin (Data → Domain → Presentation, bkz. ARCHITECTURE.md Bölüm 5.2) **tamamının** tanımlandığı yer olabilir veya katman bazlı ayrılabilir — proje büyüklüğüne göre bu karar geliştirme aşamasında netleştirilecektir; bu doküman yalnızca provider'ların Presentation katmanına ait olduğunu ve feature sınırları içinde kaldığını standardize eder.

---

## 7. Shared Klasörü

`shared/`, `ARCHITECTURE.md` Bölüm 3.5'te tanımlanan, birden fazla feature tarafından **gerçekten** ortak kullanılan bileşenlerin organizasyon noktasıdır.

```
shared/
├── widgets/            → Genel amaçlı, feature bağımsız temel widget organizasyonu
├── components/          → UI_GUIDELINES.md'deki component standartlarının (Card, Chip, Badge vb.) paylaşılan organizasyon noktası
├── dialogs/             → Ortak dialog şablonlarının organizasyonu (onay, hata, bilgi dialogları)
├── buttons/             → Primary/Secondary/Text/Destructive buton varyantlarının organizasyonu (UI_GUIDELINES.md Bölüm 10)
├── forms/               → Ortak form alanı bileşenlerinin organizasyonu (TextField, DatePicker sarmalayıcıları)
└── loaders/             → İskelet (skeleton) yükleme ve genel yükleme göstergesi organizasyonu (UX_RULES Bölüm 13.5 ile uyumlu)
```

### 7.1 Shared İçindeki Alt Ayrımın Mantığı
`widgets/` ve `components/` ayrımı şu şekilde netleştirilir: `components/` özellikle `UI_GUIDELINES.md`'de standardı tanımlanmış, isimlendirilmiş bileşenleri (Card, Chip, Badge, Progress Bar gibi) barındırır; `widgets/` ise bu standart bileşenlerin dışında kalan, daha genel amaçlı yardımcı görsel yapıları (örn. boş durum görünümü, bölüm başlığı gibi tekrar eden ama "resmi bir component standardı" olmayan yapılar) barındırır.

### 7.2 Shared'in Bağımlılık Kısıtı
`ARCHITECTURE.md` Bölüm 10.2 Madde 3'te belirtildiği gibi, `shared/` hiçbir feature'a bağımlı olamaz. Bu, dosya sistemi seviyesinde şu şekilde denetlenir: `shared/` altındaki hiçbir dosya, `features/` altındaki herhangi bir klasörü import edemez — bağımlılık yönü her zaman `features/* → shared/*` şeklindedir, asla tersi değildir.

---

## 8. Config Yapısı

```
config/
├── app_config/          → Uygulama genel ayarlarının organizasyonu (varsayılan değerler, feature flag'ler gibi statik konfigürasyon)
├── environment/         → Ortam bazlı (dev/prod) konfigürasyon organizasyonu
└── firebase_config/     → Firebase proje bağlantı konfigürasyonunun organizasyon noktası (kurulum kodu değil, yalnızca konfigürasyon dosyalarının barınma yeri)
```

### 8.1 Config ile Core'un Farkı
`config/`, **statik, ortam bazlı ayar değerlerini** barındırırken; `core/constants/` (Bölüm 2), **uygulama davranışına ait sabit değerleri** (karakter limitleri, animasyon süreleri gibi) barındırır. Bu ayrım, "hangi ortamda çalışıyoruz" sorusuyla "uygulama nasıl davranmalı" sorusunun birbirinden net şekilde ayrılmasını sağlar.

---

## 9. Routes Yapısı

`ARCHITECTURE.md` Bölüm 9'da tanımlanan Go Router stratejisinin dosya organizasyonu:

```
routes/
├── app_router/          → Kök router konfigürasyonunun toplandığı organizasyon noktası (tüm feature route'larının birleştirildiği yer)
├── route_paths/         → Tüm route path sabitlerinin merkezi organizasyonu (deep link hazırlığı için tutarlı path tanımları — ARCHITECTURE.md Bölüm 9.4)
└── guards/              → Auth Guard mantığının organizasyon noktası (ARCHITECTURE.md Bölüm 9.2)
```

### 9.1 Feature Bazlı Route Tanımlarının Konumu
Her feature'ın **kendi route parçası**, o feature'ın `presentation/pages/` klasörüyle birlikte, feature kendi içinde organize eder (örn. `features/tasks/presentation/` altında feature'a özel route tanımı bulunabilir); ancak bu parçaların **birleştirildiği kök nokta** her zaman `routes/app_router/` altındadır. Bu, `ARCHITECTURE.md` Bölüm 9.1'deki "her feature kendi route parçasını tanımlar, kök router bunları derler" ilkesinin dosya sistemi karşılığıdır.

### 9.2 Route Paths'in Merkezi Tutulma Gerekçesi
Tüm route path sabitleri (`route_paths/`) merkezi bir organizasyon noktasında tutulur — bu, `ARCHITECTURE.md` Bölüm 9.4'teki deep link hazırlığı gereksinimini destekler: bir bildirimin `payload`'ının hangi path'e karşılık geldiğini kontrol etmek için tek bir referans noktası yeterli olur.

---

## 10. Services Yapısı

`services/`, üçüncü taraf SDK'ları (Firebase, Isar, Local Notifications) uygulamaya bağlayan, feature-bağımsız global servislerin organizasyon noktasıdır.

```
services/
├── authentication_service/    → Firebase Authentication SDK sarmalayıcısının organizasyonu
├── notification_service/      → Flutter Local Notifications SDK sarmalayıcısının organizasyonu
├── database_service/          → Isar örneği başlatma/erişim sarmalayıcısının organizasyonu
└── storage_service/           → Genel amaçlı yerel depolama erişimi (örn. tema tercihi gibi feature-dışı basit anahtar-değer verileri)
```

### 10.1 Services ile Data Katmanının Farkı
`services/` altındaki servisler, **feature'a özel iş mantığı taşımaz** — yalnızca SDK'ya erişimi standardize eder. Örneğin `notification_service/`, "bir bildirim nasıl planlanır" (genel API) sorusuna cevap verirken, "bir görevin son tarihine göre ne zaman bildirim planlanmalı" (iş kuralı) sorusu `features/notifications/domain/usecases/` içinde yaşar (`ARCHITECTURE.md` Bölüm 4.2 — Notification feature'ın özel konumu ile birebir uyumlu). Bu ayrım, `services/`'in `core/` gibi feature-agnostik kalmasını, ancak iş kuralı barındırmayan saf SDK erişim katmanı olarak konumlanmasını sağlar.

### 10.2 Feature'ların Services'e Erişimi
Feature'ların `data/datasources/` katmanı, ilgili servisleri kullanabilir (örn. `features/authentication/data/datasources/` → `authentication_service`'i kullanır) ancak bu bağımlılık her zaman **Data katmanı seviyesinde** kalır; Presentation veya Domain katmanı `services/` klasörüne doğrudan erişmez (`ARCHITECTURE.md` Bölüm 3.2 — Domain'in framework bağımsızlığı kuralı burada da geçerlidir).

---

## 11. Asset Yapısı

```
assets/
├── images/            → Statik görsel dosyaların organizasyonu (illüstrasyon, boş durum görselleri vb.)
├── icons/             → UI_GUIDELINES.md Bölüm 8'de tanımlanan tekil ikon ailesinin dosya organizasyonu
├── fonts/             → UI_GUIDELINES.md Bölüm 4'te tanımlanan tipografi font dosyalarının organizasyonu
└── animations/        → Lottie/Rive gibi hafif animasyon dosyalarının organizasyonu (yalnızca boş durum/onboarding gibi ölçülü kullanım alanları için — UI_GUIDELINES.md Bölüm 1.3)
```

### 11.1 Alt Organizasyon Prensibi
`images/` ve `icons/` klasörleri kendi içinde feature bazlı değil, **kullanım amacına göre** alt gruplanır (örn. `empty_states/`, `onboarding/` gibi) — çünkü görseller genellikle birden fazla feature'da (örn. aynı "boş liste" illüstrasyonu hem Tasks hem Notes'ta) tekrar kullanılır; feature bazlı gruplama gereksiz tekrar yaratır.

---

## 12. Naming Convention (İsimlendirme Kuralları)

### 12.1 Dosya İsimleri
- Tüm dosya isimleri `snake_case` formatındadır (Dart topluluk standardı ile uyumlu).
- Dosya isimleri, içerdiği ana yapının türünü **son ek (suffix)** olarak taşır: `task_entity`, `task_model`, `task_repository`, `create_task_usecase`, `task_list_page`, `task_card_widget`, `task_list_controller`, `task_list_state`, `task_repository_provider`.
- Bu son-ek standardı, dosya adına bakarak (içeriğini açmadan) hangi katmana/türe ait olduğunun anlaşılmasını sağlar.

### 12.2 Class İsimleri
- Tüm class isimleri `PascalCase` formatındadır.
- Class ismi, dosya isminin son-ek yapısını birebir yansıtır (örn. `task_entity` dosyası → `TaskEntity` class'ı; `create_task_usecase` dosyası → `CreateTaskUseCase` class'ı).

### 12.3 Provider İsimleri
- Provider değişken isimleri `camelCase` formatındadır ve her zaman **ne sağladığını** açıkça belirten bir isim + tür son-eki taşır: örn. `taskRepositoryProvider`, `createTaskUseCaseProvider`, `taskListControllerProvider`.
- `ARCHITECTURE.md` Bölüm 5.2'deki üç seviyeli provider zinciri (Data/Domain/Presentation), isimlendirme üzerinden de ayırt edilebilir olmalıdır — bir provider isminden, hangi katmana ait olduğu (repository/usecase/controller son-ekinden) doğrudan anlaşılmalıdır.

### 12.4 Model / Entity İsimleri
- Entity isimleri sade tutulur: `Task`, `Project`, `Habit` yerine (belirsizlik yaratmaması için) her zaman `TaskEntity`, `ProjectEntity`, `HabitEntity` formatı kullanılır — bu, Entity ile Model'in (bkz. aşağı) isim çakışmasını engeller.
- Model isimleri her zaman `Model` son-ekini taşır: `TaskModel`, `ProjectModel` — bu, `DATABASE.md`'deki Firestore/Isar alan yapılarının Data katmanındaki karşılığıdır.
- Bir feature'da hem Entity hem Model bulunması zorunludur (`ARCHITECTURE.md` Bölüm 3.3'teki Mapper sorumluluğu, bu iki tip arasında köprü kurar); tek bir sınıfın hem Entity hem Model rolünü üstlenmesi (kısayol amaçlı birleştirme) bu projede uygulanmaz.

### 12.5 Klasör İsimleri
- Tüm klasör isimleri `snake_case` ve **çoğul** formdadır (içerdikleri şeyin bir koleksiyonu olduğunu yansıtmak için): `entities/`, `usecases/`, `repositories/`, `datasources/`, `models/`, `pages/`, `widgets/`.

---

## 13. State Management Organizasyonu (Riverpod Dosyalarının Konumu)

`ARCHITECTURE.md` Bölüm 5'te tanımlanan Riverpod stratejisinin dosya organizasyonu şu şekilde standardize edilir:

| Provider Katmanı | Dosya Konumu |
|---|---|
| Data katmanı provider'ları (repository/datasource örnekleri) | `features/<feature>/data/repositories/` veya `features/<feature>/presentation/providers/` altında, "data provider" alt grubu olarak |
| Domain katmanı provider'ları (usecase örnekleri) | `features/<feature>/presentation/providers/` altında, "usecase provider" alt grubu olarak |
| Presentation katmanı provider'ları (controller/state) | `features/<feature>/presentation/controllers/` (Notifier/AsyncNotifier sınıfının kendisi) + `features/<feature>/presentation/providers/` (provider tanımı) |

> **Netleştirme:** UseCase ve Repository provider'larının **tanımı** (Riverpod `Provider(...)` bildirimi), katman saflığını bozmamak için `presentation/providers/` altında toplanır — ancak bu, yalnızca "bağımlılığı sağlama" (wiring) sorumluluğudur; UseCase/Repository'nin kendisi hâlâ `domain/` ve `data/` katmanlarında yaşar. Bu ayrım, `ARCHITECTURE.md` Bölüm 5.2'deki "provider katmanlama kuralı"nın dosya organizasyonuna yansımasıdır.

Uygulama genelinde kalıcı olması gereken provider'lar (auth state, tema tercihi — bkz. ARCHITECTURE.md Bölüm 5.3), ilgili feature'ın (`authentication/`, `settings/`) `presentation/providers/` klasöründe tanımlanır ve `app/` seviyesinde (kök widget kurulumunda) tüketilir; bunlar için ayrı bir global "app_providers" klasörü açılmaz — her provider, sorumlu olduğu feature'ın sınırları içinde tanımlı kalır.

---

## 14. Testing Structure

`test/` dizini, `lib/` yapısını **birebir yansıtan** bir ağaç olarak organize edilir — bu, bir kaynak dosyanın testinin nerede olduğunu tahmin etmeyi gereksiz kılar (dosya yolu birebir eşleşir).

```
test/
├── core/                    → core/ altındaki yardımcı/uzantı mantığının unit testleri
├── features/
│   └── <feature_name>/
│       ├── domain/           → UseCase ve Entity unit testleri (framework bağımsız, en yüksek kapsam hedeflenir)
│       ├── data/              → Repository/Mapper unit testleri (sahte datasource'larla)
│       └── presentation/       → Controller/State unit testleri + widget testleri
└── integration/             → Uçtan uca akış testleri (bkz. 14.3)
```

### 14.1 Unit Tests
- `domain/` katmanı testleri, hiçbir mock framework gerektirmeden, saf Dart nesneleriyle çalışır (`ARCHITECTURE.md` Bölüm 14.3 — test edilebilirlik önceliği).
- `data/` katmanı testleri, gerçek Isar/Firestore bağlantısı kurmadan, sahte (fake) datasource implementasyonlarıyla çalışır.

### 14.2 Widget Tests
- Her feature'ın `presentation/widgets/` ve `presentation/pages/` içeriği için, ilgili widget'ın izole render/etkileşim davranışını doğrulayan testler `test/features/<feature>/presentation/` altında organize edilir.
- `shared/` altındaki paylaşılan bileşenler için ayrı bir `test/shared/` klasörü bulunur (feature bazlı tekrar test yerine, bileşen bir kez, merkezi olarak test edilir).

### 14.3 Integration Tests
- `test/integration/`, birden fazla feature'ı bir araya getiren uçtan uca senaryoları organize eder (örn. `PRD.md` Bölüm 4'teki kullanıcı senaryolarının doğrulanması — "görev oluştur → tamamla → istatistiklere yansısın" gibi akışlar).
- Bu klasör, feature bazlı değil **senaryo bazlı** dosya organizasyonu izler (çünkü doğası gereği birden fazla feature'ı kapsar).

---

## 15. Development Rules (Geliştirme Kuralları)

### 15.1 Dosya Boyutu Sınırları
- Bir dosyanın **300 satırı** aşması, o dosyanın sorumluluk açısından gözden geçirilmesi (bölünmesi) için bir sinyal olarak kabul edilir — kesin bir engelleyici kural değil, kod incelemesinde tetiklenen bir "dikkat" eşiğidir.
- `presentation/pages/` altındaki ekran dosyaları, büyük widget ağaçlarını doğrudan barındırmak yerine, alt bileşenleri `presentation/widgets/` altına çıkararak bu sınırın altında kalacak şekilde organize edilir.

### 15.2 Kod Tekrarını Önleme
- Bir mantık parçası (widget, yardımcı fonksiyon, doğrulama kuralı) **iki farklı feature'da** belirdiği anda, bu Bölüm 7.2'deki ortaklık eşiği kuralına göre `shared/` veya `core/`'a taşınır — kopyala-yapıştır ile ilerleme bu projede kabul edilmez.
- Feature içinde tekrar eden mantık (örn. birden fazla ekranda kullanılan bir form doğrulama kuralı), o feature'ın kendi içinde ortak bir noktaya (örn. `domain/` katmanında paylaşılan bir yardımcı) çıkarılır — feature dışına taşınması gerekmez.

### 15.3 Dependency Yönetimi
`ARCHITECTURE.md` Bölüm 10'daki bağımlılık yönü kuralı, klasör yapısında şu şekilde somutlaşır:
```
core/, shared/, services/, config/   ← hiçbir feature'a bağımlı değildir (herkes bunlara bağımlı olabilir)
features/<feature>/domain/           ← hiçbir katmana bağımlı değildir (feature içinde en saf nokta)
features/<feature>/data/             ← yalnızca kendi domain/'ine ve core//services/'e bağımlıdır
features/<feature>/presentation/     ← yalnızca kendi domain/'ine bağımlıdır (data/'ya asla doğrudan bağımlı değildir)
```

### 15.4 Import Düzeni
Her dosyanın import bloğu, aşağıdaki sabit sırayla organize edilir (okunabilirlik ve tutarlılık için):
1. Dart/Flutter SDK import'ları,
2. Harici paket import'ları (`riverpod`, `go_router`, `isar` vb.),
3. `core/` / `shared/` / `services/` / `config/` import'ları,
4. Aynı feature içindeki diğer katman import'ları (örn. Presentation dosyasının kendi Domain'ini import etmesi),
5. Aynı dosyanın bulunduğu klasör içi göreli import'lar.

Bu sıralama, bir dosyanın bağımlılık profilinin (dış SDK mi, iç altyapı mı, kendi feature'ı mı) tek bakışta görülmesini sağlar.

### 15.5 Feature Bağımsızlığı
- `ARCHITECTURE.md` Bölüm 4.1'deki "feature'lar birbirinin Presentation/Data katmanına bağımlı olamaz" kuralı, klasör yapısında şu şekilde denetlenir: `features/<feature_a>/` altındaki hiçbir dosya, `features/<feature_b>/data/` veya `features/<feature_b>/presentation/` klasörlerini import edemez.
- İzin verilen tek cross-feature bağımlılık: `features/<feature_a>/presentation/` → `features/<feature_b>/domain/` (yalnızca dışa açık UseCase/Repository arayüzleri üzerinden, bkz. ARCHITECTURE.md Bölüm 4.1 örneği — Dashboard'un Tasks'ın `GetTodayTasksUseCase`'ini çağırması).
- Bu kural, kod incelemelerinde otomatikleştirilebilir bir lint/analiz kontrolü olarak da düşünülmelidir (gerçek lint kuralı yazımı bu doküman kapsamında değildir).

---

## 16. Sonraki Adımlar

Bu klasör yapısı dokümanı, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Gerçek Flutter proje iskeletinin (`flutter create` sonrası dizin düzenlemesi) oluşturulması,
2. Her feature için ilk boş dosya iskeletlerinin (yalnızca dosya adları, içerik değil) hazırlanması,
3. Lint/analiz kurallarının (import sınırlama, dosya boyutu uyarısı) proje seviyesinde yapılandırılması,
4. İlk feature'ın (önerilen: Authentication, çünkü diğer tüm feature'ların önkoşuludur) geliştirme sprintine alınması.

**Bu doküman kapsamında herhangi bir kod, widget veya gerçek dosya üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
