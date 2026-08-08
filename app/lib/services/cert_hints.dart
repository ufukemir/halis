/// Etiket metninde helal sertifika İBARESİ tespiti (bilgi notu).
///
/// Bu bir doğrulama DEĞİLDİR: logo/ibare sahte olabilir; not daima
/// "kurumdan doğrulayın" uyarısıyla gösterilir ve hüküm rengini etkilemez.
class CertHints {
  static const _keywords = [
    // kurumlar
    'gimdes', 'jakim', 'mui', 'muis', 'halal food authority', 'hfa',
    'halal certification', 'helal akredite',
    // genel ibareler (6 dil)
    'helal sertifika', 'helal belgeli', 'halal certified', 'certified halal',
    'halal zertifiziert', 'certifié halal', 'sertifikat halal',
    'bersertifikat halal', 'شهادة حلال', 'معتمد حلال',
  ];

  /// Metinde geçen ilk sertifika ibaresi; yoksa null.
  static String? detect(String text) {
    final t = text.toLowerCase();
    for (final k in _keywords) {
      if (t.contains(k)) return k;
    }
    return null;
  }
}
