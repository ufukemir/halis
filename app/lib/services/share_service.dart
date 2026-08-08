/// Paylaşım metni ve geri bildirim e-postası üretimi — saf fonksiyonlar,
/// UI'dan bağımsız ve test edilebilir. Paylaşım, sıfır bütçeli büyümenin
/// motoru; "Bildir" ise yanlış hüküm yakalama kanalıdır (marka koruması).
class ShareService {
  static const supportEmail = 'destek@halis.app';
  static const appUrl = 'https://halis.app';

  /// Sonuç kartının paylaşım metni (WhatsApp vb. için düz metin).
  static String buildShareText({
    required String title,
    required String verdictLine,
    required List<String> findingLines,
    required String footer,
  }) {
    final b = StringBuffer()
      ..writeln(title)
      ..writeln(verdictLine);
    if (findingLines.isNotEmpty) {
      b.writeln();
      for (final line in findingLines.take(5)) {
        b.writeln('• $line');
      }
      if (findingLines.length > 5) b.writeln('…');
    }
    b
      ..writeln()
      ..write('$footer $appUrl');
    return b.toString();
  }

  /// "Yanlış mı? Bildir" e-postası. Hüküm bağlamı (ürün, hüküm, veri sürümü)
  /// gövdeye hazır gelir ki bildirimler ayıklanabilir olsun.
  static Uri feedbackMailUri({
    required String subject,
    required String title,
    required String verdictLine,
    required String dataVersion,
    required String lang,
  }) {
    final body = [
      title,
      verdictLine,
      'Veri: $dataVersion · Dil: $lang',
      '',
      '---',
      '',
    ].join('\n');
    return Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _encodeQuery({'subject': subject, 'body': body}),
    );
  }

  // Uri.queryParameters '+' kullanır; mailto RFC'si %20 bekler.
  static String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
