# Halis — Yapılacaklar (Lansman Yol Haritası)

> Kod donduruldu (2026-08-08, 72+12 test ✅). Aşağıdaki her şey lansmana
> giden yolun kalanı. Sıra önemli: her faz bir sonrakinin önünü açar.
> Ayrıntılar GitHub Issues'da (#1-#10).

## Faz 1 — Temel kapılar (Ufuk, ~1 gün) 🔑

- [ ] **halis.app alan adını al** + Türk Patent/EUIPO marka taraması *(15 dk — EN ACİL: destek@halis.app, gizlilik sayfası ve derin bağlantılar buna bağlı)* → Issue #1
- [ ] **destek@halis.app** e-postasını kur (Cloudflare Email Routing ücretsiz yönlendirme yeter)
- [ ] **halis.app/privacy** sayfasını yayınla (metin hazır: docs/04 → gizlilik politikası taslağı)
- [ ] **Apple Developer** hesabı (99 $/yıl; onay 1-2 gün sürebilir) → Issue #2
- [ ] **Google Play Console** hesabı (25 $ tek sefer) → Issue #2
- [ ] **Huawei AppGallery Connect** hesabı (bireysel ücretsiz, kimlik doğrulamalı) → Issue #2
- [ ] **20/B vergi kaydı** (lansmandan önce bitmiş olsun)

## Faz 2 — Gerçek cihaz testi (Ufuk + Claude, ~1-2 saat) 📱

- [ ] iPhone/Android telefonu bağla → `flutter run` ile kur → Issue #5
- [ ] Markette **20-30 ürün tarat**: kamera, barkod, OCR akışı (hiç gerçek cihaz görmedi!)
- [ ] **"Tarama anı" mağaza görselini** telefondan çek (eksik tek görsel)
- [ ] Varsa **Huawei cihazda** GMS'siz çalışmayı doğrula → Issue #6
- [ ] Bulunan hataları Claude'a bildir → düzeltme + OTA/yeni derleme

## Faz 3 — Servislerin bağlanması (Ufuk hesapları açar, Claude bağlar, ~yarım gün) 🔌

- [ ] **RevenueCat paneli**: yıllık abonelik ürünü + teklif tanımı → Issue #3
- [ ] RevenueCat webhook: URL + `HALIS_WEBHOOK_TOKEN` *(backend deploy edilirse)*
- [ ] **OFF uygulama hesabı** aç (katkı akışının kimliği) → Issue #4
- [ ] **Backend deploy kararı**: v1 backend'li mi backend'siz mi? *(backend'siz de tam çalışır; reçete backend/DEPLOY.md)* → Issue #7
- [ ] Anahtarları derlemeye bağla: `--dart-define=REVENUECAT_API_KEY=... OFF_USER_ID=... OFF_PASSWORD=... HALIS_API_URL=...` (Claude)

## Faz 4 — Mağaza yüklemeleri (birlikte, ~1 gün + inceleme bekleme) 🏪

- [ ] iOS: `flutter build ipa` → App Store Connect (metinler/görseller docs/04 + docs/store-assets hazır)
- [ ] Android: imzalı AAB hazır → Play Console'a yükle, Data Safety beyanları (docs/04'teki gibi)
- [ ] Huawei: arm64 APK → AppGallery (v1 ücretsiz sürüm)
- [ ] İnceleme retlerine hızlı dönüş (tipik 1-3 gün; bir tur pay bırak)
- [ ] ⚠️ `~/halis-keys/` yedeğini al (kaybolursa Play'de güncelleme yapılamaz!)

## Faz 5 — Lansman ve büyüme (sürekli) 📣

- [ ] Mağaza açıklamalarının DE/FR/AR/ID çevirileri (ilk hafta) → Issue #8
- [ ] Ekran görüntülerine 6 dilde pazarlama bandı → Issue #9
- [ ] TikTok/Reels "Bunu tarattım, meğer..." içerik hattı (TR + diaspora hesapları)
- [ ] halis.app'te SEO sayfaları ("E471 nedir, helal mi?" uzun kuyruk)
- [ ] "Marketini tarat" katkı kampanyası; Ramazan 2027 (≈8 Şubat) ana sezon
- [ ] Mağaza yorumlarına 24 saat içinde cevap düzeni
- [ ] İlk kullanıcı geri bildirimlerine göre v1.5 kararları → Issue #10 (v2+ havuzu)

## Arkadaş için hazır başlangıç noktaları

- Kurulum + kurallar: `CONTRIBUTING.md` (klonla → `flutter pub get` → `flutter test`)
- Uygun ilk işler: Issue #8 (çeviriler), #9 (görsel bantları), veri gözden geçirme (`data/`)
- Collaborator daveti: repo → Settings → Collaborators *(Ufuk ekleyecek)*
- Not: repo şu an **public** — private'a çekme kararı Ufuk'ta

## Tamamlananlar arşivi

MVP + tüm v1 özellikleri, 3 mağaza paketi, güvenlik sertleştirmesi, lansman
cilası: README "Durum" bölümünde ve git geçmişinde (22+ commit, 2026-08-07/08).
