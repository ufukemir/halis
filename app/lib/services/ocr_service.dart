import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Cihaz üstü OCR (ML Kit — ücretsiz, offline). Etiket fotoğrafından ham
/// metin çıkarır; hüküm ve normalizasyon başka katmanlardadır.
class OcrService {
  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}
