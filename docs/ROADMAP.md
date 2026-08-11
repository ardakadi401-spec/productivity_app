# ROADMAP.md
## Kişisel Üretkenlik Uygulaması — Profesyonel Geliştirme Yol Haritası

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Flutter Project Manager / Senior Flutter Software Architect / Senior Product Owner / Agile Development Lead
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`, `DATABASE.md`, `FOLDER_STRUCTURE.md`, `STATE_MANAGEMENT.md`, `COMPONENTS.md`, `SCREENS.md`
**Doküman Durumu:** Geliştirme Öncesi Ana Rehber — Kodlama Başlamadan Önce Onaylanmalıdır

> **Kapsam ve Sınırlar:** Bu doküman yalnızca geliştirme yol haritasını, faz sırasını, bağımlılıkları, test planını, kalite kontrol süreçlerini ve yayın hazırlığını tanımlar. Bu doküman kapsamında **hiçbir Flutter kodu, widget, Firebase kurulum adımı veya UI implementasyonu üretilmemiştir**. Referans dokümanlarda alınmış hiçbir mimari, veri modeli, ekran, komponent veya state yönetimi kararı bu doküman içinde değiştirilmemiş, yeniden yorumlanmamış veya genişletilmemiştir. Yeni özellik önerilmemiştir; tüm faz içerikleri PRD Bölüm 9 (MVP Kapsamı) ve ARCHITECTURE.md Bölüm 4 (14 Feature Modülü) ile birebir sınırlıdır.

---

## 0. Yol Haritası Yaklaşımı

### 0.1 Planlama Felsefesi
Geliştirme sırası, üç temel prensibe göre belirlenmiştir:

1. **Alttan yukarıya bağımlılık sırası:** Önce hiçbir feature'a bağımlı olmayan altyapı (Core/Shared, Authentication) kurulur; ardından bağımsız feature'lar (Tasks, Habits), sonra bunlara bağımlı feature'lar (Projects→Tasks ilişkisi, Statistics→Tasks/Habits/Pomodoro) geliştirilir. Bu sıralama `ARCHITECTURE.md` Bölüm 4 ve Bölüm 10'daki bağımlılık tablosuyla birebir uyumludur.
2. **Dikey dilim (vertical slice) yaklaşımı:** Her feature fazında, o feature'ın Domain → Data → Presentation katmanları birlikte tamamlanır (bkz. `ARCHITECTURE.md` Bölüm 14.5 "Sözleşme öncelikli geliştirme" ilkesi — önce Domain, sonra Data ve Presentation). Bir faz, yalnızca UI değil, feature'ın uçtan uca çalışan bir dikey dilimini teslim eder.
3. **Riskli/karmaşık altyapının erken doğrulanması:** Offline-first senkronizasyon mantığı (FAZ 14) kavramsal olarak en riskli bileşen olduğundan, ilk feature'lar (Tasks, Habits) üzerinde erken ve küçük ölçekte doğrulanır; tam kapsamlı senkronizasyon sertleştirmesi ise ayrı bir faz olarak (FAZ 14) tüm feature'lar tamamlandıktan sonra bütünsel şekilde ele alınır.

### 0.2 Faz Numaralandırma Notu
Fazlar sıralı numaralandırılmıştır ancak bu, **her fazın öncekini bekleyen kesin bir su şelalesi (waterfall)** olduğu anlamına gelmez. Bölüm "Bağımlılıklar" başlığı altında her fazın hangi fazların **tamamlanmasını zorunlu**, hangilerinin yalnızca **kısmi/paralel ilerlemeyi** gerektirdiği ayrı ayrı belirtilmiştir. Ayrıntılar için bkz. Bölüm 20 "Bağımlılık Matrisi ve Paralelleştirme Fırsatları".

### 0.3 Referans Doküman — Faz Eşleme Tablosu
| Faz | Birincil Referans Doküman(lar) |
|---|---|
| 1–2 | ARCHITECTURE.md (Bölüm 2, 12, 14), FOLDER_STRUCTURE.md (tümü), STATE_MANAGEMENT.md (Bölüm 1) |
| 3 | PRD.md (Bölüm 5.1, 6.1), SCREENS.md (Bölüm 1.1, 4.1–4.5), STATE_MANAGEMENT.md (Bölüm 4), ARCHITECTURE.md (Bölüm 13.1, 13.5) |
| 4 | SCREENS.md (Bölüm 2, 3), COMPONENTS.md (Bölüm 2), ARCHITECTURE.md (Bölüm 9) |
| 5 | PRD.md (Bölüm 6.4–6.5), DATABASE.md (Bölüm 4–5), SCREENS.md (Bölüm 4.9–4.12), STATE_MANAGEMENT.md (Bölüm 5) |
| 6 | PRD.md (Bölüm 6.3), DATABASE.md (Bölüm 3), SCREENS.md (Bölüm 4.7–4.8), STATE_MANAGEMENT.md (Bölüm 6) |
| 7 | PRD.md (Bölüm 6.6), SCREENS.md (Bölüm 4.13), COMPONENTS.md (Bölüm 8) |
| 8 | PRD.md (Bölüm 6.8), DATABASE.md (Bölüm 7), SCREENS.md (Bölüm 4.14) |
| 9 | PRD.md (Bölüm 6.9), DATABASE.md (Bölüm 6), SCREENS.md (Bölüm 4.15–4.16), COMPONENTS.md (Bölüm 9) |
| 10 | PRD.md (Bölüm 6.11), DATABASE.md (Bölüm 8), SCREENS.md (Bölüm 4.18–4.19) |
| 11 | PRD.md (Bölüm 6.10), DATABASE.md (Bölüm 9), SCREENS.md (Bölüm 4.17) |
| 12 | PRD.md (Bölüm 6.12–6.13), DATABASE.md (Bölüm 10), SCREENS.md (Bölüm 4.20–4.21), COMPONENTS.md (Bölüm 10) |
| 13 | PRD.md (Bölüm 6.7), ARCHITECTURE.md (Bölüm 4.2) |
| 14 | ARCHITECTURE.md (Bölüm 8), DATABASE.md (Bölüm 12) |
| 15 | PRD.md (Bölüm 6.15), ARCHITECTURE.md (Bölüm 13.3–13.5) |
| 16 | FOLDER_STRUCTURE.md (Bölüm 14), STATE_MANAGEMENT.md (Bölüm 13) |
| 17 | ARCHITECTURE.md (Bölüm 12) |
| 18 | PRD.md (Bölüm 8, 11.2) |

---

## FAZ 1 — Project Setup

### Amaç
Geliştirmenin başlayabilmesi için gerekli teknik temeli (proje iskeleti, paketler, Firebase bağlantısı, tema altyapısı, routing ve state management çatısı) `ARCHITECTURE.md` ve `FOLDER_STRUCTURE.md` ile birebir uyumlu şekilde kurmak. Bu faz sonunda hiçbir feature ekranı yoktur; yalnızca boş bir uygulama, doğru klasör iskeletiyle ve doğru paket setiyle, cihazda/emülatörde açılabilir durumdadır.

### Yapılacak İşler
- Flutter proje oluşturma (son stabil sürüm), Android minimum SDK ve hedef SDK kararlarının belgelenmesi.
- `ARCHITECTURE.md` Bölüm 2'de listelenen paketlerin (Riverpod, Go Router, yerel depolama paketi, Firebase Core/Auth/Firestore, Flutter Local Notifications) `pubspec.yaml`'a eklenmesi.
- `FOLDER_STRUCTURE.md` Bölüm 1–11'de tanımlanan üst seviye klasör iskeletinin (core, shared, features, config, routes, services, assets) boş klasörler halinde oluşturulması — bu aşamada hiçbir feature'a özel dosya açılmaz, yalnızca iskelet.
- Firebase projesinin oluşturulması, Android uygulamasının Firebase'e kaydı, `google-services.json` entegrasyonu (yalnızca bağlantı kurulumu; Firestore Rules yazımı bu fazın kapsamında değildir — bkz. FAZ 15).
- Açık/Koyu/AMOLED tema iskeletinin `UI_GUIDELINES.md` Bölüm 3–4'teki renk paleti ve tipografi tanımlarına göre `core/theme` altında kurulması (yalnızca tema tanımı; ekran implementasyonu değil).
- Go Router'ın merkezi router konfigürasyonunun, `ARCHITECTURE.md` Bölüm 9 ve `SCREENS.md` Bölüm 2.2'deki tam route listesine göre iskelet halinde (placeholder ekranlarla) kurulması.
- Riverpod `ProviderScope` kurulumu ve `ARCHITECTURE.md` Bölüm 5'teki provider tipi stratejisinin proje genelinde geçerli kural olarak dokümante edilmesi (lint/convention seviyesinde).
- Temel `.gitignore`, ortam değişkeni yönetimi (varsa `flutter_dotenv` veya benzeri — hassas anahtarların repoya girmemesi) kurulumu.
- CI iskeletinin (build + analyze + test komutlarını çalıştıran temel pipeline) hazırlanması.

### Ön Koşullar
- PRD, UI_GUIDELINES, ARCHITECTURE, DATABASE, FOLDER_STRUCTURE, STATE_MANAGEMENT, COMPONENTS, SCREENS dokümanlarının tamamının onaylanmış olması.
- Flutter SDK, Android SDK, geliştirme ortamının (IDE, emülatör/cihaz) kurulu olması.
- Firebase hesabı ve proje oluşturma yetkisinin mevcut olması.

### Bağımlılıklar
- Hiçbir fazın tamamlanmasını gerektirmez — bu, yol haritasının ilk fazıdır.
- FAZ 2'nin başlayabilmesi için bu fazın tamamlanması zorunludur.

### Tamamlanma Kriterleri
- Proje, boş (placeholder) ekranlarla derlenip bir Android cihaz/emülatörde açılabiliyor.
- `FOLDER_STRUCTURE.md`'deki üst seviye klasör iskeleti eksiksiz mevcut.
- Firebase bağlantısı kuruldu; uygulama açılışında Firebase başlatma hatası vermiyor.
- Tema sistemi (Açık/Koyu) ekranlar arası geçişte hatasız uygulanabiliyor (placeholder ekran üzerinde doğrulama yeterli).
- Router, tüm route path'lerini (23 ekran + auth ekranları) hatasız tanıyor (placeholder hedeflerle).
- CI pipeline, boş projede başarıyla "build + analyze" çalıştırıyor.

### Riskler
- Firebase proje kurulumunda paket adı (`applicationId`) uyuşmazlığı geç fark edilirse ileride yeniden imzalama gerektirebilir — bu risk, fazın başında paket adının kesinleştirilmesiyle azaltılır.
- Paket versiyon uyumsuzlukları (Riverpod, Go Router, yerel depolama paketi arasında) — bu risk, bağımlılık versiyonlarının fazın başında kilitlenmesi (lock) ile azaltılır.
- Yerel depolama paketi seçiminde (Hive/Isar) `ARCHITECTURE.md` ile `DATABASE.md` arasındaki farklılık netleşmeden bağımlılık eklenirse ileride paket değişimi maliyeti doğar — bkz. Bölüm 21 "Açık Kararlar".

### Tahmini Geliştirme Sırası
1. Flutter proje oluşturma ve paket kurulumu
2. Klasör iskeleti oluşturma
3. Tema kurulumu
4. Go Router iskeleti (placeholder ekranlarla)
5. Riverpod kurulumu
6. Firebase bağlantısı
7. CI pipeline iskeleti

### Test Edilmesi Gereken Noktalar
- Uygulama soğuk başlatmada (cold start) hatasız açılıyor mu?
- Firebase başlatma (initialization) hem online hem offline cihazda hata fırlatmıyor mu?
- Tema değişimi (Açık→Koyu) placeholder ekranda anlık ve hatasız uygulanıyor mu?
- Router, tanımsız bir route'a gidildiğinde uygun hata/yönlendirme davranışı gösteriyor mu?
- CI pipeline, kasıtlı bir derleme hatası eklendiğinde başarısız (fail) oluyor mu (pipeline'ın gerçekten kontrol ettiğinin doğrulanması)?

---

## FAZ 2 — Core Infrastructure

### Amaç
`ARCHITECTURE.md` Bölüm 3.4 ve `FOLDER_STRUCTURE.md` Bölüm 2'de tanımlanan Core katmanını, hiçbir feature'a bağımlı olmayacak şekilde kurmak. Bu faz, tüm feature fazlarının (FAZ 5 ve sonrası) üzerine inşa edileceği ortak temeldir.

### Yapılacak İşler
- **Constants:** Uygulama genelinde sabitler (route path sabitleri, Hive/Isar box/collection isimleri, varsayılan değerler — örn. Pomodoro 25/5 dakika) `FOLDER_STRUCTURE.md` Bölüm 2.1 ile uyumlu konumlandırılır.
- **Theme:** FAZ 1'de kurulan tema iskeleti, `UI_GUIDELINES.md` Bölüm 3 (renk), Bölüm 12 (tema kuralları) ile tam kapsamlı tamamlanır — Açık/Koyu/AMOLED üç palet de eksiksiz tanımlanır.
- **Typography:** `UI_GUIDELINES.md` Bölüm 4'teki type scale ve hiyerarşi kuralları, tema sistemine bağlı `TextTheme` olarak kodlanır.
- **Utils/Extensions:** Tarih formatlama, süre formatlama gibi feature-agnostik yardımcılar (`ARCHITECTURE.md` Bölüm 3.5 Shared katmanı ile sınır çizgisi netleştirilerek — gerçekten 2+ feature kullanıyorsa Shared'a, tek feature'a özgüyse o feature'ın içine).
- **Shared Components (iskelet):** `COMPONENTS.md` Bölüm 2–5'teki Layout, Button, Form, Feedback component ailelerinin temel (feature'a özgü olmayan) implementasyonları — Task/Project/Habit'e özgü kartlar bu fazda YAPILMAZ, ilgili feature fazında yapılır.
- **Error Handling:** `ARCHITECTURE.md` Bölüm 7 ve `STATE_MANAGEMENT.md` Bölüm 9'daki standart Result/Failure yaklaşımının Core katmanında somutlaştırılması (Failure tipleri, UseCase dönüş sözleşmesi).
- **Logging:** Geliştirme ve prod ortamları için farklı seviyelerde çalışan merkezi bir loglama mekanizması.
- **Network/Connectivity Servisi:** `ARCHITECTURE.md` Bölüm 8.3'teki senkronizasyon tetikleyicilerinden biri olan bağlantı durumu dinleyicisinin Core seviyesinde temel altyapısı (henüz senkronizasyon mantığına bağlanmadan — bkz. FAZ 14).

### Ön Koşullar
- FAZ 1'in tamamlanmış olması (proje iskeleti, klasör yapısı, tema/router temel kurulumu).

### Bağımlılıklar
- FAZ 1'in tam tamamlanmasını gerektirir.
- FAZ 3 (Authentication) ve sonraki tüm feature fazları, bu fazın (özellikle Error Handling ve Shared Components) tamamlanmasını **zorunlu ön koşul** olarak bekler.

### Tamamlanma Kriterleri
- Core katmanındaki hiçbir dosya, herhangi bir feature klasörünü import etmiyor (`ARCHITECTURE.md` Bölüm 10.2 Kural 3 doğrulaması).
- Failure/Result yaklaşımı, en az bir örnek (dummy) UseCase üzerinde uçtan uca (hata → Failure → UI state) test edilebiliyor.
- Açık/Koyu/AMOLED üç tema, `UI_GUIDELINES.md`'deki kontrast kurallarına (Bölüm 11.2) uygun şekilde görsel olarak doğrulanmış.
- Shared component'lerin ilk seti (AppButton, TextInput, Loading/Empty/Error State, Snackbar, Dialog, Bottom Sheet) Widget seviyesinde bağımsız çalışıyor (herhangi bir feature'a bağlı olmadan bir örnek sayfada gösterilebiliyor).

### Riskler
- Shared katmanına erken/gereksiz component taşınması ("belki ileride lazım olur" — `ARCHITECTURE.md` Bölüm 11.3'te açıkça yasaklanan bir yaklaşım) — mitigasyon: yalnızca en az 2 feature'ın kesin ihtiyaç duyacağı component'ler bu fazda kurulur, geri kalanı ilgili feature fazında feature-local başlar.
- Tema token'larının (renk/typography) sabit değer olarak component'lere gömülmesi — mitigasyon: component review sürecinde token referans kuralı (`COMPONENTS.md` Bölüm 16.4) zorunlu kontrol maddesi yapılır.

### Tahmini Geliştirme Sırası
1. Error Handling (Failure/Result yaklaşımı) — diğer her şeyin üzerine kurulacağı temel
2. Constants
3. Theme + Typography tamamlama
4. Utils/Extensions
5. Shared Components (temel set)
6. Logging
7. Network/Connectivity servisi iskeleti

### Test Edilmesi Gereken Noktalar
- Bir UseCase'in fırlattığı hatanın, Failure tipine doğru şekilde dönüştüğü unit test ile doğrulanıyor mu?
- Shared component'ler, hem Açık hem Koyu temada görsel olarak bozulmadan render ediliyor mu (widget test + manuel görsel kontrol)?
- Bağlantı durumu servisi, uçak modu açma/kapama senaryosunda doğru durum yayınlıyor mu?
- Core katmanında dairesel bağımlılık (circular dependency) veya feature import'u olmadığı statik analiz/lint ile doğrulanıyor mu?

---

## FAZ 3 — Authentication

### Amaç
`ARCHITECTURE.md` Bölüm 4'te bağımsız ("—") olarak işaretlenen tek feature olan Authentication'ı uçtan uca tamamlamak. Bu feature, hiçbir başka feature'a bağımlı değildir ve Router'ın Auth Guard mekanizmasının (`ARCHITECTURE.md` Bölüm 9.2) çalışabilmesi için tüm sonraki fazların önkoşuludur.

### Yapılacak İşler
- Authentication feature'ının Domain katmanı: `AuthRepository` arayüzü, `SignInWithGoogleUseCase`, `SignInWithEmailUseCase`, `RegisterWithEmailUseCase`, `ResetPasswordUseCase`, `SignOutUseCase`, `DeleteAccountUseCase`, oturum durumu sözleşmesi (`STATE_MANAGEMENT.md` Bölüm 4.1).
- Authentication feature'ının Data katmanı: Firebase Authentication SDK sarmalayan Remote Datasource, Repository implementasyonu.
- Splash Screen (`/splash`), Welcome Screen (`/welcome`), Login Screen (`/login`), Register Screen (`/register`), Forgot Password Screen (`/forgot-password`) — `SCREENS.md` Bölüm 4.1–4.5'teki purpose/structure/actions/states tanımlarına birebir uyumlu.
- Google ile Giriş ve E-posta ile Giriş akışlarının PRD Bölüm 5.1'deki user flow'a göre uçtan uca bağlanması.
- Router seviyesinde Auth Guard'ın (`ARCHITECTURE.md` Bölüm 9.2, `SCREENS.md` Bölüm 2.3) gerçek oturum StreamProvider'ına bağlanması — bu fazdan itibaren placeholder yönlendirme yerine gerçek guard aktif olur.
- Oturum durumunun `StreamProvider` ile dinlenmesi (`ARCHITECTURE.md` Bölüm 13.1).

### Ön Koşullar
- FAZ 1 ve FAZ 2'nin tamamlanmış olması (Core Error Handling, Shared Components, Firebase bağlantısı).

### Bağımlılıklar
- FAZ 1 ve FAZ 2'nin tam tamamlanmasını gerektirir.
- FAZ 4 (Application Layout) bu fazın tamamlanmasını zorunlu ön koşul olarak bekler — çünkü Shell'e girebilmek için gerçek Auth Guard gereklidir.
- Tüm sonraki feature fazları (FAZ 5–13), dolaylı olarak bu fazın tamamlanmasına bağımlıdır (korumalı rotalara erişim bu faz olmadan test edilemez).

### Tamamlanma Kriterleri
- Google ile Giriş ve E-posta ile Giriş/Kayıt akışları gerçek Firebase Authentication ile uçtan uca çalışıyor.
- Şifremi unuttum akışı gerçek e-posta gönderimiyle doğrulanmış.
- Oturum kapatıldığında/hesap silindiğinde kullanıcı otomatik olarak Login/Welcome'a yönlendiriliyor.
- Auth Guard, korumalı bir route'a giriş yapmadan erişim denemesinde doğru yönlendirmeyi yapıyor (`SCREENS.md` Bölüm 2.3'teki üç durum: checking/unauthenticated/authenticated).
- PRD Bölüm 8.3'teki "Kimlik doğrulama akışında terk oranı" hedefine katkı sağlayacak şekilde form hataları (`UI_GUIDELINES.md` Bölüm 13 UX Rules ile uyumlu) anlaşılır şekilde gösteriliyor.

### Riskler
- Google Sign-In'in Android tarafında SHA sertifika parmak izi eksikliği nedeniyle çalışmaması — mitigasyon: FAZ 1'de Firebase kurulumu sırasında debug/release SHA anahtarlarının önceden eklenmesi.
- Auth Guard'ın yanlış yapılandırılması, kullanıcıyı sonsuz yönlendirme döngüsüne sokabilir — mitigasyon: üç durumun (checking/unauthenticated/authenticated) her biri için ayrı widget test.
- E-posta doğrulama gereksinimi PRD'de net değilse, kayıt akışı belirsiz kalabilir — mitigasyon: PRD Bölüm 5.1'deki "Doğrulama" adımı, ekranda gösterilen mesajlaşma seviyesinde ele alınır, kapsam dışına çıkılmaz.

### Tahmini Geliştirme Sırası
1. Authentication Domain katmanı (Entity + UseCase + Repository arayüzü)
2. Authentication Data katmanı (Firebase Auth entegrasyonu)
3. Oturum durumu StreamProvider'ı
4. Splash Screen + Auth Guard bağlantısı
5. Welcome Screen
6. Login Screen (Google + E-posta)
7. Register Screen
8. Forgot Password Screen

### Test Edilmesi Gereken Noktalar
- Geçersiz e-posta/şifre girişinde kullanıcıya doğru hata mesajı gösteriliyor mu?
- Google ile giriş iptal edildiğinde (kullanıcı vazgeçtiğinde) uygulama çökmeden Login ekranında kalıyor mu?
- Oturum açıkken uygulama yeniden başlatıldığında (cold start) kullanıcı doğrudan Dashboard'a mı yönleniyor (Login ekranı görünmeden)?
- Hesap silme işlemi sonrası tüm yerel oturum verisi temizleniyor mu?
- Auth Guard, hızlı ardışık navigasyon (rapid navigation) durumunda kararlı davranıyor mu (race condition testi)?

---

## FAZ 4 — Application Layout

### Amaç
`SCREENS.md` Bölüm 2.4 ve 3'te tanımlanan ShellRoute tabanlı ana uygulama kabuğunu (Bottom Navigation, 5 sekme, iç içe navigasyon) kurmak ve Dashboard'un iskeletini oluşturmak. Bu faz, tüm feature ekranlarının (FAZ 5–13) içine yerleşeceği "çerçeveyi" hazırlar; feature'ların kendi iş mantığı bu fazda YAZILMAZ.

### Yapılacak İşler
- ShellRoute kurulumu (`ARCHITECTURE.md` Bölüm 9.3, `SCREENS.md` Bölüm 2.4): 5 sekmeli Bottom Navigation — Dashboard, Projects/Tasks, Calendar, Habits/Goals, Settings (`SCREENS.md` Bölüm 3.2).
- Her sekme için nested navigator kurulumu — bir sekme içinde detay ekranına gidildiğinde diğer sekmelerin durumunun korunması.
- Tab 2 (Projects/Tasks) ve Tab 4 (Habits/Goals) için ikinci seviye Tab Navigation (`COMPONENTS.md` Bölüm 12.1, `SCREENS.md` Bölüm 2.4) — yalnızca navigasyon iskeleti, içerik ilgili feature fazında doldurulur.
- Dashboard Screen (`/dashboard`) iskeletinin `SCREENS.md` Bölüm 4.6 ve Bölüm 5'teki yapıya göre kurulması — bu fazda yalnızca layout ve hızlı erişim kartlarının (Notes, Pomodoro) navigasyon bağlantıları kurulur; gerçek veri (bugünün görevleri, alışkanlık özeti) ilgili feature fazları tamamlandıkça bağlanır (bkz. FAZ 5, FAZ 9 sonunda Dashboard entegrasyon adımı).
- Settings Screen (`/settings`) ve Profile Screen (`/profile`) için navigasyon iskeletinin kurulması — tema seçimi (Açık/Koyu/Sistem) bu fazda gerçek işlevle bağlanır (Core Theme altyapısına bağımlı olduğu için erken bağlanabilir); bildirim tercihleri ve PIN/Biyometri ayarları ilgili fazlarda (FAZ 13, FAZ 15) doldurulur.
- AppBar arama ikonunun (`SCREENS.md` Bölüm 3.3) Search Screen'e (placeholder) yönlendirmesinin kurulması.
- Kilit ekranı (`/lock`) rotasının Shell dışı bağımsız rota olarak iskelet halinde tanımlanması (`ARCHITECTURE.md` Bölüm 9.3) — tam işlevi FAZ 15'te tamamlanır.

### Ön Koşullar
- FAZ 3'ün tamamlanmış olması (gerçek Auth Guard aktif olmalı, çünkü Shell yalnızca korumalı rotalarda erişilir).

### Bağımlılıklar
- FAZ 1, 2 ve 3'ün tam tamamlanmasını gerektirir.
- FAZ 5–13 arasındaki tüm feature fazları, ekranlarını bu fazda kurulan Shell/navigasyon iskeletine yerleştirir; bu nedenle bu faz feature fazlarının tamamı için **zorunlu ön koşuldur**.

### Tamamlanma Kriterleri
- 5 sekme arasında geçiş yapılabiliyor; her sekmenin kendi navigasyon yığını korunuyor (bir sekmede detay ekranına gidip başka sekmeye geçip geri dönüldüğünde önceki ekran durumu korunuyor).
- Tab 2 ve Tab 4'teki ikinci seviye sekmeler (Projeler/Görevler, Alışkanlıklar/Hedefler) geçiş yapabiliyor (içerik boş/placeholder olsa da).
- Dashboard, tema değişiminden ve sekme geçişlerinden etkilenmeden kararlı render ediliyor.
- `UI_GUIDELINES.md` Bölüm 13.6'daki "Dashboard'dan en fazla 2 dokunuş" kuralı, Search/Statistics/Notes/Pomodoro/Profile için navigasyon seviyesinde doğrulanmış.

### Riskler
- Nested navigator yapılandırmasının yanlış kurulması, geri tuşu (back button) davranışında beklenmeyen sonuçlara yol açabilir — mitigasyon: her sekme için manuel geri tuşu senaryosu test edilir.
- Dashboard'un erken aşamada gerçek veriyle değil placeholder ile kurulması, ileride entegrasyon fazında (FAZ 5, 9 sonunda) unutulma riski taşır — mitigasyon: bu roadmap'te ilgili feature fazlarının "Yapılacak İşler" listesine "Dashboard entegrasyonu" maddesi açıkça eklenmiştir.

### Tahmini Geliştirme Sırası
1. ShellRoute ve 5 sekmeli Bottom Navigation iskeleti
2. Nested navigator kurulumu (her sekme için)
3. Tab 2 ve Tab 4 ikinci seviye Tab Navigation iskeleti
4. Dashboard Screen iskeleti (layout + hızlı erişim kart navigasyonları)
5. Settings Screen iskeleti + tema seçimi gerçek entegrasyonu
6. Profile Screen iskeleti
7. Search ikon yönlendirmesi + Kilit ekranı rota iskeleti

### Test Edilmesi Gereken Noktalar
- Sekmeler arası hızlı ardışık geçişte (rapid tab switching) uygulama kararlı kalıyor mu?
- Bir sekmede derinlemesine navigasyon (detay ekranına push) yapıldıktan sonra başka sekmeye geçilip geri dönüldüğünde önceki navigasyon yığını korunuyor mu (widget test)?
- Tema değişimi Dashboard ve Settings ekranlarında anlık yansıyor mu?
- Android sistem geri tuşu, Shell içindeki her sekmede beklenen davranışı gösteriyor mu (ilk sekmeye dönme vs. uygulamadan çıkma)?

---

## FAZ 5 — Task Management

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Projects'e yalnızca opsiyonel bağımlı olarak tanımlanan Tasks feature'ını uçtan uca tamamlamak. Tasks, uygulamanın en sık kullanılan çekirdek feature'ı olduğundan ve Dashboard/Calendar/Goals/Pomodoro/Statistics/Notification/Search gibi 7 farklı feature'ın (`ARCHITECTURE.md` Bölüm 4 tablosu) veri sağlayıcısı konumunda olduğundan, feature fazları arasında ilk sırada ele alınır.

### Yapılacak İşler
- Domain katmanı: `Task` ve `SubTask` entity'leri, `TaskRepository` arayüzü, `CreateTaskUseCase`, `UpdateTaskUseCase`, `DeleteTaskUseCase`, `CompleteTaskUseCase`, `AddSubTaskUseCase`, `GetTodayTasksUseCase` (Dashboard tarafından tüketilecek — `ARCHITECTURE.md` Bölüm 4.1 örneği), görev filtreleme UseCase'leri.
- Data katmanı: Local Datasource (offline-first yazma — FAZ 14'ün tam senkronizasyon sertleştirmesinden önce temel "yerele yaz" davranışı), Remote Datasource (Firestore), `TaskModel`/`SubTaskModel`, Mapper'lar — `DATABASE.md` Bölüm 4–5'teki alan tanımlarına birebir uyumlu.
- Tasks Screen (`/tasks`), Task Detail Screen (`/tasks/:taskId`), Create Task Screen (`/tasks/new`), Edit Task Screen (`/tasks/:taskId/edit`) — `SCREENS.md` Bölüm 4.9–4.12.
- Alt görev (SubTask) CRUD ve üst görev tamamlanma yüzdesinin alt görevlere göre otomatik güncellenmesi (PRD Bölüm 5.3).
- Öncelik (Priority) ve tarih seçimi, Task Filters — `COMPONENTS.md` Bölüm 6 (Task Components).
- Dashboard entegrasyonu: FAZ 4'te iskelet olarak bırakılan Dashboard'un "bugünün görevleri" bölümünün `GetTodayTasksUseCase` ile gerçek veriye bağlanması.
- Hatırlatma (Reminder) alanının veri modeli seviyesinde hazırlanması — gerçek bildirim planlaması FAZ 13'te yapılır; bu fazda yalnızca görevin hatırlatma zamanı bilgisi saklanır.

### Ön Koşullar
- FAZ 1–4'ün tamamlanmış olması.

### Bağımlılıklar
- FAZ 1, 2, 3, 4'ün tam tamamlanmasını gerektirir.
- Projects (FAZ 6) ile opsiyonel ilişki taşıdığından, Tasks'ın proje bağlama alanı Projects feature'ı henüz yokken **null/boş referans olarak** çalışacak şekilde tasarlanır — FAZ 6 tamamlandığında geriye dönük entegre edilir (bkz. FAZ 6 "Yapılacak İşler").
- FAZ 7 (Calendar), FAZ 8 (Goals), FAZ 11 (Pomodoro), FAZ 12 (Statistics), FAZ 13 (Notification), Search feature'ı bu fazın Domain katmanındaki UseCase'lerini salt okunur şekilde tüketir; bu nedenle bu faz onlar için **zorunlu ön koşuldur**.

### Tamamlanma Kriterleri
- Görev CRUD işlemleri (oluştur/düzenle/tamamla/sil) uçtan uca çalışıyor ve Hive/Isar'a hemen yazılıyor.
- Alt görev eklendiğinde/tamamlandığında üst görevin tamamlanma yüzdesi otomatik güncelleniyor.
- Task Filters (öncelik, tarih, proje — proje filtresi FAZ 6 sonrası tam işlevsel) çalışıyor.
- Dashboard, gerçek "bugünün görevleri" verisini gösteriyor.
- `DATABASE.md` Bölüm 4.3'teki `recurrenceRule` alanı veri modelinde mevcut (tekrarlayan görev UI'ı MVP kapsamına göre değerlendirilir — PRD'de tekrarlayan görev ayrı bir madde olarak listelenmemiştir, bu nedenle yalnızca veri modeli uyumluluğu sağlanır, UI zorunlu değildir).

### Riskler
- Alt görev — üst görev tamamlanma yüzdesi hesaplamasının performans maliyeti (her alt görev değişiminde üst görevin yeniden hesaplanması) — mitigasyon: `ARCHITECTURE.md` Bölüm 12.1'deki `select` kullanımı ile yalnızca ilgili görev kartının rebuild edilmesi.
- Projects henüz yokken proje bağlama alanının UI'da yanlış varsayılan davranış göstermesi — mitigasyon: bu alanın FAZ 6 öncesinde UI'da gizli/pasif tutulması, FAZ 6 sonunda açılması.

### Tahmini Geliştirme Sırası
1. Domain katmanı (Task + SubTask entity, UseCase'ler, Repository arayüzü)
2. Data katmanı (Local + Remote Datasource, Model, Mapper)
3. Tasks Screen (liste + filtreleme)
4. Create Task Screen
5. Task Detail Screen
6. Edit Task Screen
7. Alt görev CRUD ve tamamlanma yüzdesi mantığı
8. Dashboard entegrasyonu

### Test Edilmesi Gereken Noktalar
- Görev oluşturma formunda zorunlu alan (başlık) boş bırakıldığında doğru validasyon mesajı gösteriliyor mu?
- Bir alt görev tamamlandığında üst görevin ilerleme yüzdesi doğru hesaplanıyor mu (unit test — sınır durumlar: 0 alt görev, tüm alt görevler tamamlı, kısmi tamamlanma)?
- Görev silindiğinde bağlı alt görevler de tutarlı şekilde temizleniyor mu?
- Dashboard'daki "bugünün görevleri" listesi, tarih değişiminde (gece yarısı geçişi senaryosu) doğru güncelleniyor mu?
- Offline modda oluşturulan görev, UI'da anında görünüyor mu (senkronizasyon beklemeden)?

---

## FAZ 6 — Project Management

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Tasks'a bağımlı (proje altındaki görev sayımı için) olarak tanımlanan Projects feature'ını tamamlamak ve FAZ 5'te opsiyonel/pasif bırakılan proje bağlama alanını aktive etmek.

### Yapılacak İşler
- Domain katmanı: `Project` entity'si, `ProjectRepository` arayüzü, `CreateProjectUseCase`, `UpdateProjectUseCase`, `ArchiveProjectUseCase`, proje ilerleme (progress) hesaplama UseCase'i — bağlı görevlerin tamamlanma oranına göre (`DATABASE.md` Bölüm 3, `PRD.md` Bölüm 9.1).
- Data katmanı: `ProjectModel`, Local/Remote Datasource, Mapper — `DATABASE.md` Bölüm 3.2 alan tanımlarına uyumlu.
- Projects Screen (`/projects`), Project Detail Screen (`/projects/:projectId`) — `SCREENS.md` Bölüm 4.7–4.8; Tab 2'nin "Projeler" alt sekmesi bu fazda gerçek içerikle doldurulur.
- Proje rengi/rozeti (`COMPONENTS.md` Bölüm 7.3 Project Color Badge) ve ilerleme göstergesi (`COMPONENTS.md` Bölüm 7.2) implementasyonu.
- FAZ 5'te pasif bırakılan Task-Project ilişkisinin aktive edilmesi: görev oluşturma/düzenleme formunda proje seçimi, Task Filters'ta proje bazlı filtreleme.
- Proje arşivleme akışı (PRD Bölüm 9.1 "oluştur, düzenle, arşivle").

### Ön Koşullar
- FAZ 5'in tamamlanmış olması (Tasks Domain/Data katmanı ve Repository arayüzü hazır olmalı — Projects'in ilerleme hesaplaması Tasks'ın UseCase'lerini tüketir).

### Bağımlılıklar
- FAZ 1–5'in tam tamamlanmasını gerektirir.
- FAZ 8 (Goals) opsiyonel olarak Tasks üzerinden dolaylı proje bağlamına erişebilir ancak doğrudan Projects'e bağımlı değildir.
- FAZ 10 (Notes) proje bağlama özelliği için bu fazın tamamlanmasını gerektirir.

### Tamamlanma Kriterleri
- Proje CRUD (oluştur/düzenle/arşivle) uçtan uca çalışıyor.
- Proje detay ekranında, o projeye bağlı görevlerin gerçek listesi görüntüleniyor (Tasks Domain UseCase'i üzerinden, doğrudan Data erişimi olmadan — `ARCHITECTURE.md` Bölüm 4.1 kuralı).
- Proje ilerleme yüzdesi, bağlı görevlerin tamamlanma durumuna göre doğru hesaplanıyor ve görev tamamlandığında/eklendiğinde otomatik güncelleniyor.
- Görev oluşturma/düzenleme formunda proje seçimi çalışıyor; Task Filters'ta proje bazlı filtreleme aktif.

### Riskler
- Cross-feature erişim kuralının ihlali riski (Projects'in doğrudan Tasks'ın Data katmanına erişmesi) — mitigasyon: code review'da `ARCHITECTURE.md` Bölüm 14 madde 4 ("Feature bağımsızlığı denetimi") standart kontrol maddesi olarak uygulanır.
- Proje arşivlendiğinde bağlı görevlerin durumu net değilse kullanıcı kafası karışabilir — mitigasyon: PRD kapsamında belirtilmeyen bu detay, arşivleme sonrası görevlerin salt-okunur şekilde görünmeye devam etmesi (silinmemesi) prensibiyle ele alınır — bu, PRD'nin "veri kaybı olmaz" felsefesiyle uyumludur, yeni bir karar değil mevcut ilkenin uygulanmasıdır.

### Tahmini Geliştirme Sırası
1. Domain katmanı (Project entity, UseCase'ler, Repository arayüzü)
2. Data katmanı
3. Projects Screen (liste)
4. Project Detail Screen (bağlı görev listesi + ilerleme göstergesi)
5. Proje oluşturma/düzenleme formu
6. Arşivleme akışı
7. Task-Project ilişkisinin Tasks tarafında aktivasyonu (form + filtre)

### Test Edilmesi Gereken Noktalar
- Proje ilerleme yüzdesi, 0 görevli bir projede hatasız (bölme hatası olmadan) 0% gösteriyor mu?
- Bir görev başka bir projeye taşındığında her iki projenin ilerleme yüzdesi doğru güncelleniyor mu?
- Arşivlenen proje, Projects Screen ana listesinden kalkıp ayrı bir "arşiv" görünümünde erişilebilir kalıyor mu?
- Proje silindiğinde (varsa) bağlı görevlerin referans bütünlüğü bozulmuyor mu (`DATABASE.md` Bölüm 11.3)?

---

## FAZ 7 — Calendar

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Tasks ve Goals'a salt okunur agregasyon ile bağımlı olan Calendar feature'ını tamamlamak.

### Yapılacak İşler
- Domain katmanı: Calendar'ın kendi `CalendarEvent` kavramı (varsa — `DATABASE.md` referanslarına göre) ve Tasks/Goals Domain katmanlarından tarih bazlı veri çeken UseCase'ler (örn. `GetTasksByDateUseCase`, `GetGoalsByDateUseCase`) — doğrudan Tasks/Goals Data katmanına erişim yapılmaz.
- Calendar Screen (`/calendar`) — `SCREENS.md` Bölüm 4.13, PRD Bölüm 6.6: aylık + günlük ajanda görünümü (haftalık görünüm PRD Bölüm 9.2'ye göre MVP+ kapsamındadır, bu fazda YAPILMAZ).
- Takvim bileşenleri: Calendar Header, Day Cell, Event Card, Date Selector — `COMPONENTS.md` Bölüm 8.
- Takvimden doğrudan yeni görev oluşturma akışı (PRD Bölüm 6.6) — Create Task Screen'e seçili tarihle birlikte yönlendirme.
- Tarih bazlı filtreleme (Date Filters).

### Ön Koşullar
- FAZ 5 (Tasks) ve FAZ 8 (Goals) Domain katmanlarının kullanılabilir olması gerekir.

> **Not (sıralama):** Kullanıcının verdiği faz numaralandırmasında Calendar (FAZ 7), Goals'tan (FAZ 8) önce sıralanmıştır; ancak `ARCHITECTURE.md` Bölüm 4 bağımlılık tablosuna göre Calendar, Goals verisine de ihtiyaç duyar. Bu nedenle Calendar fazı **iki alt adımda** ele alınır: (1) Tasks verisiyle takvim görünümünün tamamlanması bu fazda yapılır, (2) Goals verisinin takvime entegrasyonu FAZ 8 tamamlandıktan sonra kısa bir entegrasyon adımı olarak eklenir (bkz. FAZ 8 "Yapılacak İşler" son maddesi). Bu, referans dokümanlardaki hiçbir kararı değiştirmez; yalnızca iki fazın numaralandırma sırasıyla bağımlılık yönü arasındaki farkı yönetim seviyesinde ele alır.

### Bağımlılıklar
- FAZ 5'in tam tamamlanmasını gerektirir (Tasks verisi olmadan takvim boş olur).
- Goals verisiyle tam entegrasyon için FAZ 8'in tamamlanmasını gerektirir (yukarıdaki nota bakınız).

### Tamamlanma Kriterleri
- Aylık görünümde, o aya ait görevlerin olduğu günler görsel olarak işaretleniyor.
- Günlük ajanda görünümünde seçili güne ait tüm görevler (ve FAZ 8 sonrası hedefler) tek listede görüntüleniyor.
- Takvimden "+ yeni görev" ile Create Task Screen'e seçili tarih ön dolu şekilde gidiliyor.
- Tarih filtreleri (bugün, bu hafta, bu ay gibi PRD/SCREENS kapsamında tanımlı olanlar) doğru çalışıyor.

### Riskler
- Aylık görünümde çok sayıda görev/hedef olan günlerde performans sorunu (her hücrenin ağır sorgu yapması) — mitigasyon: `ARCHITECTURE.md` Bölüm 12.4 pagination/lazy loading prensiplerinin ay bazlı veri çekiminde uygulanması (tüm veri yerine görünen ay aralığı sorgulanır).
- Takvim kütüphanesi (varsa üçüncü taraf paket) ile tema sisteminin (Açık/Koyu/AMOLED) uyumsuzluğu — mitigasyon: takvim bileşeninin `UI_GUIDELINES.md` token'larına göre özelleştirilebilir olması erken doğrulanır.

### Tahmini Geliştirme Sırası
1. Domain katmanı (tarih bazlı UseCase'ler — yalnızca Tasks ile)
2. Calendar Screen — aylık görünüm (Tasks verisiyle)
3. Calendar Screen — günlük ajanda görünümü
4. Takvimden görev oluşturma akışı
5. Tarih filtreleri
6. *(FAZ 8 sonrası)* Goals entegrasyonu

### Test Edilmesi Gereken Noktalar
- Ay değiştirildiğinde (ileri/geri) doğru ay verisi yükleniyor mu?
- Görevi olmayan bir günde günlük ajanda boş durumu (Empty State) doğru gösteriyor mu?
- Takvimden oluşturulan görev, seçili tarihle birlikte doğru kaydediliyor mu?
- Zaman dilimi (timezone) farklılıklarında tarih hesaplaması hatalı gün kaymasına yol açıyor mu?

---

## FAZ 8 — Goals

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Tasks'a opsiyonel bağlama ile bağımlı olan Goals feature'ını tamamlamak; Günlük/Haftalık/Aylık hedef yönetimini uçtan uca sunmak.

### Yapılacak İşler
- Domain katmanı: `Goal` entity'si (zaman ölçeği: günlük/haftalık/aylık — `DATABASE.md` Bölüm 7.2), `GoalRepository` arayüzü, `CreateGoalUseCase`, `UpdateGoalProgressUseCase`, dönem sonu otomatik arşivleme UseCase'i.
- Data katmanı: `GoalModel`, Local/Remote Datasource, Mapper.
- Goals Screen (`/goals`) — `SCREENS.md` Bölüm 4.14; Tab 4'ün "Hedefler" alt sekmesi bu fazda gerçek içerikle doldurulur.
- Zaman aralığı seçimi (Günlük/Haftalık/Aylık) arayüzü — PRD Bölüm 5.6.
- İlerleme takibi: manuel işaretleme VEYA bağlı görev tamamlanma oranına göre otomatik hesaplama (PRD Bölüm 5.6, 6.8) — bağlı görev seçildiğinde Tasks Domain UseCase'i üzerinden ilerleme okunur.
- Dönem dolduğunda "Tamamlandı/Tamamlanmadı" otomatik arşivleme mantığı.
- Dashboard entegrasyonu: FAZ 4'te iskelet bırakılan "günlük hedef" özetinin gerçek veriye bağlanması.
- Calendar entegrasyonu: FAZ 7'de not edilen Goals→Calendar entegrasyon adımının bu fazın sonunda tamamlanması.

### Ön Koşullar
- FAZ 5'in tamamlanmış olması (opsiyonel görev bağlama için Tasks Domain katmanı hazır olmalı).

### Bağımlılıklar
- FAZ 1–5'in tam tamamlanmasını gerektirir.
- FAZ 7 (Calendar) ile karşılıklı entegrasyon ilişkisi vardır (bkz. FAZ 7 notu) — bu fazın tamamlanması, Calendar'ın tam kapsamlı hale gelmesi için gereklidir.
- FAZ 12 (Statistics) hedef başarı oranı raporlaması için bu fazın tamamlanmasını gerektirir.

### Tamamlanma Kriterleri
- Üç zaman ölçeğinde (günlük/haftalık/aylık) bağımsız hedef oluşturulabiliyor.
- İlerleme çubuğu (progress bar), hem manuel işaretlemede hem bağlı görev senaryosunda doğru güncelleniyor.
- Dönem süresi dolduğunda hedef otomatik olarak arşivleniyor ve geçmiş hedefler görüntülenebiliyor (PRD Bölüm 6.8).
- Dashboard'daki günlük hedef özeti gerçek veriyle çalışıyor.
- Calendar'da hedefler günlük ajanda görünümünde görüntüleniyor.

### Riskler
- "Dönem dolduğunda otomatik arşivleme" mantığının uygulama arka planda çalışmıyorken (kapalıyken) tetiklenememesi — mitigasyon: arşivleme kontrolünün hem periyodik hem de "uygulama açılışında geçmiş dönem kontrolü" şeklinde çift mekanizmayla ele alınması (bu bir yeni özellik değil, mevcut "otomatik arşivleme" kararının güvenilir şekilde uygulanma yöntemidir).
- Bağlı görev ilerlemesi ile manuel ilerleme arasında kullanıcı kafa karışıklığı — mitigasyon: `UI_GUIDELINES.md` Bölüm 13 UX Rules'a uygun net görsel ayrım (hangi modun aktif olduğunun açıkça gösterilmesi).

### Tahmini Geliştirme Sırası
1. Domain katmanı (Goal entity, UseCase'ler, Repository arayüzü)
2. Data katmanı
3. Goals Screen (zaman aralığı sekmeleri)
4. Hedef oluşturma formu (manuel/bağlı görev seçimi)
5. İlerleme takibi mantığı
6. Dönem sonu otomatik arşivleme
7. Dashboard entegrasyonu
8. Calendar entegrasyonu (FAZ 7 tamamlama)

### Test Edilmesi Gereken Noktalar
- Haftalık bir hedef, hafta sınırında (Pazar/Pazartesi geçişi) doğru dönemde mi kalıyor?
- Bağlı görev tamamlandığında hedef ilerlemesi doğru yüzdeye güncelleniyor mu (unit test)?
- Dönem dolan bir hedef, kullanıcı uygulamayı o gün açmasa bile bir sonraki açılışta doğru arşivleniyor mu?
- Aynı anda birden fazla aktif günlük hedef listelenebiliyor mu (PRD'de sayı sınırı belirtilmemiştir — sınırsız liste senaryosu test edilir)?

---

## FAZ 9 — Habits

### Amaç
`ARCHITECTURE.md` Bölüm 4'te bağımsız ("—") olarak işaretlenen Habits feature'ını tamamlamak; alışkanlık takibi, streak hesaplama ve istatistiklere temel oluşturacak veri üretimini sağlamak.

### Yapılacak İşler
- Domain katmanı: `Habit` ve `HabitRecord` entity'leri (`DATABASE.md` Bölüm 6), `HabitRepository` arayüzü, `CreateHabitUseCase`, `CheckInHabitUseCase`, `CalculateStreakUseCase` (`ARCHITECTURE.md` Bölüm 3.2 örneği).
- Data katmanı: `HabitModel`/`HabitRecordModel`, Local/Remote Datasource, Mapper.
- Habits Screen (`/habits`), Habit Detail Screen (`/habits/:habitId`) — `SCREENS.md` Bölüm 4.15–4.16; Tab 4'ün "Alışkanlıklar" alt sekmesi bu fazda gerçek içerikle doldurulur.
- Alışkanlık oluşturma formu: isim, ikon, tekrar sıklığı (her gün / haftanın belirli günleri) — PRD Bölüm 6.9.
- Günlük check-in arayüzü (Habit Card, Completion Button — `COMPONENTS.md` Bölüm 9).
- Streak sayacı ve en uzun seri kaydının hesaplanması ve gösterimi (Streak Indicator — `COMPONENTS.md` Bölüm 9.2).
- Dashboard entegrasyonu: FAZ 4'te iskelet bırakılan "alışkanlık özeti" bölümünün gerçek veriye bağlanması.

### Ön Koşullar
- FAZ 1–4'ün tamamlanmış olması.

### Bağımlılıklar
- FAZ 1, 2, 3, 4'ün tam tamamlanmasını gerektirir; başka feature'a bağımlı değildir, bu nedenle FAZ 5/6/7/8 ile paralel geliştirmeye uygun bir adaydır (bkz. Bölüm 20 Paralelleştirme Fırsatları).
- FAZ 12 (Statistics) alışkanlık tamamlama oranı raporlaması için, FAZ 13 (Notification) alışkanlık hatırlatmaları için bu fazın tamamlanmasını gerektirir.

### Tamamlanma Kriterleri
- Alışkanlık CRUD işlemleri uçtan uca çalışıyor.
- Günlük check-in işaretlendiğinde/geri alındığında streak sayacı doğru güncelleniyor.
- En uzun seri (longest streak) kaydı, güncel streak sıfırlansa bile korunuyor.
- Dashboard'daki alışkanlık özeti, günün alışkanlıklarını ve tamamlanma durumunu gerçek veriyle gösteriyor.

### Riskler
- Streak hesaplama mantığının "haftanın belirli günleri" tekrar tipinde yanlış gün atlaması sayması — mitigasyon: `CalculateStreakUseCase` için tekrar tipine göre ayrı ayrı kapsamlı unit test senaryoları (bkz. FAZ 9 Test Edilmesi Gereken Noktalar).
- Zaman dilimi/gün değişimi sınırında (gece yarısı) check-in durumunun yanlış güne yazılması — mitigasyon: `DATABASE.md` Bölüm 6.4'teki streak hesaplama mantığının cihaz yerel saatine göre net gün sınırı tanımlaması.

### Tahmini Geliştirme Sırası
1. Domain katmanı (Habit + HabitRecord entity, UseCase'ler, Repository arayüzü)
2. Data katmanı
3. Habits Screen (liste + günlük check-in)
4. Alışkanlık oluşturma formu (tekrar sıklığı seçimi)
5. Habit Detail Screen (streak geçmişi)
6. Streak hesaplama mantığının kapsamlı testi
7. Dashboard entegrasyonu

### Test Edilmesi Gereken Noktalar
- "Her gün" tekrar tipinde bir gün atlandığında streak doğru sıfırlanıyor mu?
- "Haftanın belirli günleri" tekrar tipinde, alışkanlığın olmadığı bir gün streak'i bozmuyor mu (unit test — kritik iş kuralı)?
- Bir check-in geri alındığında (yanlışlıkla işaretlenen bir günün düzeltilmesi) streak doğru yeniden hesaplanıyor mu?
- En uzun seri, güncel seri sıfırlandıktan sonra da korunuyor mu?
- Dashboard'daki alışkanlık özeti, gece yarısı geçişinde (yeni gün başladığında) doğru sıfırlanıyor/güncelleniyor mu?

---

## FAZ 10 — Notes

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Projects ve Tasks'a opsiyonel bağımlı olan Notes feature'ını tamamlamak.

### Yapılacak İşler
- Domain katmanı: `Note` entity'si (`DATABASE.md` Bölüm 8), `NoteRepository` arayüzü, `CreateNoteUseCase`, `UpdateNoteUseCase`, `DeleteNoteUseCase`, `LinkNoteToProjectOrTaskUseCase`.
- Data katmanı: `NoteModel`, Local/Remote Datasource, Mapper.
- Notes Screen (`/notes`), Note Detail Screen (`/notes/:noteId`) — `SCREENS.md` Bölüm 4.18–4.19; Dashboard hızlı erişim kartından ("Yeni Not") ve Project/Task Detail ekranlarından erişim (`SCREENS.md` Bölüm 3.3) bu fazda gerçek bağlantıyla kurulur.
- Serbest metin not oluşturma (başlık + içerik), basit biçimlendirme (kalın, madde işareti — PRD Bölüm 6.11'de belirtilen sınırlı kapsamla, zengin metin editörü YAPILMAZ).
- Etiketleme ve renk kodlama (PRD Bölüm 6.11, `DATABASE.md` Bölüm 1.5 Categories/Tags konumu).
- Proje veya göreve not bağlama (opsiyonel) — Project Detail ve Task Detail ekranlarına not bağlantı noktası eklenmesi.

### Ön Koşullar
- FAZ 5 (Tasks) ve FAZ 6 (Projects) Domain katmanlarının kullanılabilir olması (opsiyonel bağlama için).

### Bağımlılıklar
- FAZ 1–6'nın tam tamamlanmasını gerektirir (bağlama alanları için Tasks ve Projects Domain katmanları hazır olmalı).
- FAZ 12 (Statistics/Search) not içeriğinin arama indeksine dahil edilmesi için bu fazın tamamlanmasını gerektirir.

### Tamamlanma Kriterleri
- Not CRUD işlemleri uçtan uca çalışıyor.
- Etiketleme ve renk kodlama Notes Screen'de filtrelenebilir/görüntülenebilir durumda.
- Bir not, bir projeye veya göreve bağlandığında hem Not Detay ekranında hem ilgili Project/Task Detail ekranında bağlantı görünüyor.
- Basit biçimlendirme (kalın, madde işareti) Not Detay ekranında doğru render ediliyor.

### Riskler
- Not-Proje/Görev bağlama ilişkisinin çift yönlü tutarlılığının (not silindiğinde Project/Task tarafındaki referansın da temizlenmesi) gözden kaçması — mitigasyon: `DATABASE.md` Bölüm 11.3 Referans Bütünlüğü Yaklaşımı'nın bu ilişkide de birebir uygulanması.
- Basit biçimlendirmenin ileride "zengin metin editörü" beklentisine kayması (kapsam kayması riski) — mitigasyon: PRD Bölüm 7'deki "Zengin metin editörü... kapsamı MVP'de sınırlı" ifadesinin geliştirme sırasında referans alınması, kapsam dışına çıkılmaması.

### Tahmini Geliştirme Sırası
1. Domain katmanı (Note entity, UseCase'ler, Repository arayüzü)
2. Data katmanı
3. Notes Screen (liste + etiket/renk filtreleme)
4. Not oluşturma/düzenleme formu (başlık + içerik + basit biçimlendirme)
5. Note Detail Screen
6. Proje/Görev bağlama entegrasyonu (çift yönlü)
7. Dashboard "Yeni Not" hızlı erişim entegrasyonu

### Test Edilmesi Gereken Noktalar
- Boş başlıklı bir not kaydedilmeye çalışıldığında doğru validasyon uygulanıyor mu (`DATABASE.md` Bölüm 14.2 zorunlu alan kuralları)?
- Bir not birden fazla etiketle filtrelendiğinde doğru kesişim/birleşim mantığı çalışıyor mu?
- Bağlı olduğu görev silindiğinde not, referans hatası vermeden "bağlantısız" duruma geçiyor mu?
- Uzun not içeriğinde (`DATABASE.md` Bölüm 14.3 maksimum uzunluk standartları) sınır aşıldığında kullanıcıya uygun geri bildirim veriliyor mu?

---

## FAZ 11 — Pomodoro

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Tasks'a opsiyonel bağlama ile bağımlı olan Pomodoro feature'ını tamamlamak.

### Yapılacak İşler
- Domain katmanı: `PomodoroSession` entity'si (`DATABASE.md` Bölüm 9), `PomodoroRepository` arayüzü, `StartPomodoroSessionUseCase`, `CompletePomodoroSessionUseCase`, `LinkSessionToTaskUseCase`.
- Data katmanı: `PomodoroSessionModel`, Local/Remote Datasource, Mapper.
- Pomodoro Screen (`/pomodoro`) — `SCREENS.md` Bölüm 4.17; Dashboard hızlı erişim kartından ("Pomodoro Başlat") ve Task Detail ekranındaki "Pomodoro ile Çalış" eyleminden erişim (`SCREENS.md` Bölüm 3.3).
- Standart 25/5 dakika döngüsü ve kullanıcı tarafından özelleştirilebilir süre (PRD Bölüm 6.10).
- Zamanlayıcı durumunun `NotifierProvider` ile senkron state yönetimi (`ARCHITECTURE.md` Bölüm 5 tablosu — Pomodoro zamanlayıcı durumu örneği).
- Arka planda çalışmaya devam eden zamanlayıcı mantığı (uygulama arka plana alındığında sayaç kaybolmamalı).
- Oturumu bir göreve bağlama (opsiyonel) — Task Detail ekranından başlatılan oturumlarda otomatik bağlama.
- Tamamlanan oturum sayısının kaydedilmesi (istatistiklere veri sağlamak üzere — gerçek görselleştirme FAZ 12'de).

### Ön Koşullar
- FAZ 5 (Tasks) Domain katmanının kullanılabilir olması (opsiyonel görev bağlama için).
- FAZ 4'ün tamamlanmış olması (Dashboard hızlı erişim kartı bağlantı noktası için).

### Bağımlılıklar
- FAZ 1–5'in tam tamamlanmasını gerektirir.
- FAZ 12 (Statistics) toplam pomodoro süresi/oturum sayısı raporlaması için, FAZ 13 (Notification) oturum bitiş bildirimi için bu fazın tamamlanmasını gerektirir.

### Tamamlanma Kriterleri
- 25/5 dakika döngüsü doğru çalışıyor; kullanıcı süreyi özelleştirebiliyor.
- Zamanlayıcı, uygulama arka plana alınıp geri getirildiğinde doğru kalan süreyi gösteriyor (kaybolmuyor, sıfırlanmıyor).
- Oturum bir göreve bağlandığında Task Detail ekranında oturum geçmişi görünüyor.
- Tamamlanan her oturum kayıt altına alınıyor.

### Riskler
- Flutter'da arka planda zamanlayıcı devamlılığı, Android'in pil optimizasyonu/Doze modu nedeniyle kesintiye uğrayabilir — bu risk PRD Bölüm 11.2'de zaten "kullanıcıya açıkça belirtilmelidir" şeklinde kabul edilmiştir; mitigasyon: zamanlayıcının gerçek bitiş zamanını (wall-clock hedef zaman) baz alarak hesaplanması, saniye sayacına değil hedef zamana göre kalan süreyi türetmesi — böylece arka planda askıya alınsa dahi öne gelindiğinde doğru süre gösterilir.
- Oturum sırasında uygulama tamamen kapatılırsa (kill) yarım kalan oturumun durumu — mitigasyon: oturum başlangıcında "pending" durumda yerel kayıt oluşturulması, tamamlanmayan oturumların istatistiklerde ayrı sınıflandırılması (yeni özellik değil, mevcut senkronizasyon/durum modelinin (`syncStatus` benzeri) doğal uzantısı).

### Tahmini Geliştirme Sırası
1. Domain katmanı (PomodoroSession entity, UseCase'ler, Repository arayüzü)
2. Data katmanı
3. Zamanlayıcı state yönetimi (NotifierProvider)
4. Pomodoro Screen (zamanlayıcı UI)
5. Arka plan devamlılığı doğrulaması
6. Göreve bağlama entegrasyonu
7. Dashboard ve Task Detail hızlı erişim entegrasyonu

### Test Edilmesi Gereken Noktalar
- Zamanlayıcı, uygulama 10+ dakika arka planda kaldıktan sonra doğru kalan süreyi mi gösteriyor?
- Oturum manuel olarak iptal edildiğinde istatistiklere yanlış "tamamlandı" kaydı düşmüyor mu?
- Ekran döndürüldüğünde (varsa) veya tema değiştirildiğinde zamanlayıcı sıfırlanmıyor mu (state kaybı testi)?
- Bir göreve bağlı oturum, o görev silindiğinde geçmiş kayıtta tutarlı kalıyor mu (referans bütünlüğü)?

---

## FAZ 12 — Statistics

### Amaç
`ARCHITECTURE.md` Bölüm 4'te Tasks, Habits, Pomodoro, Goals'a salt okunur agregasyonla bağımlı olan Statistics feature'ını tamamlamak. Bu faz, tüm veri üreten feature'lar (FAZ 5–11) tamamlandıktan sonra ele alınır çünkü agregasyon yapacak veri olmadan anlamlı geliştirilemez. Search feature'ı (`ARCHITECTURE.md` Bölüm 4, #11 — Tasks/Projects/Notes/Habits'e salt okunur bağımlı) da aynı bağımlılık profiline sahip olduğundan bu fazda birlikte ele alınır.

### Yapılacak İşler
- **Statistics:** Domain katmanı: `StatisticsSnapshot` kavramı (`DATABASE.md` Bölüm 10 — Hesaplanmış Anlık Görüntü/Snapshot yaklaşımı), tamamlanan görev sayısı, alışkanlık tamamlama oranı, toplam pomodoro süresi/oturum sayısı, hedef başarı oranı UseCase'leri — her biri ilgili feature'ın Domain UseCase'lerini salt okunur şekilde çağırır.
- Data katmanı: Snapshot hesaplamalarının `ARCHITECTURE.md` Bölüm 12.3'teki "belirli tetikleyicilerde yeniden hesaplama" prensibine göre önbelleklenmesi.
- Statistics Screen (`/statistics`) — `SCREENS.md` Bölüm 4.20; Dashboard'daki haftalık özetin "Tümünü Gör" bağlantısından erişim (`SCREENS.md` Bölüm 3.3).
- Grafik bileşenleri: Progress Bar, Circular Progress, Chart Container, Statistic Summary Card — `COMPONENTS.md` Bölüm 10.
- Görev/alışkanlık/pomodoro için günlük/haftalık/aylık grafik görselleştirmeleri (PRD Bölüm 6.12).
- **Search:** Domain katmanı: birleşik arama UseCase'i — Tasks, Projects, Notes, Habits Domain katmanlarını salt okunur şekilde sorgulayan (`ARCHITECTURE.md` Bölüm 4 tablosu #11).
- Search Screen (`/search`) — `SCREENS.md` Bölüm 4.21; AppBar arama ikonundan erişim (FAZ 4'te iskelet bırakılan yönlendirmenin gerçek işlevle bağlanması).
- Anahtar kelime ve filtre (tür, tarih) bazlı arama, son aramalar geçmişi (PRD Bölüm 6.13).

### Ön Koşullar
- FAZ 5, 6, 8, 9, 10, 11'in tamamlanmış olması (agregasyon/arama yapılacak tüm feature'ların Domain katmanları hazır olmalı).

### Bağımlılıklar
- FAZ 5 (Tasks), FAZ 8 (Goals), FAZ 9 (Habits), FAZ 11 (Pomodoro)'nun tam tamamlanmasını gerektirir (Statistics için).
- FAZ 5 (Tasks), FAZ 6 (Projects), FAZ 9 (Habits), FAZ 10 (Notes)'un tam tamamlanmasını gerektirir (Search için).
- Bu faz, yukarıdaki tüm feature fazları tamamlanmadan **anlamlı şekilde başlatılamaz** — yol haritasında en geç başlayabilecek feature fazıdır (Notification hariç).

### Tamamlanma Kriterleri
- Statistics Screen'de görev/alışkanlık/pomodoro/hedef verileri doğru grafiklerle gösteriliyor.
- Snapshot hesaplamaları, ham veri her değiştiğinde değil tanımlı tetikleyicilerde (ekrana giriş, gün değişimi) yenileniyor.
- Search Screen, dört feature'daki (Tasks/Projects/Notes/Habits) verilerde birleşik arama yapabiliyor.
- Son aramalar geçmişi kaydediliyor ve gösteriliyor.
- Dashboard'daki "Tümünü Gör" bağlantısı Statistics Screen'e doğru yönleniyor.

### Riskler
- Çoklu feature'dan agregasyon yapan Statistics UseCase'lerinin performans maliyeti (çok sayıda Domain çağrısı) — mitigasyon: `ARCHITECTURE.md` Bölüm 12.3'teki önbellekleme stratejisinin sıkı uygulanması, her ekran girişinde ham veriden yeniden hesaplama yapılmaması.
- Search'ün büyüyen veri setinde (görev+not+alışkanlık+proje toplamı) yavaşlaması — mitigasyon: `ARCHITECTURE.md` Bölüm 12.4 pagination prensibinin arama sonuçlarına da uygulanması.
- Cross-feature agregasyonun yanlışlıkla feature'ların Data katmanına doğrudan erişmesi (izolasyon ihlali) — mitigasyon: code review'da standart kontrol maddesi (`ARCHITECTURE.md` Bölüm 14 madde 4).

### Tahmini Geliştirme Sırası
1. Statistics Domain katmanı (agregasyon UseCase'leri)
2. Snapshot önbellekleme mekanizması
3. Statistics Screen (grafik bileşenleri ile)
4. Search Domain katmanı (birleşik arama UseCase'i)
5. Search Screen (filtreleme + son aramalar)
6. Dashboard "Tümünü Gör" entegrasyonu
7. AppBar arama ikonu gerçek entegrasyonu

### Test Edilmesi Gereken Noktalar
- Hiçbir veri olmayan (yeni kullanıcı) senaryoda Statistics Screen çökmeden Empty State gösteriyor mu?
- Grafiklerdeki sayısal değerler, ilgili feature'daki gerçek kayıt sayısıyla birebir eşleşiyor mu (entegrasyon testi)?
- Snapshot önbelleği, gün değişiminde (gece yarısı) doğru yenileniyor mu?
- Arama sonuçları, dört feature'dan gelen farklı tiplerdeki sonuçları doğru şekilde ayırt edilebilir gösteriyor mu (tür etiketi/ikonu)?
- Büyük veri setinde (örn. 500+ görev) arama sonucu makul sürede (`PRD.md` Bölüm 8.1 performans kriterleriyle uyumlu) dönüyor mu?

---

## FAZ 13 — Notifications

### Amaç
`ARCHITECTURE.md` Bölüm 4.2'de "diğer feature'lar tarafından tüketilen bir altyapı servisi" olarak tanımlanan Notification feature'ını tamamlamak ve Tasks/Habits/Pomodoro'da önceki fazlarda veri modeli seviyesinde hazır bırakılan hatırlatma alanlarını gerçek bildirimlere bağlamak.

### Yapılacak İşler
- Domain katmanı: `ScheduleNotificationUseCase`, `CancelNotificationUseCase` (`ARCHITECTURE.md` Bölüm 4.2) — Tasks, Habits, Pomodoro feature'ları bu UseCase'leri tüketir, tersi değil.
- Data katmanı: Flutter Local Notifications SDK sarmalayan servis implementasyonu.
- Görev son tarihi/saati yaklaştığında hatırlatma — FAZ 5'te veri modeli seviyesinde hazır bırakılan alanın bu fazda gerçek planlamaya bağlanması.
- Alışkanlık hatırlatmaları (kullanıcı tanımlı saat) — FAZ 9'daki alışkanlık oluşturma formuna hatırlatma saati alanının bu fazda gerçek işlevle eklenmesi.
- Pomodoro oturum bitiş bildirimi — FAZ 11'deki zamanlayıcının bitişinde gerçek bildirim tetiklenmesi.
- Bildirim `payload` alanının ilgili route path'ini taşıyacak şekilde planlanması ve bildirime dokunulduğunda router'ın bu path'e yönlendirilmesi (`ARCHITECTURE.md` Bölüm 9.4 Deep Link Hazırlığı — gerçek deep link kurulumu değil, yalnızca bildirim içi yönlendirme).
- Android bildirim izni akışının kullanıcıya açık şekilde sunulması (PRD Bölüm 11.2).
- Settings Screen'deki bildirim tercihlerinin (FAZ 4'te iskelet bırakılan) bu fazda gerçek işlevle bağlanması.

### Ön Koşullar
- FAZ 5 (Tasks), FAZ 9 (Habits), FAZ 11 (Pomodoro)'nun tamamlanmış olması (hatırlatma tetikleyecek veri modelleri hazır olmalı).
- FAZ 4'ün tamamlanmış olması (Settings Screen iskeleti).

### Bağımlılıklar
- FAZ 1–4'ün ve FAZ 5, 9, 11'in tam tamamlanmasını gerektirir.
- Bu faz, kendisine bağımlı bir sonraki feature fazı olmadığından, FAZ 12 (Statistics) ile paralel geliştirmeye uygun bir adaydır (bkz. Bölüm 20).

### Tamamlanma Kriterleri
- Görev, alışkanlık ve pomodoro bildirimleri planlanan zamanda gerçek cihazda görüntüleniyor.
- Bir bildirime dokunulduğunda uygulama açılıp ilgili ekrana (örn. `/tasks/:taskId`) doğru yönleniyor.
- Görev/alışkanlık silindiğinde/değiştirildiğinde ilgili planlanan bildirim iptal ediliyor veya güncelleniyor.
- Bildirim izni reddedildiğinde uygulama çökmeden, özellik kullanılamaz durumda net şekilde bilgilendiriyor (PRD Bölüm 8.3).

### Riskler
- Android pil optimizasyonu/üretici bazlı arka plan kısıtlamaları (özellikle bazı Android OEM'lerinde) nedeniyle planlanan bildirimlerin gecikmesi/tetiklenmemesi — bu risk PRD Bölüm 11.2'de kabul edilmiştir; mitigasyon: kullanıcıya pil optimizasyonu istisnası eklemesi için (varsa) yönlendirme, ancak bu tamamen platform kısıtı olduğundan %100 garanti verilemeyeceği QA aşamasında belgelenir.
- Çok sayıda planlanmış bildirimin (görev + alışkanlık + pomodoro toplamda) sistem limitine (Android'in planlanabilir bildirim sayısı sınırı) yaklaşması — mitigasyon: yalnızca yakın gelecekteki (örn. önümüzdeki 7 gün) hatırlatmaların aktif planlanması, geri kalanının tetikleyici bazlı yeniden planlanması.
- Bildirim payload'ının router'a yanlış path taşıması, uygulamanın hatalı ekrana yönlenmesine yol açabilir — mitigasyon: payload formatının route path sabitleriyle (FAZ 2 Constants) birebir eşleştirilmesi ve widget/entegrasyon testiyle doğrulanması.

### Tahmini Geliştirme Sırası
1. Notification Domain katmanı (Schedule/Cancel UseCase'leri)
2. Data katmanı (Flutter Local Notifications entegrasyonu)
3. Android bildirim izni akışı
4. Görev hatırlatma entegrasyonu (FAZ 5 alanının aktivasyonu)
5. Alışkanlık hatırlatma entegrasyonu (FAZ 9 alanının aktivasyonu)
6. Pomodoro bitiş bildirimi entegrasyonu (FAZ 11 alanının aktivasyonu)
7. Bildirim payload → router yönlendirme
8. Settings Screen bildirim tercihleri entegrasyonu

### Test Edilmesi Gereken Noktalar
- Planlanan bir görev hatırlatması, görev tamamlandığında otomatik iptal ediliyor mu?
- Görevin tarihi değiştirildiğinde eski bildirim iptal edilip yeni tarihe göre yeniden mi planlanıyor?
- Uygulama tamamen kapatılmışken (arka planda bile değil) planlanan bildirim tetikleniyor mu (gerçek cihaz testi zorunlu, emülatör yetersiz kalabilir)?
- Bildirime dokunulduğunda, uygulama kapalıyken (cold start) ve açıkken (foreground) her iki durumda da doğru ekrana yönleniyor mu?
- Bildirim izni sonradan (Ayarlar üzerinden) iptal edildiğinde uygulama bunu algılayıp kullanıcıyı bilgilendiriyor mu?

---

## FAZ 14 — Offline First

### Amaç
`ARCHITECTURE.md` Bölüm 8 ve `DATABASE.md` Bölüm 12'de tanımlanan offline-first veri akışını, FAZ 5–13 boyunca her feature'da "temel yerele yaz" seviyesinde uygulanan davranışın üzerine, **tam kapsamlı ve bütünsel senkronizasyon mantığıyla** sertleştirmek: tüm feature'lar için tutarlı `syncStatus` yönetimi, çakışma çözümleme ve senkronizasyon durumu görünürlüğü.

### Yapılacak İşler
- Her feature'ın Repository implementasyonunda, `ARCHITECTURE.md` Bölüm 8.2'deki yazma/okuma akış modelinin (Hive/Isar'a hemen yaz → UI güncelle → arka planda Firestore'a gönder) tüm 14 feature genelinde **tutarlı** şekilde uygulandığının doğrulanması ve eksik kalan feature'larda tamamlanması.
- `DATABASE.md` Bölüm 12.2'deki `syncStatus`, `lastSyncedAt`, `localUpdatedAt` meta-alanlarının tüm modellerde standart şekilde mevcut olduğunun doğrulanması.
- Senkronizasyon tetikleyicilerinin (`ARCHITECTURE.md` Bölüm 8.3: app resume, offline→online geçişi, opsiyonel periyodik senkronizasyon) merkezi bir senkronizasyon servisinde toplanması.
- Çakışma çözümleme (Last-Write-Wins, `ARCHITECTURE.md` Bölüm 8.4, `DATABASE.md` Bölüm 12.4 madde 4) mantığının tüm feature'larda tutarlı uygulanması.
- Soft delete mekanizmasının (`DATABASE.md` Bölüm 13.4) tüm modellerde standart uygulanması ve senkronizasyon sırasında "bulunamadı" hatası yerine tutarlı işlenmesi.
- Senkronizasyon durumu göstergesinin (`ARCHITECTURE.md` Bölüm 8.5, PRD Bölüm 6.17) Settings/Dashboard ekranında (senkronize/bekleniyor/hata) gösterilmesi.
- `statisticsSnapshots` için "son N dönem" (örn. son 90 gün) yerel tutma, daha eskisi için talep üzerine Firestore'dan çekme mantığının (`DATABASE.md` Bölüm 12.3) uygulanması.

### Ön Koşullar
- FAZ 5–13 arasındaki tüm feature fazlarının tamamlanmış olması (her feature'ın kendi temel offline-first davranışı zaten kurulu olmalı — bu faz onu bütünsel hale getirir, sıfırdan kurmaz).

### Bağımlılıklar
- FAZ 3 ile FAZ 13 arasındaki tüm fazların tamamlanmasını gerektirir.
- FAZ 15 (Security) senkronizasyon durumu göstergesinin Settings ekranında görünmesi için bu fazla yakın koordinasyon gerektirir ancak kritik blokaj oluşturmaz.
- FAZ 16 (Testing) ve FAZ 17 (Optimization), bu fazın tamamlanmasını zorunlu ön koşul olarak bekler (senkronizasyon mantığı olmadan uçtan uca entegrasyon testleri ve performans optimizasyonu eksik kalır).

### Tamamlanma Kriterleri
- Uçak modunda tüm CRUD işlemleri (14 feature genelinde) kesintisiz çalışıyor.
- Bağlantı geri geldiğinde bekleyen (`pendingCreate`/`pendingUpdate`/`pendingDelete`) tüm kayıtlar otomatik, kullanıcı müdahalesi olmadan senkronize oluyor (PRD Bölüm 6.16).
- Aynı kaydın iki farklı cihazda çakışan değişikliklerinde Last-Write-Wins kuralı doğru uygulanıyor.
- Senkronizasyon durumu göstergesi gerçek zamanlı olarak (senkronize/bekleniyor/hata) doğru durumu yansıtıyor.
- PRD Bölüm 8.1'deki "offline'dan online'a senkronizasyon başarı oranı %99+" hedefine yönelik ölçüm altyapısı (loglama üzerinden) mevcut.

### Riskler
- Bu fazın "sonradan bütünsel sertleştirme" olarak ele alınması, önceki fazlarda feature'lar arası tutarsız offline davranışların geç fark edilmesi riskini taşır — mitigasyon: her feature fazının (FAZ 5–13) kendi "Test Edilmesi Gereken Noktalar" bölümünde offline senaryo zaten test edilmiştir; bu faz yalnızca bütünleştirme ve sertleştirmedir, sıfırdan offline davranış eklemek değildir.
- Yerel depolama paketi (Hive/Isar) kararının bu faza kadar netleşmemiş olması, senkronizasyon servisinin paket-bağımlı detaylarında geç değişiklik riski taşır — mitigasyon: bkz. Bölüm 21 "Açık Kararlar", bu kararın FAZ 1'de kesinleştirilmesi önerilir.
- Çakışma çözümleme testinin çoklu cihaz gerektirmesi (tek cihazda simüle etmek zordur) — mitigasyon: iki farklı emülatör/cihaz veya zaman damgası manipülasyonuyla kontrollü test senaryoları hazırlanır.

### Tahmini Geliştirme Sırası
1. Tüm feature'ların Repository implementasyonlarının offline-first tutarlılık denetimi (audit)
2. Merkezi senkronizasyon servisi (tetikleyiciler)
3. Çakışma çözümleme mantığının merkezi/tutarlı hale getirilmesi
4. Soft delete standardizasyonu
5. Senkronizasyon durumu göstergesi (Settings/Dashboard UI entegrasyonu)
6. Statistics snapshot yerel tutma sınırı (son N dönem) mantığı
7. Uçtan uca offline→online senaryo testleri (tüm feature'lar)

### Test Edilmesi Gereken Noktalar
- Uçak modunda 5 farklı feature'da (Task, Habit check-in, Note, Pomodoro oturumu, Goal ilerlemesi) art arda işlem yapılıp bağlantı geri geldiğinde tümü doğru senkronize oluyor mu?
- İki farklı cihazda aynı görev farklı şekilde düzenlendiğinde, daha yeni `updatedAt` değerine sahip versiyon kazanıyor mu (entegrasyon testi)?
- Silinen bir kayıt, başka bir cihazda senkronizasyon sırasında hata fırlatmadan tutarlı şekilde işleniyor mu?
- Senkronizasyon sırasında bağlantı aniden kesilirse (yarım senkronizasyon), veri bütünlüğü bozulmadan bir sonraki bağlantıda kaldığı yerden devam ediyor mu?
- Senkronizasyon durumu göstergesi, "hata" durumunda kullanıcıya anlamlı bir sonraki adım (yeniden dene) sunuyor mu?

---

## FAZ 15 — Security

### Amaç
PRD Bölüm 6.15 ve `ARCHITECTURE.md` Bölüm 13'te tanımlanan güvenlik mimarisini (PIN, Biyometrik, Firestore güvenlik prensipleri) tamamlamak; FAZ 4'te iskelet halinde bırakılan `/lock` rotasını tam işlevsel hale getirmek.

### Yapılacak İşler
- Settings feature'ının Domain katmanında `VerifyPinUseCase` (`ARCHITECTURE.md` Bölüm 13.3) ve biyometrik doğrulama sonucu değerlendirme UseCase'i.
- PIN kodunun düz metin saklanmadan, güvenli yerel depolama mekanizmasıyla (platform seviyesinde şifrelenmiş depolama) saklanması.
- Biyometrik doğrulamanın platformun kendi güvenli API'sine devredilmesi; desteklenmeyen cihazlarda otomatik PIN fallback (`ARCHITECTURE.md` Bölüm 13.4).
- Kilit ekranının (`/lock`) tam işlevsel hale getirilmesi: uygulama arka plana alınıp geri dönüldüğünde kilit ekranının zorunlu kılınması (`ARCHITECTURE.md` Bölüm 13.5, PRD Bölüm 5.7).
- Settings Screen'de kilit özelliğinin açılıp kapatılabilmesi (varsayılan: kapalı — PRD Bölüm 6.15).
- Firestore Security Rules'un gerçek yazımı: her kullanıcının verisinin kendi `userId`'sine göre izole edilmesi kuralının sunucu tarafında zorunlu kılınması (`ARCHITECTURE.md` Bölüm 13.2 — bu doküman kapsamında yalnızca mimari prensip tanımlanmıştı, gerçek Rules yazımı bu fazda yapılır).
- İstemci tarafı sorguların aktif kullanıcının `userId`'si ile filtrelenmesinin tüm feature Remote Datasource'larında doğrulanması (denetim/audit).

### Ön Koşullar
- FAZ 3 (Authentication)'ın tamamlanmış olması (oturum durumu, kullanıcı kimliği hazır olmalı).
- FAZ 4 (Application Layout)'ın tamamlanmış olması (kilit ekranı rota iskeleti hazır olmalı).
- FAZ 14 (Offline First)'in mümkünse tamamlanmış olması önerilir (senkronizasyon durumu göstergesiyle aynı Settings ekranında bir arada geliştirileceği için — zorunlu değil, önerilen paralel/ardışık sıralama).

### Bağımlılıklar
- FAZ 3 ve FAZ 4'ün tam tamamlanmasını gerektirir.
- FAZ 16 (Testing) ve FAZ 18 (Release), bu fazın tamamlanmasını zorunlu ön koşul olarak bekler — Play Store yayını, güvenlik/gizlilik gereksinimleri tamamlanmadan yapılamaz (PRD Bölüm 11.2).

### Tamamlanma Kriterleri
- PIN kodu ayarlandığında, uygulama arka plandan dönüşte veya yeniden açılışta kilit ekranı zorunlu gösteriliyor.
- Biyometrik doğrulama desteklenen cihazlarda çalışıyor; desteklenmeyen/iptal edilen durumda PIN'e otomatik düşülüyor.
- Firestore Security Rules, bir kullanıcının başka bir kullanıcının verisine erişemediğini (hem okuma hem yazma) doğrulayacak şekilde yazılmış ve test edilmiş.
- Kilit özelliği kapalıyken uygulama hiçbir ek adım istemeden normal akışta çalışıyor (varsayılan davranış bozulmuyor).

### Riskler
- Firestore Rules'un yanlış yazılması, ya aşırı kısıtlayıcı (kullanıcı kendi verisine erişemez) ya da aşırı gevşek (başka kullanıcının verisi sızar) olma riski taşır — mitigasyon: Firebase Emulator Suite ile Rules'un otomatik test senaryolarıyla (hem "izin verilmeli" hem "izin verilmemeli" durumları) doğrulanması zorunlu kılınır.
- Biyometrik API'nin cihazlar arası (farklı Android üretici/versiyon) tutarsız davranışı — mitigasyon: en az 2–3 farklı gerçek cihazda/Android sürümünde manuel doğrulama.
- PIN'in güvensiz şekilde (örn. düz SharedPreferences'ta) saklanması riski — mitigasyon: code review'da bu madde standart kontrol maddesi yapılır (`ARCHITECTURE.md` Bölüm 13.3 doğrudan referans alınarak).

### Tahmini Geliştirme Sırası
1. Firestore Security Rules yazımı ve Emulator Suite ile test edilmesi
2. PIN güvenli saklama altyapısı
3. `VerifyPinUseCase` ve kilit ekranı iş mantığı
4. Biyometrik doğrulama entegrasyonu + PIN fallback
5. Kilit ekranının arka plan/ön plan geçiş tetikleyicisine bağlanması
6. Settings Screen'de kilit açma/kapama arayüzü
7. İstemci sorgu filtreleme denetimi (tüm feature'lar)

### Test Edilmesi Gereken Noktalar
- Yanlış PIN art arda girildiğinde uygulama uygun şekilde (kilitleme/bekleme gibi PRD'de tanımlıysa) davranıyor mu?
- Biyometrik doğrulama iptal edildiğinde (kullanıcı vazgeçtiğinde) PIN ekranına doğru düşülüyor mu?
- Uygulama arka planda çok kısa süre kaldığında (örn. bildirim çubuğunu açıp kapatma) gereksiz yere kilit ekranı tetiklenmiyor mu (PRD/Architecture'da tanımlı eşik varsa ona uyum)?
- Firestore Emulator testinde, kullanıcı A'nın kullanıcı B'nin görev koleksiyonuna okuma/yazma denemesi reddediliyor mu?
- Kilit özelliği kapalıyken, uygulama arka plandan dönüşte hiçbir ek ekran göstermeden doğrudan kaldığı yerden devam ediyor mu?

---

## FAZ 16 — Testing

### Amaç
`FOLDER_STRUCTURE.md` Bölüm 14 ve `STATE_MANAGEMENT.md` Bölüm 13'te tanımlanan test stratejisini, tüm feature'lar (FAZ 5–13) ve altyapı sertleştirmeleri (FAZ 14–15) tamamlandıktan sonra bütünsel şekilde uygulamak. Not: birim seviyesi testler zaten her feature fazının "Test Edilmesi Gereken Noktalar" bölümünde ilgili fazda yazılmıştır; bu faz **kapsamı tamamlama, boşlukları kapatma ve entegrasyon/uçtan uca testleri** ekleme fazıdır.

### Yapılacak İşler
- **Unit Tests:** Her feature'ın Domain katmanındaki (Entity, UseCase) test kapsamının denetlenmesi ve eksiklerin tamamlanması — `ARCHITECTURE.md` Bölüm 14 madde 3 uyarınca Domain katmanı mock framework gerektirmeden saf unit testlerle doğrulanabilir olmalıdır.
- **Widget Tests:** Shared component'lerin (FAZ 2) ve her feature'ın kritik ekranlarının (liste, form, detay) widget testlerinin tamamlanması.
- **Integration Tests:** `FOLDER_STRUCTURE.md` Bölüm 14.3'e uygun olarak, feature'lar arası uçtan uca senaryoların (örn. "görev oluştur → projeye bağla → tamamla → istatistiklerde gör" gibi çok adımlı akışlar) test edilmesi.
- Auth Guard, senkronizasyon, çakışma çözümleme gibi FAZ 3/14'te işlenen kritik akışların entegrasyon testleriyle bir kez daha, tüm feature'lar tamamlanmış haliyle doğrulanması.
- Test kapsamı (coverage) raporlamasının CI pipeline'a entegre edilmesi.
- Bilinen test kapsamı dışı alanların (`STATE_MANAGEMENT.md` Bölüm 13.4) dokümante edilmesi (örn. gerçek cihaz bildirim testleri, biyometrik donanım testleri — bunlar manuel QA'ya devredilir).

### Ön Koşullar
- FAZ 5–15 arasındaki tüm fazların tamamlanmış olması (tüm feature'lar ve altyapı hazır olmalı — kapsamlı entegrasyon testi eksik feature ile yapılamaz).

### Bağımlılıklar
- FAZ 3 ile FAZ 15 arasındaki tüm fazların tamamlanmasını gerektirir.
- FAZ 17 (Optimization) ve FAZ 18 (Release), bu fazın tamamlanmasını zorunlu ön koşul olarak bekler.

### Tamamlanma Kriterleri
- Domain katmanı genelinde tanımlı bir minimum test kapsamı hedefine (bkz. Bölüm 19 Kodlama Standartları) ulaşılmış.
- Kritik kullanıcı akışlarının (auth, görev CRUD, offline→online senkronizasyon, kilit ekranı) her biri için en az bir entegrasyon testi mevcut.
- CI pipeline, her pull request'te otomatik olarak testleri çalıştırıp sonucu raporluyor.
- Bilinen test boşlukları (manuel QA'ya devredilenler) açıkça listelenmiş ve QA sürecine (FAZ 18) aktarılmış.

### Riskler
- Testlerin geliştirmenin sonuna bırakılması, geç aşamada büyük hacimde hata bulunması riskini taşır — mitigasyon: bu faz yalnızca **tamamlama** fazıdır; asıl unit test disiplini her feature fazında (FAZ 5–13) "Test Edilmesi Gereken Noktalar" bölümü üzerinden zaten uygulanmış olmalıdır; bu fazda büyük hacimde sıfırdan test yazılıyorsa bu, önceki fazlarda test disiplininin atlandığının bir göstergesidir ve süreç seviyesinde ayrıca ele alınmalıdır.
- Entegrasyon testlerinin Firebase gerçek bağlantısına ihtiyaç duyması, testlerin yavaş/kararsız (flaky) olma riski — mitigasyon: mümkün olduğunca Firebase Emulator Suite kullanımı.

### Tahmini Geliştirme Sırası
1. Domain katmanı unit test kapsamı denetimi ve tamamlama (tüm feature'lar)
2. Widget test kapsamı denetimi ve tamamlama
3. Kritik akışlar için entegrasyon testleri
4. CI pipeline'a coverage raporlama entegrasyonu
5. Test kapsamı dışı alanların dokümantasyonu

### Test Edilmesi Gereken Noktalar
- CI pipeline, kasıtlı olarak bozulan bir teste karşı doğru şekilde başarısız oluyor mu (pipeline'ın gerçekten çalıştığının doğrulanması)?
- "Görev oluştur → projeye bağla → tamamla → istatistiklerde gör" gibi çok adımlı bir entegrasyon senaryosu baştan sona hatasız geçiyor mu?
- Offline→online senkronizasyon entegrasyon testi, bağlantı simülasyonuyla (mock connectivity) tutarlı sonuç veriyor mu?
- Test kapsamı raporu, Domain katmanında tanımlı minimum eşiğin altına düşen bir feature olduğunda bunu görünür kılıyor mu?

---

## FAZ 17 — Optimization

### Amaç
`ARCHITECTURE.md` Bölüm 12'de tanımlanan performans standartlarının, tüm feature'lar ve altyapı tamamlandıktan sonra **gerçek kullanım koşullarında** (gerçek veri hacmi, gerçek cihazlar) doğrulanması ve gerekli iyileştirmelerin yapılması. Not: performans standartları her feature fazında zaten "tasarım aşamasında" (`ARCHITECTURE.md` Bölüm 15 madde 9) göz önünde bulundurulmuştur; bu faz **doğrulama ve ince ayar** fazıdır, sıfırdan performans mimarisi kurma fazı değildir.

### Yapılacak İşler
- **Widget Rebuild Optimizasyonu:** `select` kullanımının tüm liste ekranlarında (Tasks, Habits, Notes, Projects) tutarlı uygulandığının profiling araçlarıyla doğrulanması (`ARCHITECTURE.md` Bölüm 12.1).
- **Memory Management:** `autoDispose` kullanımının denetlenmesi, Stream aboneliklerinin (Firestore/Isar dinleyicileri) sızıntı yapmadığının (`ref.onDispose`) doğrulanması (`ARCHITECTURE.md` Bölüm 12.2).
- **Caching:** Isar/Hive önbellek katmanının gerçek veri hacmiyle (örn. yüzlerce görev, alışkanlık kaydı) performans testi.
- **Lazy Loading & Pagination:** Uzun listelerin (görev geçmişi, not listesi, istatistik geçmişi) sayfalama davranışının gerçek veriyle doğrulanması (`ARCHITECTURE.md` Bölüm 12.4).
- Soğuk başlatma (cold start) süresinin PRD Bölüm 8.1'deki "2 saniyenin altında" hedefine göre ölçülmesi ve gerekirse iyileştirilmesi.
- Animasyonların (`UI_GUIDELINES.md` Bölüm 9) gerçek cihazlarda (özellikle düşük-orta segment Android cihazlar) akıcılığının (frame rate) doğrulanması.
- Loading state'lerinin (Shared Component — FAZ 2) her ekranda tutarlı ve gecikmesiz gösterildiğinin denetimi.

### Ön Koşullar
- FAZ 5–16 arasındaki tüm fazların tamamlanmış olması (gerçek performans ölçümü, tüm feature'lar ve test altyapısı tamamlanmadan anlamlı yapılamaz).

### Bağımlılıklar
- FAZ 3 ile FAZ 16 arasındaki tüm fazların tamamlanmasını gerektirir.
- FAZ 18 (Release), bu fazın tamamlanmasını zorunlu ön koşul olarak bekler (PRD Bölüm 8.1'deki kalite kriterleri yayın öncesi doğrulanmalıdır).

### Tamamlanma Kriterleri
- Soğuk başlatma süresi, en az orta segment bir Android cihazda ölçülmüş ve 2 saniye hedefinin altında.
- Görev/not/istatistik gibi uzun listelerde kaydırma (scroll) performansı, gerçek veri hacmiyle (örn. 500+ kayıt) kabul edilebilir seviyede (takılma/jank olmadan).
- Bellek sızıntısı (memory leak) profiling aracıyla taranmış ve tespit edilen sızıntılar giderilmiş.
- Widget rebuild sayısı, liste ekranlarında profiling ile ölçülmüş ve gereksiz rebuild'ler `select` ile azaltılmış.

### Riskler
- Performans sorunlarının yalnızca gerçek veri hacminde ortaya çıkması (geliştirme sırasında az veriyle test edildiği için geç fark edilmesi) — mitigasyon: bu fazda kasıtlı olarak büyük hacimli test verisi (seed data) ile ölçüm yapılması.
- Optimizasyon sırasında mimari kararların (`ARCHITECTURE.md`) ihlal edilmesi riski (örn. performans için katman atlama) — mitigasyon: her optimizasyonun code review'da mimari uyumluluk açısından da değerlendirilmesi; performans, mimari prensiplerin (`ARCHITECTURE.md` Bölüm 15 madde 9) yerine geçmez, onunla birlikte uygulanır.

### Tahmini Geliştirme Sırası
1. Profiling araçlarıyla mevcut durumun (baseline) ölçülmesi
2. Widget rebuild optimizasyonu denetimi ve düzeltmeleri
3. Memory management denetimi ve düzeltmeleri
4. Caching/pagination gerçek veriyle doğrulama
5. Soğuk başlatma süresi ölçümü ve iyileştirme
6. Animasyon akıcılığı doğrulama (gerçek cihaz)
7. Son ölçüm turu ve sonuçların dokümante edilmesi

### Test Edilmesi Gereken Noktalar
- 500+ görev içeren bir listede kaydırma sırasında frame drop oranı kabul edilebilir seviyede mi (profiling raporu)?
- Uygulama 30+ dakika açık kaldığında (özellikle Statistics/Calendar ekranları arası geçişte) bellek kullanımı sürekli artıyor mu (sızıntı belirtisi)?
- Düşük-orta segment bir cihazda soğuk başlatma süresi hedef altında mı?
- `autoDispose` işaretli provider'lar, ilgili ekrandan çıkıldığında gerçekten bellekten temizleniyor mu (profiling doğrulaması)?

---

## FAZ 18 — Release

### Amaç
PRD Bölüm 8 (Başarı Kriterleri) ve Bölüm 11.2 (Kısıtlar)'de tanımlanan yayın kriterlerini karşılayarak uygulamayı Play Store'a yayınlanabilir hale getirmek.

### Yapılacak İşler
- **Android Build:** Release imzalama anahtarının (keystore) güvenli şekilde oluşturulması/saklanması, release build konfigürasyonunun (ProGuard/R8, versiyon kodu/adı) hazırlanması.
- **Play Store Assets:** Uygulama ikonu, ekran görüntüleri (Açık/Koyu tema ikisi de gösterilecek şekilde önerilir), tanıtım grafiği/videosu (varsa) — `UI_GUIDELINES.md`'deki tasarım diliyle tutarlı.
- **Store Listing:** Uygulama açıklaması, kategori seçimi, anahtar kelimeler — PRD Bölüm 1 (Yönetici Özeti) ve Bölüm 2.4 (Ürün Değerleri: AI yok, premium yok, reklam yok) mesajının listing metnine doğru yansıtılması.
- **Privacy Policy:** PRD Bölüm 11.2'deki "Play Store politikalarına tam uyum" gereksinimine göre gizlilik politikası metninin hazırlanması — hangi verilerin (Firebase Authentication, Firestore'da saklanan kişisel üretkenlik verisi) toplandığının, üçüncü taraf reklam/analitik SDK'sı **kullanılmadığının** (PRD Bölüm 2.4) açıkça belirtilmesi.
- Play Store Veri Güvenliği Formu'nun (Data Safety) doldurulması.
- İzin (permission) kullanımının (bildirim, biyometrik) gerekçeleriyle birlikte Store Listing'de/politika metninde açıklanması.
- **Final QA:** Tüm PRD Bölüm 8.1 (ürün kalitesi) kriterlerinin son bir tam regresyon turuyla doğrulanması; kritik/blocker seviye hataların sıfırlanması.
- Hesap silme akışının (PRD Bölüm 6.1, Google Play politikası gereği zorunlu) uçtan uca son kez doğrulanması.
- Kapalı test (internal/closed testing) sürümünün yayınlanıp, gerçek kullanıcı geri bildirimiyle son bir doğrulama turu yapılması (önerilir, PRD'de zorunlu kılınmamıştır ancak Play Store yayın sürecinin doğal bir parçasıdır).

### Ön Koşullar
- FAZ 1–17 arasındaki tüm fazların tamamlanmış olması.

### Bağımlılıklar
- Yol haritasındaki tüm önceki fazların (FAZ 1–17) tam tamamlanmasını gerektirir — bu, yol haritasının son fazıdır.

### Tamamlanma Kriterleri
- Release build, imzalı ve Play Store'a yüklenebilir `.aab` formatında hazır.
- Privacy Policy ve Data Safety Formu, gerçek veri toplama/kullanım davranışını birebir yansıtacak şekilde eksiksiz.
- Final QA turunda kritik/blocker seviye açık hata bulunmuyor.
- PRD Bölüm 8.1'deki crash-free rate ve cold start hedefleri, kapalı test sürecinde gözlemlenen verilerle (varsa) uyumlu.
- Store Listing, PRD'nin "AI yok, premium yok, reklam yok, takım çalışması yok" ilkelerini (Bölüm 2.4) yanlış yönlendirici olmayan şekilde yansıtıyor.

### Riskler
- Play Store inceleme sürecinde gizlilik/veri güvenliği formu ile gerçek uygulama davranışı arasında tutarsızlık tespit edilirse yayın reddi/gecikmesi riski — mitigasyon: formun doldurulması sırasında her feature fazında (özellikle FAZ 3 Authentication, FAZ 14 Firebase senkronizasyonu) gerçekten toplanan veri tipinin tek tek çapraz kontrol edilmesi.
- Release imzalama anahtarının kaybı/güvenlik ihlali, gelecekteki güncellemelerin yayınlanamaz hale gelmesi riski taşır — mitigasyon: keystore'un güvenli, yedekli (birden fazla güvenli konumda) saklanması ve Play App Signing kullanımının değerlendirilmesi.
- Son anda (release öncesi) bulunan kritik bir hata, yayın takvimini geciktirebilir — mitigasyon: Final QA'nın yayın tarihinden yeterli tampon süre önce planlanması.

### Tahmini Geliştirme Sırası
1. Release imzalama ve build konfigürasyonu
2. Privacy Policy ve Data Safety Formu hazırlığı
3. Play Store Assets (ikon, ekran görüntüleri, açıklama)
4. Store Listing metni
5. Final QA (tam regresyon turu)
6. Kapalı test sürümü yayını ve geri bildirim toplama (önerilir)
7. Production yayın

### Test Edilmesi Gereken Noktalar
- Release build (debug değil) üzerinde tüm kritik akışlar (auth, CRUD, offline/online, bildirim, kilit) bir kez daha uçtan uca çalışıyor mu (release konfigürasyonuna özgü sorunlar — örn. ProGuard/R8 kaynaklı kırılmalar — debug build'de görünmeyebilir)?
- Uygulama, Play Store'un hedef SDK/izin politikalarına (güncel Android sürüm gereksinimleri) uyumlu mu?
- Hesap silme işlemi, hem yerel hem Firestore verisini eksiksiz temizliyor mu (son kez doğrulama)?
- Farklı ekran boyutu/yoğunluğunda (küçük telefon, tablet gibi varsa) temel akışlar bozulmadan çalışıyor mu?
- Crash-free rate ölçümü için crash raporlama altyapısının (varsa Firebase Crashlytics — bu doküman kapsamında karar verilmemiştir, teknik implementasyon aşamasında değerlendirilir) kurulu ve veri toplar durumda olduğu doğrulanıyor mu?

---

## 19. Kodlama Standartları

### 19.1 Genel Prensipler
- Tüm kod, `ARCHITECTURE.md` Bölüm 14 (Best Practices) ve Bölüm 15 (Geliştirme Kuralları)'nde tanımlanan SOLID, Immutability, Dependency Rule kurallarına eksiksiz uyar.
- Dosya ve klasör isimlendirmesi `FOLDER_STRUCTURE.md` Bölüm 12'deki kurallarla birebir tutarlı olmalıdır.
- Component isimlendirmesi `COMPONENTS.md` Bölüm 16'daki dosya/sınıf/varyant isimlendirme kurallarına uyar.
- Sabit değerler (renk, boşluk, süre) doğrudan koda gömülmez; her zaman `UI_GUIDELINES.md`/`ARCHITECTURE.md` Core katmanındaki token/constant referansları kullanılır (`COMPONENTS.md` Bölüm 16.4).

### 19.2 Dart/Flutter Kod Kalitesi
- `flutter analyze` sıfır uyarı/hata ile geçmelidir; her PR'da CI bu kontrolü otomatik yapar.
- Resmi `dart format` biçimlendirmesi zorunludur; biçimlendirme tartışması code review'da yer almaz (otomatik uygulanır).
- Her public sınıf/metod, sorumluluğunu açıklayan kısa bir doc comment içerir (özellikle Domain katmanındaki UseCase'ler için — `ARCHITECTURE.md` Bölüm 14 madde 3 test edilebilirlik önceliğini destekler).
- Fonksiyon/metod uzunluğu ve dosya boyutu, `FOLDER_STRUCTURE.md` Bölüm 15.1'deki dosya boyutu sınırlarına uyar; aşan dosyalar mantıklı alt parçalara bölünür.
- İmport düzeni `FOLDER_STRUCTURE.md` Bölüm 15.4'teki sıralamaya (dart core → flutter → paketler → proje içi, katman sırasına göre) uyar.

### 19.3 Test Kapsamı Minimum Eşikleri
- Domain katmanı (Entity + UseCase): hedef %90+ satır kapsamı — framework bağımsız olduğu için bu seviye maliyetsizdir (`ARCHITECTURE.md` Bölüm 14 madde 3).
- Data katmanı (Repository implementasyonu, Mapper): hedef %70+ satır kapsamı.
- Presentation katmanı (widget/provider): kritik kullanıcı akışlarını kapsayan widget testleri zorunlu; tam satır kapsamı hedeflenmez (widget test maliyeti/fayda dengesi gözetilir).

### 19.4 Yasaklı Pratikler
- Domain katmanında `flutter`, `firebase_*`, `hive`/`isar` importu (`ARCHITECTURE.md` Bölüm 15 madde 2).
- Presentation'ın Data katmanı sınıflarını doğrudan import etmesi (`ARCHITECTURE.md` Bölüm 15 madde 1).
- Bir feature'ın başka bir feature'ın Data/Presentation katmanına erişmesi (`ARCHITECTURE.md` Bölüm 4.1).
- Ham exception'ların Presentation katmanına sızması — her UseCase Result/Failure döner (`ARCHITECTURE.md` Bölüm 15 madde 6).
- Sabit/hardcoded renk, boşluk, string değerlerin widget içine gömülmesi.

---

## 20. Bağımlılık Matrisi ve Paralelleştirme Fırsatları

### 20.1 Zorunlu Ardışık Fazlar
FAZ 1 → FAZ 2 → FAZ 3 → FAZ 4 → FAZ 5 zinciri kesinlikle ardışıktır; her biri bir sonrakinin zorunlu ön koşuludur.

### 20.2 Paralelleştirmeye Uygun Fazlar
FAZ 4 tamamlandıktan sonra, aşağıdaki feature fazları **birbirine doğrudan bağımlı olmadıkları için** birden fazla geliştirici/ekip tarafından paralel yürütülebilir:
- FAZ 5 (Tasks) — diğerlerinin çoğunun ön koşulu olduğundan mümkünse önce başlanmalı.
- FAZ 9 (Habits) — bağımsız, FAZ 5 ile paralel başlayabilir.
- FAZ 6 (Projects) — yalnızca FAZ 5'e bağımlı, FAZ 5 tamamlanır tamamlanmaz başlayabilir, FAZ 9 ile paralel yürüyebilir.
- FAZ 7 (Calendar) ve FAZ 8 (Goals) — FAZ 5 tamamlandıktan sonra paralel başlayabilir (bkz. FAZ 7 notu — Calendar'ın Goals entegrasyonu FAZ 8 sonrasına sarkar).
- FAZ 10 (Notes) ve FAZ 11 (Pomodoro) — FAZ 5–6 tamamlandıktan sonra paralel başlayabilir.
- FAZ 13 (Notification) — FAZ 5/9/11 tamamlandıktan sonra FAZ 12 (Statistics) ile paralel yürüyebilir (bkz. FAZ 13 Bağımlılıklar).

### 20.3 Zorunlu Toplanma Noktaları (Senkronizasyon Noktaları)
- FAZ 12 (Statistics/Search), FAZ 5/6/8/9/10/11'in **tümünün** tamamlanmasını bekleyen bir toplanma noktasıdır.
- FAZ 14 (Offline First), FAZ 5–13'ün **tümünün** tamamlanmasını bekleyen bir toplanma noktasıdır.
- FAZ 16 (Testing), FAZ 15'in de tamamlanmasını bekler.
- FAZ 17 ve FAZ 18 tamamen ardışıktır ve önceki her fazı bekler.

---

## 21. Açık Kararlar (Bu Doküman Kapsamında Çözülmeyen)

Bu bölüm, referans dokümanlar arasında tespit edilen ve bu roadmap dokümanının **kapsamı dışında olduğu için çözmediği** bir netleştirme ihtiyacını şeffaf şekilde kayıt altına alır (yeni bir karar alınmamıştır, mevcut durum tespit edilmiştir):

- **Yerel depolama paketi (Hive vs Isar):** `ARCHITECTURE.md` Bölüm 2 ve Bölüm 8.6, yerel depolama katmanı olarak **Hive**'ı esas alır. `DATABASE.md` Bölüm 12, proje talimatı gereği **Isar**'ı esas alır ve Bölüm 12.5'te bu farkı açıkça not ederek "nihai paket seçiminin teknik implementasyon aşamasında netleştirileceğini" belirtir. Bu roadmap dokümanı bu kararı **almaz**; yalnızca FAZ 1 "Paket kurulumu" adımında bu kararın **kesinleştirilmesi gerektiğini** bir ön koşul olarak işaretler. Karar, teknik implementasyon (kodlama) fazına geçmeden önce, ARCHITECTURE.md ve DATABASE.md dokümanlarının sahipleri tarafından netleştirilmelidir.

---

## 22. Git Branch Stratejisi

### 22.1 Ana Branch'ler
| Branch | Amaç |
|---|---|
| `main` | Play Store'a yayınlanmış/yayınlanmaya hazır, her zaman kararlı kod. Doğrudan commit yasaktır. |
| `develop` | Aktif geliştirmenin birleştiği entegrasyon branch'i. Her zaman derlenebilir ve temel akışlarda çalışır durumda tutulur. |

### 22.2 Çalışma Branch'leri
| Branch Öneki | Kullanım | Örnek |
|---|---|---|
| `feature/` | Bir faz veya faz içi bir feature modülünün geliştirilmesi | `feature/faz5-task-management`, `feature/tasks-subtask-crud` |
| `fix/` | `develop` veya `main` üzerinde tespit edilen hata düzeltmesi | `fix/habit-streak-calculation` |
| `refactor/` | Davranış değişikliği içermeyen kod iyileştirmesi | `refactor/task-repository-cleanup` |
| `chore/` | Bağımlılık güncelleme, CI/CD, dokümantasyon gibi kod-dışı işler | `chore/update-riverpod-version` |
| `hotfix/` | `main` üzerinde yayın sonrası acil düzeltme | `hotfix/crash-on-empty-project` |

### 22.3 Branch Kuralları
- Her `feature/` branch'i `develop`'tan türetilir ve tamamlandığında `develop`'a Pull Request ile birleştirilir — doğrudan merge yasaktır, code review (bkz. Bölüm 25) zorunludur.
- `hotfix/` branch'leri `main`'den türetilir, hem `main`'e hem `develop`'a birleştirilir (her iki branch'in de düzeltmeyi alması için).
- Bir faz tamamlandığında (örn. FAZ 5 Task Management), o faza ait tüm `feature/` branch'leri `develop`'a birleşmiş olmalı ve `develop` üzerinde faz sonu regresyon kontrolü yapılmalıdır.
- `main`'e birleşme yalnızca FAZ 18 (Release) kapsamında, Final QA sonrasında yapılır.

---

## 23. Commit Mesaj Standartları

Conventional Commits formatı esas alınır: `<tip>(<kapsam>): <kısa açıklama>`

### 23.1 Commit Tipleri
| Tip | Kullanım |
|---|---|
| `feat` | Yeni bir özellik/ekran/UseCase eklenmesi |
| `fix` | Hata düzeltmesi |
| `refactor` | Davranış değişikliği içermeyen kod iyileştirmesi |
| `test` | Test ekleme/düzenleme |
| `docs` | Yalnızca dokümantasyon değişikliği |
| `chore` | Bağımlılık, konfigürasyon, CI/CD değişikliği |
| `style` | Biçimlendirme (format) değişikliği, davranış etkilenmez |
| `perf` | Performans iyileştirmesi |

### 23.2 Kapsam (Scope) Kuralı
Kapsam, ilgili feature veya katman adını yansıtır: `feat(tasks): add subtask completion logic`, `fix(habits): correct streak calculation for weekly frequency`, `refactor(core): simplify failure mapping`.

### 23.3 Kurallar
- Kısa açıklama emir kipinde, İngilizce veya proje genelinde tutarlı tek bir dilde yazılır (dokümanlar Türkçe olsa da, kod ve commit mesajlarında dil tutarlılığı ekip içinde önceden netleştirilir — bu roadmap kapsamında dil zorunluluğu belirlenmemiştir, yalnızca **tutarlılık** zorunludur).
- Her commit, tek bir mantıksal değişikliği temsil eder ("bir commit, bir amaç" prensibi); birden fazla feature'ı aynı commit'te birleştirmekten kaçınılır.
- Gövde (body) gerekiyorsa, "neden" bu değişikliğin yapıldığını açıklar, "ne" değiştiğini değil (diff zaten "ne"yi gösterir).
- Breaking change (örn. bir Repository arayüzünün değişmesi) varsa commit gövdesinde `BREAKING CHANGE:` etiketiyle açıkça belirtilir.

---

## 24. Versiyonlama Sistemi

### 24.1 Semantic Versioning
Uygulama sürümü `MAJOR.MINOR.PATCH` (örn. `1.2.3`) formatında Semantic Versioning ile yönetilir:
- **MAJOR:** Kullanıcı verisiyle uyumsuz veri modeli değişikliği veya kapsamlı yeniden tasarım (MVP sonrası, PRD Bölüm 10'daki gelecek fikirlerinden biri onaylanıp uygulanırsa).
- **MINOR:** PRD Bölüm 9.2'deki MVP+ maddelerinden birinin (örn. takvimde haftalık görünüm) eklenmesi gibi geriye uyumlu yeni işlevsellik.
- **PATCH:** Hata düzeltmeleri, küçük iyileştirmeler, performans düzeltmeleri.

### 24.2 Android `versionCode` / `versionName` İlişkisi
- `versionName`, Semantic Versioning ile birebir eşleşir (örn. `1.0.0`).
- `versionCode`, her Play Store yüklemesinde tekil ve artan bir tam sayıdır (Semantic Versioning'den bağımsız, yalnızca artan sayaç).

### 24.3 MVP Sürüm Planlaması
- **`0.x.y` sürümleri:** FAZ 1–17 arası, henüz Play Store'a yayınlanmamış geliştirme/kapalı test sürümleri.
- **`1.0.0`:** FAZ 18 sonunda, PRD Bölüm 9.1'deki tam MVP kapsamıyla yapılan ilk resmi Play Store yayını.
- PRD Bölüm 9.2'deki MVP+ maddeleri, `1.0.0` sonrası `1.x.0` sürümlerinde ayrı bir roadmap kapsamında (bu doküman kapsamı dışında) ele alınır.

---

## 25. Debug Süreci

### 25.1 Hata Tespiti ve Sınıflandırma
Her hata, tespit edildiğinde şu önem derecelerinden birine atanır:
| Seviye | Tanım | Örnek |
|---|---|---|
| **Blocker** | Uygulamanın çökmesine veya temel bir akışın tamamen çalışmamasına yol açar | Auth Guard'ın sonsuz döngüye girmesi |
| **Critical** | Bir feature'ın ana işlevini kullanılamaz kılar ama uygulama genelini çökertmez | Görev tamamlanma yüzdesinin yanlış hesaplanması |
| **Major** | Bir feature'ın ikincil bir işlevini etkiler | Bir filtre kombinasyonunun beklenmeyen sonuç vermesi |
| **Minor** | Görsel/UX tutarsızlığı, işlevi engellemez | Bir kartın boşluk değerinin `UI_GUIDELINES.md` ile birebir örtüşmemesi |

### 25.2 Debug Akışı
1. Hata, yeniden üretilebilir (reproducible) adımlarla birlikte kayıt altına alınır (issue tracker).
2. Hata, ilgili feature/faz ile ilişkilendirilir (bu roadmap'teki faz numarasına referansla).
3. Kök neden analizi yapılırken önce ilgili katman (Presentation/Domain/Data) izole edilir — `ARCHITECTURE.md`'deki katman ayrımı, hatanın hangi katmanda olduğunu hızlı daraltmak için doğrudan kullanılır.
4. Düzeltme, `fix/` branch'inde yapılır ve **mutlaka** hatayı yeniden üreten bir regresyon testiyle birlikte teslim edilir (test olmadan hata kapatılmaz — bu, aynı hatanın gelecekte sessizce geri dönmesini önler).
5. Blocker/Critical seviye hatalar, tespit edildiği fazın "Test Edilmesi Gereken Noktalar" listesine geriye dönük eklenir (roadmap'in yaşayan bir doküman olarak güncellenmesi — bkz. Bölüm 27).

### 25.3 Loglama Disiplini
- FAZ 2'de kurulan merkezi loglama mekanizması, geliştirme ortamında ayrıntılı (debug seviyesi), prod ortamında sınırlı (yalnızca hata/uyarı seviyesi) çalışır.
- Hassas kullanıcı verisi (görev/not içeriği, kimlik bilgileri) hiçbir loglama seviyesinde açık metin olarak loglanmaz.

---

## 26. Code Review Kuralları

### 26.1 Zorunlu Kontrol Maddeleri
Her Pull Request incelemesinde aşağıdaki maddeler standart olarak kontrol edilir:
1. **Katman ihlali kontrolü:** Presentation, Data katmanını doğrudan import ediyor mu? Domain katmanı framework paketi import ediyor mu? (`ARCHITECTURE.md` Bölüm 15)
2. **Feature izolasyonu kontrolü:** Bir feature, başka bir feature'ın iç (Data/Presentation) katmanına sızıyor mu? (`ARCHITECTURE.md` Bölüm 14 madde 4)
3. **Provider tipi uygunluğu:** Kullanılan Riverpod provider tipi, `ARCHITECTURE.md` Bölüm 5.1'deki karar kriterlerine uyuyor mu?
4. **Result/Failure disiplini:** UseCase'ler ham exception fırlatmak yerine standart Result/Failure döndürüyor mu? (`ARCHITECTURE.md` Bölüm 15 madde 6)
5. **Token referans kuralı:** Renk/boşluk/tipografi değerleri sabit kodlanmış mı, yoksa `UI_GUIDELINES.md` token'larına mı referans veriyor? (`COMPONENTS.md` Bölüm 16.4)
6. **Test eşliği:** Yeni eklenen Domain/Data kodu, ilgili unit testle birlikte mi geldi? (Bölüm 19.3 minimum eşikler)
7. **Offline-first tutarlılığı:** Yeni bir feature, doğrudan Firestore'a yazmak yerine önce yerel depolamaya mı yazıyor? (`ARCHITECTURE.md` Bölüm 15 madde 7)
8. **İsimlendirme tutarlılığı:** Dosya/sınıf/provider isimleri `FOLDER_STRUCTURE.md` Bölüm 12 ile uyumlu mu?

### 26.2 İnceleme Süreci
- Her PR, birleştirilmeden önce en az bir onay (approval) gerektirir; Domain katmanı veya cross-feature değişiklikler içeren PR'lar için iki onay önerilir.
- PR açıklaması, hangi roadmap fazına/feature'ına ait olduğunu ve ilgili referans doküman bölümünü (örn. "SCREENS.md Bölüm 4.9") belirtir.
- CI kontrolleri (analyze, format, test) geçmeyen bir PR incelemeye alınmaz.
- İnceleyen kişi, yalnızca "çalışıyor mu" değil "mimariye uygun mu" sorusunu da yanıtlamakla yükümlüdür.

---

## 27. Dokümantasyon Güncelleme Kuralları

### 27.1 Referans Dokümanların Değişmezliği
PRD, UI_GUIDELINES, ARCHITECTURE, DATABASE, FOLDER_STRUCTURE, STATE_MANAGEMENT, COMPONENTS, SCREENS dokümanları, bu roadmap'in temelini oluşturur. Geliştirme sırasında bu dokümanlardaki bir kararın **değiştirilmesi gerektiği** ortaya çıkarsa (örn. Bölüm 21'deki Hive/Isar kararı gibi), bu değişiklik:
1. Rastgele kod içinde sessizce yapılmaz.
2. İlgili referans dokümanın kendisinde, gerekçesiyle birlikte güncellenir.
3. Güncelleme, bu roadmap dokümanının "Referans Dokümanlar" listesindeki versiyon numarasına yansıtılır.

### 27.2 Roadmap'in Yaşayan Doküman Olarak Güncellenmesi
- Bir fazın "Riskler" bölümünde öngörülmeyen yeni bir risk gerçekleşirse, bu roadmap dokümanı güncellenir (versiyon numarası artırılır) ve değişiklik gerekçesiyle kayıt altına alınır.
- Bir fazın "Test Edilmesi Gereken Noktalar" listesine, Bölüm 25.2 madde 5 uyarınca geriye dönük hata senaryoları eklenebilir.
- Faz sırası veya bağımlılık matrisinde (Bölüm 20) bir değişiklik gerekirse, bu değişiklik yalnızca yönetimsel/sıralama kararıdır — hiçbir referans dokümandaki mimari/veri/ekran kararını etkilemez ve o dokümanları değiştirmez.

### 27.3 Doküman Sürüm Kaydı
Her referans doküman ve bu roadmap, kendi başlığında `Doküman Versiyonu` alanı taşır. Bir dokümanda içerik değişikliği yapıldığında versiyon numarası artırılır ve değişiklik tarihi güncellenir; böylece hangi geliştirme döneminin hangi doküman versiyonuna göre yapıldığı geriye dönük izlenebilir.

---

## 28. Sonraki Adımlar

Bu roadmap dokümanı onaylandıktan sonra:
1. Bölüm 21'de belirtilen açık karar (Hive/Isar) netleştirilir.
2. FAZ 1 (Project Setup) başlatılır — bu, Flutter teknik implementasyon (kodlama) sürecinin fiilen başladığı noktadır.
3. Her faz tamamlandığında, o fazın "Tamamlanma Kriterleri" bölümü bir kabul kontrol listesi (acceptance checklist) olarak kullanılır ve bir sonraki faza geçiş bu kontrolün onayına bağlıdır.

**Bu doküman kapsamında herhangi bir Flutter kodu, widget, Firebase kurulum adımı veya UI implementasyonu üretilmemiştir.** Sonraki aşama, bu roadmap'in FAZ 1 maddesiyle başlayan, ayrı ve bağımsız bir teknik implementasyon (kodlama) sürecidir.
