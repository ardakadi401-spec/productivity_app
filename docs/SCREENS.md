# SCREENS.md
## Kişisel Üretkenlik Uygulaması — Ekran Planlama ve Kullanıcı Akışları Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Product Designer / Senior Mobile UX Designer / Mobile Application Flow Architect
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`, `DATABASE.md`, `FOLDER_STRUCTURE.md`, `STATE_MANAGEMENT.md`, `COMPONENTS.md`
**Doküman Durumu:** Ekran Planlama Referansı — Tüm ekran implementasyonları bu dokümana uymalıdır

> Bu doküman yalnızca ekran planlamasını, bilgi mimarisini ve kullanıcı akışlarını tanımlar. Kod, widget, Flutter implementasyonu veya ekran tasarım (görsel) dosyası içermez. Bu dokümanda geçen tüm bileşen isimleri `COMPONENTS.md`'den, tüm veri alanları `DATABASE.md`'den, tüm state/durum isimleri `STATE_MANAGEMENT.md`'den birebir alınmıştır — yeni bir bileşen, alan veya durum türetilmemiştir.

---

## 0. Kapsam ve Sınırlar

- Bu doküman, önceki 7 aşamada alınmış hiçbir kararı **değiştirmez**. Yalnızca `PRD.md` Bölüm 5 (User Flows) ve Bölüm 9 (MVP Kapsamı)'daki özellikleri somut ekranlara ve navigasyon yapısına döker.
- Planlanan ekran sayısı **23**'tür (5 Authentication + 18 Main Application) — bu, talimatta verilen listeyle birebir aynıdır; yeni ekran eklenmemiştir.
- PRD Bölüm 2.4 ve 7'deki ilkeler (AI yok, premium yok, reklam yok, takım çalışması yok) bu dokümanda da geçerlidir — hiçbir ekranda yükseltme/kilit rozeti, paylaşım eylemi veya AI destekli öneri alanı planlanmamıştır.
- Kilit Ekranı (PIN/Biyometri) ve Onboarding tamamlama akışı, `PRD.md` Bölüm 5.7 ve `ARCHITECTURE.md` Bölüm 9.3'te tanımlı, Shell dışında bağımsız rotalar olarak zaten mevcuttur; talimatta verilen 23 ekran listesinde yer almadığından bu dokümanda ayrı bir ekran kartı olarak detaylandırılmamış, yalnızca Navigasyon Planı'nda (Bölüm 2) referans olarak belirtilmiştir.
- Her ekran kartındaki "Kullanılacak Componentler" alanı yalnızca `COMPONENTS.md`'de tanımlı bileşenlere referans verir; her "Boş/Loading/Error Durumu" alanı `STATE_MANAGEMENT.md` Bölüm 8'deki beş durumluk standart sözleşmeye (Loading/Success/Empty/Error/Refreshing) ve bunların `COMPONENTS.md` Bölüm 11'deki görsel karşılıklarına dayanır.

---

## 1. Screen List

### 1.1 Authentication (5 Ekran)
| # | Ekran | Route |
|---|---|---|
| 1 | Splash Screen | `/splash` |
| 2 | Welcome Screen | `/welcome` |
| 3 | Login Screen | `/login` |
| 4 | Register Screen | `/register` |
| 5 | Forgot Password Screen | `/forgot-password` |

### 1.2 Main Application (18 Ekran)
| # | Ekran | Route |
|---|---|---|
| 6 | Dashboard Screen | `/dashboard` |
| 7 | Projects Screen | `/projects` |
| 8 | Project Detail Screen | `/projects/:projectId` |
| 9 | Tasks Screen | `/tasks` |
| 10 | Task Detail Screen | `/tasks/:taskId` |
| 11 | Create Task Screen | `/tasks/new` |
| 12 | Edit Task Screen | `/tasks/:taskId/edit` |
| 13 | Calendar Screen | `/calendar` |
| 14 | Goals Screen | `/goals` |
| 15 | Habits Screen | `/habits` |
| 16 | Habit Detail Screen | `/habits/:habitId` |
| 17 | Pomodoro Screen | `/pomodoro` |
| 18 | Notes Screen | `/notes` |
| 19 | Note Detail Screen | `/notes/:noteId` |
| 20 | Statistics Screen | `/statistics` |
| 21 | Search Screen | `/search` |
| 22 | Settings Screen | `/settings` |
| 23 | Profile Screen | `/profile` |

---

## 2. Navigation Plan

### 2.1 Genel Yaklaşım
`ARCHITECTURE.md` Bölüm 9'daki Go Router stratejisi esas alınır: deklaratif, merkezi route tanımı; route'lar feature bazlı gruplanır, kök router bunları derler. Route path'leri `ARCHITECTURE.md` Bölüm 9.4 ile uyumlu olarak anlamlı ve parametreli tasarlanmıştır (`/tasks/:taskId`, `/projects/:projectId`) — bu, gelecekteki bildirim tabanlı deep link ihtiyacına (aynı bölüm) hazırlıktır.

### 2.2 Route Planning (Tam Route Listesi)

| Route | Ekran | Erişim | Konum |
|---|---|---|---|
| `/splash` | Splash Screen | Public, ilk açılış rotası | Shell dışı |
| `/welcome` | Welcome Screen | Public | Shell dışı |
| `/login` | Login Screen | Public | Shell dışı |
| `/register` | Register Screen | Public | Shell dışı |
| `/forgot-password` | Forgot Password Screen | Public | Shell dışı |
| `/dashboard` | Dashboard Screen | Protected | Shell — Tab 1 |
| `/projects` | Projects Screen | Protected | Shell — Tab 2 (Projeler alt-sekmesi) |
| `/projects/:projectId` | Project Detail Screen | Protected | Shell — Tab 2 üzerinden push |
| `/tasks` | Tasks Screen | Protected | Shell — Tab 2 (Görevler alt-sekmesi) |
| `/tasks/:taskId` | Task Detail Screen | Protected | Shell dışı push (tam ekran detay) |
| `/tasks/new` | Create Task Screen | Protected | Shell dışı push (Bottom Sheet veya tam ekran — Bölüm 4.11) |
| `/tasks/:taskId/edit` | Edit Task Screen | Protected | Shell dışı push |
| `/calendar` | Calendar Screen | Protected | Shell — Tab 3 |
| `/habits` | Habits Screen | Protected | Shell — Tab 4 (Alışkanlıklar alt-sekmesi) |
| `/habits/:habitId` | Habit Detail Screen | Protected | Shell dışı push |
| `/goals` | Goals Screen | Protected | Shell — Tab 4 (Hedefler alt-sekmesi) |
| `/pomodoro` | Pomodoro Screen | Protected | Shell dışı push (Dashboard hızlı erişimden) |
| `/notes` | Notes Screen | Protected | Shell dışı push |
| `/notes/:noteId` | Note Detail Screen | Protected | Shell dışı push |
| `/statistics` | Statistics Screen | Protected | Shell dışı push |
| `/search` | Search Screen | Protected | Shell dışı push (AppBar arama ikonu) |
| `/settings` | Settings Screen | Protected | Shell — Tab 5 |
| `/profile` | Profile Screen | Protected | Shell dışı push (Settings üzerinden) |

> Not: `ARCHITECTURE.md` Bölüm 9.3'te tanımlı Kilit Ekranı (`/lock`) ve Onboarding tamamlama rotası, Shell dışında bağımsız rotalar olarak mevcuttur ancak talimatın 23 ekranlık listesinde yer almadığından bu tabloda ayrıca detaylandırılmamıştır.

### 2.3 Auth Guard
`ARCHITECTURE.md` Bölüm 9.2 ve `STATE_MANAGEMENT.md` Bölüm 4.1 ile birebir uyumlu:

```
Router, oturum StreamProvider'ının güncel değerini okur
   ↓
checking   → Splash Screen'de kalınır (yönlendirme yapılmaz)
unauthenticated → Protected bir route'a erişim denemesi varsa → /welcome veya /login yönlendirilir
authenticated   → Public bir route'a (login/register/welcome) erişim denemesi varsa → /dashboard yönlendirilir
```

- Guard mantığı, Authentication feature'ının Domain katmanındaki auth-state sözleşmesine bağımlıdır; router hiçbir zaman Firebase SDK'sını doğrudan bilmez (`ARCHITECTURE.md` Bölüm 9.2).
- `/splash`, `/welcome`, `/login`, `/register`, `/forgot-password` **Public**; listede olmayan tüm rotalar **Protected**'dır.

### 2.4 Main Navigation Yapısı (ShellRoute)
- `ARCHITECTURE.md` Bölüm 9.3 uyarınca ana uygulama kabuğu (Bottom Navigation'ı barındıran) bir **ShellRoute** olarak tanımlanır.
- Beş bottom navigation sekmesinin her biri kendi **nested navigator**'ına sahiptir — bir sekme içinde detay ekranına gidildiğinde diğer sekmelerin durumu korunur (`ARCHITECTURE.md` Bölüm 9.3).
- Tab 2 (Projeler/Görevler) ve Tab 4 (Alışkanlıklar/Hedefler) kendi içinde **Tab Navigation** bileşeniyle (`COMPONENTS.md` Bölüm 12.1) ikinci bir sekme seviyesi taşır — bu, Bottom Navigation'ın birincil, Tab Navigation'ın ikincil gezinme seviyesi olduğunu görsel olarak ayırt eder (`COMPONENTS.md` Bölüm 12.1).
- Pomodoro, Notes, Statistics, Search ve Profile; Shell dışında, ilgili sekmeden veya Dashboard'dan push edilen bağımsız ekranlardır (bkz. Bölüm 3.2).

### 2.5 Route Erişim Kuralı
`ARCHITECTURE.md` Bölüm 9.5 ile uyumlu: her route tanımı yalnızca kendi Presentation ekranına referans verir; route parametreleri (`taskId`, `projectId`, `habitId`, `noteId`) ilgili ekranın controller provider'ına iletilir, router hiçbir iş mantığı içermez.

---

## 3. Bottom Navigation Plan

### 3.1 Karar ve Gerekçe
`COMPONENTS.md` Bölüm 2.3 uyarınca bu uygulamada **Drawer kullanılmaz**; `UI_GUIDELINES.md` Bölüm 13.6'daki "bilgi mimarisi sığ tutulur, Dashboard'dan en fazla 2 dokunuş" ilkesi ve `COMPONENTS.md` Bölüm 2.2'deki "4–5 sekme sınırı" kuralı esas alınmıştır. `ARCHITECTURE.md` Bölüm 9.3'te örnek olarak verilen gruplama (*Dashboard, Projects/Tasks, Calendar, Habits/Goals, Settings gibi gruplamalar*) bu dokümanda **birebir uygulanmıştır** — PRD Bölüm 5'teki ilk öneri (Dashboard/Projects/Tasks/Calendar/Profile) beş bağımsız sekme yerine, mimari dokümanın öngördüğü gruplanmış yapıyla uyumlu hale getirilmiştir; PRD'nin kendisi de "önceki dokümanlara uygun karar ver" serbestliğini tanımaktadır ve mimari doküman daha spesifik/sonraki bir karardır.

### 3.2 Beş Sekme

| Sekme | İkon Anlamı | İçerik | Alt Yapı |
|---|---|---|---|
| **1. Dashboard** | Ana sayfa | Günlük özet ekranı | Tek ekran, alt sekme yok |
| **2. Projects/Tasks** | Klasör + Görev | Projeler ve Görevler listesi | Tab Navigation ile iki alt sekme: "Projeler" / "Görevler" |
| **3. Calendar** | Takvim | Aylık + günlük ajanda görünümü | Tek ekran, alt sekme yok |
| **4. Habits/Goals** | Seri + Hedef | Alışkanlıklar ve Hedefler listesi | Tab Navigation ile iki alt sekme: "Alışkanlıklar" / "Hedefler" |
| **5. Settings** | Ayarlar | Tema, kilit, bildirim tercihleri | Tek ekran, alt sekme yok |

### 3.3 Bottom Navigation Dışında Kalan Ekranlar
`COMPONENTS.md` Bölüm 2.3 uyarınca: *"Bottom Navigation dışında kalan ikincil erişimler (Search, Statistics, Profile gibi) AppBar ikon eylemleri veya Dashboard içi hızlı erişim kartlarıyla sağlanır."* Bu ilkeye göre:

| Ekran | Erişim Noktası |
|---|---|
| Search Screen | Dashboard ve diğer ana ekranların AppBar'ında arama ikonu (Icon Button) |
| Statistics Screen | Dashboard'daki haftalık özet bölümünün "Tümünü Gör" bağlantısı (Section Header) |
| Notes Screen | Dashboard hızlı erişim kartı ("Yeni Not") + Project/Task Detail ekranlarındaki not bağlantıları |
| Pomodoro Screen | Dashboard hızlı erişim kartı ("Pomodoro Başlat") + Task Detail ekranındaki "Pomodoro ile Çalış" eylemi |
| Profile Screen | Settings Screen içindeki profil kartı/girişi |

Bu yapı, `UI_GUIDELINES.md` Bölüm 13.6'daki "herhangi bir özelliğe Dashboard'dan en fazla 2 dokunuşla ulaşılabilir" kuralını korur: her ikincil ekran, Dashboard'dan ya doğrudan (1 dokunuş) ya da bir ana sekme üzerinden (2 dokunuş) erişilebilir durumdadır.

---

## 4. Ekran Detayları (Screen Purpose, Structure, Actions, States)

> Format notu: Her ekran aşağıdaki 10 alanla tanımlanır — Amaç, Geliş Nedeni, Ekran Bölümleri, Componentler, Kullanıcı Aksiyonları, Boş Durum, Loading Durumu, Error Durumu, Başarılı İşlem Sonrası, Sonraki Ekran Bağlantıları.

### 4.1 Splash Screen

| Alan | Açıklama |
|---|---|
| Amaç | Uygulama açılışında oturum durumunu (`checking`) kontrol ederken marka kimliğini göstermek — `STATE_MANAGEMENT.md` Bölüm 4.1 |
| Geliş Nedeni | Uygulamanın her açılışında ilk gösterilen ekran (PRD Bölüm 5.1) |
| Ekran Bölümleri | Ortalanmış marka/logo alanı; alt bilgi yok |
| Componentler | Yalnızca statik marka görseli — form/liste bileşeni yok |
| Kullanıcı Aksiyonları | Yok (tamamen otomatik geçiş ekranı) |
| Boş Durum | Geçerli değil |
| Loading Durumu | Ekranın kendisi zaten bir loading/geçiş durumudur; `authStateProvider` (`StreamProvider`) `checking` durumundan çıkana kadar gösterilir |
| Error Durumu | Oturum kontrolünde `CacheFailure` oluşursa doğrudan `/welcome`'a düşülür (kullanıcı tekrar giriş yapabilir) — bloklayıcı hata ekranı gösterilmez |
| Başarılı İşlem Sonrası | `authenticated` → Dashboard'a yönlendirme; `unauthenticated` → Welcome'a yönlendirme |
| Sonraki Ekran Bağlantıları | → Dashboard Screen (`authenticated`) / → Welcome Screen (`unauthenticated`) |

### 4.2 Welcome Screen

| Alan | Açıklama |
|---|---|
| Amaç | Giriş yapmamış kullanıcıyı karşılamak, ürünün değer önerisini kısaca iletmek ve Giriş/Kayıt'a yönlendirmek |
| Geliş Nedeni | Splash'ten `unauthenticated` sonucu ile veya oturum kapatıldığında |
| Ekran Bölümleri | Üstte marka görseli/başlık (`type/display`); ortada kısa değer önerisi metni (1–2 cümle); altta eylem butonları |
| Componentler | Primary Button ("Giriş Yap"), Secondary Button ("Kayıt Ol") |
| Kullanıcı Aksiyonları | "Giriş Yap" dokunma, "Kayıt Ol" dokunma |
| Boş Durum | Geçerli değil (statik içerik) |
| Loading Durumu | Geçerli değil |
| Error Durumu | Geçerli değil |
| Başarılı İşlem Sonrası | Geçerli değil (yönlendirme ekranı) |
| Sonraki Ekran Bağlantıları | → Login Screen / → Register Screen |

### 4.3 Login Screen

| Alan | Açıklama |
|---|---|
| Amaç | Google ile Giriş veya E-posta ile Giriş yoluyla kullanıcıyı kimlik doğrulamak (PRD Bölüm 6.1) |
| Geliş Nedeni | Welcome Screen'den "Giriş Yap" ile, veya Register/Forgot Password'den geri dönüşle |
| Ekran Bölümleri | Üstte başlık; Google ile Giriş butonu; ayraç ("veya"); E-posta + Şifre Text Input çifti; "Şifremi Unuttum" bağlantısı; Giriş butonu; altta "Hesabın yok mu? Kayıt Ol" bağlantısı |
| Componentler | Primary Button (Google ile Giriş, Giriş Yap), Text Input (e-posta), Password Input (şifre), Text Button (Şifremi Unuttum, Kayıt Ol'a git) |
| Kullanıcı Aksiyonları | Google ile giriş yapma, e-posta/şifre girip giriş yapma, "Şifremi Unuttum"a dokunma, "Kayıt Ol"a dokunma |
| Boş Durum | Geçerli değil (form ekranı) |
| Loading Durumu | Giriş butonu Loading durumuna geçer (`COMPONENTS.md` Bölüm 3.2 — buton boyutu sabit kalır, metin yerine ince spinner) — `AsyncNotifierProvider` giriş eylemini işlerken |
| Error Durumu | `AuthFailure` (`STATE_MANAGEMENT.md` Bölüm 9.2) → ilgili alanın altında veya form üstünde çözüm odaklı hata mesajı (örn. "E-posta veya şifre hatalı"); form alanları korunur |
| Başarılı İşlem Sonrası | Auth state `authenticated`'e geçer, Auth Guard otomatik olarak Dashboard'a yönlendirir |
| Sonraki Ekran Bağlantıları | → Dashboard Screen (başarılı) / → Register Screen / → Forgot Password Screen |

### 4.4 Register Screen

| Alan | Açıklama |
|---|---|
| Amaç | E-posta + şifre ile yeni hesap oluşturmak (PRD Bölüm 6.1) |
| Geliş Nedeni | Welcome veya Login Screen'den "Kayıt Ol" ile |
| Ekran Bölümleri | Üstte başlık; Ad, E-posta, Şifre, Şifre Tekrar Text/Password Input alanları; Kayıt Ol butonu; altta "Zaten hesabın var mı? Giriş Yap" bağlantısı |
| Componentler | Text Input (ad, e-posta), Password Input (şifre, şifre tekrar), Primary Button (Kayıt Ol), Text Button (Giriş Yap'a git) |
| Kullanıcı Aksiyonları | Form alanlarını doldurma, Kayıt Ol'a dokunma, Giriş Yap'a dönme |
| Boş Durum | Geçerli değil (form ekranı) |
| Loading Durumu | Kayıt Ol butonu Loading durumuna geçer |
| Error Durumu | `ValidationFailure` → ilgili alanın altında hata metni (`COMPONENTS.md` Bölüm 5.1 Error durumu); `AuthFailure` (örn. e-posta zaten kayıtlı) → form üstünde çözüm odaklı mesaj |
| Başarılı İşlem Sonrası | Hesap oluşturulur, auth state `authenticated`'e geçer, Auth Guard Dashboard'a yönlendirir (PRD Bölüm 5.1'de onboarding sonrası doğrudan Dashboard akışı tanımlıdır) |
| Sonraki Ekran Bağlantıları | → Dashboard Screen (başarılı) / → Login Screen |

### 4.5 Forgot Password Screen

| Alan | Açıklama |
|---|---|
| Amaç | Şifresini unutan kullanıcıya e-posta ile şifre sıfırlama bağlantısı göndermek (PRD Bölüm 6.1) |
| Geliş Nedeni | Login Screen'den "Şifremi Unuttum" ile |
| Ekran Bölümleri | Üstte kısa açıklama metni; E-posta Text Input; Gönder butonu |
| Componentler | Text Input (e-posta), Primary Button (Sıfırlama Bağlantısı Gönder) |
| Kullanıcı Aksiyonları | E-posta girip gönderme, geri dönme |
| Boş Durum | Geçerli değil |
| Loading Durumu | Gönder butonu Loading durumuna geçer |
| Error Durumu | `ValidationFailure` (geçersiz e-posta formatı) veya `AuthFailure` (kayıtlı olmayan e-posta) → alan altı hata metni |
| Başarılı İşlem Sonrası | Success Message Snackbar ("Sıfırlama bağlantısı e-postana gönderildi") gösterilir, Login Screen'e geri dönülür |
| Sonraki Ekran Bağlantıları | → Login Screen |

---

### 4.6 Dashboard Screen

> Detaylı kırılım için bkz. Bölüm 5 — Dashboard Detayı. Bu tablo yalnızca özet ekran kartıdır.

| Alan | Açıklama |
|---|---|
| Amaç | Kullanıcının gününü tek bakışta görmesini sağlamak: bugünün görevleri, alışkanlık check-in'leri, hedef/istatistik özeti (PRD Bölüm 6.2) |
| Geliş Nedeni | Girişten sonra otomatik yönlendirme veya Bottom Navigation Tab 1 |
| Ekran Bölümleri | Gün özeti başlığı, "Bugünün Görevleri" bölümü, "Alışkanlıklar" bölümü, "Haftalık İlerleme" özeti, hızlı erişim eylemleri (bkz. Bölüm 5) |
| Componentler | Section Header, Task Card (kompakt), Habit Card (kompakt), Statistic Summary Card, Progress Bar, FAB veya hızlı erişim buton grubu |
| Kullanıcı Aksiyonları | Görev tamamlama (Completion Checkbox), alışkanlık check-in (Completion Button), "Tümünü Gör" ile ilgili listeye gitme, hızlı erişim eylemlerine dokunma |
| Boş Durum | Bugün için görev/alışkanlık/hedef yoksa Empty State ("Bugün için planlanan bir şey yok" + "Görev Ekle" Primary Button) — bölüm bazında ayrı ayrı uygulanır |
| Loading Durumu | Skeleton yükleme deseni; Dashboard birden fazla feature'ı agregize ettiği için her bölüm kendi skeleton bloğunu bağımsız gösterir |
| Error Durumu | İlgili bölüm `CacheFailure` alırsa yalnızca o bölüm Error State gösterir ("Tekrar Dene"), diğer bölümler etkilenmez |
| Başarılı İşlem Sonrası | Görev tamamlama/check-in sonrası ilgili kart anında güncellenir (Isar Stream üzerinden), Snackbar ile geri bildirim + "Geri Al" seçeneği |
| Sonraki Ekran Bağlantıları | → Tasks Screen, → Habits Screen, → Statistics Screen, → Create Task Screen, → Notes Screen (yeni not), → Pomodoro Screen, → Task Detail Screen |

### 4.7 Projects Screen

| Alan | Açıklama |
|---|---|
| Amaç | Kullanıcının tüm projelerini listelemesini ve yeni proje oluşturmasını sağlamak (PRD Bölüm 6.3) |
| Geliş Nedeni | Bottom Navigation Tab 2 → "Projeler" alt sekmesi |
| Ekran Bölümleri | Tab Navigation (Projeler/Görevler), Aktif/Arşivlenmiş filtre chip'leri, proje listesi, FAB |
| Componentler | Tab Navigation, Project Card, FAB, Empty State, Section Header |
| Kullanıcı Aksiyonları | Proje kartına dokunup detaya girme, FAB ile yeni proje oluşturma (Bottom Sheet), aktif/arşiv filtresi değiştirme, projeyi arşivleme (kaydırma/uzun basma hızlı eylemi) |
| Boş Durum | "Henüz proje eklemedin" + "Yeni Proje" Primary Button (`COMPONENTS.md` Bölüm 11.2 örneği) |
| Loading Durumu | Skeleton — proje kartı iskeletini taklit eden bloklar |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Yeni proje Bottom Sheet'te oluşturulunca liste anında güncellenir, Snackbar ile onay |
| Sonraki Ekran Bağlantıları | → Project Detail Screen, → Tasks Screen (alt sekme geçişi) |

### 4.8 Project Detail Screen

| Alan | Açıklama |
|---|---|
| Amaç | Seçili projenin bilgilerini, ilerleme yüzdesini ve altındaki görevleri göstermek (PRD Bölüm 5.3) |
| Geliş Nedeni | Projects Screen'den bir Project Card'a dokunma |
| Ekran Bölümleri | AppBar (proje başlığı + düzenle/arşivle ikon eylemleri), proje açıklaması, ilerleme göstergesi (Circular/Progress Bar), projeye bağlı görev listesi, "Görev Ekle" eylemi |
| Componentler | App Bar, Progress Bar veya Circular Progress, Task Card, FAB veya Primary Button ("Görev Ekle"), Empty State |
| Kullanıcı Aksiyonları | Görev ekleme, görev listesine dokunup detaya gitme, projeyi düzenleme, projeyi arşivleme (Dialog onayı — geri döndürülemez his taşımadığı için Dialog, kalıcı silme değildir) |
| Boş Durum | Projeye bağlı görev yoksa "Bu projede henüz görev yok" + "Görev Ekle" Primary Button |
| Loading Durumu | Skeleton — başlık + ilerleme + görev listesi iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Yeni görev eklendiğinde `taskCount`/`completedTaskCount` denormalize alanları (`DATABASE.md` Bölüm 15.4) üzerinden ilerleme anında güncellenir |
| Sonraki Ekran Bağlantıları | → Create Task Screen (proje önceden seçili), → Task Detail Screen, → Edit Task Screen |

### 4.9 Tasks Screen

| Alan | Açıklama |
|---|---|
| Amaç | Kullanıcının tüm görevlerini filtreli/sıralı şekilde listelemesini sağlamak (PRD Bölüm 6.4) |
| Geliş Nedeni | Bottom Navigation Tab 2 → "Görevler" alt sekmesi |
| Ekran Bölümleri | Tab Navigation (Projeler/Görevler), filtre/sıralama chip grubu (tarih/öncelik/proje), görev listesi, FAB |
| Componentler | Tab Navigation, Task Card, Priority Badge, Due Date Label, FAB, Search Input (liste içi hızlı filtre) |
| Kullanıcı Aksiyonları | Görev tamamlama (Completion Checkbox — listeden çıkmadan), göreve dokunup detaya gitme, filtre/sıralama değiştirme, FAB ile yeni görev, kaydırma ile hızlı eylemler (tamamla/ertele/sil) |
| Boş Durum | Aktif filtreyle eşleşen görev yoksa "Bu filtreyle görev bulunamadı" (filtre varsa) veya "Henüz görev eklemedin" + "Görev Ekle" Primary Button (filtre yoksa) |
| Loading Durumu | Skeleton — liste kartı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Tamamlama sonrası kart anında "Tamamlandı" durumuna geçer (üstü çizili + soluk), Snackbar + "Geri Al" |
| Sonraki Ekran Bağlantıları | → Task Detail Screen, → Create Task Screen, → Edit Task Screen |

### 4.10 Task Detail Screen

| Alan | Açıklama |
|---|---|
| Amaç | Bir görevin tüm alanlarını, alt görevlerini ve ilişkili notlarını göstermek (PRD Bölüm 5.3) |
| Geliş Nedeni | Tasks/Project Detail/Calendar/Dashboard/Search ekranlarından bir Task Card'a dokunma |
| Ekran Bölümleri | AppBar (düzenle/sil ikon eylemleri), başlık + açıklama + öncelik + son tarih, alt görev listesi, ilişkili proje/etiket bilgisi, "Pomodoro ile Çalış" eylemi, ilişkili notlar (varsa) |
| Componentler | App Bar, Priority Badge, Due Date Label, Completion Checkbox (ana görev + alt görevler), Progress Bar (alt görev tamamlanma %), Outline Button ("Pomodoro ile Çalış") |
| Kullanıcı Aksiyonları | Görevi tamamlama, alt görev ekleme/tamamlama/yeniden sıralama, düzenlemeye gitme, silme (Dialog onayı), Pomodoro'ya bağlanarak başlatma |
| Boş Durum | Alt görev yoksa alt görev bölümünde "Alt görev eklenmedi" + "Alt Görev Ekle" Text Button |
| Loading Durumu | Skeleton — detay alanı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Alt görev tamamlanınca `subtaskCount`/`completedSubtaskCount` (`DATABASE.md` Bölüm 4.2) üzerinden ana görev ilerleme yüzdesi otomatik güncellenir (`ARCHITECTURE.md` Bölüm 4, Dashboard/Projects satırı) |
| Sonraki Ekran Bağlantıları | → Edit Task Screen, → Pomodoro Screen (görev bağlı), → Note Detail Screen (ilişkili not varsa) |

### 4.11 Create Task Screen

| Alan | Açıklama |
|---|---|
| Amaç | Yeni bir görev oluşturmak (PRD Bölüm 5.2) |
| Geliş Nedeni | Dashboard/Tasks/Project Detail/Calendar ekranlarındaki FAB veya "Görev Ekle" eylemi |
| Ekran Bölümleri | Başlık Text Input (zorunlu), açıklama Text Input (opsiyonel), Proje Dropdown, Tarih/Saat Picker, Öncelik seçimi (chip grubu), alt görev taslak listesi, Kaydet eylemi |
| Componentler | Text Input, Dropdown (proje seçimi), Date Picker/Time Picker, Priority Badge (seçilebilir chip varyantı), Primary Button (Kaydet), Bottom Sheet (hızlı ekleme için tercih edilen sunum biçimi — `COMPONENTS.md` Bölüm 11.7) |
| Kullanıcı Aksiyonları | Alanları doldurma, proje/tarih/öncelik seçme, alt görev taslağı ekleme, Kaydet'e dokunma, vazgeçme |
| Boş Durum | Geçerli değil (form ekranı) |
| Loading Durumu | Kaydet butonu Loading durumuna geçer |
| Error Durumu | `ValidationFailure` (örn. boş başlık) → alan altı hata metni; form gönderilmeden önce UI seviyesinde de engellenir (`DATABASE.md` Bölüm 14.2) |
| Başarılı İşlem Sonrası | Görev kaydedilir, varsa yerel bildirim planlanır (`ScheduleNotificationUseCase` — `ARCHITECTURE.md` Bölüm 4.2), ekran kapanır, çağrıldığı listede görev anında görünür + Snackbar onayı |
| Sonraki Ekran Bağlantıları | → (kapanır) çağrıldığı ekrana (Dashboard/Tasks/Project Detail/Calendar) geri döner |

### 4.12 Edit Task Screen

| Alan | Açıklama |
|---|---|
| Amaç | Var olan bir görevin alanlarını güncellemek |
| Geliş Nedeni | Task Detail Screen'deki "Düzenle" ikon eylemi |
| Ekran Bölümleri | Create Task Screen ile birebir aynı alan seti, mevcut değerlerle önceden doldurulmuş |
| Componentler | Create Task Screen ile aynı (Text Input, Dropdown, Date/Time Picker, Priority chip grubu, Primary Button "Güncelle") |
| Kullanıcı Aksiyonları | Alanları güncelleme, Güncelle'ye dokunma, vazgeçme |
| Boş Durum | Geçerli değil (form ekranı) |
| Loading Durumu | Güncelle butonu Loading durumuna geçer |
| Error Durumu | `ValidationFailure` → alan altı hata metni |
| Başarılı İşlem Sonrası | Görev güncellenir, tarih/saat değiştiyse ilgili bildirim yeniden planlanır (eski bildirim iptal edilir), Task Detail Screen'e dönülür + Snackbar onayı |
| Sonraki Ekran Bağlantıları | → (kapanır) Task Detail Screen'e geri döner |

### 4.13 Calendar Screen

| Alan | Açıklama |
|---|---|
| Amaç | Görev ve hedeflerin tarih bazlı görüntülenmesini sağlamak (PRD Bölüm 6.6) |
| Geliş Nedeni | Bottom Navigation Tab 3 |
| Ekran Bölümleri | Aylık takvim grid görünümü, seçili güne ait günlük ajanda listesi (o güne ait tüm görev/hedef öğeleri tek listede — PRD Bölüm 6.6) |
| Componentler | Date Picker temelli aylık grid (native temalandırılmış), Task Card (kompakt ajanda satırı), Goal Card (o gün bitiyorsa), FAB ("Bu Güne Görev Ekle") |
| Kullanıcı Aksiyonları | Gün seçme, aylık/günlük görünüm arasında geçiş, seçili günden doğrudan yeni görev oluşturma, bir öğeye dokunup detaya gitme |
| Boş Durum | Seçili günde öğe yoksa "Bu gün için planlanan bir şey yok" + "Görev Ekle" Primary Button |
| Loading Durumu | Skeleton — ajanda listesi iskeleti (takvim grid'i statik olduğundan yalnızca liste bölümü skeleton gösterir) |
| Error Durumu | `CacheFailure` → ajanda listesinde Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Seçili günden oluşturulan görev, o günün tarihiyle önceden doldurulmuş olarak Create Task Screen'e taşınır; kaydedilince ajandada anında görünür |
| Sonraki Ekran Bağlantıları | → Create Task Screen (tarih önceden seçili), → Task Detail Screen, → Goals Screen (hedef öğesine dokunma) |

### 4.14 Goals Screen

| Alan | Açıklama |
|---|---|
| Amaç | Günlük/haftalık/aylık hedefleri listelemek ve yönetmek (PRD Bölüm 6.8) |
| Geliş Nedeni | Bottom Navigation Tab 4 → "Hedefler" alt sekmesi |
| Ekran Bölümleri | Tab Navigation (Alışkanlıklar/Hedefler), zaman aralığı filtre chip'leri (Günlük/Haftalık/Aylık), hedef listesi, FAB |
| Componentler | Tab Navigation, Goal Card, Progress Bar, FAB, Empty State |
| Kullanıcı Aksiyonları | Zaman aralığı filtresi değiştirme, hedef kartına dokunup detaya gitme, `manualProgress` tipi hedeflerde kart üstünden hızlı yüzde güncelleme, FAB ile yeni hedef oluşturma (Bottom Sheet) |
| Boş Durum | Seçili zaman aralığında hedef yoksa "Henüz [dönem] hedefi eklemedin" + "Hedef Ekle" Primary Button |
| Loading Durumu | Skeleton — hedef kartı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Yeni hedef listeye anında eklenir; bağlı görev tamamlandığında (`progressType: linkedTasks`) ilerleme otomatik güncellenir |
| Sonraki Ekran Bağlantıları | → (hedef detayı bu doküman kapsamındaki 23 ekran listesinde ayrı bir ekran olarak yer almadığından, hedef detay/düzenleme etkileşimi Bottom Sheet üzerinden bu ekran içinde çözülür — bkz. Bölüm 0), → Tasks Screen (bağlı görevi görüntüleme) |

### 4.15 Habits Screen

| Alan | Açıklama |
|---|---|
| Amaç | Alışkanlıkları listelemek ve günlük check-in yapılmasını sağlamak (PRD Bölüm 6.9) |
| Geliş Nedeni | Bottom Navigation Tab 4 → "Alışkanlıklar" alt sekmesi |
| Ekran Bölümleri | Tab Navigation (Alışkanlıklar/Hedefler), günlük alışkanlık kartları listesi, FAB |
| Componentler | Tab Navigation, Habit Card, Streak Indicator, Completion Button, FAB, Empty State |
| Kullanıcı Aksiyonları | Completion Button ile günlük check-in yapma (tek dokunuş — PRD "2–3 dokunuş kuralı"), kart dokunmasıyla Habit Detail'e gitme, FAB ile yeni alışkanlık oluşturma |
| Boş Durum | "Henüz alışkanlık eklemedin" + "Alışkanlık Ekle" Primary Button (`COMPONENTS.md` Bölüm 11.2 doğrudan örneği) |
| Loading Durumu | Skeleton — alışkanlık kartı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Check-in sonrası `currentStreak` anında güncellenir, Streak Indicator 300ms "pop" animasyonuyla artışı gösterir (`COMPONENTS.md` Bölüm 9.2) |
| Sonraki Ekran Bağlantıları | → Habit Detail Screen, → Statistics Screen (alışkanlık istatistiği) |

### 4.16 Habit Detail Screen

| Alan | Açıklama |
|---|---|
| Amaç | Bir alışkanlığın geçmiş kayıtlarını, güncel/en uzun serisini ve ayarlarını göstermek (PRD Senaryo 3) |
| Geliş Nedeni | Habits Screen'den bir Habit Card'a dokunma |
| Ekran Bölümleri | AppBar (düzenle/sil ikon eylemleri), güncel/en uzun seri özeti, geçmiş check-in takvimi/ısı görünümü (basit liste/grid), tekrar sıklığı ve hatırlatma saati bilgisi |
| Componentler | App Bar, Streak Indicator, Statistic Summary Card (güncel seri, en uzun seri), Progress Bar (dönemsel tamamlama oranı) |
| Kullanıcı Aksiyonları | Geçmiş kayıtları inceleme, alışkanlığı düzenleme, arşivleme/silme (Dialog onayı) |
| Boş Durum | Henüz hiç check-in yapılmamışsa "Henüz kayıt yok, bugün başla" mesajı + Completion Button |
| Loading Durumu | Skeleton — özet + geçmiş liste iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Düzenleme sonrası bilgiler anında güncellenir + Snackbar onayı |
| Sonraki Ekran Bağlantıları | → (düzenleme bu ekran içinde Bottom Sheet ile çözülür), → Habits Screen (geri) |

### 4.17 Pomodoro Screen

| Alan | Açıklama |
|---|---|
| Amaç | Pomodoro zamanlayıcısını çalıştırmak, opsiyonel olarak bir göreve bağlamak (PRD Bölüm 6.10) |
| Geliş Nedeni | Dashboard hızlı erişim eylemi veya Task Detail Screen'deki "Pomodoro ile Çalış" eylemi |
| Ekran Bölümleri | Büyük dairesel geri sayım göstergesi (Circular Progress), çalışma/mola durumu etiketi, opsiyonel bağlı görev bilgisi, Başlat/Duraklat/Sıfırla eylemleri, tamamlanan oturum sayacı |
| Componentler | Circular Progress (120dp), Primary Button (Başlat/Duraklat), Text Button (Sıfırla), Dropdown veya Bottom Sheet (görev seçimi) |
| Kullanıcı Aksiyonları | Süreyi başlatma/duraklatma/sıfırlama, göreve bağlama, süre bitince bildirimi görme |
| Boş Durum | Geçerli değil (zamanlayıcı her zaman varsayılan 25/5 süreyle hazır durumda gösterilir) |
| Loading Durumu | Geçerli değil — zamanlayıcı durumu (`NotifierProvider`) senkron olarak kurulur (`STATE_MANAGEMENT.md` Bölüm 1.2.5) |
| Error Durumu | Oturum kaydı `CacheFailure` alırsa Snackbar ile sessiz hata bildirimi gösterilir; zamanlayıcı kendisi etkilenmez |
| Başarılı İşlem Sonrası | Süre bitiminde yerel bildirim tetiklenir, oturum kaydedilir, tamamlanan oturum sayısı/istatistikler güncellenir, otomatik olarak mola/çalışma döngüsüne geçilir |
| Sonraki Ekran Bağlantıları | → (kapanır) çağrıldığı ekrana döner, → Statistics Screen (oturum geçmişi incelemek için) |

### 4.18 Notes Screen

| Alan | Açıklama |
|---|---|
| Amaç | Tüm notları listelemek ve yeni not oluşturmak (PRD Bölüm 6.11) |
| Geliş Nedeni | Dashboard hızlı erişim eylemi veya Project/Task Detail üzerinden not bağlantısı |
| Ekran Bölümleri | Sabitlenmiş (pinned) notlar bölümü, tüm notlar listesi, FAB |
| Componentler | Note Card, Section Header (Sabitlenmiş/Tümü ayrımı), FAB, Search Input (liste içi filtre) |
| Kullanıcı Aksiyonları | Not kartına dokunup detaya gitme, notu sabitleme/sabit kaldırma (kaydırma hızlı eylemi), FAB ile yeni not oluşturma |
| Boş Durum | "Henüz not eklemedin" + "Not Ekle" Primary Button |
| Loading Durumu | Skeleton — not kartı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Yeni not listeye anında eklenir + Snackbar onayı |
| Sonraki Ekran Bağlantıları | → Note Detail Screen |

### 4.19 Note Detail Screen

| Alan | Açıklama |
|---|---|
| Amaç | Bir notu görüntülemek/düzenlemek (oluşturma ve düzenleme aynı ekranda ele alınır — Notes feature için ayrı Create/Edit ekranı talimatın 23 ekranlık listesinde tanımlanmamıştır) |
| Geliş Nedeni | Notes Screen'den bir Note Card'a dokunma veya "Yeni Not" eylemi |
| Ekran Bölümleri | Başlık Text Input, içerik metin alanı (temel biçimlendirme: kalın, madde işareti — PRD Bölüm 6.11), renk seçimi, opsiyonel proje/görev bağlama, sabitleme eylemi |
| Componentler | Text Input (başlık), basit metin editörü alanı, Dropdown (proje/görev bağlama — opsiyonel), Icon Button (sabitle, sil) |
| Kullanıcı Aksiyonları | Başlık/içerik düzenleme (otomatik kaydetme veya "Kaydet" eylemi), renk seçme, proje/göreve bağlama, sabitleme, silme (Dialog onayı) |
| Boş Durum | Geçerli değil (form/detay ekranı) |
| Loading Durumu | Skeleton — mevcut bir not açılıyorsa içerik iskeleti; yeni not oluşturuluyorsa geçerli değil |
| Error Durumu | `ValidationFailure` (boş başlık) → alan altı hata metni; `CacheFailure` → Error State |
| Başarılı İşlem Sonrası | Not kaydedilir, Notes Screen'e dönüldüğünde liste güncel görünür + Snackbar onayı |
| Sonraki Ekran Bağlantıları | → (kapanır) Notes Screen'e veya çağrıldığı Project/Task Detail ekranına döner |

### 4.20 Statistics Screen

| Alan | Açıklama |
|---|---|
| Amaç | Görev, alışkanlık, pomodoro ve hedef istatistiklerini görselleştirmek (PRD Bölüm 6.12) |
| Geliş Nedeni | Dashboard "Tümünü Gör" bağlantısı veya Habits/Pomodoro ekranlarındaki istatistik erişimi |
| Ekran Bölümleri | Dönem seçici (Günlük/Haftalık/Aylık chip grubu), özet metrik kartları grid'i, grafik alanı (görev tamamlama trendi), alışkanlık tamamlama oranı, pomodoro toplam süresi, hedef başarı oranı |
| Componentler | Statistic Summary Card (2'li grid — `COMPONENTS.md` Bölüm 10.4), Chart Container, Circular Progress, Progress Bar |
| Kullanıcı Aksiyonları | Dönem değiştirme, bir metrik kartına dokunup ilgili feature ekranına gitme |
| Boş Durum | Seçili dönemde hiç veri yoksa Chart Container içinde "Bu dönem için veri yok" (`COMPONENTS.md` Bölüm 10.3 — Veri Yok durumu) |
| Loading Durumu | Skeleton — metrik kartı + grafik alanı iskeleti |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Geçerli değil (salt okunur görüntüleme ekranı) |
| Sonraki Ekran Bağlantıları | → Tasks Screen, → Habits Screen, → Pomodoro Screen (metrik kartlarından) |

### 4.21 Search Screen

| Alan | Açıklama |
|---|---|
| Amaç | Görev, proje, not ve alışkanlık genelinde birleşik arama yapmak (PRD Bölüm 6.13) |
| Geliş Nedeni | Herhangi bir ana ekranın AppBar'ındaki arama ikonu |
| Ekran Bölümleri | Üstte Search Input (otomatik odaklanmış), tür/tarih filtre chip grubu, sonuç listesi, sonuç yokken/arama boşken son aramalar geçmişi |
| Componentler | Search Input, tür filtre chip grubu, Task Card / Project Card / Note Card / Habit Card (karma sonuç listesi, her biri kendi kart tipiyle) |
| Kullanıcı Aksiyonları | Sorgu yazma (debounce ile sonuç güncelleme — `STATE_MANAGEMENT.md` Bölüm 10.3), filtre uygulama, sonuca dokunup ilgili detay ekranına gitme, son aramadan birine dokunma |
| Boş Durum | Sorgu boşken "Son Aramalar" listesi (varsa) veya "Aramaya başlamak için yaz" ipucu; sorgu sonuçsuzsa "Sonuç bulunamadı" mesajı |
| Loading Durumu | Sorgu değişiminde ince, satır içi bir yükleme göstergesi (tam ekran skeleton değil — debounce sonrası kısa süreli) |
| Error Durumu | `CacheFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Geçerli değil (salt okunur arama ekranı) |
| Sonraki Ekran Bağlantıları | → Task Detail Screen, → Project Detail Screen, → Note Detail Screen, → Habit Detail Screen |

### 4.22 Settings Screen

| Alan | Açıklama |
|---|---|
| Amaç | Tema, bildirim ve güvenlik (PIN/Biyometri) tercihlerini yönetmek (PRD Bölüm 6.14, 6.15) |
| Geliş Nedeni | Bottom Navigation Tab 5 |
| Ekran Bölümleri | Profil kartı (Profile Screen'e giriş), "Görünüm" bölümü (tema seçimi), "Bildirimler" bölümü, "Güvenlik" bölümü (PIN/Biyometri), "Hakkında/Hesap" bölümü (hesap silme — PRD Bölüm 6.1) |
| Componentler | Section Header, Switch, Dropdown/seçim listesi (tema: Açık/Koyu/AMOLED/Sistem), Text Button/Outline Button (hesap silme — Destructive varyant) |
| Kullanıcı Aksiyonları | Tema değiştirme, bildirim anahtarlarını açma/kapama, kilit türünü (PIN/Biyometri/İkisi/Yok) ayarlama, PIN belirleme, hesabı silme (Dialog onayı — geri döndürülemez eylem) |
| Boş Durum | Geçerli değil (ayar listesi her zaman doludur) |
| Loading Durumu | İlk yüklemede kısa süreli skeleton (tema/kilit tercihi `FutureProvider` ile bir kez okunur — `STATE_MANAGEMENT.md` Bölüm 3) |
| Error Durumu | `PermissionFailure` (biyometri izni reddi) → otomatik olarak PIN akışına düşülür + bilgilendirici mesaj (`ARCHITECTURE.md` Bölüm 13.4); diğer `CacheFailure` durumlarında Error State |
| Başarılı İşlem Sonrası | Tema değişikliği anında (yeniden başlatma gerektirmeden) yansır; diğer tercihler Snackbar onayıyla kaydedilir |
| Sonraki Ekran Bağlantıları | → Profile Screen |

### 4.23 Profile Screen

| Alan | Açıklama |
|---|---|
| Amaç | Kullanıcının profil bilgisini (ad, e-posta, fotoğraf) görüntülemesini/güncellemesini sağlamak |
| Geliş Nedeni | Settings Screen'deki profil kartı |
| Ekran Bölümleri | Profil fotoğrafı (Google girişinden geldiyse), ad, e-posta, giriş yöntemi bilgisi, çıkış yap eylemi |
| Componentler | Text Input (ad düzenleme), Primary Button (Kaydet), Text Button/Outline Button (Çıkış Yap — Destructive varyant) |
| Kullanıcı Aksiyonları | Adı güncelleme, çıkış yapma (Dialog onayı) |
| Boş Durum | Geçerli değil |
| Loading Durumu | İlk yüklemede skeleton (`FutureProvider` — `STATE_MANAGEMENT.md` Bölüm 3, satır 13) |
| Error Durumu | `CacheFailure` veya `AuthFailure` → Error State + "Tekrar Dene" |
| Başarılı İşlem Sonrası | Ad güncellenince Snackbar onayı; çıkış yapılınca Auth Guard otomatik olarak Welcome Screen'e yönlendirir |
| Sonraki Ekran Bağlantıları | → (kapanır) Settings Screen'e döner / → Welcome Screen (çıkış sonrası) |

---

## 5. Dashboard Detayı

`UI_GUIDELINES.md` Bölüm 2 İlke 3 (Progressive Disclosure) ve PRD talimatındaki "ekran kalabalık olmamalı" kuralı gözetilerek, Dashboard **beş bölüme** ayrılır; her bölüm en fazla 3–5 öğe gösterir, kalanı için ilgili ana ekrana "Tümünü Gör" bağlantısı verilir.

| Sıra | Bölüm | İçerik Sınırı | Component | Bağlantı |
|---|---|---|---|---|
| 1 | Gün Özeti | Tarih + kısa karşılama başlığı, tek satır | Section Header (`type/display` veya `type/h1`) | — |
| 2 | Bugünkü Görevler | En fazla 5 görev (önceliğe göre sıralı) | Task Card (kompakt) + Section Header ("Tümünü Gör") | → Tasks Screen |
| 3 | Alışkanlıklar | Bugün için tanımlı tüm alışkanlıklar (Habit Card, yatay kaydırılabilir liste — çok sayıdaysa taşmayı önler) | Habit Card (kompakt) + Completion Button | → Habits Screen |
| 4 | Haftalık İlerleme / Hedef Durumu | Tek bir Statistic Summary Card (bu haftaki tamamlanan görev sayısı) + Circular Progress; aktif hedeflerden en fazla 1 öne çıkan Goal Card | Statistic Summary Card, Circular Progress, Goal Card | → Statistics Screen, → Goals Screen |
| 5 | Hızlı Erişim | Yeni Görev, Yeni Not, Pomodoro Başlat — üç eylem (PRD Bölüm 6.2) | Outline Button grubu (yatay 3'lü) veya FAB + Bottom Sheet seçim menüsü | → Create Task Screen, → Notes Screen, → Pomodoro Screen |

### 5.1 Kalabalıklaşmayı Önleme Kararları
- Görev ve alışkanlık bölümleri **sabit üst sınırla** (5 / tüm-günlük-liste) gösterilir; fazlası "Tümünü Gör" ile ilgili ana ekrana taşınır — bu, `UI_GUIDELINES.md` Bölüm 2 İlke 3'ün doğrudan uygulamasıdır.
- Dashboard'da **yalnızca 1 birincil eylem düzeyi** vardır (Hızlı Erişim bölümü); her bölümün kendi Primary Button'ı yoktur — `UI_GUIDELINES.md` Bölüm 2 İlke 2 ("bir ekranda tek birincil eylem") ile uyumludur.
- Haftalık ilerleme, tam bir Statistics ekranı değil, **tek bir özet kart** olarak sunulur; detay isteyen kullanıcı Statistics Screen'e yönlendirilir.
- Dashboard'un kendi Repository'si yoktur (`ARCHITECTURE.md` Bölüm 4) — yalnızca Tasks/Habits/Goals feature'larının UseCase'lerini orkestre eder; bu, ekranın veri yükünü feature sınırları içinde tutar.

---

## 6. Kullanıcı Akışları (User Journeys)

### 6.1 İlk Kullanım Akışı
```
Splash Screen
   ↓ (checking → unauthenticated)
Welcome Screen
   ↓ ("Giriş Yap" veya "Kayıt Ol")
Login Screen  /  Register Screen
   ↓ (authenticated)
Dashboard Screen
```
İlgili ekranlar: 4.1, 4.2, 4.3/4.4, 4.6. Auth Guard mantığı (Bölüm 2.3) her adımda geçerlidir.

### 6.2 Görev Oluşturma Akışı
```
Dashboard Screen (Hızlı Erişim: "Yeni Görev")  veya  Tasks Screen (FAB)
   ↓
Create Task Screen (başlık, opsiyonel: proje/tarih/öncelik/alt görev)
   ↓ Kaydet
Görev Isar'a "pendingCreate" ile yazılır (ARCHITECTURE.md Bölüm 8.2)
   ↓
Varsa yerel bildirim planlanır (dueDate/dueTime alanına göre)
   ↓
Ekran kapanır → çağrıldığı ekrana dönülür, görev listede anında görünür + Snackbar onayı
```
İlgili ekranlar: 4.6, 4.9, 4.11.

### 6.3 Proje Oluşturma Akışı
```
Projects Screen (FAB)
   ↓
Yeni Proje Bottom Sheet (ad, renk/ikon, açıklama)
   ↓ Oluştur
Proje Isar'a yazılır, liste anında güncellenir
   ↓
Project Detail Screen'e otomatik geçiş
   ↓
"Görev Ekle" eylemi ile Create Task Screen (proje önceden seçili)
```
İlgili ekranlar: 4.7, 4.8, 4.11.

### 6.4 Görev Tamamlama Akışı
```
Tasks Screen  veya  Task Detail Screen  veya  Dashboard Screen
   ↓
Completion Checkbox dokunması
   ↓
150ms scale+fade animasyonu + haptic (COMPONENTS.md Bölüm 6.3)
   ↓
Görev status: "completed", completedAt set edilir
   ↓
Metin 300ms içinde üstü çizili + soluk hale geçer
   ↓
Snackbar ("Görev tamamlandı" + "Geri Al", 4 saniye)
   ↓
İlgili istatistik alanları (Statistics Screen, Dashboard haftalık özet) bir sonraki görüntülemede güncel veriyi yansıtır
```
İlgili ekranlar: 4.6, 4.9, 4.10, 4.20.

### 6.5 Alışkanlık Takibi Akışı
```
Habits Screen  veya  Dashboard Screen
   ↓
Habit Card üzerindeki Completion Button dokunması
   ↓
HabitRecord (yyyy-MM-dd ID'li) oluşturulur/güncellenir
   ↓
CalculateStreakUseCase tetiklenir → currentStreak/longestStreak güncellenir
   ↓
Streak Indicator 300ms "pop" animasyonu
   ↓
Statistics Screen'deki alışkanlık tamamlama oranı bir sonraki görüntülemede yansır
```
İlgili ekranlar: 4.6, 4.15, 4.16, 4.20.

### 6.6 Offline Kullanım Akışı
```
İnternet Yok (connectivityStatusProvider: offline)
   ↓
Kullanıcı herhangi bir ekranda CRUD işlemi yapar (görev/not/alışkanlık/proje/hedef)
   ↓
İşlem doğrudan Isar'a yazılır, syncStatus: pendingCreate/pendingUpdate/pendingDelete
   ↓
UI, Isar Stream üzerinden anında güncellenir — kullanıcı bekleme hissetmez (ARCHITECTURE.md Bölüm 8.2)
   ↓
İnternet Gelir (connectivityStatusProvider: online)
   ↓
pending kayıtlar sıraya alınıp Firestore'a gönderilir
   ↓
Başarılı → syncStatus: synced; çakışma varsa Last-Write-Wins uygulanır (sessiz, MVP kapsamı)
   ↓
Settings/Dashboard'daki senkronizasyon durumu göstergesi güncellenir
```
İlgili ekranlar: tüm ekranlar (offline-first her feature için zorunludur — `ARCHITECTURE.md` Bölüm 15.7); görünürlük noktası: 4.22 (Settings), 4.6 (Dashboard).

### 6.7 Ayarlar Akışı
```
Settings Screen
   ↓
"Görünüm" bölümü → Tema seçimi (Açık/Koyu/AMOLED/Sistem)
   ↓ Seçim anında uygulanır (yeniden başlatma gerekmez)
"Bildirimler" bölümü → Genel bildirim anahtarı + tür bazlı tercihler
   ↓
"Güvenlik" bölümü → Kilit türü seçimi (PIN/Biyometri/İkisi/Yok)
   ↓ PIN seçiliyse → PIN belirleme Bottom Sheet
   ↓ Biyometri seçiliyse ve cihaz desteklemiyorsa → otomatik PIN akışına düşülür
Ayar değişiklikleri Snackbar onayıyla kaydedilir
```
İlgili ekranlar: 4.22.

---

## 7. Sonraki Adımlar

Bu ekran planlama dokümanı, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Ekran bazlı wireframe/yüksek çözünürlüklü tasarım üretimi (bu doküman kapsamında yapılmamıştır),
2. Go Router gerçek route/guard implementasyonu (`ARCHITECTURE.md` Bölüm 9 ile birlikte),
3. Her ekran için `presentation/pages/` ve `presentation/widgets/` dosya iskeletlerinin (`FOLDER_STRUCTURE.md` ile uyumlu) oluşturulması,
4. Her ekranın state akışının ilgili `xControllerProvider`'lara bağlanması (`STATE_MANAGEMENT.md` ile uyumlu).

**Bu doküman kapsamında herhangi bir kod, widget veya ekran tasarımı üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
