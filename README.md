# Halis — Helal Gıda Tarayıcı

> "Barkodu tara, içindekini bil." Güven-öncelikli, mezhep-farkındalıklı helal gıda tarayıcı. Konumlanma: helal gıdanın Yuka'sı.

## Yapı

```
halis/
├── docs/                  # Pazar/rakip/teknik araştırma + MVP planı
│   ├── 01-rakip-analizi.md
│   ├── 02-teknik-altyapi.md
│   └── 03-mvp-plani.md
├── data/                  # ÇEKİRDEK VARLIK: elle derlenen hüküm verileri
│   ├── e_codes_v0.json    # 304 E-kodu, 6 mezhep sütunu (hanefi/safii/maliki/hanbeli/caferi/diyanet)
│   └── ingredients_v0.json# Haram/şüpheli madde sözlüğü (TR/EN/DE)
├── app/                   # Flutter uygulaması (iOS + Android)
│   └── lib/
│       ├── models/        # Verdict, Profile, EcodeEntry...
│       ├── services/      # rule_engine (yerel hüküm motoru), off_api, knowledge_base
│       └── screens/       # tarama, sonuç kartı
└── backend/               # FastAPI — LLM etiket normalizasyonu (hüküm VERMEZ)
```

## Çalıştırma

```bash
# Testler (kural motoru — 14 test)
cd app && flutter test

# Uygulama (simülatörde elle barkod girişiyle test edilebilir)
cd app && flutter run

# Backend
cd backend && pip install -r requirements.txt
ANTHROPIC_API_KEY=sk-... uvicorn app.main:app --reload
```

## Mimari ilkeler (değiştirilemez)

1. **Yeşil yalnız kural motorundan çıkar.** LLM sadece OCR metnini normalize eder; hüküm daima cihazdaki deterministik motorda verilir. Şüphede daima turuncu.
2. **Marka parası yok; banner/marka reklamı yok.** Gelir: abonelik + kullanıcının kendi başlattığı ödüllü videolar (1 reklam = 1 tarama). Hükümler satılık değildir; reklam hüküm ekranına asla karışmaz.
3. **ODbL ayrımı.** Open Food Facts verisi canlı API'dan sorgulanır, kendi hüküm veritabanımızla kalıcı olarak birleştirilmez (share-alike tetiklenmesin). Uygulamada OFF'a atıf gösterilir.
4. **Dini hüküm değil, bilgilendirme.** Her sonuç kartında disclaimer + gerekçe + kaynak. `data/` dosyaları elle derlenmiştir; bağımsız dini danışman incelemesi yayın önkoşulu değildir (Ufuk, 2026-08-07), istenirse sonradan güven/pazarlama unsuru olarak yaptırılabilir.

## Durum (2026-08-08)

- [x] Pazar + rakip + teknik araştırma (docs/)
- [x] Flutter iskeleti: barkod tarama (mobile_scanner) + OFF sorgusu + kural motoru + sonuç ekranı
- [x] FastAPI backend iskeleti (Claude Haiku 4.5, structured outputs)
- [x] Etiket fotoğrafı akışı: ML Kit OCR → (varsa) backend normalizasyonu → kural motoru.
      Backend adresi `--dart-define=HALIS_API_URL=...` ile verilir; tanımsızsa akış tamamen
      yerel çalışır, backend hatası akışı asla bloke etmez.
- [x] E-kod tablosu v1: **304 madde** (0.4.0), mezhep sütunları — Hanefî/Şafiî/Mâlikî/Hanbelî/Caferî + Diyanet
      (elle derlendi; danışman incelemesi opsiyonel). "Sadece Müslümanım" = mezhep sütunlarının
      en ihtiyatlısı, uygulama tarafında hesaplanır (varsayılan seçim). Hüküm ekranı ikili
      (Helal/Haram) + "Net değil" ara durumu; şüpheli maddeler uyarı listesinde gerekçeleriyle.
- [x] i18n **17 dil**: çekirdek TR/EN/DE/FR/AR/ID (strings.dart içinde) + overlay katmanıyla
      ES/IT/NL/PL/RU/SQ/BS/AZ/MS/UR/BN (lib/l10n/overlay_*.dart; anahtar = İngilizce metin,
      eksik anahtar EN'e düşer; test/i18n_overlay_test.dart anahtar kümelerini ve yer
      tutucuları denetler — strings.dart'ta EN metni değiştirirsen overlay'i de güncelle!)
      + onboarding/disclaimer ekranı + tarama geçmişi
- [x] Ayarlar ekranı: yazı boyutu (%85-140, canlı ölçekleme) + dil seçimi (sistem dili
      veya 17 dilden biri); SharedPreferences'ta kalıcı, değişince tüm uygulama anında
      yeniden çizilir (AppSettings ChangeNotifier + MaterialApp builder)
- [x] RevenueCat abonelik + aylık kota: barkod sınırsız ücretsiz; etiket analizi ücretsizde
      ayda 10 (cihazda sayılır), premium sınırsız. Anahtarlar `--dart-define=REVENUECAT_API_KEY=...`
      ile; anahtar yoksa mağaza kapalı, uygulama ücretsiz katman kurallarıyla çalışır.
      Paywall ekranı fiyatı mağaza teklifinden okur. (Android minSdk 24'e sabitlendi.)
- [x] E-kod isim eşleşmesi: 55 sorunlu koda çok dilli alias (TR/EN/DE/FR/AR/ID) —
      etiket kodu yazmasa da ("polysorbate 80", "stéarate de magnésium") yakalanır;
      istisna kalıpları ("bitkisel gliserin") eşleşmeyi iptal eder. Tablo 0.3.0.
- [x] Backend kota doğrulaması: `X-Device-Id` başına aylık sınır (SQLite), aşımda 402 →
      istemci yerel analize düşer. `/v1/revenuecat-webhook` (HALIS_WEBHOOK_TOKEN ile
      korunur) premium tablosunu besler; `/v1/quota` durum ucu. Cihaz kimliği =
      RevenueCat appUserID (mağazasız modda kalıcı yerel kimlik). 10 pytest ✅
- [x] OFF katkı akışı (MVP md.7): ürün bulunamadığında etiket fotoğrafı, kullanıcı
      onayıyla (ODbL uyarılı diyalog) Open Food Facts'e yüklenir. OFF hesabı
      `--dart-define=OFF_USER_ID/OFF_PASSWORD` ile; tanımsızsa akış gizli.
- [x] Yanlış yeşil koruması: istisna maskeleme düzeltmesi (ikinci kaynaksız
      madde artık maskelenmez), Almanca bileşik kelimeler (Schweineschmalz),
      304 kodluk tablo denetimi, düşmanca test paketi (haram etiketler
      6 dil × 7 profilde asla yeşil yanmaz)
- [x] Paylaş (halis.app bağlantılı) + "Yanlış mı? Bildir" (mailto, hüküm
      bağlamlı) + ana ekranda veri sürümü göstergesi
- [x] Temiz alternatif önerisi (premium; her aday kural motorundan geçer),
      isimle arama (ücretsiz), süpermarket modu (art arda tarama + sepet özeti; PREMIUM —
      girişte paywall, abone olunca hemen açılır)
- [x] Ödüllü reklam modeli (AdMob): ücretsizde 1 reklam = 1 barkod tarama
      (5 kredilik hoş geldin paketi; elle giriş de kapıdan geçer); reklam
      yüklenemezse tarama ücretsiz sürer (fail-open — çevrimdışı/inceleme asla
      kilitlenmez); istekler kişiselleştirilmemiş (npa); TEST kimlikleri gömülü,
      gerçekleri dart-define + manifest/plist (docs/06); premium: reklamsız+sınırsız
- [x] Dünya fiyatlandırma planı (docs/05): 29,99$ taban, 4 PPP kuşağı, ~70 ülke için
      yerel fiyat önerisi; uygulama fiyatı mağazadan okur, kod değişikliği gerekmez
- [x] Mağaza paketi: metinler + ASO + gizlilik beyanları (docs/04),
      6 ekran görüntüsü 6,9" (docs/store-assets/), OFF User-Agent yayın değeri
- [x] Play: imzalı AAB doğrulandı (74 MB); split-ABI APK'lar. AppGallery:
      GMS bağımlılığı yok (gömülü ML Kit), v1 ücretsiz çıkar — docs/04
- [x] Backend deploy reçetesi (backend/Dockerfile + DEPLOY.md; deploy kararı bekliyor)
- [x] E-Kod Ansiklopedisi: 304 kodun aranabilir başvurusu (kod/isim/alias),
      profil bazlı hüküm + 7 profil karşılaştırma çipleri
- [x] Alerjen/diyet katmanı: **25 alerjen** — AB 1169/2011 zorunlu 14'lüsü + OFF
      taksonomisindeki 11 bölgesel ek (sığır/tavuk/jelatin/meyveler/Japon listesi;
      domuz bilinçli hariç — hüküm motoru işi) + vegan/vejetaryen/palm yağı seçimi;
      seçim ekranı bölümlü (AB / bölgesel / diyet); OFF traces_tags "içerebilir"
      beyanları "— iz olabilir" etiketiyle ayrıca uyarır; ürün kartında hükümden
      AYRI turuncu uyarı çipleri (hükmü asla etkilemez)
- [x] Favoriler + kara liste ("Ürünlerim"), ürün karşılaştırma (2 slot),
      süpermarket modunda hüküm başına titreşim, aylık istatistik kartı
- [x] Geçmiş yeniden analizi (profil değişince hükümler tazelenir),
      sertifika ibaresi tespiti (bilgi notu, "kurumdan doğrulayın")
- [x] Arama büyüme döngüsü: ülke öncelikli sonuçlar (TR/DE/FR/ID), sayfalama,
      "Barkodu Tarat ve Ekle" → OFF katkısı (veritabanı her aramayla büyür)
- [x] Uygulama simgesi kısayolları (Tara/Etiket/Market), Ramazan sezon banner'ı
- [x] Lansman cilası: karanlık mod (sistem), erişilebilirlik (hüküm ikonlarında
      sesli etiket), OTA veri güncellemesi (backend /v1/data → kabul çitleriyle
      sıcak değişim), mağaza değerlendirme isteği (5. taramada bir kez)
- [x] Birim testleri: **72 app + 12 backend** ✅, `flutter analyze` temiz
- [x] CONTRIBUTING.md (kurulum, ilkeler, veri kuralları, iş bölüşümü)

**KOD DONDURULDU (2026-08-08):** v1 kapsamı tamam; yeni özellik kararları
lansman sonrası kullanıcı geri bildirimiyle verilecek. Kalan işler GitHub
Issues'da (hesap kapıları + cihaz testleri).

### Kalan işler

Hesap/karar (kod dışı — Ufuk):
- [ ] halis.app alan adı + Türk Patent/EUIPO taraması (destek@halis.app ve
      gizlilik sayfası buna bağlı)
- [ ] Apple Developer (99 $/yıl) + Google Play Console (25 $) + AppGallery
      Connect (ücretsiz) hesapları
- [ ] RevenueCat paneli: ürün/teklif + webhook URL'si + HALIS_WEBHOOK_TOKEN
- [ ] OFF'ta uygulama hesabı (katkı akışının kimliği)
- [ ] 20/B vergi kaydı

Cihaz gerektiren:
- [ ] Gerçek cihazda uçtan uca test (kamera/barkod/OCR hiç gerçek cihaz görmedi)
- [ ] "Tarama anı" mağaza görseli (simülatörde kamera yok)
- [ ] Huawei cihazda GMS'siz çalışma doğrulaması (AppGallery yayını öncesi şart)

Kod (küçük / sonraya):
- [ ] Backend deploy (istenirse; reçete hazır)
- [ ] Mağaza açıklamalarının DE/FR/AR/ID çevirileri (lansman sonrası ilk hafta)
- [ ] Ekran görüntülerine pazarlama bandı (6 dil)
- [ ] v2+: sertifika sorgusu (GİMDES/TSE), restoran modu, geçmiş senkronu,
      Huawei IAP (talep görürse), kozmetik (v3)
