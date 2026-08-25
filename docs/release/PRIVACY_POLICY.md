# Gizlilik Politikası — Productivity App

**Son güncelleme:** 25 Ağustos 2026

> **Yayınlanan sayfa (Play/App Store'a eklenecek URL):**
> https://claude.ai/code/artifact/80d0d46a-296f-4fd4-8190-2753b81f7675
>
> Bu dosya (`PRIVACY_POLICY.md`) referans/versiyon kontrolü içindir — yukarıdaki
> Artifact sayfası mağaza formlarına eklenecek gerçek, canlı URL'dir. Store
> Console'a eklemeden önce sayfanın paylaşım menüsünden **herkese açık**
> yapılması gerekir (varsayılan olarak private yayınlanır).

Bu gizlilik politikası, Productivity App ("Uygulama") tarafından toplanan, kullanılan ve saklanan verileri açıklar. Uygulamayı kullanarak bu politikayı kabul etmiş olursunuz.

## 1. Uygulamanın Doğası

Productivity App kişisel bir üretkenlik uygulamasıdır (görev, proje, alışkanlık, hedef, not ve pomodoro takibi). Uygulama:
- **Reklam içermez.**
- **Üçüncü taraf analitik veya reklam SDK'sı kullanmaz.**
- **Yapay zeka özelliği içermez.**
- **Takım/paylaşım özelliği içermez** — tüm veriler yalnızca kendi hesabınıza aittir ve başka kullanıcılarla paylaşılmaz.
- **Premium/ücretli katman içermez.**

## 2. Toplanan Veriler

### 2.1 Hesap Bilgileri (Firebase Authentication)
Hesap oluştururken veya Google ile giriş yaparken şu bilgiler işlenir:
- E-posta adresiniz
- Adınız (kayıt formunda veya Google hesabınızdan)
- Google ile giriş yaptıysanız Google profil bilgileriniz (ad, e-posta, profil fotoğrafı URL'si)

Şifreniz hiçbir zaman uygulama tarafından görülmez veya saklanmaz — kimlik doğrulama tamamen Firebase Authentication altyapısı tarafından yönetilir.

### 2.2 Kişisel Üretkenlik Verisi (Cloud Firestore)
Uygulamada oluşturduğunuz tüm içerik — görevler, projeler, alt görevler, notlar, alışkanlıklar ve check-in kayıtları, hedefler, pomodoro oturumları, istatistik özetleri, etiketler ve uygulama tercihleriniz — hesabınıza özel olarak Google Cloud Firestore'da saklanır. Bu veriler:
- Yalnızca sizin hesabınızla ilişkilendirilir (`users/{kullanıcı_kimliği}` yolu altında, sunucu tarafı güvenlik kurallarıyla izole edilir — başka bir kullanıcı bu verilere erişemez).
- Cihazınızda da (Isar yerel veritabanı) çevrimdışı erişim için önbelleğe alınır.
- Reklam, pazarlama veya üçüncü taraflarla paylaşım amacıyla **kullanılmaz**.

### 2.3 Uygulama Kilidi (PIN/Biyometrik)
Uygulama kilidi etkinleştirdiyseniz, PIN'iniz asla düz metin olarak saklanmaz — yalnızca rastgele bir tuz (salt) ile birlikte tek yönlü (SHA-256) özeti, cihazınızın güvenli donanım destekli deposunda (Android Keystore) tutulur. Biyometrik veri (parmak izi/yüz) hiçbir zaman uygulamaya veya sunuculara iletilmez — doğrulama tamamen işletim sisteminin kendi güvenli katmanında gerçekleşir. **Bu veriler hiçbir zaman Firestore'a senkronize edilmez veya cihaz dışına çıkmaz.**

### 2.4 Bildirimler
Görev/alışkanlık/pomodoro hatırlatmaları tamamen cihazınız üzerinde yerel olarak planlanır. Bildirim göndermek için herhangi bir üçüncü taraf push bildirim sunucusu (örn. FCM push) veya harici servis kullanılmaz.

### 2.5 Toplanmayan Veriler
Uygulama; konum verisi, kişi listesi, fotoğraf galerisi, mikrofon/kamera erişimi, reklam kimliği (advertising ID) veya kullanım analitiği/çökme (crash) raporlaması **toplamaz**.

## 3. Verilerin Kullanım Amacı
Toplanan tüm veriler yalnızca uygulamanın temel işlevini (görevlerinizi/alışkanlıklarınızı/notlarınızı cihazlar arasında senkronize etmek ve size göstermek) sağlamak için kullanılır. Hiçbir veri reklam hedeflemesi, profil oluşturma veya üçüncü taraflara satış amacıyla kullanılmaz.

## 4. Veri Paylaşımı
Verileriniz, uygulamanın altyapısını sağlayan Google Firebase (Authentication, Firestore) dışında **hiçbir üçüncü tarafla paylaşılmaz**. Firebase'in kendi gizlilik politikası için: https://firebase.google.com/support/privacy

## 5. Veri Saklama ve Silme
Hesabınızı, Ayarlar → Hesap → "Hesabı Sil" yolunu izleyerek istediğiniz zaman kalıcı olarak silebilirsiniz. Hesap silindiğinde:
- Firebase Authentication hesabınız silinir.
- Firestore'daki tüm kişisel verileriniz kalıcı olarak silinir.

Bu işlem geri alınamaz.

## 6. İzinler
Uygulama şu izinleri talep edebilir:
- **Bildirim izni:** Görev/alışkanlık/pomodoro hatırlatmalarını gösterebilmek için (Android 13+).
- **Biyometrik donanım izni:** Uygulama kilidini parmak izi/yüz tanıma ile açabilmeniz için (yalnızca bu özelliği etkinleştirirseniz).

Bu izinlerin hiçbiri reklam veya analitik amaçlı kullanılmaz.

## 7. Çocukların Gizliliği
Uygulama genel kullanıcı kitlesine yöneliktir ve bilerek 13 yaşın altındaki çocuklardan veri toplamaz.

## 8. Politika Değişiklikleri
Bu politika güncellenirse, güncel sürüm bu sayfada yayınlanır ve sayfanın en üstündeki "Son güncelleme" tarihi değiştirilir.

## 9. İletişim
Bu gizlilik politikasıyla ilgili sorularınız için: **[GELİŞTİRİCİ İLETİŞİM E-POSTASI BURAYA EKLENECEK]**
