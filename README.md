# Halis — Helal Gıda Tarayıcı

> "Barkodu tara, içindekini bil." Reklamsız, güven-öncelikli, mezhep-farkındalıklı helal gıda tarayıcı. Konumlanma: helal gıdanın Yuka'sı.

## Yapı

```
halis/
├── docs/                  # Pazar/rakip/teknik araştırma + MVP planı
│   ├── 01-rakip-analizi.md
│   ├── 02-teknik-altyapi.md
│   └── 03-mvp-plani.md
├── data/                  # ÇEKİRDEK VARLIK: elle derlenen hüküm verileri
│   ├── e_codes_v0.json    # 57 E-kodu, 3 hassasiyet profili (temkinli/genişlik/diyanet)
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
2. **Reklam yok, marka parası yok.** Gelir sadece abonelik (Yuka bağımsızlık modeli).
3. **ODbL ayrımı.** Open Food Facts verisi canlı API'dan sorgulanır, kendi hüküm veritabanımızla kalıcı olarak birleştirilmez (share-alike tetiklenmesin). Uygulamada OFF'a atıf gösterilir.
4. **Dini hüküm değil, bilgilendirme.** Her sonuç kartında disclaimer + gerekçe + kaynak. `data/` dosyaları elle derlenmiştir; bağımsız dini danışman incelemesi yayın önkoşulu değildir (Ufuk, 2026-08-07), istenirse sonradan güven/pazarlama unsuru olarak yaptırılabilir.

## Durum (2026-08-07)

- [x] Pazar + rakip + teknik araştırma (docs/)
- [x] Flutter iskeleti: barkod tarama (mobile_scanner) + OFF sorgusu + kural motoru + sonuç ekranı
- [x] FastAPI backend iskeleti (Claude Haiku 4.5, structured outputs)
- [x] Etiket fotoğrafı akışı: ML Kit OCR → (varsa) backend normalizasyonu → kural motoru.
      Backend adresi `--dart-define=HALIS_API_URL=...` ile verilir; tanımsızsa akış tamamen
      yerel çalışır, backend hatası akışı asla bloke etmez.
- [x] E-kod tablosu v1: **304 madde** (0.2.0), 3 hassasiyet profili (elle derlendi; danışman incelemesi opsiyonel)
- [x] i18n (TR/EN/DE/FR/AR/ID) + onboarding/disclaimer ekranı + tarama geçmişi
- [x] RevenueCat abonelik + aylık kota: barkod sınırsız ücretsiz; etiket analizi ücretsizde
      ayda 10 (cihazda sayılır), premium sınırsız. Anahtarlar `--dart-define=REVENUECAT_API_KEY=...`
      ile; anahtar yoksa mağaza kapalı, uygulama ücretsiz katman kurallarıyla çalışır.
      Paywall ekranı fiyatı mağaza teklifinden okur. (Android minSdk 24'e sabitlendi.)
- [x] Birim testleri: kural motoru + kota + normalizasyon (29/29 ✅), `flutter analyze` temiz
- [ ] halis.app alan adı (Ufuk alıyor) + Türk Patent/EUIPO taraması
- [ ] Backend kota doğrulaması (RevenueCat webhook + cihaz kimliği) — şimdilik kota istemci tarafında
- [ ] RevenueCat panelinde ürün/teklif tanımı + mağaza hesapları (Ufuk)
- [ ] Fransızca sözlük (OFF'ta Avrupa ürünleri ağırlıkla FR etiketli)
