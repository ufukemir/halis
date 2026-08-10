import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/data_update_service.dart';
import 'package:halis_app/services/knowledge_base.dart';

String _ecodes(String version, int count) => jsonEncode({
      'version': version,
      'codes': [
        for (var i = 0; i < count; i++)
          {
            'code': 'E${100 + i}',
            'name_tr': 'x',
            'name_en': 'x',
            'source': 'plant',
            'verdict': {
              'hanefi': 'halal', 'safii': 'halal', 'maliki': 'halal',
              'hanbeli': 'halal', 'caferi': 'halal', 'diyanet': 'halal',
            },
            'reason_tr': 'r',
            'reason_en': 'r',
          }
      ],
    });

String _ingredients(int count) => jsonEncode({
      'entries': [
        for (var i = 0; i < count; i++)
          {
            'id': 'e$i',
            'status': 'haram',
            'terms_tr': ['t$i'],
            'reason_tr': 'r',
            'reason_en': 'r',
          }
      ],
    });

void main() {
  final current = KnowledgeBase.fromJsonStrings(_ecodes('0.3.0', 5), _ingredients(3));

  group('OTA sürüm karşılaştırma', () {
    test('parça bazlı sayısal sıralama', () {
      expect(DataUpdateService.compareVersions('0.3.1', '0.3.0'), greaterThan(0));
      expect(DataUpdateService.compareVersions('0.10.0', '0.9.9'), greaterThan(0));
      expect(DataUpdateService.compareVersions('1.0.0', '0.99.99'), greaterThan(0));
      expect(DataUpdateService.compareVersions('0.3.0', '0.3.0'), 0);
      expect(DataUpdateService.compareVersions('0.2.9', '0.3.0'), lessThan(0));
    });
  });

  group('OTA kabul çitleri', () {
    test('daha yeni sürüm + aynı/fazla kayıt → kabul', () {
      expect(
          DataUpdateService.isAcceptable(
              newEcodes: _ecodes('0.3.1', 6),
              newIngredients: _ingredients(3),
              current: current),
          isTrue);
    });

    test('eski veya aynı sürüm → ret (downgrade koruması)', () {
      for (final v in ['0.3.0', '0.2.9']) {
        expect(
            DataUpdateService.isAcceptable(
                newEcodes: _ecodes(v, 9),
                newIngredients: _ingredients(9),
                current: current),
            isFalse,
            reason: v);
      }
    });

    test('kayıt sayısı azalırsa → ret (kırpılmış tablo koruması)', () {
      expect(
          DataUpdateService.isAcceptable(
              newEcodes: _ecodes('0.4.0', 4),
              newIngredients: _ingredients(3),
              current: current),
          isFalse);
      expect(
          DataUpdateService.isAcceptable(
              newEcodes: _ecodes('0.4.0', 5),
              newIngredients: _ingredients(2),
              current: current),
          isFalse);
    });

    test('parse edilemeyen veri → ret', () {
      expect(
          DataUpdateService.isAcceptable(
              newEcodes: 'bozuk{json', newIngredients: _ingredients(3), current: current),
          isFalse);
    });
  });
}
