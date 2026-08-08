import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/share_service.dart';

void main() {
  group('paylaşım metni', () {
    test('başlık + hüküm + tespitler + halis.app bağlantısı', () {
      final text = ShareService.buildShareText(
        title: 'Ferrero Nutella',
        verdictLine: 'Şüpheli · Profil: Diyanet',
        findingLines: ['E471: kaynağı belirsiz'],
        footer: 'Halis ile tarandı —',
      );
      expect(text, contains('Ferrero Nutella'));
      expect(text, contains('Şüpheli'));
      expect(text, contains('• E471'));
      expect(text, contains('Halis ile tarandı — https://halis.app'));
    });

    test('tespitler 5 ile sınırlanır, fazlası … ile kısaltılır', () {
      final text = ShareService.buildShareText(
        title: 'x',
        verdictLine: 'y',
        findingLines: List.generate(8, (i) => 'tespit $i'),
        footer: 'z',
      );
      expect('• '.allMatches(text).length, 5);
      expect(text, contains('…'));
    });

    test('tespitsiz temiz üründe madde işareti yok', () {
      final text = ShareService.buildShareText(
        title: 'Ekmek', verdictLine: 'Sorun görünmüyor', findingLines: [], footer: 'f');
      expect(text, isNot(contains('• ')));
    });
  });

  group('geri bildirim e-postası', () {
    test('mailto: destek adresi + konu + hüküm bağlamı + veri sürümü', () {
      final uri = ShareService.feedbackMailUri(
        subject: 'Halis geri bildirim',
        title: 'Ülker Çikolatalı Gofret',
        verdictLine: 'Şüpheli · Profil: Temkinli',
        dataVersion: '0.3.0',
        lang: 'tr',
      );
      expect(uri.scheme, 'mailto');
      expect(uri.path, ShareService.supportEmail);
      expect(uri.query, contains('subject='));
      final decoded = Uri.decodeComponent(uri.query);
      expect(decoded, contains('Ülker Çikolatalı Gofret'));
      expect(decoded, contains('Veri: 0.3.0'));
      // mailto gövdesinde '+' boşluk olarak yorumlanmamalı (%20 kullanılmalı).
      expect(uri.query, isNot(contains('+')));
    });
  });
}
