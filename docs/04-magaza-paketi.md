# Halis — Mağaza Paketi (App Store + Google Play)

## Kimlik

| Alan | Değer |
|---|---|
| Uygulama adı | **Halis** |
| Mağaza başlığı | Halis — Helal Gıda Tarayıcı / Halal Food Scanner |
| Paket (Android) | `com.halis.app` |
| Bundle ID (iOS) | `com.halis.halisApp` (Xcode'da görünen; istenirse App Store Connect'te `com.halis.app` olarak yeniden oluşturulabilir — ilk yüklemeden ÖNCE kararlaştır) |
| Sürüm | 1.0.0 (build 1) |
| Kategori | Yemek & İçecek (Food & Drink) / Sağlık |
| Yaş | 4+ |
| Fiyat | Ücretsiz (v1.1'de abonelik: sınırsız AI analiz ~29,99 $/yıl) |
| Diller | TR, EN, DE, FR, AR, ID |

## Mağaza açıklamaları

### Türkçe — kısa açıklama (80 kr)
> Barkodu tara, içindekini bil. Helal hassasiyetiyle içerik analizi.

### Türkçe — uzun açıklama
> **Markette kararsız kalma. Barkodu tarat, saniyeler içinde bil.**
>
> Halis, ürünlerin içindekiler listesini helal hassasiyetiyle analiz eden reklamsız bir bilgilendirme aracıdır.
>
> ✓ **Barkod tarama** — milyonlarca ürünün içerik verisine anında erişim
> ✓ **Etiket fotoğrafı analizi** — ürün veritabanında yoksa etiketi çek, cihaz üzerinde okunsun
> ✓ **Gerekçeli sonuç** — sadece renk değil: hangi madde, neden şüpheli, hangi kaynağa göre
> ✓ **Hassasiyet profili** — Temkinli, Genişlik veya Diyanet yaklaşımına göre değerlendirme
> ✓ **57+ katkı maddesi (E-kodu) veritabanı** — mezhep farkları ve gerekçelerle
> ✓ **6 dil, 6 etiket dili** — Türkçe, İngilizce, Almanca, Fransızca, Arapça, Endonezyaca etiketleri tanır
> ✓ **Reklamsız** — asla reklam göstermeyiz, asla marka parası almayız
>
> **Dürüstlük ilkemiz:** Emin olamadığımızda "şüpheli" deriz; asla tahminle "helal" demeyiz. Sonuçlarımız dini hüküm değil, içerik verilerine dayalı bilgilendirmedir.
>
> Ürün verisi: Open Food Facts (ODbL).

### English — subtitle (30 ch, App Store)
> Halal ingredient scanner

### English — description
> **Stop guessing at the supermarket. Scan the barcode, know in seconds.**
>
> Halis is an ad-free informational tool that analyzes product ingredients with halal sensitivity.
>
> ✓ **Barcode scanning** — instant access to ingredient data for millions of products
> ✓ **Label photo analysis** — product not in the database? Snap the label; it's read on your device
> ✓ **Explained results** — not just a color: which ingredient, why doubtful, per which source
> ✓ **Sensitivity profiles** — Cautious, Lenient, or Diyanet methodology
> ✓ **57+ additive (E-number) database** — with school-of-thought differences and reasoning
> ✓ **6 languages** — recognizes labels in Turkish, English, German, French, Arabic, Indonesian
> ✓ **Ad-free** — we never show ads and never take money from brands
>
> **Our honesty principle:** when we're not sure, we say "doubtful" — we never guess "halal". Results are informational, based on ingredient data, not religious rulings.
>
> Product data: Open Food Facts (ODbL).

### Diğer diller
DE/FR/AR/ID açıklamaları EN metninden çevrilecek (lansman sonrası ilk hafta; App Store Connect + Play Console yerelleştirme alanlarına).

## Anahtar kelimeler (ASO)

- **TR:** helal, helal mi, e kodu, katkı maddesi, barkod, içindekiler, jelatin, E471, helal gıda, gıda kontrol
- **EN:** halal, halal check, halal scanner, e number, additives, is it halal, ingredients, halal food, barcode scanner, gelatin
- **DE:** halal, halal check, e-nummern, zusatzstoffe, zutaten scanner
- **FR:** halal, vérificateur halal, additifs, e-numéros, scanner ingrédients
- **AR:** حلال، فحص حلال، مكونات، إضافات
- **ID:** halal, cek halal, komposisi, pemindai halal, bahan tambahan

## Ekran görüntüsü planı (6,7"/6,5" + 5,5" iOS; telefon+7"tablet Android)

1. Ana ekran — "Barkodu tara, içindekini bil" + profil seçici
2. Tarama anı — çerçeve overlay
3. Yeşil sonuç kartı (gerekçeli, güven yüzdeli)
4. Turuncu "Şüpheli" kartı — E471 tespiti açık halde (farklılaştırıcı ekran!)
5. Etiket fotoğrafı analizi ekranı
6. Onboarding/dürüstlük ilkesi ekranı
Her görüntünün üstüne tek cümlelik pazarlama bandı (6 dilde).

## Gizlilik (Data Safety / App Privacy)

- Hesap yok, kişisel veri toplanmıyor, tarama geçmişi yalnız cihazda.
- Ağ istekleri: Open Food Facts (barkod sorgusu; barkod dışında veri gitmez), Halis backend (yalnız etiket METNİ — fotoğraf cihazdan çıkmaz; v1'de backend kullanılmıyorsa bu satır da kalkar).
- Üçüncü taraf reklam/izleme SDK'sı YOK.
- Gerekli beyanlar: iOS App Privacy "Data Not Collected"; Play Data Safety "No data collected/shared".
- Gizlilik politikası sayfası: halis.app/privacy (alan adı alınınca; taslak aşağıda).

### Gizlilik politikası taslağı (halis.app/privacy)
> Halis kişisel veri toplamaz. Hesap açılmaz. Tarama geçmişiniz yalnızca cihazınızda saklanır ve bize gönderilmez. Barkod taramalarında yalnızca barkod numarası Open Food Facts servisine iletilir. Etiket fotoğrafları cihazınızda işlenir; fotoğraflarınız sunucularımıza yüklenmez. Sorular: destek@halis.app

## Yükleme öncesi kontrol listesi

- [ ] Apple Developer hesabı (99 $/yıl) — **Ufuk**
- [ ] Google Play Console hesabı (25 $ tek sefer) — **Ufuk**
- [ ] halis.app alan adı + privacy sayfası — **Ufuk**
- [ ] Bundle ID kararı (`com.halis.app` önerilir; iOS projesinde güncelle)
- [ ] `data/` dosyalarının dini danışman onayı (yayın engeli!)
- [ ] Ekran görüntüleri (plan yukarıda; simülatörden alınabilir)
- [ ] AAB: `flutter build appbundle --release` (imzalama ~/halis-keys ile otomatik)
- [ ] iOS: `flutter build ipa` + Transporter/Xcode ile yükleme
- [ ] ⚠️ `~/halis-keys/` YEDEKLE (kaybolursa Play'de güncelleme yapılamaz!)
