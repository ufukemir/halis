/// Ek dillerin çeviri katmanı. strings.dart'taki `_t` önce dilin kendi
/// haritasına bakar; bulamazsa buradan İngilizce metinle arar; o da yoksa
/// İngilizce gösterir — hiçbir dilde boş/kırık metin çıkmaz.
library;

import 'overlay_asia.dart';
import 'overlay_east.dart';
import 'overlay_west.dart';

const Map<String, Map<String, String>> kOverlayTranslations = {
  'es': esOverlay,
  'it': itOverlay,
  'nl': nlOverlay,
  'pl': plOverlay,
  'ru': ruOverlay,
  'sq': sqOverlay,
  'bs': bsOverlay,
  'az': azOverlay,
  'ms': msOverlay,
  'ur': urOverlay,
  'bn': bnOverlay,
};
