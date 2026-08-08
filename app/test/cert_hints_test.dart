import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/cert_hints.dart';

void main() {
  group('sertifika ibaresi tespiti', () {
    test('GİMDES ve genel ibareler yakalanır (büyük/küçük harf duyarsız)', () {
      expect(CertHints.detect('İçindekiler: su, şeker. GIMDES onaylıdır.'), isNotNull);
      expect(CertHints.detect('This product is Halal Certified.'), isNotNull);
      expect(CertHints.detect('Certifié halal par AVS'), isNotNull);
      expect(CertHints.detect('منتج معتمد حلال'), isNotNull);
      expect(CertHints.detect('Produk bersertifikat halal MUI'), isNotNull);
    });

    test('sıradan içerik metni ibare saymaz', () {
      expect(CertHints.detect('buğday unu, su, tuz, maya'), isNull);
      // 'helal' kelimesi tek başına sertifika iddiası değildir
      expect(CertHints.detect('helal gıda tüketmeye özen gösterin'), isNull);
    });
  });
}
