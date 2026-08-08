import 'package:flutter/material.dart';

import '../models/models.dart';

/// Hafif yerelleştirme: TR/EN/DE/FR/AR/ID. Eksik anahtar EN'e düşer.
/// Arapça RTL yönü MaterialApp'in localization delegate'leriyle otomatiktir.
class S {
  final String lang;

  const S(this.lang);

  static const supported = ['tr', 'en', 'de', 'fr', 'ar', 'id'];

  static S of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ??
        WidgetsBinding.instance.platformDispatcher.locale;
    final code = locale.languageCode;
    return S(supported.contains(code) ? code : 'en');
  }

  /// Türkçe gerekçe/özet metinleri yalnız TR arayüzde; diğer diller EN metni görür.
  bool get useTurkishReasons => lang == 'tr';

  String _t(Map<String, String> m) => m[lang] ?? m['en']!;

  String get appName => 'Halis';

  String get tagline => _t(const {
        'tr': 'Barkodu tara,\niçindekini bil.',
        'en': "Scan the barcode,\nknow what's inside.",
        'de': 'Barcode scannen,\nInhalt kennen.',
        'fr': 'Scannez le code-barres,\nsachez ce qu\'il contient.',
        'ar': 'امسح الباركود\nواعرف المكونات.',
        'id': 'Pindai barcode,\nketahui isinya.',
      });

  String get scanBarcode => _t(const {
        'tr': 'Barkod Tara', 'en': 'Scan Barcode', 'de': 'Barcode scannen',
        'fr': 'Scanner le code-barres', 'ar': 'مسح الباركود', 'id': 'Pindai Barcode',
      });

  String get analyzeLabel => _t(const {
        'tr': 'Etiket Fotoğrafı Analiz Et', 'en': 'Analyze Label Photo',
        'de': 'Etikett-Foto analysieren', 'fr': 'Analyser la photo de l\'étiquette',
        'ar': 'تحليل صورة الملصق', 'id': 'Analisis Foto Label',
      });

  String get sensitivityProfile => _t(const {
        'tr': 'Hassasiyet profili', 'en': 'Sensitivity profile', 'de': 'Empfindlichkeitsprofil',
        'fr': 'Profil de sensibilité', 'ar': 'ملف الحساسية', 'id': 'Profil sensitivitas',
      });

  String profileName(Profile p) => switch (p) {
        Profile.temkinli => _t(const {
            'tr': 'Temkinli', 'en': 'Cautious', 'de': 'Vorsichtig',
            'fr': 'Prudent', 'ar': 'احتياطي', 'id': 'Hati-hati',
          }),
        Profile.genislik => _t(const {
            'tr': 'Genişlik', 'en': 'Lenient', 'de': 'Weit',
            'fr': 'Souple', 'ar': 'موسَّع', 'id': 'Longgar',
          }),
        Profile.diyanet => 'Diyanet',
      };

  String get manualBarcode => _t(const {
        'tr': 'Barkodu elle gir (test)', 'en': 'Enter barcode manually (test)',
        'de': 'Barcode manuell eingeben (Test)', 'fr': 'Saisir le code-barres (test)',
        'ar': 'أدخل الباركود يدويًا (اختبار)', 'id': 'Masukkan barcode manual (uji)',
      });

  String get recentScans => _t(const {
        'tr': 'Son taramalar', 'en': 'Recent scans', 'de': 'Letzte Scans',
        'fr': 'Analyses récentes', 'ar': 'عمليات المسح الأخيرة', 'id': 'Pemindaian terakhir',
      });

  String get result => _t(const {
        'tr': 'Sonuç', 'en': 'Result', 'de': 'Ergebnis',
        'fr': 'Résultat', 'ar': 'النتيجة', 'id': 'Hasil',
      });

  String get alignBarcode => _t(const {
        'tr': 'Barkodu çerçeveye hizala', 'en': 'Align the barcode within the frame',
        'de': 'Barcode im Rahmen ausrichten', 'fr': 'Alignez le code-barres dans le cadre',
        'ar': 'ضع الباركود داخل الإطار', 'id': 'Sejajarkan barcode dalam bingkai',
      });

  String get profileLabel => _t(const {
        'tr': 'Profil', 'en': 'Profile', 'de': 'Profil',
        'fr': 'Profil', 'ar': 'الملف', 'id': 'Profil',
      });

  String get confidence => _t(const {
        'tr': 'Güven', 'en': 'Confidence', 'de': 'Konfidenz',
        'fr': 'Confiance', 'ar': 'الثقة', 'id': 'Keyakinan',
      });

  String get findings => _t(const {
        'tr': 'Tespitler', 'en': 'Findings', 'de': 'Befunde',
        'fr': 'Constats', 'ar': 'النتائج', 'id': 'Temuan',
      });

  String get ingredientsLabel => _t(const {
        'tr': 'İçindekiler (etiket)', 'en': 'Ingredients (label)', 'de': 'Zutaten (Etikett)',
        'fr': 'Ingrédients (étiquette)', 'ar': 'المكونات (الملصق)', 'id': 'Komposisi (label)',
      });

  String get unnamedProduct => _t(const {
        'tr': 'İsimsiz ürün', 'en': 'Unnamed product', 'de': 'Unbenanntes Produkt',
        'fr': 'Produit sans nom', 'ar': 'منتج بلا اسم', 'id': 'Produk tanpa nama',
      });

  String verdictTitle(Verdict v) => switch (v) {
        Verdict.halal => _t(const {
            'tr': 'Sorun görünmüyor', 'en': 'Looks fine', 'de': 'Unbedenklich',
            'fr': 'Rien à signaler', 'ar': 'لا مشكلة ظاهرة', 'id': 'Tampak aman',
          }),
        Verdict.mushbooh => _t(const {
            'tr': 'Şüpheli', 'en': 'Doubtful', 'de': 'Zweifelhaft',
            'fr': 'Douteux', 'ar': 'مشبوه', 'id': 'Syubhat',
          }),
        Verdict.haram => _t(const {
            'tr': 'Uygun değil', 'en': 'Not permissible', 'de': 'Nicht zulässig',
            'fr': 'Non permis', 'ar': 'غير جائز', 'id': 'Tidak halal',
          }),
        Verdict.unknown => _t(const {
            'tr': 'Veri yetersiz', 'en': 'Not enough data', 'de': 'Zu wenig Daten',
            'fr': 'Données insuffisantes', 'ar': 'بيانات غير كافية', 'id': 'Data kurang',
          }),
      };

  String get notFound => _t(const {
        'tr': 'Bu barkod veritabanında bulunamadı.\n\nEtiketin fotoğrafını çekerek analiz edebilirsiniz.',
        'en': 'This barcode was not found in the database.\n\nYou can analyze the label by taking a photo of it.',
        'de': 'Dieser Barcode wurde nicht gefunden.\n\nSie können das Etikett fotografieren und analysieren.',
        'fr': 'Code-barres introuvable dans la base.\n\nVous pouvez analyser l\'étiquette en la photographiant.',
        'ar': 'لم يُعثر على هذا الباركود في قاعدة البيانات.\n\nيمكنك تحليل الملصق بالتقاط صورة له.',
        'id': 'Barcode tidak ditemukan di basis data.\n\nAnda dapat menganalisis label dengan memotretnya.',
      });

  String get networkError => _t(const {
        'tr': 'Ürün sorgulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.',
        'en': 'Could not look up the product. Check your internet connection and try again.',
        'de': 'Produkt konnte nicht abgefragt werden. Prüfen Sie Ihre Internetverbindung.',
        'fr': 'Impossible de consulter le produit. Vérifiez votre connexion Internet.',
        'ar': 'تعذّر الاستعلام عن المنتج. تحقق من اتصالك بالإنترنت وحاول مجددًا.',
        'id': 'Tidak dapat mencari produk. Periksa koneksi internet Anda dan coba lagi.',
      });

  String get disclaimer => _t(const {
        'tr': 'İçerik verisine dayalı bilgilendirmedir; dini hüküm değildir. Ürün verisi: Open Food Facts.',
        'en': 'Informational, based on ingredient data; not a religious ruling. Product data: Open Food Facts.',
        'de': 'Information auf Basis von Zutatendaten; kein religiöses Urteil. Produktdaten: Open Food Facts.',
        'fr': 'Information basée sur les données d\'ingrédients ; pas un avis religieux. Données : Open Food Facts.',
        'ar': 'معلومات تستند إلى بيانات المكونات؛ وليست حكمًا شرعيًا. بيانات المنتج: Open Food Facts.',
        'id': 'Informasi berdasarkan data komposisi; bukan fatwa. Data produk: Open Food Facts.',
      });

  // Etiket analiz ekranı
  String get labelTitle => _t(const {
        'tr': 'Etiket Analizi', 'en': 'Label Analysis', 'de': 'Etikett-Analyse',
        'fr': 'Analyse de l\'étiquette', 'ar': 'تحليل الملصق', 'id': 'Analisis Label',
      });

  String get takePhoto => _t(const {
        'tr': 'Fotoğraf Çek', 'en': 'Take Photo', 'de': 'Foto aufnehmen',
        'fr': 'Prendre une photo', 'ar': 'التقاط صورة', 'id': 'Ambil Foto',
      });

  String get fromGallery => _t(const {
        'tr': 'Galeriden Seç', 'en': 'From Gallery', 'de': 'Aus Galerie',
        'fr': 'Depuis la galerie', 'ar': 'من المعرض', 'id': 'Dari Galeri',
      });

  String get ocrHint => _t(const {
        'tr': 'İçindekiler listesinin fotoğrafını çekin; metni okuyup analiz edelim. Metni aşağıda düzeltebilirsiniz.',
        'en': 'Take a photo of the ingredients list; we will read and analyze the text. You can correct it below.',
        'de': 'Fotografieren Sie die Zutatenliste; wir lesen und analysieren den Text. Unten können Sie ihn korrigieren.',
        'fr': 'Photographiez la liste des ingrédients ; nous lirons et analyserons le texte. Vous pouvez le corriger ci-dessous.',
        'ar': 'التقط صورة لقائمة المكونات؛ سنقرأ النص ونحلله. يمكنك تصحيحه أدناه.',
        'id': 'Foto daftar komposisi; kami akan membaca dan menganalisis teksnya. Anda dapat mengoreksinya di bawah.',
      });

  String get labelTextField => _t(const {
        'tr': 'İçindekiler metni', 'en': 'Ingredients text', 'de': 'Zutatentext',
        'fr': 'Texte des ingrédients', 'ar': 'نص المكونات', 'id': 'Teks komposisi',
      });

  String get analyze => _t(const {
        'tr': 'Analiz Et', 'en': 'Analyze', 'de': 'Analysieren',
        'fr': 'Analyser', 'ar': 'تحليل', 'id': 'Analisis',
      });

  String get ocrFailed => _t(const {
        'tr': 'Metin okunamadı. Daha net bir fotoğraf deneyin veya metni elle yazın.',
        'en': 'Could not read the text. Try a clearer photo or type the text manually.',
        'de': 'Text konnte nicht gelesen werden. Versuchen Sie ein schärferes Foto oder tippen Sie den Text.',
        'fr': 'Texte illisible. Essayez une photo plus nette ou saisissez le texte.',
        'ar': 'تعذّرت قراءة النص. جرّب صورة أوضح أو اكتب النص يدويًا.',
        'id': 'Teks tidak terbaca. Coba foto yang lebih jelas atau ketik teksnya.',
      });

  // Kota / premium
  String get quotaTitle => _t(const {
        'tr': 'Aylık ücretsiz analiz hakkınız doldu', 'en': 'Monthly free analyses used up',
        'de': 'Monatliches Gratis-Kontingent aufgebraucht', 'fr': 'Quota mensuel gratuit épuisé',
        'ar': 'انتهت التحليلات المجانية لهذا الشهر', 'id': 'Kuota analisis gratis bulan ini habis',
      });

  String get quotaBody => _t(const {
        'tr': 'Barkod tarama her zaman sınırsız ve ücretsizdir. Sınırsız etiket analizi için Halis Premium yakında burada olacak.',
        'en': 'Barcode scanning is always unlimited and free. Halis Premium with unlimited label analysis is coming soon.',
        'de': 'Barcode-Scannen bleibt immer unbegrenzt und kostenlos. Halis Premium mit unbegrenzter Etikett-Analyse kommt bald.',
        'fr': 'Le scan de code-barres reste illimité et gratuit. Halis Premium avec analyse illimitée arrive bientôt.',
        'ar': 'مسح الباركود مجاني وغير محدود دائمًا. Halis Premium بتحليل غير محدود قريبًا.',
        'id': 'Pemindaian barcode selalu gratis tanpa batas. Halis Premium dengan analisis tak terbatas segera hadir.',
      });

  String get ok => _t(const {
        'tr': 'Tamam', 'en': 'OK', 'de': 'OK', 'fr': 'OK', 'ar': 'حسنًا', 'id': 'OK',
      });

  String get myProducts => _t(const {
        'tr': 'Ürünlerim', 'en': 'My Products', 'de': 'Meine Produkte',
        'fr': 'Mes produits', 'ar': 'منتجاتي', 'id': 'Produk Saya',
      });

  String get favorites => _t(const {
        'tr': 'Favoriler', 'en': 'Favorites', 'de': 'Favoriten',
        'fr': 'Favoris', 'ar': 'المفضلة', 'id': 'Favorit',
      });

  String get avoided => _t(const {
        'tr': 'Kaçındıklarım', 'en': 'Avoided', 'de': 'Gemieden',
        'fr': 'À éviter', 'ar': 'أتجنبها', 'id': 'Dihindari',
      });

  String get dietTitle => _t(const {
        'tr': 'Diyet ve Alerjen Uyarıları', 'en': 'Diet & Allergen Alerts',
        'de': 'Diät- & Allergen-Hinweise', 'fr': 'Alertes régime et allergènes',
        'ar': 'تنبيهات الحمية ومسببات الحساسية', 'id': 'Peringatan Diet & Alergen',
      });

  String get dietHint => _t(const {
        'tr': 'Seçtiğiniz hassasiyetler ürün kartında ayrı uyarı olarak görünür; helal hükmünü etkilemez.',
        'en': 'Selected sensitivities appear as separate alerts on the product card; they never affect the halal verdict.',
        'de': 'Ausgewählte Empfindlichkeiten erscheinen als separate Hinweise; sie beeinflussen das Halal-Ergebnis nicht.',
        'fr': 'Les sensibilités choisies apparaissent comme alertes séparées ; elles n\'affectent jamais le verdict halal.',
        'ar': 'تظهر الحساسيات المختارة كتنبيهات منفصلة على بطاقة المنتج؛ ولا تؤثر على الحكم أبدًا.',
        'id': 'Sensitivitas terpilih muncul sebagai peringatan terpisah; tidak memengaruhi hasil halal.',
      });

  String allergenName(String key) => _t(switch (key) {
        'gluten' => const {'tr': 'Gluten', 'en': 'Gluten', 'de': 'Gluten', 'fr': 'Gluten', 'ar': 'الغلوتين', 'id': 'Gluten'},
        'milk' => const {'tr': 'Süt/Laktoz', 'en': 'Milk/Lactose', 'de': 'Milch/Laktose', 'fr': 'Lait/Lactose', 'ar': 'الحليب/اللاكتوز', 'id': 'Susu/Laktosa'},
        'eggs' => const {'tr': 'Yumurta', 'en': 'Eggs', 'de': 'Eier', 'fr': 'Œufs', 'ar': 'البيض', 'id': 'Telur'},
        'nuts' => const {'tr': 'Sert kabuklu (fındık vb.)', 'en': 'Tree nuts', 'de': 'Schalenfrüchte', 'fr': 'Fruits à coque', 'ar': 'المكسرات', 'id': 'Kacang pohon'},
        'peanuts' => const {'tr': 'Yer fıstığı', 'en': 'Peanuts', 'de': 'Erdnüsse', 'fr': 'Arachides', 'ar': 'الفول السوداني', 'id': 'Kacang tanah'},
        'soy' => const {'tr': 'Soya', 'en': 'Soy', 'de': 'Soja', 'fr': 'Soja', 'ar': 'الصويا', 'id': 'Kedelai'},
        'sesame' => const {'tr': 'Susam', 'en': 'Sesame', 'de': 'Sesam', 'fr': 'Sésame', 'ar': 'السمسم', 'id': 'Wijen'},
        'fish' => const {'tr': 'Balık', 'en': 'Fish', 'de': 'Fisch', 'fr': 'Poisson', 'ar': 'السمك', 'id': 'Ikan'},
        'vegan' => const {'tr': 'Vegan değil/belirsiz', 'en': 'Not/maybe not vegan', 'de': 'Nicht/evtl. nicht vegan', 'fr': 'Non/peut-être non végane', 'ar': 'غير نباتي صرف/غير مؤكد', 'id': 'Bukan/mungkin bukan vegan'},
        'vegetarian' => const {'tr': 'Vejetaryen değil/belirsiz', 'en': 'Not/maybe not vegetarian', 'de': 'Nicht/evtl. nicht vegetarisch', 'fr': 'Non/peut-être non végétarien', 'ar': 'غير نباتي/غير مؤكد', 'id': 'Bukan/mungkin bukan vegetarian'},
        _ => const {'tr': '?', 'en': '?'},
      });

  /// Hassasiyet seçim ekranındaki onay kutusu etiketi (vegan/vejetaryen
  /// için tercihin adı, uyarı metni değil).
  String dietPrefName(String key) => _t(switch (key) {
        'vegan' => const {'tr': 'Vegan', 'en': 'Vegan', 'de': 'Vegan', 'fr': 'Végane', 'ar': 'نباتي صرف', 'id': 'Vegan'},
        'vegetarian' => const {'tr': 'Vejetaryen', 'en': 'Vegetarian', 'de': 'Vegetarisch', 'fr': 'Végétarien', 'ar': 'نباتي', 'id': 'Vegetarian'},
        _ => const {'tr': '?', 'en': '?'},
      });

  String statsLine(int total, int flagged) => _t({
        'tr': 'Bu ay $total tarama · $flagged uyarı',
        'en': 'This month: $total scans · $flagged warnings',
        'de': 'Diesen Monat: $total Scans · $flagged Warnungen',
        'fr': 'Ce mois-ci : $total scans · $flagged alertes',
        'ar': 'هذا الشهر: $total مسحًا · $flagged تحذيرًا',
        'id': 'Bulan ini: $total pindaian · $flagged peringatan',
      });

  String get encyclopediaTitle => _t(const {
        'tr': 'E-Kod Ansiklopedisi', 'en': 'E-Number Encyclopedia',
        'de': 'E-Nummern-Lexikon', 'fr': 'Encyclopédie des E-numéros',
        'ar': 'موسوعة أرقام E', 'id': 'Ensiklopedia E-Number',
      });

  String get encyclopediaSearchHint => _t(const {
        'tr': 'E-kod veya isim ara… (ör. E471, jelatin)',
        'en': 'Search code or name… (e.g. E471, gelatin)',
        'de': 'Code oder Name suchen… (z. B. E471)',
        'fr': 'Chercher un code ou un nom… (ex. E471)',
        'ar': 'ابحث عن رمز أو اسم… (مثل E471)',
        'id': 'Cari kode atau nama… (mis. E471)',
      });

  String get searchByName => _t(const {
        'tr': 'İsimle Ara', 'en': 'Search by Name', 'de': 'Nach Name suchen',
        'fr': 'Rechercher par nom', 'ar': 'البحث بالاسم', 'id': 'Cari dengan Nama',
      });

  String get searchHint => _t(const {
        'tr': 'Ürün veya marka adı…', 'en': 'Product or brand name…',
        'de': 'Produkt- oder Markenname…', 'fr': 'Nom du produit ou de la marque…',
        'ar': 'اسم المنتج أو العلامة…', 'id': 'Nama produk atau merek…',
      });

  String get noResults => _t(const {
        'tr': 'Sonuç bulunamadı.', 'en': 'No results found.',
        'de': 'Keine Ergebnisse gefunden.', 'fr': 'Aucun résultat trouvé.',
        'ar': 'لم يتم العثور على نتائج.', 'id': 'Tidak ada hasil.',
      });

  String get alternativesTitle => _t(const {
        'tr': 'Temiz alternatifler', 'en': 'Clean alternatives',
        'de': 'Saubere Alternativen', 'fr': 'Alternatives sans problème',
        'ar': 'بدائل نظيفة', 'id': 'Alternatif bersih',
      });

  String get alternativesTeaser => _t(const {
        'tr': 'Premium ile bu ürünün aynı kategoriden, kural motorumuzda temiz çıkan alternatiflerini görün.',
        'en': 'With Premium, see alternatives from the same category that pass our rule engine clean.',
        'de': 'Mit Premium sehen Sie Alternativen aus derselben Kategorie, die unsere Prüfung sauber bestehen.',
        'fr': 'Avec Premium, découvrez des alternatives de la même catégorie jugées sans problème par notre moteur.',
        'ar': 'مع Premium، شاهد بدائل من الفئة نفسها اجتازت محرك القواعد لدينا.',
        'id': 'Dengan Premium, lihat alternatif dari kategori yang sama yang lolos mesin aturan kami.',
      });

  String get alternativesEmpty => _t(const {
        'tr': 'Bu kategoride içerik verisi temiz çıkan alternatif bulunamadı.',
        'en': 'No alternative with clean ingredient data found in this category.',
        'de': 'Keine Alternative mit sauberen Zutatendaten in dieser Kategorie gefunden.',
        'fr': 'Aucune alternative aux ingrédients sans problème trouvée dans cette catégorie.',
        'ar': 'لم يُعثر على بديل ببيانات مكونات نظيفة في هذه الفئة.',
        'id': 'Tidak ditemukan alternatif dengan data bahan bersih di kategori ini.',
      });

  String get marketMode => _t(const {
        'tr': 'Süpermarket Modu', 'en': 'Supermarket Mode', 'de': 'Supermarkt-Modus',
        'fr': 'Mode supermarché', 'ar': 'وضع السوبرماركت', 'id': 'Mode Supermarket',
      });

  String marketSummary(int total, int clean, int flagged) => _t({
        'tr': '$total ürün · $clean temiz · $flagged işaretli',
        'en': '$total products · $clean clean · $flagged flagged',
        'de': '$total Produkte · $clean sauber · $flagged markiert',
        'fr': '$total produits · $clean sans problème · $flagged signalés',
        'ar': '$total منتجات · $clean نظيفة · $flagged مُعلَّمة',
        'id': '$total produk · $clean bersih · $flagged ditandai',
      });

  String get marketHint => _t(const {
        'tr': 'Ürünleri art arda taratın; her sonuç listeye eklenir.',
        'en': 'Scan products one after another; each result is added to the list.',
        'de': 'Scannen Sie Produkte nacheinander; jedes Ergebnis wird zur Liste hinzugefügt.',
        'fr': 'Scannez les produits à la suite ; chaque résultat s\'ajoute à la liste.',
        'ar': 'امسح المنتجات تباعًا؛ تُضاف كل نتيجة إلى القائمة.',
        'id': 'Pindai produk satu per satu; setiap hasil ditambahkan ke daftar.',
      });

  String get share => _t(const {
        'tr': 'Paylaş', 'en': 'Share', 'de': 'Teilen', 'fr': 'Partager',
        'ar': 'مشاركة', 'id': 'Bagikan',
      });

  String get reportWrong => _t(const {
        'tr': 'Yanlış mı? Bildir',
        'en': 'Wrong? Report it',
        'de': 'Falsch? Melden',
        'fr': 'Erreur ? Signaler',
        'ar': 'خطأ؟ أبلغ عنه',
        'id': 'Salah? Laporkan',
      });

  String get reportSubject => _t(const {
        'tr': 'Halis geri bildirim: hüküm itirazı',
        'en': 'Halis feedback: verdict dispute',
        'de': 'Halis Feedback: Einspruch zum Ergebnis',
        'fr': 'Halis retour : contestation du résultat',
        'ar': 'ملاحظات Halis: اعتراض على النتيجة',
        'id': 'Masukan Halis: sanggahan hasil',
      });

  String get sharedWith => _t(const {
        'tr': 'Halis ile tarandı —',
        'en': 'Scanned with Halis —',
        'de': 'Gescannt mit Halis —',
        'fr': 'Scanné avec Halis —',
        'ar': 'تم المسح بواسطة Halis —',
        'id': 'Dipindai dengan Halis —',
      });

  String get dataVersionLabel => _t(const {
        'tr': 'Veri', 'en': 'Data', 'de': 'Daten', 'fr': 'Données',
        'ar': 'البيانات', 'id': 'Data',
      });

  String ecodeDbBadge(int n) => _t({
        'tr': '$n katkı maddesi (E-kod) veritabanı',
        'en': '$n-additive (E-number) database',
        'de': 'Datenbank mit $n Zusatzstoffen (E-Nummern)',
        'fr': 'Base de $n additifs (E-numéros)',
        'ar': 'قاعدة بيانات تضم $n من الإضافات (أرقام E)',
        'id': 'Basis data $n bahan tambahan (E-number)',
      });

  String get cancel => _t(const {
        'tr': 'Vazgeç', 'en': 'Cancel', 'de': 'Abbrechen', 'fr': 'Annuler',
        'ar': 'إلغاء', 'id': 'Batal',
      });

  String get offContribTitle => _t(const {
        'tr': 'Veritabanına katkıda bulun',
        'en': 'Contribute to the database',
        'de': 'Zur Datenbank beitragen',
        'fr': 'Contribuer à la base de données',
        'ar': 'ساهم في قاعدة البيانات',
        'id': 'Berkontribusi ke basis data',
      });

  String get offContribHint => _t(const {
        'tr': 'Bu ürün veritabanında yok. Etiket fotoğrafını paylaşırsanız bir sonraki kullanıcı ürünü tek taramayla bulur.',
        'en': "This product isn't in the database yet. Share the label photo so the next user finds it with a single scan.",
        'de': 'Dieses Produkt ist noch nicht in der Datenbank. Teilen Sie das Etikett-Foto, damit der nächste Nutzer es mit einem Scan findet.',
        'fr': "Ce produit n'est pas encore dans la base. Partagez la photo de l'étiquette pour que le prochain utilisateur le trouve en un scan.",
        'ar': 'هذا المنتج غير موجود في قاعدة البيانات بعد. شارك صورة الملصق ليجده المستخدم التالي بمسحة واحدة.',
        'id': 'Produk ini belum ada di basis data. Bagikan foto label agar pengguna berikutnya menemukannya dengan sekali pindai.',
      });

  String get offContribConsent => _t(const {
        'tr': 'Etiket fotoğrafı, açık gıda veritabanı Open Food Facts\'e herkese açık olarak (ODbL lisansıyla) yüklenecek. Fotoğrafta kişisel bilgi görünmediğinden emin olun.',
        'en': 'The label photo will be uploaded publicly to Open Food Facts, the open food database (ODbL license). Make sure no personal information is visible in the photo.',
        'de': 'Das Etikett-Foto wird öffentlich in die offene Lebensmitteldatenbank Open Food Facts hochgeladen (ODbL-Lizenz). Stellen Sie sicher, dass keine persönlichen Daten sichtbar sind.',
        'fr': 'La photo de l\'étiquette sera publiée sur Open Food Facts, la base alimentaire ouverte (licence ODbL). Vérifiez qu\'aucune information personnelle n\'est visible.',
        'ar': 'سيتم رفع صورة الملصق علنًا إلى قاعدة الأغذية المفتوحة Open Food Facts (رخصة ODbL). تأكد من عدم ظهور أي معلومات شخصية في الصورة.',
        'id': 'Foto label akan diunggah secara publik ke Open Food Facts, basis data pangan terbuka (lisensi ODbL). Pastikan tidak ada informasi pribadi yang terlihat.',
      });

  String get offContribSend => _t(const {
        'tr': 'Fotoğrafı Gönder', 'en': 'Upload Photo', 'de': 'Foto hochladen',
        'fr': 'Envoyer la photo', 'ar': 'رفع الصورة', 'id': 'Unggah Foto',
      });

  String get offContribThanks => _t(const {
        'tr': 'Teşekkürler! Fotoğraf Open Food Facts\'e yüklendi.',
        'en': 'Thank you! The photo was uploaded to Open Food Facts.',
        'de': 'Danke! Das Foto wurde zu Open Food Facts hochgeladen.',
        'fr': 'Merci ! La photo a été envoyée à Open Food Facts.',
        'ar': 'شكرًا لك! تم رفع الصورة إلى Open Food Facts.',
        'id': 'Terima kasih! Foto telah diunggah ke Open Food Facts.',
      });

  String get offContribFailed => _t(const {
        'tr': 'Yükleme başarısız oldu. Daha sonra tekrar deneyebilirsiniz.',
        'en': 'Upload failed. You can try again later.',
        'de': 'Hochladen fehlgeschlagen. Versuchen Sie es später erneut.',
        'fr': 'Échec de l\'envoi. Vous pourrez réessayer plus tard.',
        'ar': 'فشل الرفع. يمكنك المحاولة لاحقًا.',
        'id': 'Unggahan gagal. Anda dapat mencoba lagi nanti.',
      });

  String get quotaBodyUpgrade => _t(const {
        'tr': 'Barkod tarama her zaman sınırsız ve ücretsizdir. Halis Premium ile etiket analizi de sınırsız olur.',
        'en': 'Barcode scanning is always unlimited and free. With Halis Premium, label analysis becomes unlimited too.',
        'de': 'Barcode-Scannen bleibt immer unbegrenzt und kostenlos. Mit Halis Premium wird auch die Etikett-Analyse unbegrenzt.',
        'fr': 'Le scan de code-barres reste illimité et gratuit. Avec Halis Premium, l\'analyse d\'étiquettes devient illimitée.',
        'ar': 'مسح الباركود مجاني وغير محدود دائمًا. مع Halis Premium يصبح تحليل الملصقات غير محدود أيضًا.',
        'id': 'Pemindaian barcode selalu gratis tanpa batas. Dengan Halis Premium, analisis label juga tanpa batas.',
      });

  String get goPremium => _t(const {
        'tr': 'Premium\'a Geç', 'en': 'Go Premium', 'de': 'Premium holen',
        'fr': 'Passer à Premium', 'ar': 'الترقية إلى Premium', 'id': 'Ke Premium',
      });

  String get aiNormalized => _t(const {
        'tr': 'Metin yapay zekâ ile düzeltildi — analizden önce kontrol edebilirsiniz.',
        'en': 'Text was cleaned up by AI — you can review it before analyzing.',
        'de': 'Der Text wurde per KI bereinigt — Sie können ihn vor der Analyse prüfen.',
        'fr': 'Le texte a été corrigé par IA — vous pouvez le vérifier avant l\'analyse.',
        'ar': 'تم تنقيح النص بالذكاء الاصطناعي — يمكنك مراجعته قبل التحليل.',
        'id': 'Teks dirapikan oleh AI — Anda dapat memeriksanya sebelum analisis.',
      });

  // Paywall
  String get premiumTitle => 'Halis Premium';

  String get premiumBenefits => _t(const {
        'tr': '• Sınırsız etiket (AI) analizi\n• Tüm hassasiyet profilleri\n• Reklam yok — hiçbir zaman olmadı, olmayacak\n• Gelirin tamamı bağımsızlığımızı korur: marka parası ve reklam almayız',
        'en': '• Unlimited label (AI) analyses\n• All sensitivity profiles\n• No ads — never had them, never will\n• Revenue keeps us independent: no brand money, no advertising',
        'de': '• Unbegrenzte Etikett-(KI-)Analysen\n• Alle Empfindlichkeitsprofile\n• Keine Werbung — nie gehabt, nie geplant\n• Der Erlös sichert unsere Unabhängigkeit: kein Markengeld, keine Werbung',
        'fr': '• Analyses d\'étiquettes (IA) illimitées\n• Tous les profils de sensibilité\n• Pas de pub — jamais eu, jamais prévu\n• Les revenus garantissent notre indépendance : pas d\'argent de marques, pas de publicité',
        'ar': '• تحليلات ملصقات (AI) غير محدودة\n• جميع ملفات الحساسية\n• لا إعلانات — أبدًا\n• الإيرادات تحفظ استقلالنا: لا أموال علامات تجارية ولا إعلانات',
        'id': '• Analisis label (AI) tanpa batas\n• Semua profil sensitivitas\n• Tanpa iklan — tidak pernah dan tidak akan\n• Pendapatan menjaga independensi kami: tanpa uang merek, tanpa iklan',
      });

  String subscribeFor(String price) => _t(const {
        'tr': 'Abone Ol — {price}/yıl', 'en': 'Subscribe — {price}/year',
        'de': 'Abonnieren — {price}/Jahr', 'fr': 'S\'abonner — {price}/an',
        'ar': 'اشترك — {price}/سنة', 'id': 'Berlangganan — {price}/tahun',
      }).replaceFirst('{price}', price);

  String get restorePurchases => _t(const {
        'tr': 'Satın alımları geri yükle', 'en': 'Restore purchases',
        'de': 'Käufe wiederherstellen', 'fr': 'Restaurer les achats',
        'ar': 'استعادة المشتريات', 'id': 'Pulihkan pembelian',
      });

  String get premiumActive => _t(const {
        'tr': 'Premium etkin — teşekkürler!', 'en': 'Premium is active — thank you!',
        'de': 'Premium ist aktiv — danke!', 'fr': 'Premium actif — merci !',
        'ar': 'Premium مفعّل — شكرًا لك!', 'id': 'Premium aktif — terima kasih!',
      });

  String get purchaseFailed => _t(const {
        'tr': 'Satın alma tamamlanamadı. Ücret alınmadıysa tekrar deneyebilirsiniz.',
        'en': 'Purchase could not be completed. If you were not charged, you can try again.',
        'de': 'Der Kauf konnte nicht abgeschlossen werden. Falls nichts abgebucht wurde, versuchen Sie es erneut.',
        'fr': 'L\'achat n\'a pas pu être finalisé. Si vous n\'avez pas été débité, réessayez.',
        'ar': 'تعذّر إتمام الشراء. إن لم يتم خصم مبلغ يمكنك المحاولة مجددًا.',
        'id': 'Pembelian tidak dapat diselesaikan. Jika tidak terpotong biaya, coba lagi.',
      });

  String get storeUnavailable => _t(const {
        'tr': 'Mağaza bağlantısı bu sürümde etkin değil.',
        'en': 'Store connection is not enabled in this build.',
        'de': 'Die Store-Verbindung ist in dieser Version nicht aktiviert.',
        'fr': 'La connexion à la boutique n\'est pas activée dans cette version.',
        'ar': 'اتصال المتجر غير مفعّل في هذا الإصدار.',
        'id': 'Koneksi toko tidak diaktifkan dalam versi ini.',
      });

  String remainingAnalyses(int n) => _t(const {
        'tr': 'Bu ay kalan ücretsiz analiz: {n}', 'en': 'Free analyses left this month: {n}',
        'de': 'Verbleibende Gratis-Analysen diesen Monat: {n}', 'fr': 'Analyses gratuites restantes ce mois-ci : {n}',
        'ar': 'التحليلات المجانية المتبقية هذا الشهر: {n}', 'id': 'Sisa analisis gratis bulan ini: {n}',
      }).replaceFirst('{n}', '$n');

  // Onboarding
  String get onboardingTitle => _t(const {
        'tr': 'Halis\'e hoş geldiniz', 'en': 'Welcome to Halis', 'de': 'Willkommen bei Halis',
        'fr': 'Bienvenue sur Halis', 'ar': 'مرحبًا بكم في Halis', 'id': 'Selamat datang di Halis',
      });

  String get onboardingBody => _t(const {
        'tr': 'Halis, ürün içeriklerini helal hassasiyetiyle analiz eden bir bilgilendirme aracıdır.\n\n'
            '• Sonuçlar dini hüküm (fetva) değildir; içerik verilerine dayalı değerlendirmedir.\n'
            '• Veriler (Open Food Facts ve katkı maddesi tablomuz) güncel veya eksiksiz olmayabilir.\n'
            '• Şüpheli durumlarda üreticiye veya bir helal sertifika kuruluşuna danışın.\n'
            '• Beslenme tercihlerinizin sorumluluğu size aittir.\n\n'
            'Hassasiyet profilinizi (Temkinli / Genişlik / Diyanet) ana ekrandan seçebilirsiniz.',
        'en': 'Halis is an informational tool that analyzes product ingredients with halal sensitivity.\n\n'
            '• Results are not religious rulings (fatwa); they are assessments based on ingredient data.\n'
            '• Data (Open Food Facts and our additive table) may be incomplete or outdated.\n'
            '• When in doubt, consult the producer or a halal certification body.\n'
            '• You are responsible for your own dietary choices.\n\n'
            'You can choose your sensitivity profile (Cautious / Lenient / Diyanet) on the home screen.',
        'de': 'Halis ist ein Informationswerkzeug, das Produktzutaten mit Halal-Sensibilität analysiert.\n\n'
            '• Ergebnisse sind keine religiösen Urteile (Fatwa), sondern datenbasierte Einschätzungen.\n'
            '• Daten (Open Food Facts und unsere Zusatzstofftabelle) können unvollständig oder veraltet sein.\n'
            '• Im Zweifel Hersteller oder Halal-Zertifizierungsstelle fragen.\n'
            '• Für Ihre Ernährungsentscheidungen sind Sie selbst verantwortlich.\n\n'
            'Ihr Empfindlichkeitsprofil wählen Sie auf dem Startbildschirm.',
        'fr': 'Halis est un outil d\'information qui analyse les ingrédients avec une sensibilité halal.\n\n'
            '• Les résultats ne sont pas des avis religieux (fatwa) ; ce sont des évaluations basées sur les données.\n'
            '• Les données (Open Food Facts et notre table d\'additifs) peuvent être incomplètes ou obsolètes.\n'
            '• En cas de doute, consultez le producteur ou un organisme de certification halal.\n'
            '• Vous êtes responsable de vos choix alimentaires.\n\n'
            'Choisissez votre profil de sensibilité sur l\'écran d\'accueil.',
        'ar': 'Halis أداة معلوماتية تحلل مكونات المنتجات بحساسية الحلال.\n\n'
            '• النتائج ليست فتاوى شرعية؛ بل تقييمات تستند إلى بيانات المكونات.\n'
            '• قد تكون البيانات (Open Food Facts وجدول المضافات لدينا) ناقصة أو غير محدثة.\n'
            '• عند الشك استشر المنتِج أو جهة اعتماد حلال.\n'
            '• أنت المسؤول عن خياراتك الغذائية.\n\n'
            'يمكنك اختيار ملف الحساسية من الشاشة الرئيسية.',
        'id': 'Halis adalah alat informasi yang menganalisis komposisi produk dengan kepekaan halal.\n\n'
            '• Hasil bukan fatwa; melainkan penilaian berdasarkan data komposisi.\n'
            '• Data (Open Food Facts dan tabel aditif kami) mungkin tidak lengkap atau tidak mutakhir.\n'
            '• Jika ragu, hubungi produsen atau lembaga sertifikasi halal.\n'
            '• Anda bertanggung jawab atas pilihan makanan Anda.\n\n'
            'Pilih profil sensitivitas Anda di layar utama.',
      });

  String get onboardingAccept => _t(const {
        'tr': 'Anladım, kabul ediyorum', 'en': 'I understand and accept',
        'de': 'Verstanden, ich akzeptiere', 'fr': 'J\'ai compris et j\'accepte',
        'ar': 'فهمت وأوافق', 'id': 'Saya mengerti dan menerima',
      });
}
