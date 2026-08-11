# Product Requirement Document (PRD)
## Kişisel Üretkenlik Uygulaması

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Product Manager / Senior Mobile Product Designer
**Platform:** Android (Play Store), Flutter tabanlı geliştirme planlanmaktadır (bu doküman kod içermez)
**Doküman Durumu:** Taslak — Geliştirme Öncesi Onay Bekliyor

---

## 1. Yönetici Özeti

Bu doküman, kullanıcıların görevlerini, projelerini, notlarını, alışkanlıklarını ve hedeflerini tek bir uygulama üzerinden yönetebilmesini sağlayan, reklamsız, premium sistemi olmayan, yapay zekâ içermeyen ve yalnızca bireysel kullanıma yönelik bir mobil üretkenlik uygulamasının ürün gereksinimlerini tanımlar.

Uygulamanın temel felsefesi **"sadelik + kontrol"** üzerine kuruludur: kullanıcı verisinin sahibidir, uygulama herhangi bir ücretli katman, reklam ağı veya takım/işbirliği mekanizması içermez. Odak noktası, dağınık üretkenlik araçlarını (yapılacaklar listesi, not defteri, alışkanlık takipçisi, pomodoro zamanlayıcı, takvim) tek bir tutarlı deneyimde birleştirmektir.

---

## 2. Projenin Amacı

### 2.1 Problem Tanımı
Günümüzde kullanıcılar üretkenlik ihtiyaçlarını karşılamak için genellikle birden fazla uygulama kullanmak zorunda kalmaktadır: görevler için bir uygulama, notlar için başka bir uygulama, alışkanlık takibi için üçüncü bir uygulama, pomodoro için dördüncü bir uygulama. Bu parçalanmışlık:
- Bağlam değiştirme (context switching) maliyetini artırır,
- Veri tutarlılığını bozar (örneğin bir projeye bağlı görev ile o projeye ait not birbirinden kopuktur),
- Kullanıcıyı sürekli reklam, premium duvarları (paywall) ve gereksiz sosyal/takım özellikleriyle karşı karşıya bırakır.

### 2.2 Çözüm
Bu uygulama; görev, proje, not, alışkanlık ve hedef yönetimini tek bir veri modeli ve tek bir kullanıcı arayüzü altında birleştirerek, kullanıcının günlük, haftalık ve aylık planlamasını kesintisiz şekilde yapabilmesini sağlar. Uygulama tamamen bireysel kullanım için tasarlanmıştır; hiçbir işbirliği, paylaşım veya çoklu kullanıcı mekanizması içermez.

### 2.3 Ürün Vizyonu
"Kullanıcının zihnindeki dağınıklığı tek bir sade, hızlı ve güvenilir uygulamaya taşımak."

### 2.4 Ürün Değerleri (Non-Negotiable)
| İlke | Açıklama |
|---|---|
| Yapay zekâ yok | Uygulama hiçbir AI/LLM entegrasyonu içermez. |
| Premium yok | Tüm özellikler tüm kullanıcılar için ücretsiz ve eşit şekilde açıktır. |
| Reklam yok | Uygulama içinde hiçbir reklam ağı veya sponsorlu içerik bulunmaz. |
| Takım çalışması yok | Paylaşım, davet, çoklu kullanıcı, yorum gibi işbirliği özellikleri bulunmaz. |
| Kişisel kullanım | Uygulama yalnızca tek kullanıcının kendi verisini yönetmesi için tasarlanmıştır. |

---

## 3. Hedef Kullanıcı Kitlesi

### 3.1 Birincil Persona: "Düzenli Düşünen Profesyonel"
- **Yaş:** 22–40
- **Meslek:** Bilgi işçisi, öğrenci, serbest çalışan, girişimci
- **Davranış:** Günlük olarak birden fazla proje/görev arasında geçiş yapar; not alma alışkanlığı vardır; kişisel gelişim hedefleri (spor, okuma, meditasyon vb.) takip etmek ister.
- **İhtiyaç:** Karmaşık olmayan, hızlı açılan, dikkat dağıtmayan bir araç.
- **Motivasyon:** Kontrol hissi, ilerleme görünürlüğü, veri gizliliği.

### 3.2 İkincil Persona: "Alışkanlık Kurucusu"
- **Yaş:** 18–35
- **Davranış:** Günlük/haftalık/aylık hedefler belirler, streak (seri) takibiyle motive olur.
- **İhtiyaç:** Basit, görsel olarak tatmin edici alışkanlık takip ekranı.

### 3.3 Üçüncül Persona: "Odaklanma Arayan Öğrenci/Çalışan"
- **Davranış:** Pomodoro tekniğiyle çalışır, dikkatini dağıtan uygulamalardan kaçınır.
- **İhtiyaç:** Reklamsız, sade bir zamanlayıcı; istatistiklerle çalışma süresini görme.

### 3.4 Kullanıcı Kitlesi Dışında Kalanlar
- Takım/departman yönetimi arayan kurumsal kullanıcılar (kapsam dışı),
- Karmaşık proje yönetimi (Gantt, kaynak planlama vb.) arayan profesyonel PM'ler (kapsam dışı),
- Sosyal paylaşım/motivasyon arayan kullanıcılar (kapsam dışı).

---

## 4. Kullanıcı Senaryoları (User Scenarios)

### Senaryo 1 — Sabah Rutini
Ayşe sabah uygulamayı açar, Dashboard'da bugünün görevlerini, günlük hedefini ve alışkanlık listesini tek ekranda görür. Tamamlanmamış 3 görevi olduğunu fark eder ve en öncelikli olanı seçip Pomodoro ile çalışmaya başlar.

### Senaryo 2 — Proje Bazlı Çalışma
Mehmet, "Web Sitesi Yenileme" adlı bir proje oluşturur, bu projenin altına görevler ekler, bazı görevlere alt görevler tanımlar ve göreve dair notlarını proje içinden ekler.

### Senaryo 3 — Alışkanlık Takibi
Zeynep her gün su içme, kitap okuma ve spor yapma alışkanlıklarını işaretler. Uygulama seri (streak) sayısını gösterir; bir gün alışkanlığı kaçırdığında istatistik ekranından bunu görür.

### Senaryo 4 — Haftalık/Aylık Planlama
Can, hafta başında haftalık hedeflerini belirler (ör. "3 kitap bölümü bitir"), ay başında ise aylık hedeflerini girer. Uygulama bu hedeflerin altına bağlı görevleri ilişkilendirmesine izin verir.

### Senaryo 5 — Çevrimdışı Kullanım
Selin, internet bağlantısı olmayan bir ortamda (uçakta) görev ekler, not alır, alışkanlık işaretler. İnternet geldiğinde uygulama otomatik olarak Firebase ile senkronize olur.

### Senaryo 6 — Güvenlik
Burak, hassas notlarının bulunduğu uygulamayı parmak izi ile kilitler. Telefonunu kaybetmesi durumunda içeriklerinin görülememesini ister.

### Senaryo 7 — Arama ve Hızlı Erişim
Elif, geçen hafta aldığı bir notu hatırlamak için arama özelliğini kullanır ve anahtar kelimeyle notuna ulaşır.

---

## 5. Kullanıcı Akışları (User Flows)

### 5.1 Onboarding & Kimlik Doğrulama Akışı
```
Uygulama Açılışı
   ↓
Splash Screen
   ↓
Kullanıcı Girişi Yapılmış mı?
   ├── Evet → Dashboard
   └── Hayır → Giriş Ekranı
                 ├── Google ile Giriş → Kimlik Doğrulama → Dashboard
                 └── E-posta ile Giriş
                        ├── Kayıt Ol (E-posta + Şifre) → Doğrulama → Dashboard
                        └── Giriş Yap (E-posta + Şifre) → Dashboard
```

### 5.2 Görev Oluşturma Akışı
```
Dashboard / Görevler Ekranı
   ↓
"+ Yeni Görev"
   ↓
Görev Başlığı Girilir
   ↓
Opsiyonel: Proje Seç / Tarih Seç / Öncelik Seç / Alt Görev Ekle
   ↓
Kaydet
   ↓
Görev Listesinde Görünür + (varsa) Yerel Bildirim Planlanır
```

### 5.3 Proje → Görev → Alt Görev Hiyerarşi Akışı
```
Projeler Ekranı
   ↓
Proje Seç / Yeni Proje Oluştur
   ↓
Proje Detay Ekranı (Görev Listesi)
   ↓
Görev Ekle
   ↓
Görev Detayına Gir
   ↓
Alt Görev Ekle
   ↓
Görev Tamamlama % Otomatik Güncellenir (alt görevlere göre)
```

### 5.4 Alışkanlık Takibi Akışı
```
Alışkanlıklar Ekranı
   ↓
Yeni Alışkanlık Oluştur (İsim, Tekrar Sıklığı, Hatırlatma Saati)
   ↓
Günlük Görünümde Alışkanlık Kartı Listelenir
   ↓
Kullanıcı Günü İşaretler (Yapıldı / Yapılmadı)
   ↓
Streak Sayacı Güncellenir
   ↓
İstatistikler Ekranına Yansır
```

### 5.5 Pomodoro Akışı
```
Pomodoro Ekranı
   ↓
(Opsiyonel) Görev Seç
   ↓
Süre Başlat (Varsayılan 25 dk çalışma / 5 dk mola)
   ↓
Zamanlayıcı Çalışır (Arka planda devam eder)
   ↓
Süre Bitince Yerel Bildirim
   ↓
Oturum Kaydedilir → İstatistiklere Yansır
```

### 5.6 Hedef Belirleme Akışı (Günlük/Haftalık/Aylık)
```
Hedefler Ekranı
   ↓
Zaman Aralığı Seç (Günlük / Haftalık / Aylık)
   ↓
Yeni Hedef Ekle (Başlık, Açıklama, Opsiyonel Görev Bağlantısı)
   ↓
İlerleme Takibi (Manuel işaretleme veya bağlı görev tamamlanma oranı)
   ↓
Süre Dolduğunda Hedef "Tamamlandı / Tamamlanmadı" Olarak Arşivlenir
```

### 5.7 Güvenlik Kilidi Akışı
```
Uygulama Arka Plana Alınır / Yeniden Açılır
   ↓
Kilit Aktif mi? (Ayarlarda tanımlı)
   ├── Hayır → Doğrudan Dashboard
   └── Evet → Kilit Ekranı
                ├── Parmak İzi Doğrulama → Başarılı → Dashboard
                └── PIN Girişi → Başarılı → Dashboard
                (Başarısız denemelerde tekrar deneme hakkı sunulur)
```

### 5.8 Senkronizasyon Akışı (Offline → Online)
```
Kullanıcı Offline İşlem Yapar (Ekle/Düzenle/Sil)
   ↓
İşlem Yerel Veritabanına Kaydedilir (Local-first)
   ↓
Bağlantı Algılanır (Online)
   ↓
Değişiklikler Firebase'e Senkronize Edilir
   ↓
Çakışma Varsa: "Son Yazan Kazanır" (Last-write-wins) Kuralı Uygulanır
```

---

## 6. Özellik Açıklamaları (Feature Specifications)

### 6.1 Kimlik Doğrulama
- **Google ile Giriş:** Firebase Authentication üzerinden tek tıkla giriş.
- **E-posta ile Giriş:** E-posta + şifre ile kayıt/giriş, şifre sıfırlama akışı içerir.
- Oturum kalıcıdır; kullanıcı elle çıkış yapmadıkça tekrar giriş istenmez.
- Hesap silme özelliği (KVKK/Play Store politikaları gereği) ayarlar içinde sunulur.

### 6.2 Dashboard (Ana Ekran)
- Bugünün görevleri (özet liste),
- Günlük hedef durumu,
- Aktif alışkanlıkların günlük check-in kartları,
- Haftalık ilerleme özeti (mini istatistik),
- Hızlı erişim butonları: Yeni Görev, Yeni Not, Pomodoro Başlat.

### 6.3 Projeler
- Sınırsız proje oluşturma,
- Proje adı, renk/ikon etiketleme, açıklama,
- Proje bazlı görev listesi ve ilerleme yüzdesi,
- Proje arşivleme (silme dışında, geri getirilebilir arşiv).

### 6.4 Görevler
- Başlık, açıklama, son tarih, saat, öncelik (Düşük/Orta/Yüksek), etiket,
- Proje ile ilişkilendirme (opsiyonel — projesiz görev de olabilir),
- Tamamlandı/Tamamlanmadı durumu,
- Tekrarlanan görev desteği (günlük/haftalık/aylık tekrar),
- Sıralama ve filtreleme (tarihe göre, önceliğe göre, projeye göre).

### 6.5 Alt Görevler
- Her göreve sınırsız alt görev eklenebilir,
- Alt görev tamamlanma durumu, ana görevin ilerleme yüzdesine yansır,
- Alt görevler bağımsız olarak yeniden sıralanabilir.

### 6.6 Takvim
- Aylık/haftalık/günlük görünüm,
- Görevlerin ve hedeflerin tarih bazlı görüntülenmesi,
- Takvimden doğrudan yeni görev oluşturma,
- Günlük ajanda görünümü (o güne ait tüm öğeler tek listede).

### 6.7 Yerel Bildirimler
- Görev son tarihi/saati yaklaştığında hatırlatma,
- Alışkanlık hatırlatmaları (kullanıcı tanımlı saat),
- Pomodoro oturum bitiş bildirimi,
- Tüm bildirimler cihaz üzerinde yerel olarak planlanır (push sunucusu gerekmez).

### 6.8 Günlük / Haftalık / Aylık Hedefler
- Üç ayrı zaman ölçeğinde bağımsız hedef tanımlama,
- Hedeflere opsiyonel olarak görev bağlama,
- İlerleme yüzdesi görselleştirme (progress bar),
- Dönem sonunda otomatik arşivleme ve geçmiş hedeflerin görüntülenebilmesi.

### 6.9 Alışkanlık Takibi
- Alışkanlık oluşturma: isim, ikon, tekrar sıklığı (her gün / haftanın belirli günleri),
- Günlük check-in (yapıldı/yapılmadı) arayüzü,
- Streak (seri) sayacı ve en uzun seri kaydı,
- Alışkanlık bazlı tamamlama oranı istatistiği.

### 6.10 Pomodoro
- Standart 25/5 dakika döngüsü, kullanıcı tarafından özelleştirilebilir süre,
- Oturumu bir göreve bağlama (opsiyonel),
- Arka planda çalışmaya devam eden zamanlayıcı,
- Tamamlanan pomodoro oturumu sayısının istatistiklere işlenmesi.

### 6.11 Notlar
- Serbest metin not oluşturma (başlık + içerik),
- Notları proje veya göreve bağlama (opsiyonel),
- Etiketleme ve renk kodlama,
- Notlarda basit biçimlendirme (kalın, madde işareti — zengin metin editörü kapsamı MVP'de sınırlı tutulur).

### 6.12 İstatistikler
- Tamamlanan görev sayısı (günlük/haftalık/aylık grafik),
- Alışkanlık tamamlama oranları,
- Toplam pomodoro süresi/oturum sayısı,
- Hedef başarı oranı (dönemsel).

### 6.13 Arama
- Görev, proje, not, alışkanlık genelinde birleşik arama,
- Anahtar kelime ve filtre (tür, tarih) bazlı arama,
- Son aramalar geçmişi.

### 6.14 Tema Sistemi
- Açık/Koyu tema,
- Sistem temasını takip etme seçeneği,
- (Opsiyonel MVP+) Sınırlı sayıda vurgu rengi seçimi.

### 6.15 Parmak İzi ve PIN
- Uygulama açılışında veya arka plandan dönüşte kilit,
- Biyometrik doğrulama (parmak izi/yüz tanıma — cihaz destekliyorsa),
- PIN kodu yedek doğrulama yöntemi olarak,
- Kilit özelliği kullanıcı tarafından açılıp kapatılabilir (varsayılan: kapalı).

### 6.16 Offline Çalışma
- Tüm CRUD işlemleri internet olmadan yerel veritabanı üzerinde çalışır,
- Uygulama hiçbir özellik için zorunlu internet bağlantısı istemez,
- Bağlantı geldiğinde otomatik, kullanıcı müdahalesi gerektirmeyen senkronizasyon.

### 6.17 Firebase Senkronizasyonu
- Kullanıcı verisinin bulutta (Firestore) yedeklenmesi,
- Cihaz değişikliğinde veya yeniden kurulumda veri geri yükleme,
- Senkronizasyon durumu göstergesi (senkronize / bekleniyor / hata),
- Çakışma çözümleme: son değişiklik zaman damgasına göre önceliklendirme.

---

## 7. Uygulamanın Sınırları (Out of Scope)

Aşağıdaki maddeler bu ürünün **kapsamı dışındadır** ve MVP veya sonrası için planlanmamaktadır (aksi ayrıca belirtilmedikçe):

- Yapay zekâ destekli öneri, otomatik özetleme veya doğal dil işleme özellikleri,
- Herhangi bir premium/abonelik modeli, satın alma akışı veya kilitli özellik,
- Reklam gösterimi veya üçüncü taraf reklam SDK entegrasyonu,
- Takım çalışması: görev/proje paylaşımı, davet sistemi, yorum, atama, çoklu kullanıcı erişimi,
- Sosyal özellikler (paylaşım, takip etme, liderlik tablosu, topluluk),
- Üçüncü taraf takvim entegrasyonları (Google Calendar, Outlook vb. senkronizasyonu),
- Masaüstü veya web istemcisi (MVP yalnızca Android mobil),
- Zengin metin editörü / dosya eki / ses kaydı notları,
- Konum tabanlı hatırlatmalar,
- Gerçek zamanlı çoklu cihaz eşzamanlı düzenleme (yalnızca senkronizasyon, gerçek zamanlı ortak düzenleme değil).

---

## 8. Başarı Kriterleri (Success Metrics)

### 8.1 Ürün Kalitesi Kriterleri
| Kriter | Hedef |
|---|---|
| Uygulama çökme oranı (crash-free rate) | %99.5 ve üzeri |
| Soğuk başlatma (cold start) süresi | 2 saniyenin altında |
| Offline'dan online'a senkronizasyon başarı oranı | %99 ve üzeri veri kaybı olmadan |
| Play Store puanı (yayından 3 ay sonra) | 4.3 ve üzeri |

### 8.2 Kullanıcı Etkileşim Kriterleri
| Kriter | Hedef |
|---|---|
| Gün 1 kullanıcı tutundurma (retention) | %35+ |
| Gün 7 kullanıcı tutundurma | %15+ |
| Gün 30 kullanıcı tutundurma | %8+ |
| Ortalama günlük aktif kullanıcı başına tamamlanan görev sayısı | 3+ |
| Alışkanlık takibi kullanan aktif kullanıcı oranı | %40+ |
| Haftalık en az 1 pomodoro oturumu tamamlayan kullanıcı oranı | %25+ |

### 8.3 İş/Ürün Sağlığı Kriterleri
- Kullanıcı destek talebi başına ortalama çözüm süresi < 48 saat,
- Kimlik doğrulama akışında terk oranı (drop-off) < %10,
- Uygulama izin reddi nedeniyle bildirim özelliğini kullanamayan kullanıcı oranının izlenmesi (bilgi amaçlı, hedef belirlenmez).

---

## 9. MVP Kapsamı (Minimum Viable Product)

MVP, Play Store'da yayına uygun, tüm temel değer önerisini sunan ama karmaşıklığı minimumda tutan ilk sürümdür.

### 9.1 MVP'de Yer Alan Özellikler
- ✅ Google ile Giriş
- ✅ E-posta ile Giriş
- ✅ Dashboard (bugünün görevleri, günlük hedef, alışkanlık özeti)
- ✅ Projeler (oluştur, düzenle, arşivle)
- ✅ Görevler (tam CRUD, öncelik, tarih, proje bağlama)
- ✅ Alt Görevler
- ✅ Takvim (aylık + günlük görünüm; haftalık görünüm MVP+ olabilir)
- ✅ Yerel Bildirimler (görev ve alışkanlık hatırlatmaları)
- ✅ Günlük / Haftalık / Aylık Hedefler
- ✅ Alışkanlık Takibi (temel check-in + streak)
- ✅ Pomodoro (sabit döngü + göreve bağlama)
- ✅ Notlar (temel metin, proje/görev bağlama)
- ✅ İstatistikler (temel grafikler: görev, alışkanlık, pomodoro)
- ✅ Arama (görev + proje + not birleşik arama)
- ✅ Tema Sistemi (Açık/Koyu + Sistem)
- ✅ Parmak İzi ve PIN kilidi
- ✅ Offline çalışma (local-first mimari)
- ✅ Firebase senkronizasyonu (temel senkronizasyon, çakışma çözümü ile)

### 9.2 MVP Dışına Ertelenebilecek Detaylar (MVP+ / v1.1)
- Takvimde haftalık görünüm,
- Notlarda gelişmiş biçimlendirme,
- Tema sisteminde özel vurgu rengi seçenekleri,
- Alışkanlıklar için gelişmiş tekrar kuralları (ör. "ayda 3 kez"),
- İstatistiklerde dışa aktarma (PDF/CSV).

> Not: Bu maddeler MVP kapsamı dışıdır ancak "Kapsam Dışı" (Bölüm 7) listesinden farklıdır — bunlar ürünün doğal genişlemesidir, sadece ilk sürümde önceliklendirilmemiştir.

---

## 10. Gelecekte Eklenebilecek Özellikler (Yalnızca Fikir Aşamasında)

> **Önemli not:** Bu bölümdeki maddeler yalnızca gelecek fikirleri olarak listelenmiştir. Hiçbiri onaylanmış bir yol haritası öğesi değildir ve ürünün mevcut ilkeleriyle (AI yok, premium yok, reklam yok, takım çalışması yok) çelişen hiçbir fikir uygulanmayacaktır. Bu bölüm yalnızca beyin fırtınası amaçlıdır.

- Widget desteği (ana ekran görev/alışkanlık widget'ı),
- Wear OS (akıllı saat) desteği,
- Veri dışa/içe aktarma (JSON/CSV yedekleme),
- Gelişmiş istatistik/analiz görünümleri (ısı haritası, trend grafikleri),
- Görev şablonları (tekrarlayan proje yapıları için),
- Sesli not ekleme (transkripsiyon olmadan, yalnızca ses dosyası),
- Erişilebilirlik geliştirmeleri (ekran okuyucu optimizasyonu, yazı tipi ölçekleme),
- iOS sürümü (platform genişletme),
- Uygulama içi yedekleme/geri yükleme geçmişi (versiyonlama),
- Klavye kısayolları / tablet optimize arayüz.

---

## 11. Varsayımlar ve Kısıtlar

### 11.1 Varsayımlar
- Kullanıcılar Google Play Services yüklü Android cihaz kullanmaktadır,
- Firebase (Authentication + Firestore) altyapısı kullanılacaktır,
- Uygulama tek dil ile başlayabilir (Türkçe/İngilizce lokalizasyon kapsamı ayrı değerlendirilecektir — bu doküman dil kapsamına karar vermez),
- Kullanıcı başına veri hacmi kişisel kullanım ölçeğindedir (kurumsal ölçek değildir).

### 11.2 Kısıtlar
- Uygulama Play Store politikalarına (veri gizliliği, hesap silme, izin kullanımı) tam uyumlu olmalıdır,
- Biyometrik kilit özelliği cihaz donanım desteğine bağlıdır; desteklemeyen cihazlarda yalnızca PIN sunulmalıdır,
- Yerel bildirimler, cihazın pil optimizasyonu ayarlarından etkilenebilir; bu, kullanıcıya açıkça belirtilmelidir.

---

## 12. Onay ve Sonraki Adımlar

Bu PRD, aşağıdaki aşamalar için temel referans doküman olarak kullanılacaktır:
1. Bilgi mimarisi ve kullanıcı arayüzü (UX/UI) tasarım süreci,
2. Veri modeli ve mimari tasarım dokümanı (ADR),
3. Flutter teknik implementasyon planı,
4. Play Store yayın öncesi kontrol listesi (gizlilik politikası, izinler, veri güvenliği formu).

**Bu doküman kapsamında herhangi bir kod, arayüz tasarımı veya teknik implementasyon detayı üretilmemiştir.** Sonraki adımlarda ayrı dokümanlar/görevler olarak ele alınacaktır.

