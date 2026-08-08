# Halis — Katkı Kılavuzu

## Kurulum

```bash
# Uygulama
cd app && flutter pub get && flutter test      # 58 test, hepsi yeşil olmalı
flutter analyze                                 # sıfır uyarı kuralı

# Backend (opsiyonel — uygulama backend'siz de tam çalışır)
cd backend && python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
.venv/bin/python -m pytest tests/               # 10 test
```

Simülatör notu: ML Kit pod'ları arm64 simülatör dilimi içermediğinden iOS 26
simülatöründe normal derleme AÇILMAZ. Simülatör için geçici OCR-stub tarifi:
`docs/store-assets/README.md`. Gerçek cihazda sorun yok.

## Değiştirilemez mimari ilkeler (README'de de var)

1. **Yeşil yalnız kural motorundan çıkar.** LLM sadece normalize eder; hüküm
   daima cihazdaki deterministik motorda. Şüphede daima turuncu.
2. **Reklam yok, marka parası yok.** Gelir sadece abonelik.
3. **ODbL ayrımı:** OFF verisi canlı sorgulanır, hüküm veritabanımızla kalıcı
   birleştirilmez.
4. **Dini hüküm değil, bilgilendirme.** Her sonuçta disclaimer + gerekçe.

## Veri düzenleme kuralları

- `data/` ve `app/assets/data/` İKİZ tutulur — birini değiştirirsen diğerini de
  senkronla (script: `data/add_aliases.py` örneğine bak), sürümü artır.
- Yeni E-kodu/madde eklerken: 3 profil hükmü + TR ve EN gerekçe zorunlu.
  Emin değilsen hüküm DAİMA `mushbooh` — asla tahminle `halal` yazma.
- Her veri değişikliğinde `flutter test` — "yanlış yeşil koruması" test grubu
  bilinen haram etiketlerin hiçbir dil/profilde yeşil yanmadığını doğrular.

## Test kuralı

Davranış değiştiren her PR test getirir. Özellikle kural motoru/veri
değişikliklerinde: yeni davranışın hem pozitif hem "yanlış yeşil" testi.

## Açık işler (2026-08-08 itibarıyla)

Kod:
- [ ] Backend deploy (reçete: `backend/DEPLOY.md`; karar: şimdilik deploy yok)
- [ ] FR/AR/ID mağaza açıklamaları çevirisi (docs/04, EN'den)
- [ ] Geçmiş senkronu (premium vaadi, v1.5)
- [ ] Sertifika sorgusu (GİMDES/TSE, v2) · Restoran modu (v2) · Kozmetik (v3)

Kod dışı (Ufuk):
- [ ] halis.app alan adı + Türk Patent/EUIPO taraması
- [ ] Apple Developer + Play Console + RevenueCat + OFF uygulama hesabı
- [ ] Gerçek cihaz testi (kamera/barkod/OCR + "tarama anı" ekran görüntüsü)
- [ ] 20/B vergi kaydı

## Commit/PR

- Küçük, tek konulu commit'ler; Türkçe mesaj serbest.
- `main`'e doğrudan push yerine PR tercih edilir (iki kişi olunca).
- PR şablonu: ne değişti, neden, hangi testler eklendi.
