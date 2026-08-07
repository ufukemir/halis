# Halis — MVP Planı ve Konumlanma

## Konumlanma (tek cümle)
**"Helal gıdanın Yuka'sı":** reklamsız, güven-öncelikli, mezhep-farkındalıklı, Türkiye+Avrupa'yı gerçekten kapsayan helal tarayıcı.

## Rakiplerin yaralarına karşı 5 ilke
| Rakip yarası | Halis ilkesi |
|---|---|
| Reklam bombardımanı (Mustakshif: 4×60sn) | **Sıfır reklam, sonsuza dek.** Gelir sadece abonelik. |
| Güven kaybı (TagHalal: domuz jelatinine "helal") | Her sonuçta **gerekçe + kaynak + güven seviyesi**; emin değilsek "şüpheli" deriz, asla tahmin yeşili yakmayız. |
| Bayat DB (Scan Halal: 1+ yıl inceleme kuyruğu) | OFF canlı API + kural motoru → statik hüküm DB'si yok, içerikten türetilmiş hüküm. |
| Cimri ücretsiz katman (1-2 tarama) | Barkod taraması **sınırsız ücretsiz** (yerel kural motoru, marjinal maliyet ~0). Premium = AI foto analizi + mezhep modu + alternatif önerisi. |
| Tek hüküm dayatması | Mezhep/hassasiyet seçimi: "Temkinli" (Şafii/ihtiyat) vs "Genişlik" (Hanefi/istihale) + Diyanet referansı. |

## Karar akışı (hüküm motoru)
```
Barkod tara
 ├─ OFF'ta bulundu → içerik listesi + E-kodlar çek
 │   ├─ Kural motoru (yerel, ücretsiz):
 │   │   haram madde var → KIRMIZI (gerekçeli)
 │   │   mushbooh var → TURUNCU "şüpheli: E471 kaynağı belirsiz" (+mezhep notu)
 │   │   vegan=yes / temiz → YEŞİL (güven notuyla)
 │   └─ İçerik verisi eksik → kullanıcıdan etiket fotoğrafı iste (OCR akışına düş + OFF'a katkı)
 └─ Bulunamadı → etiket fotoğrafı → ML Kit OCR (ücretsiz) → LLM analizi (premium/kotali)
```

## MVP kapsamı (v1.0 — hedef: 10-12 hafta)
1. Barkod tarama (mobile_scanner) + OFF sorgusu + yerel kural motoru + 3 renkli sonuç kartı (gerekçe, kaynak, güven seviyesi)
2. E-kodu veritabanı v1: ~200 katkı maddesi, mezhep boyutlu, gerekçeli (elle derlenmiş — çekirdek varlık)
3. Etiket fotoğrafı → OCR → LLM analizi (ücretsiz kullanıcıya ayda 10, premium sınırsız)
4. Mezhep/hassasiyet ayarı (Temkinli/Genişlik/Diyanet)
5. Diller: TR + EN + DE (Almanya diasporası) — SALSABİL i18n altyapısı yeniden kullanılacak
6. Tarama geçmişi (yerel) + disclaimer onboarding'i
7. "Ürün bulunamadı → fotoğrafla katkıda bulun" akışı (DB'yi kullanıcı büyütür — Türkiye kapsam açığını bu kapatır)

### v1'e BİLEREK girmeyenler
- Restoran modu (v2), sertifika sorgulama (v2, GİMDES/TSE senkronu), alternatif ürün önerisi (v1.5 — Yuka'nın katil özelliği, premium'un ana kozu olacak), kozmetik/ilaç (v3)

## Monetizasyon
- **Ücretsiz:** sınırsız barkod, ayda 10 AI foto analizi, tek mezhep modu
- **Premium ~$29,99/yıl** (RevenueCat medyanı; rakip HalalChecker AI ile aynı): sınırsız AI analizi, mezhep modları, alternatif önerisi (v1.5), geçmiş senkronu
- Reklam YOK. Marka parası YOK (Yuka bağımsızlık modeli = pazarlama mesajının kendisi)

## Teknoloji seçimi
- **Uygulama: Flutter** (mobile_scanner + ML Kit + resmi OFF SDK'sı en olgun burada; tek kod tabanı iOS+Android)
- **Backend: FastAPI (Python)** — Ufuk'un mevcut uzmanlığı; işi: LLM proxy + kota/abonelik doğrulama + E-kod tablosu dağıtımı + katkı kuyruğu. E-kod tablosu uygulamaya gömülü gider (offline çalışır), backend'den güncellenir.
- LLM: Claude Haiku 4.5 (prompt caching ile) veya GPT-4o-mini; A/B ile karar.

## Dağıtım planı (gün 1'den)
- TikTok/Reels/Shorts: "Bunu tarattım, meğer..." formatı — TR + diaspora (DE/UK/FR) hesapları
- Ramazan 2027 (≈ 8 Şubat 2027 civarı) = lansman sonrası ilk büyük sezon; SALSABİL ile çapraz tanıtım
- ASO: "helal mi", "E471 helal mi" tipi uzun kuyruk aramalar; App Store indirmelerinin %60'ı aramadan geliyor
- Reddit/forum: r/islam, r/Muslim topluluklarına üye olarak katıl (drive-by tanıtım yasak)

## Riskler
1. **Yanlış "yeşil" verme riski** → en kritik ürün riski. Politika: şüphede daima turuncu; kural motoru muhafazakâr; LLM çıktısı asla tek başına yeşil yakamaz (yalnız kural motoru teyidiyle).
2. Muslim Pro'nun tarayıcı eklemesi → hız + güven markası + yerelleşmeyle öne geçmek; onlar reklam modeline mahkûm, biz değiliz.
3. OFF Türkiye kapsamı zayıf (~8K ürün) → katkı akışı + Ramazan kampanyası ("marketini tarat, veritabanını büyüt").
4. ODbL share-alike → mimari ayrımla yönetiliyor (bkz. 02-teknik-altyapi.md).

## Sonraki adımlar
- [ ] E-kod tablosu v0: ilk 50 kritik katkı maddesi (Diyanet + HalalCodeCheck + akademik kaynaklardan derleme)
- [ ] Flutter projesi iskeleti + mobile_scanner + OFF sorgusu POC (1 hafta)
- [ ] Kural motoru çekirdeği + 20 gerçek ürünle test (Türk marketi + Alman marketi ürünleri)
- [ ] Ücretsiz/premium kota altyapısı (RevenueCat)
- [x] İsim/marka kararı: ~~HalalLens~~ dolu çıktı (halallens.no + Play'de 2 uygulama) → **marka adı: Halis** (TR/AR "saf, katıksız"; mağaza adı: "Halis — Halal Food Scanner" / "Halis — Helal Gıda Tarayıcı"). Yapılacak: halis.app alan adını HEMEN al (boşta görünüyor); Türk Patent + EUIPO marka taraması yaptır. Not: halisapp.com Mayıs 2026'da başkasınca alınmış, zulal.app ve tayib.app dolu.
