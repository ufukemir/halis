import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/models/models.dart';
import 'package:halis_app/services/knowledge_base.dart';
import 'package:halis_app/services/rule_engine.dart';

void main() {
  late RuleEngine engine;

  setUpAll(() {
    final ecodes = File('assets/data/e_codes_v0.json').readAsStringSync();
    final ingredients = File('assets/data/ingredients_v0.json').readAsStringSync();
    engine = RuleEngine(KnowledgeBase.fromJsonStrings(ecodes, ingredients));
  });

  group('haram tespitleri', () {
    test('domuz yağı → haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Buğday unu, domuz yağı, tuz',
      );
      expect(r.verdict, Verdict.haram);
      expect(r.findings.any((f) => f.verdict == Verdict.haram), isTrue);
    });

    test('kaynağı belirsiz jelatin → haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Şeker, glikoz şurubu, jelatin, aroma verici',
      );
      expect(r.verdict, Verdict.haram);
    });

    test('E120 karmin → her üç profilde haram', () {
      for (final p in Profile.values) {
        final r = engine.analyze(profile: p, ingredientsText: 'şeker, renklendirici (e120)');
        expect(r.verdict, Verdict.haram, reason: 'profil: ${p.key}');
      }
    });

    test('OFF additives_tags üzerinden E441 → diyanet profili haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'şeker, aroma',
        additiveTags: ['en:e441'],
      );
      expect(r.verdict, Verdict.haram);
    });
  });

  group('istisnalar ve yanlış pozitif koruması', () {
    test('bitkisel jelatin haram sayılmaz', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Şeker, bitkisel jelatin, aroma',
      );
      expect(r.verdict, isNot(Verdict.haram));
    });

    test('cetyl alcohol (yağ alkolü) haram sayılmaz', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'aqua, cetyl alcohol, glyceryl stearate',
      );
      expect(r.findings.where((f) => f.verdict == Verdict.haram), isEmpty);
    });

    test('kelime sınırı: "hamsi" içindeki "ham" eşleşmez', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'hamsi, tuz, ayçiçek yağı',
      );
      expect(r.findings.where((f) => f.verdict == Verdict.haram), isEmpty);
    });
  });

  group('mushbooh ve profil farkları', () {
    test('E471 → şüpheli', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'kakao yağı, emülgatör (E471), lesitin (E322)',
      );
      expect(r.verdict, Verdict.mushbooh);
      expect(r.findings.any((f) => f.label.contains('E471')), isTrue);
      // E322 lesitin helal → tespit listesinde sorun olarak yer almamalı.
      expect(r.findings.any((f) => f.label.contains('E322')), isFalse);
    });

    test('E904 şellak: temkinli şüpheli, genişlik helal', () {
      final temkinli = engine.analyze(profile: Profile.temkinli, ingredientsText: 'şeker, parlatıcı (e904)');
      final genislik = engine.analyze(profile: Profile.genislik, ingredientsText: 'şeker, parlatıcı (e904)');
      expect(temkinli.verdict, Verdict.mushbooh);
      expect(genislik.verdict, Verdict.halal);
    });

    test('bilinmeyen E-kodu → temkinen şüpheli', () {
      // E998 gerçek bir E-numarası değildir; tabloya asla girmeyecek sahte kod.
      final r = engine.analyze(profile: Profile.diyanet, ingredientsText: 'su, E998');
      expect(r.verdict, Verdict.mushbooh);
    });

    test('E150a alt varyantı ana koda düşer (E150a tabloda var → halal)', () {
      final r = engine.analyze(profile: Profile.diyanet, ingredientsText: 'şeker, karamel (e150a)');
      expect(r.verdict, Verdict.halal);
    });
  });

  group('Fransızca etiketler', () {
    test('gélatine de porc → haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Sucre, sirop de glucose, gélatine de porc, arômes',
      );
      expect(r.verdict, Verdict.haram);
    });

    test('gélatine végétale → haram değil', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Sucre, gélatine végétale, arômes',
      );
      expect(r.verdict, isNot(Verdict.haram));
    });

    test('Nutella etiketi (lactoserum): temkinli şüpheli, diyanet notlu temiz', () {
      const nutella =
          'Sucre, huile de palme, NOISETTES 13%, cacao maigre, LAIT écrémé en poudre, LACTOSERUM en poudre, émulsifiants: lécithines [SOJA], vanilline.';
      final temkinli = engine.analyze(profile: Profile.temkinli, ingredientsText: nutella.toLowerCase());
      final diyanet = engine.analyze(profile: Profile.diyanet, ingredientsText: nutella.toLowerCase());
      expect(temkinli.verdict, Verdict.mushbooh);
      expect(diyanet.verdict, Verdict.halal);
      expect(diyanet.findings.any((f) => f.isNote), isTrue);
    });

    test('présure animale → şüpheli; présure microbienne → temiz', () {
      final animal = engine.analyze(profile: Profile.diyanet, ingredientsText: 'lait, présure animale, sel');
      final microbial = engine.analyze(profile: Profile.diyanet, ingredientsText: 'lait, présure microbienne, sel');
      expect(animal.verdict, Verdict.mushbooh);
      expect(microbial.verdict, Verdict.halal);
    });
  });

  group('Arapça ve Endonezyaca etiketler', () {
    test('Endonezyaca: gelatin babi (domuz jelatini) → haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'gula, sirup glukosa, gelatin babi, perisa',
      );
      expect(r.verdict, Verdict.haram);
    });

    test('Endonezyaca: gelatin sapi (sığır) istisnası → haram değil', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'gula, gelatin sapi, perisa',
      );
      expect(r.verdict, isNot(Verdict.haram));
    });

    test('Arapça: جيلاتين (jelatin) → haram; lecithin temiz', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'سكر، جيلاتين، ليسيثين الصويا',
      );
      expect(r.verdict, Verdict.haram);
    });

    test('Arapça: خنزير (domuz) → haram', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'دهن الخنزير، ملح',
      );
      expect(r.verdict, Verdict.haram);
    });
  });

  group('E-kod isim (alias) eşleşmeleri', () {
    test('polysorbate 80 (kod yazılmadan) → şüpheli, E433 tespiti', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'eau, arôme, émulsifiant: polysorbate 80',
      );
      expect(r.verdict, Verdict.mushbooh);
      expect(r.findings.any((f) => f.label.contains('E433')), isTrue);
    });

    test('stéarate de magnésium → şüpheli (E572)', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'édulcorant, arôme, stéarate de magnésium',
      );
      expect(r.verdict, Verdict.mushbooh);
    });

    test('glycérine → şüpheli; glycérine végétale → temiz', () {
      final plain = engine.analyze(profile: Profile.diyanet, ingredientsText: 'eau, glycérine, arôme');
      final veg = engine.analyze(profile: Profile.diyanet, ingredientsText: 'eau, glycérine végétale, arôme');
      expect(plain.verdict, Verdict.mushbooh);
      expect(veg.verdict, Verdict.halal);
    });

    test('Almanca: Magnesiumstearat → şüpheli', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'süßungsmittel, magnesiumstearat, aroma',
      );
      expect(r.verdict, Verdict.mushbooh);
    });

    test('gomme-laque: temkinli şüpheli, genişlik helal (E904 ile aynı)', () {
      final temkinli = engine.analyze(profile: Profile.temkinli, ingredientsText: 'sucre, agent d\'enrobage: gomme-laque');
      final genislik = engine.analyze(profile: Profile.genislik, ingredientsText: 'sucre, agent d\'enrobage: gomme-laque');
      expect(temkinli.verdict, Verdict.mushbooh);
      expect(genislik.verdict, Verdict.halal);
    });

    test('disodium inosinate + guanylate (EN etiket) → şüpheli', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'salt, flavour enhancers: disodium inosinate, disodium guanylate',
      );
      expect(r.verdict, Verdict.mushbooh);
      expect(r.findings.any((f) => f.label.contains('E631')), isTrue);
      expect(r.findings.any((f) => f.label.contains('E627')), isTrue);
    });

    test('alias hem kod hem isim geçince tek tespit (E433 + polysorbate 80)', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'émulsifiant: polysorbate 80 (e433)',
      );
      expect(r.findings.where((f) => f.label.contains('E433')).length, 1);
    });

    test('karoten yalnız temkinli profilde şüpheli (alias üzerinden)', () {
      final temkinli = engine.analyze(profile: Profile.temkinli, ingredientsText: 'su, beta-carotene, aroma');
      final diyanet = engine.analyze(profile: Profile.diyanet, ingredientsText: 'su, beta-carotene, aroma');
      expect(temkinli.verdict, Verdict.mushbooh);
      expect(diyanet.verdict, Verdict.halal);
    });
  });

  group('temiz ürünler ve veri yetersizliği', () {
    test('basit temiz içerik → halal', () {
      final r = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'Buğday unu, su, tuz, maya',
      );
      expect(r.verdict, Verdict.halal);
    });

    test('vegan sinyali güveni yükseltir', () {
      final clean = engine.analyze(profile: Profile.diyanet, ingredientsText: 'nohut, su, tuz');
      final vegan = engine.analyze(
        profile: Profile.diyanet,
        ingredientsText: 'nohut, su, tuz',
        veganStatus: 'yes',
      );
      expect(vegan.confidence, greaterThan(clean.confidence));
    });

    test('içerik verisi yoksa asla yeşil yakma → unknown', () {
      final r = engine.analyze(profile: Profile.diyanet, ingredientsText: null);
      expect(r.verdict, Verdict.unknown);
      expect(r.confidence, 0);
    });
  });
}
