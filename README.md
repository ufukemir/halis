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
4. **Dini hüküm değil, bilgilendirme.** Her sonuç kartında disclaimer + gerekçe + kaynak. `data/` dosyaları DRAFT'tır; yayın öncesi dini danışman onayı zorunludur.

## Durum (2026-07-31)

- [x] Pazar + rakip + teknik araştırma (docs/)
- [x] E-kod tablosu v0 (57 madde) + içerik sözlüğü v0
- [x] Flutter iskeleti: barkod tarama (mobile_scanner) + OFF sorgusu + kural motoru + sonuç ekranı
- [x] Kural motoru birim testleri (14/14 ✅), OFF API canlı doğrulama (Nutella barkodu)
- [x] FastAPI backend iskeleti (Claude Haiku 4.5, structured outputs)
- [ ] halis.app alan adı (Ufuk alacak) + Türk Patent/EUIPO taraması
- [ ] Etiket fotoğrafı akışı (ML Kit OCR → backend → kural motoru)
- [ ] E-kod tablosunu 200 maddeye genişletme + dini danışman incelemesi
- [ ] Fransızca sözlük (OFF'ta Avrupa ürünleri ağırlıkla FR etiketli)
- [ ] RevenueCat abonelik + kota
- [ ] i18n (SALSABİL altyapısından port) + onboarding + disclaimer ekranı
