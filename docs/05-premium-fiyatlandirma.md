# Halis Premium — Dünya Fiyatlandırma Planı (ekonomiye endeksli, s2)

Güncelleme: 2026-08-10. Tek ürün: **yıllık abonelik** (aylık plan yok — tek plan, tek karar).
İlke: **ne pahalı ne ucuz** — her ülkede fiyat, o ülkenin alım gücüne göre "bir aile için
düşünmeden verilebilecek yıllık tutar" hedefler.

## Yöntem (sistematik)

1. **Taban: 24,99 $/yıl (ABD).** Gerekçe: kitlesel gıda tarayıcı Yuka ~15 $/yıl,
   premium İslami uygulamalar (Muslim Pro vb.) 25-40 $/yıl. 24,99 $ ikisinin ortası:
   niş değerini korur, "pahalı" algısı yaratmaz. (29,99 $ üst deneme olarak RevenueCat
   A/B'sine bırakıldı.)
2. Her ülke **Dünya Bankası gelir sınıfına** (2025) oturtulur ve fiyat, taban fiyatın
   şu oranına çekilir:
   - **Kuşak A — yüksek gelir:** taban × 1,00 → **24,99 $**
   - **Kuşak B — üst-orta gelir:** taban × ~0,60 → **14,99 $**
   - **Kuşak C — alt-orta gelir (üst dilim) / oynak kurlu orta pazarlar:** taban × ~0,36 → **8,99 $**
   - **Kuşak D — alt-orta (alt dilim) ve düşük gelir:** taban × ~0,18 → **4,49 $**
3. Yerel tutar, mağaza geleneğine yuvarlanır (x,99 / x9,90 / tam yüzlük) ve **Big Mac
   testi**nden geçirilir: yıllık fiyat, o ülkede kabaca 4-8 fast-food menüsü tutarını
   aşmamalı. Aşarsa bir kuşak aşağı çek.
4. **Listede olmayan her ülke:** Dünya Bankası sınıfına göre yukarıdaki kuşağa koy;
   sınıfı bilinmiyorsa Kuşak C. (Böylece "her ülke" tanımlı — istisnasız.)
5. Mekanik: **kodda sıfır değişiklik** — paywall fiyatı mağazadan okur (`subscribeFor`).
   Apple: taban 24,99 $ → 175 vitrine otomatik dönüşüm → aşağıdaki listeyle vitrin
   vitrin elle düzelt. Play: "Regional pricing" şablonuna aynı değerleri gir
   (AB fiyatları KDV dahildir).

## Kuşak A — 24,99 $/yıl eşleniği (yüksek gelir)

| Ülke | Yerel öneri |
|---|---|
| ABD | $24.99 |
| Kanada | C$34.99 |
| Birleşik Krallık | £19.99 |
| Euro bölgesi (DE, FR, NL, BE, AT, IE, FI, LU) | €24.99 |
| İsviçre | CHF 24.99 |
| Norveç / İsveç / Danimarka / İzlanda | 279 kr / 279 kr / 179 kr / 3.490 kr |
| Avustralya / Yeni Zelanda | A$39.99 / NZ$44.99 |
| Japonya / Güney Kore / Tayvan | ¥3.800 / ₩33.000 / NT$790 |
| Singapur / Hong Kong | S$33.98 / HK$188 |
| **BAE / Suudi Arabistan / Katar** | AED 89.99 / SAR 89.99 / QAR 89.99 |
| **Kuveyt / Bahreyn / Umman** | KWD 7.49 / BHD 9.49 / OMR 9.49 |
| İsrail | ₪84.90 |
| Çekya, Slovenya, Estonya, Litvanya, Letonya, Slovakya, Malta, GKRY | €22.99 (veya 549 Kč) |
| Polonya / Macaristan | 99.99 zł / 8.990 Ft |
| Şili / Uruguay | CLP 22.900 / $U 990 |
| **Brunei** | B$32.98 |

Not: Körfez tam fiyat — gelir yüksek, helal uygulamasına ödeme istekliliği kanıtlı.
Polonya/Çekya/Şili artık Dünya Bankası'nda yüksek gelir → A'ya alındı (s1'de B idi).

## Kuşak B — ≈ 14,99 $/yıl (üst-orta gelir)

| Ülke | Yerel öneri |
|---|---|
| İspanya, İtalya, Portekiz, Yunanistan* | €17.99 (*yüksek gelir ama gıda-uygulama fiyat hassasiyeti yüksek — bilinçli B+) |
| **Malezya** | RM 59.90 |
| **Türkiye** | ₺399,99 (bkz. oynak kur notu) |
| **Kazakistan / Azerbaycan** | ₸6.990 / ₼24.99 |
| **Arnavutluk / Bosna-Hersek / Sırbistan / K. Makedonya / Karadağ / Kosova** | €12.99 (KM 24,99 / 1.490 RSD) |
| Bulgaristan / Romanya / Hırvatistan | €14.99 (69.99 lei) |
| Meksika / Brezilya / Kolombiya* | MX$279 / R$74.90 / COP 59.900 |
| Güney Afrika / Botsvana / Namibya | R 269.99 |
| Çin (App Store) / Tayland | ¥98 / ฿499 |
| Gürcistan / Ermenistan | ₾39.99 / ֏5.990 |
| **Maldivler** | $14.99 |

## Kuşak C — ≈ 8,99 $/yıl (alt-orta üst dilim + oynak kurlu pazarlar)

| Ülke | Yerel öneri |
|---|---|
| **Endonezya** | Rp 139.000 |
| **Ürdün / Lübnan / Irak / Filistin** | JOD 5.99 / $8.99 / IQD 11.900 / $8.99 |
| **Fas / Tunus / Cezayir / Libya** | MAD 84.99 / TND 27.99 / DZD 1.190 / $8.99 |
| **Mısır** | EGP 449 (oynak kur) |
| **Özbekistan / Türkmenistan** | 109.000 soʻm / $8.99 |
| Vietnam / Filipinler | ₫219.000 / ₱499 |
| Hindistan* | ₹749 (*alt-orta ama app-ekonomisi büyük; D yerine C) |
| Sri Lanka / Moğolistan / Butan | Rs 2.700 / ₮31.900 / $8.99 |
| Peru / Ekvador / Paraguay / Bolivya / Guatemala | S/32.90 / $8.99 / ₲69.000 / Bs 61.99 / Q 69.99 |
| Arjantin | USD tabanlı $8.99 (kur çok oynak — yerel sabitleme yapma) |
| Ukrayna / Moldova | ₴379 / $8.99 |
| Rusya / Belarus | ₽899 (mağaza kısıtları elveriyorsa) |

## Kuşak D — ≈ 4,49 $/yıl (alt-orta alt dilim + düşük gelir; erişilebilirlik önceliği)

| Ülke | Yerel öneri |
|---|---|
| **Pakistan** | Rs 1.290 |
| **Bangladeş** | ৳540 |
| **Nijerya** | ₦6.900 |
| **Senegal / Mali / Nijer / Burkina Faso / Gine / Gambiya** (CFA bölgesi) | CFA 2.700 |
| **Somali / Cibuti / Sudan / Yemen / Moritanya** | $4.49 eşleniği |
| **Afganistan / Tacikistan / Kırgızistan** | $4.49 eşleniği |
| Kenya / Tanzanya / Uganda / Etiyopya / Ruanda | KSh 590 / TSh 11.900 / USh 16.900 / $4.49 / $4.49 |
| **Kamerun / Çad / Komorlar** | CFA 2.700 |
| Nepal / Kamboçya / Laos / Myanmar | $4.49 eşleniği |
| Haiti / Nikaragua / Honduras | $4.49 eşleniği |

## Kapsam dışı / özel durumlar

- **İran, Kuzey Kore, Suriye, Küba**: Apple/Google vitrini yok ya da yaptırım — plan dışı.
- **Oynak kur listesi** (₺, EGP, PKR, NGN, ARS, LBP): yerel fiyatı **çeyrekte bir** güncelle;
  hedef USD eşleniğinden ±%20 saparsa düzelt. Takvim hatırlatıcısı kur.
- Listede olmayan ülke → Dünya Bankası sınıfına göre kuşak; bilinmiyorsa Kuşak C.

## Lansman taktikleri

1. **7 gün ücretsiz deneme** — tüm ülkelerde.
2. **Ramazan intro offer** (2027: 8 Şub–9 Mar): ilk yıl %30 indirim (mağaza tarafında).
3. RevenueCat Experiments: ABD'de 24,99 vs 29,99; TR'de ₺349 vs ₺399; ID'de Rp 119k vs 139k.
4. AppGallery: RevenueCat çalışmadığından v1 ücretsiz (docs/04 kararı değişmedi).

## Konsol yapılacakları (Ufuk)

- [ ] App Store Connect: yıllık abonelik taban 24,99 $ + yukarıdaki vitrin fiyatları + 7 gün deneme
- [ ] Play Console: aynı değerlerle bölgesel fiyat şablonu (KDV dahil kontrolü)
- [ ] RevenueCat: "premium" entitlement'a ürünleri bağla (kod hazır)
- [ ] Çeyreklik kur gözden geçirme hatırlatıcısı (oynak kur listesi)
