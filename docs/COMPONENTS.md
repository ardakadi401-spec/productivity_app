# COMPONENTS.md
## Kişisel Üretkenlik Uygulaması — UI Component Library Dokümanı

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior Mobile UI Engineer / Senior Design System Architect / Flutter Component Library Uzmanı
**Referans Dokümanlar:** `PRD.md`, `UI_GUIDELINES.md`, `ARCHITECTURE.md`, `DATABASE.md`, `FOLDER_STRUCTURE.md`, `STATE_MANAGEMENT.md`
**Doküman Durumu:** Component Referans Kütüphanesi — Tüm ekran geliştirmeleri bu dokümandaki bileşenleri kullanmalıdır

> Bu doküman yalnızca component tasarım standartlarını tanımlar. Kod, widget veya implementasyon içermez. Tüm ölçü, renk, radius, boşluk ve animasyon değerleri `UI_GUIDELINES.md`'den birebir alınır; bu doküman yeni bir token türetmez, yalnızca mevcut tokenları somut bileşenlere uygular.

---

## 0. Kapsam ve Sınırlar

- Bu doküman, `UI_GUIDELINES.md`'de tanımlanmış renk paleti (Bölüm 3), tipografi (Bölüm 4), spacing (Bölüm 5), grid (Bölüm 6), mevcut component standartları (Bölüm 7), ikonografi (Bölüm 8), animasyon (Bölüm 9) ve erişilebilirlik (Bölüm 11) kararlarını **değiştirmez**; bunları component seviyesinde detaylandırır ve birbirleriyle tutarlı bir kütüphaneye dönüştürür.
- `STATE_MANAGEMENT.md` Bölüm 8'de tanımlanan beş UI-state durumu (Loading/Success/Empty/Error/Refreshing), Bölüm 10 (Feedback Components)'daki bileşenlerin doğrudan görsel karşılığıdır.
- `DATABASE.md`'de tanımlanan veri alanları (örn. `priority`: low/medium/high, `status`: pending/completed, kategori/etiket rengi, proje rengi, `currentStreak`/`longestStreak`, hedef `progressType`) bu dokümandaki component tasarımlarının veri kaynağıdır; hiçbir yeni alan varsayılmaz.
- PRD Bölüm 2.4 ve 7'deki kapsam sınırları (AI yok, premium yok, reklam yok, takım çalışması yok) geçerlidir — hiçbir component bu ilkelerle çelişmez (örn. hiçbir "yükseltme/kilit" rozeti tasarlanmaz).
- Bu doküman yeni bir ekran, yeni bir özellik veya yeni bir renk/tipografi tokenı tanımlamaz.

---

## 1. Component Philosophy

### 1.1 Temel Yaklaşım
Component kütüphanesi, `UI_GUIDELINES.md` Bölüm 1–2'deki tasarım felsefesinin (ferahlık, premium, güven, hız, sadelik) **tekrar kullanılabilir yapı taşlarına** dönüştürülmüş halidir. Her component:
- Yalnızca token'lara (renk, tipografi, spacing, radius, elevation) bağımlıdır — asla sabit/hard-coded bir değer taşımaz,
- Tüm ekranlarda **aynı görünüp aynı davranır** (`UI_GUIDELINES.md` İlke 6 — "Consistency beats novelty"),
- Üç temada (Açık/Koyu/AMOLED) otomatik uyum sağlayacak şekilde tasarlanır (Bölüm 12).

### 1.2 Atomic Yaklaşım (Kavramsal Seviyeler)
Bileşenler üç kavramsal seviyede organize edilir (bu, `FOLDER_STRUCTURE.md`'deki dosya organizasyonunun tasarım karşılığıdır, klasör yapısını değiştirmez):
- **Temel (Foundation):** Buton, input, chip, badge, checkbox gibi tek başına anlamlı en küçük etkileşim birimleri (Bölüm 3–4).
- **Bileşik (Composite):** Kart, liste öğesi gibi birden fazla temel bileşeni bir araya getiren yapılar (Bölüm 4.1, 6–9).
- **Yapısal (Structural):** AppBar, Bottom Navigation, Page Container gibi ekranın iskeletini oluşturan bileşenler (Bölüm 2).

### 1.3 Tekrarı Önleme İlkesi
Aynı görsel/işlevsel ihtiyaç birden fazla feature'da ortaya çıktığında (örn. hem Task hem Note kartında bir "renk noktası" göstergesi), bu ihtiyaç **ayrı ayrı tasarlanmaz**; tek bir temel bileşen (örn. Bölüm 5.6 Category/Color Chip) tüm feature'larda aynı şekilde tüketilir. Bu, `ARCHITECTURE.md` Bölüm 3.5'teki Shared Layer prensibinin tasarım karşılığıdır — bir component yalnızca gerçekten 2 veya daha fazla feature tarafından kullanılıyorsa "paylaşılan" olarak sınıflandırılır.

### 1.4 Component Belirleme Kuralı
Yeni bir ekran tasarlanırken önce bu dokümandaki mevcut component setine bakılır; yalnızca gerçekten karşılanmayan bir ihtiyaç varsa yeni bir component **bu dokümana eklenerek** tanımlanır — ekran bazında tek seferlik, dokümante edilmemiş bileşen üretilmez.

---

## 2. Layout Components (App Structure)

### 2.1 App Bar
| Özellik | Değer |
|---|---|
| Kullanım amacı | Ekran bağlamını (başlık) ve en fazla 2 ikincil eylemi göstermek |
| Nerede kullanılır | Tüm ana ve detay ekranlarının üstünde (`UI_GUIDELINES.md` Bölüm 7.1) |
| Boyut | Yükseklik 56dp |
| Renk | Arka plan `color/surface`; scroll edilmeden gölgesiz, yalnızca `color/border` alt ayraç |
| Tipografi | Başlık `type/h2`, sola hizalı |
| Durumlar | Varsayılan (gölgesiz) / Scroll edilmiş (`elevation/1` belirir — elevation-on-scroll) |
| Etkileşim | Sol: geri butonu (Bölüm 11.3) veya yok; sağ: en fazla 2 ikon eylemi, her biri 48dp dokunma alanlı |

### 2.2 Bottom Navigation
| Özellik | Değer |
|---|---|
| Kullanım amacı | Ana feature grupları (Dashboard, Tasks/Projects, Calendar, Habits/Goals, Settings gibi gruplamalar) arasında birincil gezinme |
| Nerede kullanılır | Uygulamanın kök shell yapısı (`ARCHITECTURE.md` Bölüm 9.3 — ShellRoute) |
| Boyut | Yükseklik 64dp + güvenli alan |
| Renk | Aktif sekme `color/primary` (ikon + etiket); pasif sekmeler `color/text-secondary` |
| Tipografi | Sekme etiketi `type/caption` |
| Durumlar | Aktif / Pasif |
| Etkileşim | Aktif durum göstergesi: ikon üstünde ince (3dp) yuvarlatılmış çizgi veya `color/primary-light` kapsül; 4–5 sekme sınırı |

### 2.3 Drawer
- Bu uygulamada **kullanılmaz.** `UI_GUIDELINES.md` Bölüm 13.6'daki "bilgi mimarisi sığ tutulur, Dashboard'dan en fazla 2 dokunuş" ilkesi ve Bottom Navigation'ın 4–5 sekmeyle tüm ana feature gruplarını karşılaması nedeniyle, ek bir yan menü katmanına ihtiyaç yoktur. Bottom Navigation dışında kalan ikincil erişimler (Search, Statistics, Profile gibi) AppBar ikon eylemleri veya Dashboard içi hızlı erişim kartlarıyla sağlanır.

### 2.4 Page Container
| Özellik | Değer |
|---|---|
| Kullanım amacı | Her ekranın içerik alanını standart kenar boşlukları ve zeminle sarmalamak |
| Nerede kullanılır | Tüm ekranlar (kök yapı) |
| Boyut | Yatay margin 16dp (kompakt), 20dp (geniş telefon/tablet geçişi — `UI_GUIDELINES.md` Bölüm 5.2) |
| Renk | Arka plan `color/background` |
| Durumlar | Normal / Kaydırılabilir (scrollable) — çoğu ekranın varsayılan durumu |
| Etkileşim | Pull-to-refresh destekli ekranlarda, `UI_GUIDELINES.md` Bölüm 9.3'teki marka renginde ince spinner kullanılır |

### 2.5 Section Header
| Özellik | Değer |
|---|---|
| Kullanım amacı | Bir ekran içinde birden fazla bölümü (örn. Dashboard'da "Bugünün Görevleri", "Alışkanlıklar") ayırmak |
| Nerede kullanılır | Dashboard, liste ekranları, detay ekranları |
| Boyut | Üst boşluk `space/lg` (24dp) — bir önceki bölümden ayrım için |
| Tipografi | Başlık `type/h2` (`color/text-primary`); opsiyonel sağda "Tümünü Gör" `type/button` metin bağlantısı |
| Durumlar | Yalnızca başlık / Başlık + aksiyon bağlantısı |
| Etkileşim | Sağdaki opsiyonel aksiyon (örn. "Tümünü Gör"), ilgili listenin tam ekran görünümüne yönlendirir |

---

## 3. Button Components

`UI_GUIDELINES.md` Bölüm 10'daki dört buton tipine, Icon Button ve FAB eklenerek altı bileşenlik tam set:

| Bileşen | Kullanım Amacı | Renk | Boyut | Radius | Padding |
|---|---|---|---|---|---|
| **Primary Button** | Ekran başına tek, en önemli eylem (Kaydet, Oluştur, Giriş Yap) | Dolgu `color/primary`, metin beyaz | Yükseklik 52dp, tam genişlik veya içerik genişliği | 12dp | Yatay `space/lg` (24dp), dikey `space/md` (16dp) |
| **Secondary Button** | İkincil eylemler (İptal, Daha Fazla) | Border 1.5dp `color/primary`, metin `color/primary`, dolgusuz | Yükseklik 52dp | 12dp | Primary ile aynı |
| **Outline Button** | Secondary ile aynı görsel aileden, düşük vurgulu bağlamsal eylemler (örn. kart içi "Detay Gör") | Border 1dp `color/border`, metin `color/text-primary` | Yükseklik 44dp (kart içi kullanım için Primary'den kompakt) | 10dp | Yatay `space/md` (16dp), dikey `space/sm` (8dp) |
| **Text Button** | Düşük vurgulu eylemler (Vazgeç, Atla) | Dolgusuz, bordersız, metin `color/primary` veya `color/text-secondary` | Yükseklik 44dp | — (radius yok, yalnızca metin) | Yatay `space/sm` (8dp) |
| **Icon Button** | Tek ikonla ifade edilen hızlı eylemler (AppBar eylemleri, liste öğesi hızlı aksiyonları) | İkon `color/text-secondary` (aktifte `color/primary`) | Görsel 24dp ikon, dokunma alanı 48dp x 48dp (`UI_GUIDELINES.md` Bölüm 11.1) | Tam yuvarlak dokunma alanı | — |
| **Floating Action Button (FAB)** | Ekranın birincil "ekle" eylemi | Dolgu `color/primary`, ikon beyaz | 56dp standart, 40dp mini (yalnızca ikincil ekranlar) | Tam yuvarlak | — |

### 3.1 Destructive Varyant
Primary veya Secondary Button'ın `color/accent-danger` ile render edilen varyantıdır (silme, hesap kapatma gibi geri döndürülemez eylemler — `UI_GUIDELINES.md` Bölüm 10). Ayrı bir bileşen değildir; mevcut Primary/Secondary Button'ın renk parametresi değişir.

### 3.2 Ortak Kurallar (Tüm Buton Tipleri)
- Minimum dokunma alanı her zaman 48dp x 48dp (`UI_GUIDELINES.md` Bölüm 11.1).
- Buton metni her zaman aksiyon fiiliyle başlar ("Görevi Kaydet" — belirsiz "Tamam" kullanılmaz).
- Bir ekranda aynı anda en fazla **1 Primary Button** bulunur.
- Buton metni tipografisi: `type/button` (15sp, SemiBold).
- Durumlar: Default / Basılı (100ms ease-out ölçek animasyonu — `UI_GUIDELINES.md` Bölüm 9.2) / Disabled (%50 opaklık) / Loading (metin yerine ince, marka renginde spinner — buton boyutu sabit kalır, layout kaymaz).

---

## 4. Card Components

`UI_GUIDELINES.md` Bölüm 7.4'teki temel Card standardı (16dp radius, `elevation/1`, 16dp padding, 48dp minimum dokunma yüksekliği) tüm kart varyantlarının ortak temelidir. Her varyant, bu temele feature'a özgü içerik düzeni ekler.

### 4.1 Ortak Kart İskeleti
Tüm kartlar aynı üç bölgeli düzeni paylaşır:
1. **Başlık Bölgesi:** `type/h3` başlık + opsiyonel sağ üst hızlı eylem (ikon buton veya durum rozeti).
2. **İçerik Bölgesi:** `type/body-md` açıklama/meta bilgi, `space/sm` (8dp) iç öğe aralığıyla.
3. **Alt Bölge (opsiyonel):** İlerleme çubuğu, etiket/chip grubu veya tarih bilgisi — `space/sm` üst boşlukla ayrılır.

### 4.2 Task Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Görev listesinde tek bir görevi temsil etmek |
| İçerik düzeni | Sol: Completion Checkbox (Bölüm 6.3) → Orta: başlık (`type/body-lg`) + Due Date Label + Category Chip → Sağ: Priority Badge |
| Köşe/gölge/padding | Standart Card temeli (16dp / `elevation/1` / 16dp) |
| Durumlar | Bekliyor / Tamamlandı (metin üstü çizili + soluklaşmış — `UI_GUIDELINES.md` Bölüm 7.13) / Gecikmiş (Due Date Label `color/accent-danger`) |
| Etkileşim | Dokunma → görev detayına gider; uzun basma/kaydırma → hızlı eylemler (tamamla, ertele, sil — `UI_GUIDELINES.md` Bölüm 13.7) |

### 4.3 Project Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Proje listesinde bir projeyi özetlemek |
| İçerik düzeni | Sol: Project Color Badge (Bölüm 7.3) → Başlık (`type/h3`) → Alt: bağlı görev sayısı özeti (`type/caption`, `color/text-secondary`) + Progress Indicator (Bölüm 7.2) |
| Durumlar | Aktif / Arşivlenmiş (%60 opaklık, "Arşivlendi" `type/caption` rozeti) |
| Etkileşim | Dokunma → proje detay ekranına gider |

### 4.4 Goal Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Günlük/haftalık/aylık hedefi göstermek |
| İçerik düzeni | Başlık (`type/h3`) + zaman aralığı etiketi (`type/overline`: "GÜNLÜK" / "HAFTALIK" / "AYLIK") → İlerleme çubuğu (dolgu `color/secondary` — alışkanlık/hedef bağlamı, `UI_GUIDELINES.md` Bölüm 7.10) → Yüzde metni (`type/caption`) |
| Durumlar | Devam Ediyor / Başarıldı (yeşil `color/secondary` check ikonu) / Kaçırıldı (`color/text-secondary`, soluk, "Kaçırıldı" etiketi — kırmızı kullanılmaz, bu bir hata değildir) |
| Etkileşim | Dokunma → hedef detayına gider; `manualProgress` tipi hedeflerde kart üstünden hızlı yüzde güncelleme mümkündür |

### 4.5 Habit Card
Bölüm 8.1'de ayrıntılı tanımlanmıştır (Habit Components başlığı altında, çünkü hem Card hem Habit-özel etkileşim içerir).

### 4.6 Statistics Card
Bölüm 9.4'te (Statistic Summary Card) ayrıntılı tanımlanmıştır.

### 4.7 Note Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Not listesinde bir notu özetlemek |
| İçerik düzeni | Sol kenarda ince (4dp) renk şeridi (notun `color` alanı — `DATABASE.md` not renk alanı) → Başlık (`type/h3`) → İçerik önizlemesi (`type/body-md`, en fazla 2 satır, taşarsa "…") → Alt: bağlı proje/görev chip'i (varsa) |
| Durumlar | Normal / Bağlantısız (proje/görev bağlantısı olmayan notlarda alt bölge gösterilmez) |
| Etkileşim | Dokunma → not detay/düzenleme ekranına gider |

---

## 5. Form Components

`UI_GUIDELINES.md` Bölüm 7.12–7.15'teki tanımların tam seti, eksik olanlar (Dropdown, Search Input ayrımı) eklenerek:

### 5.1 Text Input
| Özellik | Değer |
|---|---|
| Boyut | Yükseklik 52dp, radius 12dp |
| Durumlar | Default (`color/border`) / Focus (`color/primary`, 1.5dp) / Error (`color/accent-danger` + alt hata metni) / Disabled (%50 opaklık) |
| Kural | Label her zaman alan üstünde sabit (floating label kullanılmaz); hata mesajı her zaman çözüm odaklı |

### 5.2 Search Input
| Özellik | Değer |
|---|---|
| Kullanım amacı | Search feature'ında ve liste ekranlarındaki filtre arama kutusunda |
| Boyut | Yükseklik 48dp, radius 12dp (`UI_GUIDELINES.md` Bölüm 7.11) |
| Renk | Arka plan `color/surface` + ince `color/border`; focus'ta 1.5dp `color/primary` kenarlık |
| İçerik | Sol: sabit arama ikonu; sağ: yalnızca metin girildiğinde görünen temizle ikonu |
| Etkileşim | Yazarken debounce ile sonuç güncellenir (`STATE_MANAGEMENT.md` Bölüm 10.3) |

### 5.3 Password Input
Text Input'un bir varyantıdır; ek olarak sağda göz ikonu (göster/gizle toggle) taşır. Diğer tüm ölçü/durum kuralları Text Input ile birebir aynıdır.

### 5.4 Dropdown
| Özellik | Değer |
|---|---|
| Kullanım amacı | Proje/kategori seçimi, sıralama kriteri seçimi gibi tek seçimli sabit liste seçimleri |
| Boyut | Yükseklik 52dp, radius 12dp (Text Input ile tutarlı) |
| Durumlar | Default / Focus (açık) / Disabled |
| Etkileşim | Dokunulduğunda Bottom Sheet (Bölüm 10.7) içinde seçenek listesi açılır — native dropdown menüsü yerine, `UI_GUIDELINES.md`'nin genel "dialog yerine bottom sheet tercih edilir" ilkesiyle uyumlu (Bölüm 7.6) |

### 5.5 Date Picker / Time Picker
`UI_GUIDELINES.md` Bölüm 7.15 birebir esas alınır: native platform bileşeni, marka renkleriyle temalandırılır; "Bugün", "Yarın", "Gelecek Hafta" hızlı seçim chip'leri picker üstünde sunulur.

### 5.6 Switch
`UI_GUIDELINES.md` Bölüm 7.14 birebir esas alınır: 51dp x 31dp, açık durumda `color/primary` dolgu, 150ms ease-in-out geçiş. Kullanım alanı: Settings feature'ında tema/bildirim/kilit tercihleri.

### 5.7 Checkbox
`UI_GUIDELINES.md` Bölüm 7.13 birebir esas alınır: 22dp boyut, 6dp radius, 44dp x 44dp dokunma alanı, 150ms scale-in. İki kullanım bağlamı ayırt edilir:
- **Form Checkbox:** Genel form onayları (örn. "Beni hatırla") için standart görünüm.
- **Completion Checkbox:** Task/Habit tamamlama için özel davranış (Bölüm 6.3).

---

## 6. Task Components

### 6.1 Task Item
Task Card'ın (Bölüm 4.2) temel yapı taşı; liste içi kompakt satır görünümüdür. Task Card, Task Item'ın kart-sarmalanmış halidir — aynı iç bileşenleri (checkbox, başlık, badge, chip, label) paylaşır.

### 6.2 Priority Badge
| Özellik | Değer |
|---|---|
| Kullanım amacı | Görevin `priority` alanını (low/medium/high — `DATABASE.md`) görsel olarak iletmek |
| Boyut | Badge, `UI_GUIDELINES.md` Bölüm 7.9 temel alınır: 18dp yükseklik, dinamik genişlik |
| Renk | Öncelik pastel setinden (`UI_GUIDELINES.md` Bölüm 3.3) sabit üç eşleme: Low → `#8CE99A`, Medium → `#FFC078`, High → `#FF8A8A` |
| Erişilebilirlik | Renk tek başına yeterli değildir (`UI_GUIDELINES.md` Bölüm 11.3): her badge içinde kısa metin ("Düşük"/"Orta"/"Yüksek") veya harf (D/O/Y) bulunur |
| Etkileşim | Statik gösterge; dokunulamaz (bilgi amaçlı) |

### 6.3 Completion Checkbox
`UI_GUIDELINES.md` Bölüm 7.13 ve 9.3 birebir esas alınır: işaretlenince `color/primary` dolgu + beyaz check + 150ms scale-in; ardından görev metni 300ms içinde üstü çizili + soluklaşmış hale geçer; hafif haptic titreşim eşlik eder. Silme öncesi görsel onay niteliğindedir.

### 6.4 Due Date Label
| Özellik | Değer |
|---|---|
| Kullanım amacı | Görevin son tarihini/saatini kısa biçimde göstermek |
| Tipografi | `type/caption` |
| Renk | Normal: `color/text-secondary` / Bugün: `color/accent-info` / Yaklaşan (24 saat içinde): `color/accent-warning` / Gecikmiş: `color/accent-danger` |
| Erişilebilirlik | Gecikmiş durumda renk + saat ikonu + "Gecikti" metni birlikte kullanılır (`UI_GUIDELINES.md` Bölüm 11.3) |

### 6.5 Category Chip
`UI_GUIDELINES.md` Bölüm 7.8 (Chip) temel alınır: 32dp yükseklik, tam yuvarlak (pill) radius. Kategori'nin `DATABASE.md`'de tanımlı `color` alanı, chip dolgu rengi olarak kullanılır (düşük opaklık arka plan + tam opaklık metin — kontrast kuralına uyum için).

### 6.6 Tag Chip
Category Chip ile aynı temel (32dp, pill radius) ancak varsayılan durumu her zaman **Default** (border'lı, dolgusuz) biçimindedir — Category Chip'ten görsel olarak ayrışması için etiketler dolgu almaz, yalnızca border + metin taşır. Birden fazla etiket yan yana `space/xs` (4dp) boşlukla dizilir.

---

## 7. Project Components

### 7.1 Project Preview Card
Bölüm 4.3'teki Project Card ile aynı bileşendir; "Preview" adlandırması yalnızca Dashboard gibi özet alanlarda kullanılan **kompakt varyantı** ifade eder: aynı iskelet, yalnızca alt bölge (görev sayısı özeti) gizlenebilir, yalnızca başlık + Progress Indicator gösterilir.

### 7.2 Progress Indicator
| Özellik | Değer |
|---|---|
| Kullanım amacı | Proje/hedef tamamlanma yüzdesini göstermek |
| Boyut | `UI_GUIDELINES.md` Bölüm 7.10 esas alınır: 6dp (kart içi), 4dp (liste öğesi altı) |
| Renk | Dolgu `color/primary` (genel ilerleme — proje bağlamı) veya `color/secondary` (alışkanlık/hedef bağlamı); track: `color/primary-light` (dark temada %12 opaklık primary) |
| Radius | Tam yuvarlak |
| Etkileşim | Statik gösterge; dokunulamaz |

### 7.3 Project Color Badge
| Özellik | Değer |
|---|---|
| Kullanım amacı | Projenin kullanıcı tarafından seçilen rengini (öncelik pastel setinden — `UI_GUIDELINES.md` Bölüm 3.3) hızlıca tanımlanabilir kılmak |
| Boyut | 12dp çap, tam yuvarlak nokta |
| Konum | Project Card'da başlığın solunda |
| Erişilebilirlik | Yalnızca dekoratif tanımlama amaçlıdır; proje adı her zaman yanında metin olarak bulunduğundan Bölüm 11.3'teki "renk tek başına anlam taşımaz" kuralına aykırılık oluşturmaz (renk burada bir durumu değil, kullanıcı tercihini temsil eder) |

---

## 8. Calendar Components

### 8.1 Calendar Header
| Özellik | Değer |
|---|---|
| Kullanım amacı | Görüntülenen ay/yıl bilgisini göstermek ve ay değiştirme eylemini sağlamak |
| Tipografi | `type/h2` (ay + yıl) |
| Etkileşim | Sol/sağ ok Icon Button'ları (48dp dokunma alanı) ile önceki/sonraki aya geçiş; başlığa dokunma → hızlı yıl/ay seçici (Bottom Sheet) |

### 8.2 Day Cell
| Özellik | Değer |
|---|---|
| Kullanım amacı | Aylık takvim görünümünde tek bir günü temsil etmek |
| Boyut | Grid sistemine göre eşit genişlikte kare hücre (`UI_GUIDELINES.md` Bölüm 6 — 8dp grid hizası) |
| Durumlar | Normal / Bugün (`color/primary` dolgulu dairesel arka plan) / Seçili (`color/primary` border) / Etkinlik İçeren (hücre altında 1–3 küçük nokta göstergesi, etkinlik renklerine göre) / Ay Dışı (soluk `color/text-disabled`) |
| Etkileşim | Dokunma → o günün ajanda görünümüne (günlük liste) geçilir |

### 8.3 Event Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Günlük ajanda görünümünde bir görev/hedef öğesini listelemek |
| İçerik düzeni | Sol: saat etiketi (`type/caption`) → Orta: başlık (`type/body-md`) + kaynak göstergesi (Task/Goal ikonu ile ayırt edilir) |
| Köşe/gölge/padding | Standart Card temeli (Bölüm 4.1), ancak kompakt padding (`space/sm` — liste yoğunluğu için) |
| Etkileşim | Dokunma → ilgili görev/hedef detayına gider (Calendar'ın kendi detay ekranı yoktur — `ARCHITECTURE.md` Bölüm 4, Calendar salt okunur agregasyon) |

### 8.4 Date Selector
| Özellik | Değer |
|---|---|
| Kullanım amacı | Aylık görünüm yerine yatay kaydırılabilir haftalık gün şeridi (görev/hedef oluşturma akışlarında hızlı tarih seçimi) |
| Boyut | Yükseklik 64dp, her gün öğesi Day Cell ile aynı durum/renk kurallarını paylaşır ancak dikdörtgen değil kapsül (pill) biçimindedir |
| Etkileşim | Yatay kaydırma + dokunma ile seçim; `UI_GUIDELINES.md` Bölüm 7.15'teki "Bugün/Yarın/Gelecek Hafta" hızlı chip'leriyle birlikte kullanılabilir |

---

## 9. Habit Components

### 9.1 Habit Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Alışkanlık listesinde bir alışkanlığı ve günlük check-in durumunu göstermek |
| İçerik düzeni | Sol: alışkanlık ikonu (kullanıcı seçimi) → Orta: başlık (`type/h3`) + tekrar sıklığı özeti (`type/caption`) → Sağ: Streak Indicator (9.2) üstte, Completion Button (9.3) altta |
| Köşe/gölge/padding | Standart Card temeli (Bölüm 4.1) |
| Durumlar | Bugün İşaretlenmedi / Bugün Tamamlandı / Bugün Atlandı (kullanıcı tekrar sıklığında o gün yoksa kart soluklaştırılır, etkileşimsiz) |
| Etkileşim | Completion Button dokunması → check-in kaydı; kart dokunması → alışkanlık istatistik/detay görünümüne gider |

### 9.2 Streak Indicator
| Özellik | Değer |
|---|---|
| Kullanım amacı | `currentStreak` değerini (`DATABASE.md`) görsel olarak vurgulamak |
| Tasarım | Alev/yıldız gibi tek, sabit bir ikon (`color/accent-warning` tonunda) + sayı (`type/caption`, Medium ağırlık) |
| Etkileşim | Streak arttığında 300ms "pop" animasyonu (`UI_GUIDELINES.md` Bölüm 9.3) — abartılı efekt kullanılmaz |
| Erişilebilirlik | Sayı her zaman metin olarak yanında yer alır; yalnızca ikonla anlam taşınmaz |

### 9.3 Completion Button
| Özellik | Değer |
|---|---|
| Kullanım amacı | Günlük check-in eylemini (yapıldı/yapılmadı) tek dokunuşla gerçekleştirmek |
| Boyut | 44dp çap, tam yuvarlak (Icon Button ailesinden, ancak durum taşıdığı için ayrı bileşen) |
| Durumlar | Boş (border'lı, dolgusuz) / Tamamlandı (`color/secondary` dolgu + beyaz check ikonu) |
| Etkileşim | Dokunma → 150ms scale + fade animasyonu (Checkbox ile tutarlı davranış), hafif haptic; PRD'deki "2–3 dokunuş kuralı"na uygun tek dokunuşla tamamlanır |

---

## 10. Statistics Components

### 10.1 Progress Bar
Bölüm 7.2'deki Progress Indicator ile aynı temel bileşendir; Statistics bağlamında dönemsel tamamlama oranlarını (görev/alışkanlık/hedef) göstermek için kullanılır.

### 10.2 Circular Progress
| Özellik | Değer |
|---|---|
| Kullanım amacı | Tek bir yüzde değerini (örn. haftalık görev tamamlama oranı) dairesel biçimde vurgulu göstermek |
| Boyut | Statistic Summary Card içinde 64dp çap; tam ekran istatistik görünümünde 120dp çap |
| Renk | Dolgu yayı `color/primary`; track `color/primary-light` (Progress Bar ile tutarlı renk mantığı) |
| İçerik | Merkezde yüzde metni (`type/h2` küçük varyant boyutunda, `color/text-primary`) |
| Etkileşim | Statik gösterge; ilk render'da 250ms ease-in-out ile 0'dan hedef değere dolan giriş animasyonu |

### 10.3 Chart Container
| Özellik | Değer |
|---|---|
| Kullanım amacı | Çubuk/çizgi grafik gibi veri görselleştirmelerini standart bir çerçeve içinde sunmak |
| Köşe/gölge/padding | Standart Card temeli (Bölüm 4.1) |
| Renk | Grafik çizgi/çubuk rengi `color/primary`; ikincil seri (varsa) `color/secondary` — ekranda ikiden fazla rakip renk kullanılmaz (`UI_GUIDELINES.md` Bölüm 14 Don'ts) |
| İçerik düzeni | Üstte başlık (`type/h3`) + dönem seçici (chip grubu: Günlük/Haftalık/Aylık) → Ortada grafik alanı → Altta eksen etiketleri (`type/caption`) |
| Durumlar | Veri Var / Veri Yok (Empty State — Bölüm 11.2) |

### 10.4 Statistic Summary Card
| Özellik | Değer |
|---|---|
| Kullanım amacı | Tek bir metriği (örn. "Bu Hafta Tamamlanan Görev: 12") kompakt biçimde özetlemek |
| İçerik düzeni | Üstte etiket (`type/overline`, `color/text-secondary`) → Ortada büyük değer (`type/display` veya `type/h1`, `color/text-primary`) → Altta opsiyonel Circular Progress veya trend ikonu (artış/azalış) |
| Köşe/gölge/padding | Standart Card temeli (Bölüm 4.1); genellikle 2'li grid düzeninde yan yana kullanılır (istisnai olarak `UI_GUIDELINES.md` Bölüm 6'daki "tek kolon kart" kuralına, yalnızca özet kartlar için, kompakt grid uygulanabilir — bilgi yoğunluğu düşük olduğundan bilişsel yük artırmaz) |

---

## 11. Feedback Components

Bu bölüm, `STATE_MANAGEMENT.md` Bölüm 8'deki beş UI-state durumunun (Loading/Success/Empty/Error/Refreshing) doğrudan görsel karşılığıdır.

### 11.1 Loading State
| Özellik | Değer |
|---|---|
| Kullanım amacı | `STATE_MANAGEMENT.md` Bölüm 8'deki `Loading` durumunu göstermek |
| Tasarım | İskelet (skeleton) yükleme deseni — jenerik spinner **kullanılmaz** (`UI_GUIDELINES.md` Bölüm 13.5) |
| Uygulama | İlgili ekranın gerçek kart/liste yapısını taklit eden, `color/border` tonunda soluk dikdörtgen bloklar; hafif "shimmer" (parıltı) animasyonu ile canlılık hissi verilir |
| Kural | Asla boş beyaz ekran bırakılmaz |

### 11.2 Empty State
| Özellik | Değer |
|---|---|
| Kullanım amacı | `STATE_MANAGEMENT.md` Bölüm 8'deki `Empty` durumunu göstermek |
| İçerik düzeni | Ölçülü illüstrasyon/ikon (üstte `space/xxl` — 48dp boşluk) + kısa açıklama (`type/body-md`, `color/text-secondary`) + birincil eylem butonu (Primary Button) |
| Örnek | "Henüz alışkanlık eklemedin" + "Alışkanlık Ekle" butonu (`UI_GUIDELINES.md` Bölüm 13.3) |
| Kural | Her boş liste bu bileşenle karşılanır; asla düz boş ekran bırakılmaz |

### 11.3 Error State
| Özellik | Değer |
|---|---|
| Kullanım amacı | `STATE_MANAGEMENT.md` Bölüm 9'daki Failure durumlarının (Bölüm 9.2) UI karşılığı |
| İçerik düzeni | İkon (`color/accent-danger` tonunda, ölçülü) + kullanıcı dostu, çözüm odaklı mesaj (`type/body-md`) + "Tekrar Dene" Secondary Button |
| Kural | Hata durumları kullanıcıyı suçlamaz, teknik jargon içermez (`UI_GUIDELINES.md` Bölüm 13.4); "Hata oluştu" gibi belirsiz metin kullanılmaz |

### 11.4 Success Message
| Özellik | Değer |
|---|---|
| Kullanım amacı | Bir eylemin başarıyla tamamlandığını kısa süreli bildirmek (örn. "Görev oluşturuldu") |
| Tasarım | Snackbar'ın (11.5) başarı varyantıdır — ayrı bir bileşen değil, Snackbar'ın renk/ikon parametresi `color/secondary` yeşiline ayarlanmış hali |
| Süre | 4 saniye otomatik kapanma (Snackbar standardı ile aynı) |

### 11.5 Snackbar
| Özellik | Değer |
|---|---|
| Boyut/Renk | `UI_GUIDELINES.md` Bölüm 7.7 esas alınır: 12dp radius, arka plan `color/text-primary` (ters kontrast) |
| İçerik | Tek satır mesaj + opsiyonel tek aksiyon ("Geri Al") |
| Süre | 4 saniye, ardından 200ms slide-up + fade ile kapanır |
| Kural | Silme/tamamlama gibi geri alınabilir eylemlerde her zaman "Geri Al" aksiyonu bulunur (`UI_GUIDELINES.md` Bölüm 2 İlke 8) |

### 11.6 Dialog
| Özellik | Değer |
|---|---|
| Boyut | `UI_GUIDELINES.md` Bölüm 7.5 esas alınır: 20dp radius, maksimum 400dp genişlik, ortalanmış |
| İçerik | Başlık (`type/h2`) + açıklama (`type/body-md`) + en fazla 2 aksiyon (sağa hizalı: Text Button + Primary/Destructive Button) |
| Kullanım alanı | Yalnızca gerçekten kesintili onay gerektiren eylemler (örn. hesap silme onayı) — hızlı ekleme gibi sık işlemler için Bottom Sheet tercih edilir (Bölüm 11.7) |

### 11.7 Bottom Sheet
| Özellik | Değer |
|---|---|
| Boyut | `UI_GUIDELINES.md` Bölüm 7.6 esas alınır: üst köşeler 24dp radius, üstte 4dp x 32dp sürükleme tutamacı, maksimum ekran yüksekliğinin %90'ı |
| Kullanım alanı | Görev/not hızlı ekleme, Dropdown seçim listesi (Bölüm 5.4), filtre paneli — dialog yerine tercih edilen ana bileşen |

---

## 12. Navigation Components

### 12.1 Tab Navigation
| Özellik | Değer |
|---|---|
| Kullanım amacı | Bir ekran içinde ikincil sekmeler arası geçiş (örn. Proje Detayında "Görevler / Notlar" sekmeleri) |
| Tasarım | Bottom Navigation'dan görsel olarak ayrışması için üstte ince (2dp) alt çizgi göstergesi kullanılır (Bottom Nav'daki kapsül yerine) — bu, iki farklı navigasyon seviyesinin (birincil vs ikincil) karışmasını önler |
| Renk | Aktif sekme `color/primary` metin + alt çizgi; pasif `color/text-secondary` |
| Etkileşim | Yatay kaydırılabilir (sekme sayısı ekrana sığmıyorsa) |

### 12.2 Navigation Item
Bottom Navigation (2.2) ve Tab Navigation (12.1) içindeki tek bir sekme öğesinin genel adıdır; ikisi de aynı temel durum kurallarını (Aktif/Pasif renk ayrımı) paylaşır.

### 12.3 Back Button
| Özellik | Değer |
|---|---|
| Kullanım amacı | AppBar solunda, bir önceki ekrana dönüş |
| Boyut | Icon Button standardı (48dp dokunma alanı, 24dp ikon) |
| Etkileşim | Dokunma → 250ms ease-in-out sayfa geçiş animasyonuyla (`UI_GUIDELINES.md` Bölüm 9.2) önceki ekrana döner |

---

## 13. Theme Compatibility

### 13.1 Genel Kural
Bu dokümandaki **hiçbir bileşen sabit renk değeri taşımaz** — yalnızca `UI_GUIDELINES.md` Bölüm 3'te tanımlı token isimlerine (`color/primary`, `color/surface` vb.) referans verir. Bu sayede Açık, Koyu ve AMOLED temaları arasında geçiş, component tasarımında hiçbir değişiklik gerektirmez (`UI_GUIDELINES.md` Bölüm 12.1).

### 13.2 Açık Tema Uyumu
Tüm kartlar `color/surface` (#FFFFFF) zemin üzerinde, `elevation/1` gölgesiyle `color/background` (#FAFAFC) zeminden ayrışır (Bölüm 4.1, `UI_GUIDELINES.md` Bölüm 12.2).

### 13.3 Koyu Tema Uyumu
Gölge yerine `color/surface` – `color/surface-elevated` ton farkı derinlik aracı olarak kullanılır (`UI_GUIDELINES.md` Bölüm 12.3). Bu, özellikle Card (Bölüm 4), Dialog (11.6) ve Bottom Sheet (11.7) bileşenlerinde geçerlidir — koyu temada bu bileşenlerin gölge değeri görsel olarak zayıf algılanacağından, arka plan tonu bir kademe açık (`surface-elevated`) render edilir.

### 13.4 AMOLED Tema Uyumu
Gölge tamamen kaldırılır; derinlik yalnızca ince (1dp) `color/border` ile sağlanır (`UI_GUIDELINES.md` Bölüm 3.6, 12.4). Bu nedenle Card, Dialog, Bottom Sheet gibi elevation'a dayalı bileşenler, AMOLED temada `elevation` token'ı yerine otomatik olarak `border` varyantına geçer — bu geçiş component davranışında ek bir "AMOLED modu" anahtarı gerektirmez, yalnızca aktif temanın elevation token'ı boş döndüğünde border token'ı devreye girer.

### 13.5 Vurgu Renkleri
Priority Badge (6.2), Streak Indicator (9.2), Chart Container (10.3) gibi semantik renk taşıyan bileşenler, koyu/AMOLED temalarda `UI_GUIDELINES.md` Bölüm 3.5'teki açıklaştırılmış varyantları (örn. `color/primary` → `#8B84FF`) otomatik kullanır — pastel öncelik seti (Bölüm 3.3) için ayrı bir koyu tema varyantı tanımlanmamıştır; bu renkler zaten pastel/açık tonda olduğundan koyu zeminde de yeterli kontrastı sağlar.

---

## 14. Accessibility Rules

`UI_GUIDELINES.md` Bölüm 11'in bu component kütüphanesine uygulanmış hali:

### 14.1 Dokunma Alanları
- Her interaktif component (Button, Icon Button, Checkbox, Chip, Navigation Item) minimum **48dp x 48dp** dokunma alanına sahiptir — görsel boyut daha küçük olsa dahi (örn. Checkbox 22dp görsel, 44dp dokunma; Icon Button 24dp ikon, 48dp dokunma) görünmez padding ile tamamlanır.

### 14.2 Yazı Boyutları
- Tüm component'lerdeki metinler `UI_GUIDELINES.md` Bölüm 4.2'deki type scale token'larını kullanır; hiçbir component'te sabit piksel/sp kilidi yapılmaz — sistem erişilebilirlik ayarlarına göre ölçeklenir.

### 14.3 Kontrast
- Card, Dialog, Bottom Sheet gibi metin taşıyan tüm bileşenlerde gövde metni/arka plan kontrastı minimum 4.5:1; başlık metinleri minimum 3:1 (`UI_GUIDELINES.md` Bölüm 11.2).
- `color/text-disabled`, yalnızca gerçekten devre dışı component durumlarında (Disabled buton, Disabled input) kullanılır; okunması gereken hiçbir bilgi bu tonda gösterilmez.

### 14.4 Erişilebilir Kullanım
- Priority Badge (6.2), Due Date Label (6.4), Habit Card durumları (9.1) gibi renk taşıyan tüm bileşenler, her zaman ikon veya metin desteğiyle birlikte sunulur — renk tek başına bir durumu ifade etmez.
- Tüm ikon-only bileşenler (Icon Button, Completion Button, Back Button) ekran okuyucu etiketi (semantic label) taşır.
- Bu dokümandaki tüm animasyonlar (Bölüm 15), sistemin "hareketi azalt" ayarına duyarlıdır; bu ayar açıkken geçişler fade'e indirgenir (`UI_GUIDELINES.md` Bölüm 11.4).

---

## 15. Animation Rules

`UI_GUIDELINES.md` Bölüm 9'daki standart süre/easing tablosunun, component bazında uygulama haritası:

| Component | Etkileşim | Süre | Easing |
|---|---|---|---|
| Primary/Secondary/Outline Button | Basılı durum | 100ms | ease-out |
| Completion Checkbox / Completion Button | İşaretleme | 150ms | ease-out (scale + fade) |
| Task Card | Tamamlanma (metin üstü çizili geçişi) | 300ms | ease-in-out |
| Sayfa geçişleri (Back Button, kart dokunma → detay) | Push/pop | 250ms | ease-in-out (slide) |
| Bottom Sheet (11.7) | Açılış | 220ms | ease-out (slide-up) |
| Dialog (11.6) | Açılış | 180ms | ease-out (scale 0.95→1 + fade) |
| Snackbar (11.5) | Giriş/çıkış | 200ms | ease-out (slide-up + fade) |
| Task Card | Swipe-to-delete | 200ms | ease-in (slide-out + collapse) |
| Streak Indicator (9.2) | Sayaç artışı | 300ms | "pop" (ölçülü, abartısız) |
| Circular Progress (10.2) | İlk render dolum | 250ms | ease-in-out |
| Switch (5.6) | Açık/kapalı geçiş | 150ms | ease-in-out |

### 15.1 Genel Kurallar
- Hiçbir component animasyonu 250ms'yi aşmaz (`UI_GUIDELINES.md` Bölüm 14 Don'ts).
- Hiçbir animasyon kullanıcı eylemini bloklamaz — animasyon bitmeden bir sonraki dokunuş her zaman kabul edilir.
- Loading State'teki (11.1) shimmer efekti bu tabloya dahil değildir; sürekli, döngüsel bir yükleme göstergesidir, tek seferlik bir geçiş animasyonu değildir.

---

## 16. Naming Convention

`FOLDER_STRUCTURE.md` Bölüm 12.2–12.3'teki dosya/isimlendirme kurallarının component kütüphanesine özgü uzantısı:

### 16.1 Component Dosya İsimlendirme
- Her component, kendi feature'ının veya `shared/` katmanının `presentation/widgets/` (ya da ekran-özel component'ler için ilgili ekranın kendi alt klasörü) altında, işlevini açıkça belirten `_widget` son ekiyle adlandırılır: `task_card_widget`, `priority_badge_widget`, `empty_state_widget`, `habit_streak_indicator_widget`.
- Yalnızca 2 veya daha fazla feature tarafından kullanılan component'ler (Bölüm 1.3 — Tekrarı Önleme İlkesi) `shared/` katmanında adlandırılır: `app_button_widget`, `app_card_widget`, `app_chip_widget`, `empty_state_widget`, `loading_skeleton_widget`, `error_state_widget`.

### 16.2 Component Sınıf/Değişken İsimlendirme
- Component sınıf isimleri `PascalCase`, önekleri paylaşılan bileşenlerde `App` ile başlar: `AppButton`, `AppCard`, `AppChip` — feature'a özgü bileşenlerde feature adı önek olur: `TaskCard`, `HabitStreakIndicator`, `ProjectColorBadge`.
- Bu isimlendirme, `FOLDER_STRUCTURE.md` Bölüm 12.3'teki "dosya isminden hangi katmana/türe ait olduğu anlaşılmalı" ilkesiyle birebir uyumludur.

### 16.3 Varyant/Durum İsimlendirme
- Bir component'in görsel varyantları (örn. Buton tipleri) enum benzeri, açık isimlerle ayrılır: `primary`, `secondary`, `outline`, `text`, `destructive` — kısaltma veya belirsiz isim (`type1`, `btnA`) kullanılmaz.
- Durum isimleri (Bölüm 11'deki beş UI-state) tüm component'lerde tutarlı terminolojiyle anılır: `loading`, `success`, `empty`, `error`, `refreshing` — `STATE_MANAGEMENT.md` Bölüm 8'deki isimlendirmeyle birebir aynıdır.

### 16.4 Token Referans Kuralı
- Hiçbir component isminde veya dokümantasyonunda ham hex değeri (`#6C63FF` gibi) doğrudan geçmez; her zaman token ismi (`color/primary`) kullanılır — bu doküman boyunca hex değerler yalnızca `UI_GUIDELINES.md`'ye referansla, o dokümanın tanımını hatırlatmak amacıyla parantez içinde belirtilmiştir.

---

## 17. Sonraki Adımlar

Bu component kütüphanesi dokümanı, aşağıdaki süreçler için referans olarak kullanılacaktır:
1. Gerçek Flutter widget implementasyonları (bu doküman kapsamında yapılmamıştır),
2. Her component için tema token'larının (`ThemeExtension` veya benzeri mekanizma) somut Dart kod karşılıklarının yazılması (ayrı teknik görev),
3. Ekran bazlı wireframe/yüksek çözünürlüklü tasarımların bu component setine referansla üretilmesi,
4. Widget test planlarının (her component için Bölüm 14 erişilebilirlik ve Bölüm 15 animasyon kurallarını doğrulayacak şekilde) ayrı bir aşamada hazırlanması.

**Bu doküman kapsamında herhangi bir kod, widget veya implementasyon üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak ele alınacaktır.
