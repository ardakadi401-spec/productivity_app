# UI Design Guidelines
## Kişisel Üretkenlik Uygulaması — Design System

**Doküman Versiyonu:** 1.0
**Tarih:** 04 Ağustos 2026
**Hazırlayan:** Senior UI/UX Designer / Senior Product Designer / Mobile Design System Architect
**Doküman Durumu:** Referans Tasarım Sistemi — Tüm ekran geliştirmeleri bu dokümana uymalıdır

> Bu doküman yalnızca bir tasarım sistemidir. Kod, widget veya Figma dosyası içermez. Tüm gelecek ekran tasarımları ve implementasyonları bu dokümandaki kurallara referans vermelidir.

---

## 1. Tasarım Felsefesi

Bu uygulama, piyasadaki klasik "yapılacaklar listesi" uygulamalarının kalabalık, sıkışık ve jenerik hissinden bilinçli olarak uzaklaşır. Kullanıcı uygulamayı ilk açtığı andan itibaren şu hissi yaşamalıdır: **"Bu uygulama özenle tasarlanmış, güvenilir ve kullanması keyifli."**

### 1.1 Temel Duygu Haritası
| Hissettirilmek İstenen | Nasıl Sağlanır |
|---|---|
| Ferahlık | Bol beyaz alan, düşük görsel yoğunluk, nefes alan grid |
| Kalite / Premium | Tutarlı gölgeler, yumuşak köşeler, hassas tipografi hiyerarşisi |
| Güven | Tutarlı renk kullanımı, öngörülebilir etkileşim kalıpları |
| Hız | Kısa animasyonlar, minimum dokunuşla tamamlanan akışlar |
| Canlılık | Vurgu renklerinin stratejik, ölçülü kullanımı |

### 1.2 Tasarım Kuzey Yıldızı
Referans alınan ürünlerin (Notion, TickTick, Todoist, Linear, Apple Reminders) **kopyası değil**, şu ortak paydalarının sentezi hedeflenir:
- Notion → sakin, yapılandırılmış beyaz alan kullanımı,
- TickTick / Todoist → hız, düşük sürtünmeli görev ekleme,
- Linear → keskin tipografi hiyerarşisi, minimal renk paleti, güçlü kontrast noktaları,
- Apple Reminders → sistemsel sadelik, dokunma hedeflerinin rahatlığı.

### 1.3 Tasarım Yasağı Listesi
- Aşırı gölgeli, "cam efekti" (glassmorphism) abartısı yok,
- Gereksiz dekoratif illüstrasyon yok (yalnızca boş durum ekranlarında ölçülü kullanım),
- Yoğun gradyan arka planlar yok,
- Ekran başına birden fazla rakip vurgu rengi yok.

---

## 2. Design Principles (Tasarım İlkeleri)

1. **Clarity over decoration** — Süsleme, işlevi asla gölgelemez.
2. **One primary action per screen** — Her ekranda tek, net bir birincil eylem vardır.
3. **Progressive disclosure** — Detaylar ancak gerektiğinde gösterilir; ilk görünüm sade kalır.
4. **Thumb-first design** — Kritik eylemler ekranın alt yarısında, tek elle erişilebilir konumda olur.
5. **2–3 dokunuş kuralı** — Görev ekleme, tamamlama, alışkanlık işaretleme gibi sık işlemler en fazla 2–3 dokunuşla biter.
6. **Consistency beats novelty** — Aynı bileşen, uygulama genelinde her zaman aynı şekilde davranır.
7. **Feedback is immediate** — Her kullanıcı eylemi, 100ms içinde görsel/haptic geri bildirim alır.
8. **Nothing gets lost** — Silme gibi geri alınamaz eylemler her zaman "geri al" (undo) seçeneğiyle sunulur.

---

## 3. Color Guidelines

### 3.1 Renk Felsefesi
Renkler işlevseldir, dekoratif değildir. Palet; nötr bir temel üzerine, yalnızca dikkat çekilmesi gereken noktalarda kullanılan canlı-pastel bir vurgu renginden oluşur. Koyu/parlak aşırılıklardan kaçınılır.

### 3.2 Ana Palet (Light Theme)

| Token | Kullanım | Hex |
|---|---|---|
| `color/primary` | Ana marka rengi, birincil buton, aktif durumlar | `#6C63FF` (Yumuşak İndigo) |
| `color/primary-light` | Hover/basılı durum, açık arka plan vurgusu | `#EEEDFF` |
| `color/primary-dark` | Basılı buton durumu, koyu vurgu | `#4B44CC` |
| `color/secondary` | İkincil vurgu (örn. alışkanlık modülü) | `#2FC4A0` (Nane Yeşili) |
| `color/accent-warning` | Uyarı, yaklaşan son tarih | `#FFB020` (Amber) |
| `color/accent-danger` | Hata, silme, geciken görev | `#FF5A5F` (Mercan Kırmızı) |
| `color/accent-info` | Bilgilendirme | `#3AA0FF` (Gök Mavisi) |
| `color/background` | Sayfa arka planı | `#FAFAFC` |
| `color/surface` | Kart, sheet, dialog yüzeyi | `#FFFFFF` |
| `color/border` | İnce ayraç çizgileri | `#ECECF2` |
| `color/text-primary` | Ana metin | `#1A1A2E` |
| `color/text-secondary` | İkincil/açıklama metni | `#6B6B7B` |
| `color/text-disabled` | Pasif metin | `#B0B0BC` |

### 3.3 Öncelik / Etiket Renkleri (Pastel Set)
Görev önceliği, proje etiketleri ve alışkanlık ikonları için sınırlı, tekrarlanabilir bir pastel set kullanılır — kullanıcı bunları özgürce seçebilir ama sistem 8 rengi geçmez:

`#FF8A8A` `#FFC078` `#FFE066` `#8CE99A` `#66D9E8` `#74C0FC` `#B197FC` `#F783AC`

### 3.4 Kullanım Kuralları
- Bir ekranda birincil renk (`primary`) **tek bir baskın eylem** için kullanılır (örn. FAB, ana CTA).
- Kırmızı yalnızca hata/silme/geciken durumlar için ayrılmıştır — asla dekoratif kullanılmaz.
- Arka plan her zaman `background`/`surface` ikilisiyle katmanlanır; üçüncü bir gri ton eklenmez.
- Renk asla tek başına anlam taşımaz (renk körlüğü uyumluluğu için ikon/metin desteği zorunludur — bkz. Bölüm 11).

### 3.5 Koyu Tema Paleti (Dark Theme)

| Token | Hex |
|---|---|
| `color/background` | `#121218` |
| `color/surface` | `#1C1C24` |
| `color/surface-elevated` | `#24242E` |
| `color/border` | `#2E2E3A` |
| `color/text-primary` | `#F2F2F7` |
| `color/text-secondary` | `#A0A0B0` |
| `color/primary` | `#8B84FF` (Light Indigo — kontrast için açıklaştırılmış) |
| `color/secondary` | `#4FE0BC` |
| `color/accent-danger` | `#FF7A7F` |

### 3.6 AMOLED Tema Paleti
Koyu temanın enerji tasarrufu odaklı, saf siyah varyantıdır (OLED ekranlarda piksel kapatma avantajı için).

| Token | Hex |
|---|---|
| `color/background` | `#000000` |
| `color/surface` | `#0A0A0D` |
| `color/surface-elevated` | `#151519` |
| `color/border` | `#232329` |
| `color/text-primary` | `#F2F2F7` |
| `color/primary` | `#8B84FF` |

> AMOLED temada gölge kullanılmaz; derinlik yalnızca `surface-elevated` ton farkıyla ve ince border ile sağlanır (bkz. Bölüm 12.3).

---

## 4. Typography

### 4.1 Font Ailesi
Tek bir modern, geometrik-humanist sans-serif font ailesi kullanılır (örn. **Inter** veya benzeri sistem-uyumlu font). Başlık ve gövde metni için ayrı font kullanılmaz — ağırlık (weight) farkı hiyerarşiyi sağlar.

### 4.2 Type Scale

| Token | Boyut | Ağırlık | Satır Yüksekliği | Kullanım |
|---|---|---|---|---|
| `type/display` | 32sp | Bold (700) | 40sp | Onboarding, büyük başlıklar |
| `type/h1` | 24sp | SemiBold (600) | 32sp | Ekran başlıkları |
| `type/h2` | 20sp | SemiBold (600) | 28sp | Bölüm başlıkları |
| `type/h3` | 17sp | Medium (500) | 24sp | Kart başlıkları |
| `type/body-lg` | 16sp | Regular (400) | 24sp | Ana gövde metni |
| `type/body-md` | 14sp | Regular (400) | 20sp | İkincil gövde, liste öğeleri |
| `type/caption` | 12sp | Medium (500) | 16sp | Etiketler, zaman damgaları |
| `type/overline` | 11sp | SemiBold (600), harf aralığı +0.5 | 14sp | Bölüm etiketleri (büyük harf) |
| `type/button` | 15sp | SemiBold (600) | 20sp | Buton metni |

### 4.3 Hiyerarşi Kuralları
- Bir ekranda en fazla **3 tipografi seviyesi** aynı anda kullanılır (örn. h1 + body-lg + caption).
- Başlıklar her zaman `text-primary`, açıklamalar her zaman `text-secondary` renginde olur.
- Metin asla `text-disabled` altında bir kontrasta düşürülmez (bkz. Bölüm 11.2).
- Satır uzunluğu okunabilirlik için ~60-75 karakterle sınırlandırılır (geniş ekranlarda içerik genişliği kısıtlanır).

---

## 5. Spacing System

### 5.1 Temel Birim
Tüm spacing değerleri **4dp temel birimin** katlarıdır. Bu, tüm ekranlarda tutarlı bir ritim sağlar.

| Token | Değer | Kullanım |
|---|---|---|
| `space/xs` | 4dp | İkon-metin arası, mikro boşluklar |
| `space/sm` | 8dp | Kart içi öğe aralığı |
| `space/md` | 16dp | Standart kart padding, öğeler arası ana boşluk |
| `space/lg` | 24dp | Bölümler arası boşluk |
| `space/xl` | 32dp | Ekran üst/alt büyük boşluklar |
| `space/xxl` | 48dp | Boş durum (empty state) üstü boşluk |

### 5.2 Ekran Kenar Boşlukları (Margin)
- Standart yatay ekran margini: **16dp** (kompakt telefonlar), **20dp** (geniş telefonlar/tablet geçişi).
- Kart listeleri arası dikey boşluk: **12dp**.
- Kart içi padding: **16dp** (tüm kenarlarda eşit).

### 5.3 Kural
> "Sıkışık görünen hiçbir ekran onaylanmaz." Bir bölüm dört veya daha fazla öğe içeriyorsa, gruplar arasına en az `space/lg` (24dp) boşluk konur.

---

## 6. Grid System

- **Kolon sistemi:** 4 kolonluk esnek grid (mobil), kolon genişliği ekran genişliğine göre dinamik, gutter (kolon arası boşluk) **16dp**.
- **Dokunma hedefi hizası:** Tüm interaktif öğeler 8dp grid'e hizalanır.
- **Kart genişliği:** Tam genişlik (ekran margini düşülmüş) — mobilde çoklu kolon kart düzeni kullanılmaz (bilişsel yükü artırır).
- **Bottom Sheet / Dialog genişliği:** Ekran genişliğinin tamamı (bottom sheet) veya maksimum 400dp (dialog, tablet genişliğinde ortalanır).

---

## 7. Component Standards

### 7.1 AppBar
- Yükseklik: 56dp. Gölgesiz, yalnızca `border` rengiyle alt ayraç (scroll edilince hafif gölge belirir — elevation-on-scroll deseni).
- Sol: geri butonu veya ekran başlığı (h2). Sağ: en fazla 2 ikon eylemi.
- Başlık her zaman sola hizalı (ortalanmış başlık kullanılmaz — hız hissi için).

### 7.2 Bottom Navigation
- Yükseklik: 64dp + güvenli alan (safe area).
- 4–5 sekme, her biri ikon + kısa etiket (`type/caption`).
- Aktif sekme `primary` renginde ikon + etiket; pasif sekmeler `text-secondary`.
- Aktif durum göstergesi: ikon üstünde ince (3dp) yuvarlatılmış çizgi veya ikon arka planında yumuşak `primary-light` kapsül — keskin alt çizgi kullanılmaz.

### 7.3 FAB (Floating Action Button)
- Boyut: 56dp standart, 40dp mini (yalnızca ikincil ekranlarda).
- Konum: sağ alt, güvenli alandan 16dp içeride.
- Yalnızca **tek FAB** ekranda bulunur; birincil "ekle" eylemini temsil eder.
- Basılınca hafif ölçek animasyonu (bkz. Bölüm 10).

### 7.4 Card
- Köşe yarıçapı: **16dp** (bkz. Bölüm 12 — köşe standardı).
- Gölge: `elevation/1` (yumuşak, düşük opaklık — bkz. 7.4.1).
- Padding: 16dp. Minimum dokunma yüksekliği: 48dp.
- Keskin çizgi/border varsayılan olarak kullanılmaz; yalnızca AMOLED temada border ile ayrım yapılır.

**7.4.1 Elevation (Gölge) Skalası**
| Token | Kullanım | Tanım |
|---|---|---|
| `elevation/0` | Sayfa arka planı | Gölge yok |
| `elevation/1` | Standart kart | y:1dp, blur:4dp, opaklık %4 |
| `elevation/2` | Yüzen kart, FAB | y:2dp, blur:8dp, opaklık %8 |
| `elevation/3` | Dialog, açık bottom sheet | y:4dp, blur:16dp, opaklık %12 |

### 7.5 Dialog
- Köşe yarıçapı: 20dp. Maksimum genişlik: 400dp, ortalanmış.
- Başlık (h2) + açıklama (body-md) + en fazla 2 aksiyon butonu (yatay, sağa hizalı: Text Button + Primary Button).
- Arka plan karartma (scrim): `#000000` %40 opaklık.

### 7.6 Bottom Sheet
- Üst köşeler yuvarlatılmış: 24dp.
- Üstte 4dp x 32dp "sürükleme tutamacı" (drag handle), ortalanmış.
- İçerik yüksekliği içerik miktarına göre dinamik; maksimum ekran yüksekliğinin %90'ı.
- Görev/not hızlı ekleme gibi işlemler için tercih edilen bileşendir (dialog yerine — daha az kesintili).

### 7.7 Snackbar
- Ekran altında, bottom navigation üzerinde yüzer; 4 saniye sonra otomatik kapanır.
- Tek satır mesaj + opsiyonel tek aksiyon ("Geri Al" gibi).
- Köşe yarıçapı: 12dp. Arka plan: `text-primary` rengi (ters kontrast — light temada koyu, dark temada açık).

### 7.8 Chip
- Yükseklik: 32dp. Köşe yarıçapı: tam yuvarlak (pill — 16dp).
- Durumlar: Default (border'lı, dolgusuz), Selected (dolgulu `primary-light` + `primary` metin), Disabled (%40 opaklık).
- Etiket/kategori/filtre gösteriminde kullanılır.

### 7.9 Badge
- Boyut: 18dp minimum, sayı içeriyorsa dinamik genişlik.
- Konum: ikon sağ üst köşesi, -4dp/-4dp ofset.
- Renk: bildirim sayacı için `accent-danger`; durum göstergesi için ilgili semantik renk.

### 7.10 Progress Bar
- Yükseklik: 6dp (inline, kart içi), 4dp (liste öğesi altı).
- Köşe: tam yuvarlak. Dolgu rengi: `primary` (genel ilerleme) veya `secondary` (alışkanlık/hedef bağlamı).
- Arka plan track: `primary-light` / dark temada `%12 opaklık primary`.

### 7.11 Search Bar
- Yükseklik: 48dp. Köşe yarıçapı: 12dp. Arka plan: `surface` + ince `border`.
- Sol: arama ikonu (sabit). Sağ: temizle ikonu (yalnızca metin girildiğinde görünür).
- Odaklandığında (focus) ince `primary` renkli 1.5dp kenarlık belirir.

### 7.12 TextField
- Yükseklik: 52dp (tek satır). Köşe yarıçapı: 12dp.
- Durumlar: Default (border `#ECECF2`), Focus (border `primary`, 1.5dp), Error (border `accent-danger` + altında hata metni), Disabled (%50 opaklık, dolgu `background`).
- Label her zaman alan üstünde sabit (floating label kullanılmaz — netlik için).
- Hata mesajı her zaman kullanıcı dostu, çözüm odaklı yazılır (örn. "Şifre en az 8 karakter olmalı" — asla "Geçersiz giriş" gibi belirsiz mesaj).

### 7.13 Checkbox
- Boyut: 22dp, köşe yarıçapı 6dp (tam kare değil — yumuşatılmış).
- Dokunma alanı: 44dp x 44dp (görsel boyuttan büyük — erişilebilirlik).
- İşaretlenince: `primary` dolgu + beyaz check ikonu + 150ms scale-in animasyonu.
- Görev tamamlama checkbox'ı işaretlenince görev metni 300ms içinde üstü çizili + soluklaşmış hale geçer (silinmeden önce kullanıcıya görsel onay verir).

### 7.14 Switch
- Boyut: 51dp x 31dp (standart mobil switch ölçüsü).
- Açık durumda: `primary` dolgu. Kapalı durumda: `border` rengi dolgu, gri thumb.
- Geçiş animasyonu: 150ms ease-in-out.

### 7.15 Date Picker / Time Picker
- Native platform bileşenleri temel alınır ancak marka renkleriyle temalandırılır (seçili gün/saat `primary` renginde vurgulanır).
- Hızlı seçim kısayolları önerilir: "Bugün", "Yarın", "Gelecek Hafta" gibi chip'ler picker üstünde sunulur (görev/hedef tarih seçiminde sürtünmeyi azaltır).

---

## 8. Iconography

- Tek ikon ailesi kullanılır: **ince çizgili (line/outline), 1.5–2dp kalınlık, 24dp x 24dp** standart alan (rounded uçlu — outline stiliyle tutarlı — örn. Phosphor Icons, Feather veya benzeri tekil bir set).
- Aktif/seçili durumlarda ikon, dolgulu (filled) varyantına geçebilir (ikon ailesi hem outline hem filled sunuyorsa) — bu, ekstra renk kullanmadan durum farkını iletir.
- İkonlar asla metinle yarışmaz; her zaman metnin görsel ağırlığından bir kademe daha soluk (`text-secondary`) tonda başlar, aktif durumda `primary`'ye geçer.
- Dekoratif ikon kullanımı minimumda tutulur; her ikon işlevsel bir anlam taşımalıdır.

---

## 9. Motion & Animation

### 9.1 İlkeler
- Her animasyon **150–250ms** aralığında tutulur (bu aralık dışı "premium hız hissi"ni bozar).
- Easing eğrisi: `ease-out` (giriş), `ease-in-out` (durum değişimi). Ani/lineer geçişler kullanılmaz.
- Hiçbir animasyon kullanıcı eylemini bloklamaz — animasyon bitmeden bir sonraki eylem her zaman kabul edilebilir olmalıdır.

### 9.2 Standart Animasyon Süreleri
| Etkileşim | Süre | Easing |
|---|---|---|
| Buton basılı durumu | 100ms | ease-out |
| Checkbox işaretleme | 150ms | ease-out (scale + fade) |
| Sayfa geçişi (push/pop) | 250ms | ease-in-out (slide) |
| Bottom sheet açılış | 220ms | ease-out (slide-up) |
| Dialog açılış | 180ms | ease-out (scale 0.95→1 + fade) |
| Snackbar giriş/çıkış | 200ms | ease-out (slide-up + fade) |
| Liste öğesi silme (swipe-to-delete) | 200ms | ease-in (slide-out + collapse) |

### 9.3 Mikro-Etkileşimler
- Görev tamamlandığında: checkbox scale-in + metin fade-to-strikethrough + hafif haptic titreşim.
- Alışkanlık streak arttığında: sayaç üzerinde kısa (300ms) "pop" animasyonu — abartılı confetti kullanılmaz, ölçülü kalınır.
- Pull-to-refresh: marka renginde minimal, tek çizgili spinner (jenerik platform spinner'ı yerine).

---

## 10. Buton Standartları

| Tip | Kullanım | Görünüm |
|---|---|---|
| **Primary Button** | Ekran başına tek, en önemli eylem (Kaydet, Oluştur, Giriş Yap) | Dolgu `primary`, beyaz metin, 12dp köşe, 52dp yükseklik |
| **Secondary Button** | İkincil eylemler (İptal, Daha Fazla) | `primary` renkli border (1.5dp), `primary` metin, dolgusuz |
| **Text Button** | Düşük vurgulu eylemler (Vazgeç, Atla) | Dolgusuz, bordersız, `primary` veya `text-secondary` metin |
| **Destructive Button** | Silme/geri döndürülemez eylemler | `accent-danger` dolgu veya border varyantı |

- Tüm butonlarda minimum dokunma alanı **48dp x 48dp**.
- Buton metni her zaman aksiyon fiili ile başlar ("Görevi Kaydet", "Projeyi Sil" — belirsiz "Tamam/OK" yerine bağlamsal metin tercih edilir).
- Bir ekranda aynı anda en fazla 1 Primary Button bulunur.

---

## 11. Accessibility (Erişilebilirlik)

### 11.1 Dokunma Alanları
- Tüm interaktif öğelerde minimum dokunma alanı: **48dp x 48dp** (Material erişilebilirlik standardı).
- Küçük ikon butonları (örn. liste içi hızlı eylemler) görsel olarak 24dp olsa dahi dokunma alanı 48dp'ye tamamlanır (görünmez padding ile).

### 11.2 Kontrast Kuralları
- Gövde metni / arka plan kontrastı: minimum **4.5:1** (WCAG AA).
- Büyük başlık metni (18sp+ bold veya 24sp+ regular): minimum **3:1**.
- İkon-arka plan kontrastı: minimum **3:1**.
- `text-disabled` yalnızca gerçekten devre dışı öğelerde kullanılır; hiçbir okunması gereken bilgi bu tonda gösterilmez.

### 11.3 Renk Körlüğü Uyumluluğu
- Durum bilgisi (tamamlandı/gecikmiş/uyarı) **asla yalnızca renkle** iletilmez; her zaman ikon veya metin etiketiyle desteklenir (örn. geciken görev: kırmızı renk + saat ikonu + "Gecikti" etiketi).
- Öncelik renkleri (Bölüm 3.3) ile birlikte her zaman bir öncelik ikonu/harfi kullanılır (yalnızca renk noktası yeterli değildir).

### 11.4 Diğer Erişilebilirlik Kuralları
- Tüm görsel olmayan ikon-only butonlarda ekran okuyucu etiketi (semantic label) zorunludur.
- Yazı tipi boyutu, sistem erişilebilirlik ayarlarına göre ölçeklenebilir olmalıdır (sabit piksel kilidi yapılmaz).
- Animasyonlar, sistemin "hareketi azalt" (reduce motion) ayarına duyarlı olmalı; bu ayar açıkken geçişler fade'e indirgenir.

---

## 12. Theme Rules

### 12.1 Genel Kural
Üç tema desteklenir: **Açık (Light)**, **Koyu (Dark)**, **AMOLED**. Tema geçişi anlık olur (yeniden başlatma gerektirmez) ve tüm bileşenler token tabanlı çalıştığı için otomatik uyum sağlar.

### 12.2 Açık Tema
- Zemin: çok hafif gri-mor tonlu beyaz (`#FAFAFC`) — saf beyaz değil, göz yormayan yumuşak zemin.
- Kartlar saf beyaz (`#FFFFFF`) ile zeminden hafif elevation farkıyla ayrılır.
- Gölgeler belirgin ama yumuşaktır (bkz. 7.4.1).

### 12.3 Koyu Tema
- Saf siyah kullanılmaz (`#121218` baz alınır) — göz yorgunluğunu azaltmak için hafif mavi-mor alt tonlu koyu gri tercih edilir.
- Gölgeler yerine **yüzey ton farkı** (`surface` vs `surface-elevated`) ile derinlik iletilir; koyu temada gölgeler görsel olarak zayıf algılandığından ana derinlik aracı değildir.
- Vurgu renkleri, koyu zeminde yeterli kontrast için hafifçe açıklaştırılmış varyantlarla kullanılır (bkz. 3.5).

### 12.4 AMOLED Tema
- Zemin saf siyahtır (`#000000`) — OLED ekranlarda pil tasarrufu sağlar.
- Derinlik yalnızca ince `border` (1dp, `#232329`) ile ayrılır; gölge tamamen kaldırılır (siyah zeminde gölge görünmez ve gereksizdir).
- Bu tema, koyu temanın "elektrik tasarrufu" odaklı özel bir varyantı olarak sunulur; kullanıcı ayarlardan manuel seçer.

### 12.5 Tema Geçiş Kuralı
- Sistem teması takip seçeneği varsayılan olarak açıktır.
- Kullanıcı manuel seçim yaptığında bu tercih cihaz genelinde kalıcıdır.

---

## 13. UX Rules (Etkileşim Kuralları)

1. **Hızlı ekleme her zaman erişilebilir olmalı** — Görev/not/alışkanlık ekleme, ana ekranlardan FAB ile maksimum 1 dokunuşta başlatılabilir.
2. **Geri alma her zaman mümkün olmalı** — Silme, tamamlama gibi eylemler Snackbar üzerinden 4 saniyelik "Geri Al" penceresi sunar.
3. **Boş durumlar (empty states) asla boş bırakılmaz** — Her boş liste, ölçülü bir illüstrasyon/ikon + kısa açıklama + birincil eylem butonu içerir (örn. "Henüz alışkanlık eklemedin" + "Alışkanlık Ekle" butonu).
4. **Hata durumları kullanıcıyı suçlamaz** — Mesajlar her zaman çözüm odaklıdır, teknik jargon içermez.
5. **Yükleme durumları asla boş ekran bırakmaz** — İskelet (skeleton) yükleme deseni kullanılır, jenerik spinner yerine.
6. **Bilgi mimarisi sığ tutulur** — Herhangi bir özelliğe Dashboard'dan en fazla 2 dokunuşla ulaşılabilir.
7. **Bağlamsal eylemler yerinde sunulur** — Bir görev üzerinde uzun basma/kaydırma ile hızlı eylemler (tamamla, ertele, sil) doğrudan liste öğesinde sunulur; ayrı ekrana gitmek zorunlu değildir.

---

## 14. Do's & Don'ts

### ✅ Do's
- Her ekranda tek net birincil eylem tanımla.
- Renkleri anlam taşıyacak şekilde, tutarlı ve tutumlu kullan.
- Bol beyaz alan bırak; öğeler arasında nefes payı olsun.
- Tüm etkileşimlerde anında görsel/haptic geri bildirim ver.
- Silme/kritik eylemlerde her zaman geri alma veya onay mekanizması sun.
- Tipografi hiyerarşisini en fazla 3 seviyeyle sınırlı tut.
- Boş durumları rehberlik eden, eylem çağıran içerikle doldur.

### ❌ Don'ts
- Bir ekranda birden fazla rakip vurgu rengi kullanma.
- Kartları veya listeleri sıkışık, boşluksuz bırakma.
- Kritik olmayan bilgi için kırmızı/uyarı rengi kullanma.
- 250ms'yi aşan, kullanıcıyı bekleten animasyon ekleme.
- Aynı işlev için farklı ekranlarda farklı bileşen davranışı tanımlama.
- Yalnızca renkle durum iletme (ikon/metin desteği olmadan).
- Belirsiz buton/hata metni kullanma ("Tamam", "Hata oluştu" gibi).
- Dokunma alanını 48dp altına düşürme.

---

## 15. Sonraki Adımlar

Bu design system, aşağıdaki süreçler için referans doküman olarak kullanılacaktır:
1. Ekran bazlı wireframe ve yüksek çözünürlüklü tasarım üretimi (bu doküman kapsamında yapılmamıştır),
2. Flutter tasarım token / tema implementasyon planı (ayrı teknik doküman olarak ele alınacaktır),
3. Bileşen kütüphanesi (component library) geliştirme görevleri.

**Bu doküman kapsamında herhangi bir kod, widget veya Figma dosyası üretilmemiştir.** Sonraki aşamalar ayrı, bağımsız görevler olarak planlanacaktır.
