/// Overlay çeviri anahtarları: strings.dart'taki UZUN İngilizce metinlerin
/// birebir kopyaları. Overlay haritaları bu sabitleri anahtar olarak kullanır;
/// böylece 11 dil dosyasında aynı uzun metni elle kopyalama hatası olmaz.
///
/// DİKKAT: strings.dart'ta bu metinlerden biri değişirse buradaki sabit de
/// birebir güncellenmeli; aksi halde ek diller o dizgede İngilizceye düşer.
library;

const kTaglineEn = "Scan the barcode,\nknow what's inside.";
const kProfDescMuslimEn =
    'No school distinction: if any school deems it haram, it is avoided. The safest common ground.';
const kProfDescHanafiEn =
    'Hanafi fiqh: complete chemical transformation (istihala) is considered purifying.';
const kProfDescShafiiEn =
    "Shafi'i fiqh: avoidance in doubt is the rule; istihala is interpreted narrowly.";
const kProfDescMalikiEn =
    'Maliki fiqh: istihala is interpreted broadly; rulings are close to the Hanafi line.';
const kProfDescHanbaliEn =
    "Hanbali fiqh: precaution is the rule; rulings are close to the Shafi'i line.";
const kProfDescJafariEn =
    "Ja'fari fiqh: precaution is the basis; insect-derived and unverified animal-derived substances are avoided.";
const kProfDescDiyanetEn =
    "Based on the fatwas of Türkiye's Diyanet; rulings follow the actual source of the substance.";
const kNotFoundEn =
    'This barcode was not found in the database.\n\nYou can analyze the label by taking a photo of it.';
const kNetworkErrorEn =
    'Could not look up the product. Check your internet connection and try again.';
const kDisclaimerEn =
    'Informational, based on ingredient data; not a religious ruling. Product data: Open Food Facts.';
const kOcrHintEn =
    'Take a photo of the ingredients list; we will read and analyze the text. You can correct it below.';
const kOcrFailedEn =
    'Could not read the text. Try a clearer photo or type the text manually.';
const kQuotaBodyEn =
    'Barcode scans stay free by watching ads. Halis Premium with unlimited, ad-free use is coming soon.';
const kRamadanEn =
    "Ramadan blessings 🌙 Scan products for your iftar table; add missing ones with a photo and let's grow the database together.";
const kCertHintEn =
    'A halal certification mention was seen on the label. We recommend verifying it with the issuing body.';
const kDietHintEn =
    'Selected sensitivities appear as separate alerts on the product card; they never affect the halal verdict. Producer "may contain traces" declarations also trigger alerts.';
const kSearchContributeEn =
    "Can't find your product? Scan its barcode — if it's missing, add it with a photo. The database grows with every search.";
const kAlternativesTeaserEn =
    'With Premium, see alternatives from the same category that pass our rule engine clean.';
const kAlternativesEmptyEn =
    'No alternative with clean ingredient data found in this category.';
const kMarketHintEn =
    'Scan products one after another; each result is added to the list.';
const kOffContribHintEn =
    "This product isn't in the database yet. Share the label photo so the next user finds it with a single scan.";
const kOffContribConsentEn =
    'The label photo will be uploaded publicly to Open Food Facts, the open food database (ODbL license). Make sure no personal information is visible in the photo.';
const kOffContribThanksEn = 'Thank you! The photo was uploaded to Open Food Facts.';
const kOffContribFailedEn = 'Upload failed. You can try again later.';
const kQuotaUpgradeEn =
    'Barcode scans are free by watching ads. With Halis Premium, scans and label analysis become unlimited and ad-free.';
const kAiNormalizedEn =
    'Text was cleaned up by AI — you can review it before analyzing.';
const kPremiumBenefitsEn =
    '• Unlimited, ad-free barcode scanning\n• Unlimited label (AI) analyses\n• Supermarket mode — rapid scanning + basket summary\n• Clean alternative suggestions';
const kPurchaseFailedEn =
    'Purchase could not be completed. If you were not charged, you can try again.';
const kStoreUnavailableEn = 'Store connection is not enabled in this build.';
const kOnboardingBodyEn =
    'Halis is an informational tool that analyzes product ingredients with halal sensitivity.\n\n'
    '• Results are not religious rulings (fatwa); they are assessments based on ingredient data.\n'
    '• Data (Open Food Facts and our additive table) may be incomplete or outdated.\n'
    '• When in doubt, consult the producer or a halal certification body.\n'
    '• You are responsible for your own dietary choices.\n\n'
    'You can choose your assessment basis (your school of fiqh, "Just Muslim", or Diyanet) on the home screen.';
const kTextSizePreviewEn = 'Sample: the ingredient list will appear at this size.';
const kStatsLineEn = 'This month: {total} scans · {flagged} warnings';
const kMarketSummaryEn = '{total} products · {clean} clean · {flagged} flagged';
const kEcodeDbBadgeEn = '{n}-additive (E-number) database';
const kTraceSuffixEn = '{n} — possible traces';
const kSubscribeEn = 'Subscribe — {price}/year';
const kRemainingEn = 'Free analyses left this month: {n}';
const kSearchEcodeHintEn = 'Search code or name… (e.g. E471, gelatin)';
const kQuotaTitleEn = 'Monthly free analyses used up';
const kAllergensCommonEn = 'Common allergens (EU mandatory list)';
const kAllergensOtherEn = 'Other allergens (regional)';
const kAlignBarcodeEn = 'Align the barcode within the frame';
const kPremiumActiveEn = 'Premium is active — thank you!';
const kSystemLanguageEn = 'System language (automatic)';
const kWatchAdBodyEn =
    '1 short ad = 1 barcode scan. With Halis Premium, scanning is unlimited and ad-free.';
const kScansLeftEn = 'Scans left: {n}';
