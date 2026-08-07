# Halis — Rakip Analizi (Temmuz 2026)

> Kaynak: 27 web araması/sayfa incelemesi ile derlenen saha araştırması.

## Özet tablo

| Uygulama | İndirme | Puan (iOS / Android) | Yöntem | Fiyat | Ana şikayet | Pazar | Durum |
|---|---|---|---|---|---|---|---|
| Scan Halal | 1M+ (Android) | 3.8★ / ~3★ | Barkod + statik DB | $9,99/ay | Bayat DB, ürün bulunamıyor, buglar | K. Amerika | Yarı aktif (Android 2022'de kalmış) |
| Halal Check حلال | ? | 4.5★ (1,6K) | AI foto + barkod, 42 dil, mezhep bazlı | $2,99–14,99 | Ücretsiz katman 1 tarama | Küresel | Aktif |
| Muslim Pro | 170M kullanıcı | 4.7★ (597K) | **Tarayıcı YOK** (sadece restoran bulucu) | $34,99/yıl | Reklam bombardımanı | Küresel | Aktif |
| Verify Halal (JAKIM) | ~100K+ | 3.8★ (148) | Sertifika DB + AI | RM9,90–119,90 | Verimsiz tarama; sertifikasız ürünlerde kör | GD Asya | Aktif |
| Halal Advisor | ~15K | 3.9★ (98) | Restoran rehberi | Ücretsiz | UI hataları | Avustralya | Küçük |
| Mustakshif | 100–390K | 4.4★ (38) | Barkod, 2,5M DB iddiası | $129,99 lifetime | **4×60 sn reklam/tarama** | Küresel | Çok aktif |
| eHalal | ? | 4.9★ (668) | Barkod + restoran + eSIM | RM15–23/dönem | Lag, sonuç dönmüyor | JP/KR turisti | Aktif |
| TagHalal | 1M+ | 4.7★ / 4.6★ | Barkod + E-kod | Freemium | **Domuz jelatinli ürüne "helal" dedi** | Küresel | Aktif |
| HalalChecker AI | ~25K | 4.7★ (158) | Barkod + foto + OCR AI | $29,99/yıl | Ayda 2 ücretsiz tarama; mezhep eksik | SG/US/UK/MY/UAE | Çok aktif |
| **Yuka (referans)** | **80M kullanıcı** | 4.8★ (97K) | Barkod + skor + alternatif öneri | ~$15/yıl | — | FR/US/EU | Kategori dışı lider |

## Uygulama bazında kritik notlar

### Scan Halal — "yaşlı ağır top"
- 2M+ ürünlük topluluk DB'si ama ürün gönderimleri 1+ yıldır incelenmiyor; üretici tedarikçi değiştirince DB güncellenmiyor.
- Sadece ABD+Kanada; UK/Avrupa yıllardır "coming soon". Android build'i Aralık 2022'de kalmış.
- Yorum: *"The app still has bugs and glitches, sometimes even failing to open. There are still lots of items missing."*

### Halal Check حلال — en ciddi AI rakibi
- Ayırt edici özelliği mezhep bazlı açıklama (Hanefi/Şafii/Maliki/Hanbeli/Caferi) + 42 dil.
- Zayıf yeri: ücretsiz katman fiilen 1 tarama; E-kodu odaklı, tam içerik analizi zayıf.

### Muslim Pro — dev ama bu dikeyde yok
- 170M kullanıcıya rağmen tarayıcı özelliği yok; sadece helal restoran bulucu.
- Hem tehdit (eklerse pazar kapanır) hem kanıt (dikey uzman uygulamaya alan var).

### Verify Halal — resmi ama kör noktalı
- Yalnız sertifikalı ürünü doğruluyor → Batı marketlerindeki sertifikasız ürünlerin çoğunda hiçbir şey söyleyemiyor.
- Resmî JAKIM desteğine rağmen 148 oy / 3.8★.

### Mustakshif — reklamla intihar
- Kategorinin en aktif geliştirilen uygulamalarından; ama tarama başına 4 adet 60 saniyelik reklam raporu var.
- Yorum: *"It's frustrating waiting at the supermarket for so long just so I can find out if it's halal or not."*

### TagHalal — güven felaketi örneği
- 1M+ indirmeye rağmen domuz jelatinli ürüne "helal" verdiği raporlanmış. Kategorideki güven sorununun sembolü.

### Yuka — kopyalanacak model
- 80M kullanıcı, sıfır pazarlama, sıfır yatırım, 5. yılda kârlı, ~$20M/yıl gelir.
- Formülü: reklamsız + marka parası almıyor (bağımsızlık = güven) + tek ekran skor + **daha iyi alternatif önerisi** + premium ~$15/yıl.
- Bu model helal kategorisine HİÇ taşınmamış.

## Tespit edilen boşluklar (Halis'in konumlanması)

1. **Güvenilir + reklamsız + güncel DB** kombinasyonu hiçbir helal uygulamasında yok.
2. **Türkiye'ye özel tüketici uygulaması yok** — resmi yol TSE e-Devlet sorgusu + GİMDES PDF listesi. Barkodlu yerli mobil çözüm bulunamadı.
3. **"Alternatif öner"** (Yuka'nın katil özelliği) kategoride neredeyse hiç yok.
4. **Mezhep bazlı açıklama** sadece Halal Check'te ciddi.
5. Rakiplerin ücretsiz katmanları cimri (1-2 tarama) → şikayet mıknatısı; cömert ücretsiz katman fark yaratır.

## Talep sinyalleri
- Küresel helal gıda pazarı 2025'te ~$2,96 trilyon → 2034 projeksiyonu ~$6,3T (IMARC, %13 CAGR).
- Google Trends: "halal food" sürekli yüksek; Ramazan'da zirve (her yıl bedava büyüme sezonu).
- 2024-26'da onlarca AI-wrapper helal tarayıcı çıktı = talep kanıtlı; ama hâkim oyuncu yok. ASO anahtar kelimelerinde doygunluk var → farklılaşma ürün kalitesi + güven + yerelleşme ile olmalı.
