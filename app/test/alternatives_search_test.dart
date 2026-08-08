import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:halis_app/models/models.dart';
import 'package:halis_app/services/alternatives_service.dart';
import 'package:halis_app/services/knowledge_base.dart';
import 'package:halis_app/services/off_api.dart';

/// Türkçe karakterli JSON — http.Response'un varsayılan Latin1'i yerine UTF-8.
http.Response _jsonResponse(Map<String, dynamic> body) => http.Response.bytes(
    utf8.encode(jsonEncode(body)), 200,
    headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  late KnowledgeBase kb;

  setUpAll(() {
    kb = KnowledgeBase.fromJsonStrings(
      File('assets/data/e_codes_v0.json').readAsStringSync(),
      File('assets/data/ingredients_v0.json').readAsStringSync(),
    );
  });

  group('OFF isim araması', () {
    test('sonuç listesi ayrıştırılır, kodsuz kayıtlar atlanır', () async {
      final client = MockClient((req) async {
        expect(req.url.path, '/cgi/search.pl');
        expect(req.headers['User-Agent'], contains('Halis/'));
        return _jsonResponse({
          'products': [
            {'code': '111', 'product_name': 'Fındık Ezmesi', 'brands': 'MarkaA'},
            {'product_name': 'kodsuz ürün'},
            {'code': '222', 'product_name': 'Çikolata'},
          ]
        });
      });
      final hits = await OffApi(client).searchByName('ezme');
      expect(hits, hasLength(2));
      expect(hits.first.barcode, '111');
      expect(hits.first.name, 'Fındık Ezmesi');
    });

    test('sunucu hatası OffApiException fırlatır', () {
      final client = MockClient((req) async => http.Response('oops', 500));
      expect(() => OffApi(client).searchByName('x'), throwsA(isA<OffApiException>()));
    });
  });

  group('temiz alternatif süzgeci', () {
    OffProduct problemli() => const OffProduct(
          barcode: '000',
          name: 'Şüpheli Gofret',
          categoryTags: ['en:snacks', 'en:wafers'],
        );

    MockClient categoryClient(List<Map<String, dynamic>> products) =>
        MockClient((req) async {
          expect(req.url.path, '/api/v2/search');
          expect(req.url.queryParameters['categories_tags'], 'en:wafers');
          return _jsonResponse({'products': products});
        });

    test('yalnız kural motorundan yeşil çıkanlar önerilir; verisiz ve haram elenir', () async {
      final client = categoryClient([
        {'code': '000', 'product_name': 'Kendisi', 'ingredients_text': 'un, su'},
        {'code': '1', 'product_name': 'Temiz Gofret', 'ingredients_text': 'buğday unu, şeker, bitkisel yağ'},
        {'code': '2', 'product_name': 'Jelatinli', 'ingredients_text': 'şeker, jelatin'},
        {'code': '3', 'product_name': 'Verisiz Ürün'},
        {'code': '4', 'product_name': 'E471li', 'ingredients_text': 'un, emülgatör e471'},
        {'code': '5', 'product_name': 'Temiz 2', 'ingredients_text': 'nohut, su, tuz'},
      ]);
      final alts = await AlternativesService(api: OffApi(client), kb: kb)
          .findClean(problemli(), Profile.diyanet);
      expect(alts.map((a) => a.barcode), ['1', '5']);
    });

    test('limit uygulanır', () async {
      final client = categoryClient([
        for (var i = 1; i <= 6; i++)
          {'code': '$i', 'product_name': 'T$i', 'ingredients_text': 'su, tuz'},
      ]);
      final alts = await AlternativesService(api: OffApi(client), kb: kb)
          .findClean(problemli(), Profile.diyanet, limit: 3);
      expect(alts, hasLength(3));
    });

    test('kategori yoksa veya ağ hatasında boş liste (akış bloke olmaz)', () async {
      const noCategory = OffProduct(barcode: 'x');
      final failing = MockClient((req) async => http.Response('down', 503));
      expect(
          await AlternativesService(api: OffApi(failing), kb: kb)
              .findClean(noCategory, Profile.diyanet),
          isEmpty);
      expect(
          await AlternativesService(api: OffApi(failing), kb: kb)
              .findClean(problemli(), Profile.diyanet),
          isEmpty);
    });
  });
}
