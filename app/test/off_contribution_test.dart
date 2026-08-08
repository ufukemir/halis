import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/off_contribution.dart';

void main() {
  group('OFF katkı akışı', () {
    test('OFF hesabı tanımlı değilken servis kapalıdır ve yükleme yapılmaz', () async {
      expect(OffContribution.isConfigured, isFalse);
      final ok = await OffContribution().uploadIngredientsPhoto(
        barcode: '8690000000000',
        imagePath: '/tmp/yok.jpg',
      );
      expect(ok, isFalse);
    });

    test('OFF yanıtı: "status ok" başarı sayılır', () {
      expect(OffContribution.isUploadOk('{"status":"status ok","image":{"imgid":1}}'), isTrue);
    });

    test('OFF yanıtı: hata ve bozuk gövde başarısız sayılır', () {
      expect(OffContribution.isUploadOk('{"status":"status not ok","error":"field imgupload_ingredients_tr not set"}'), isFalse);
      expect(OffContribution.isUploadOk('<html>502 Bad Gateway</html>'), isFalse);
      expect(OffContribution.isUploadOk(''), isFalse);
    });
  });
}
