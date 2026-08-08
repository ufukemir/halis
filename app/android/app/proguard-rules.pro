# ML Kit Text Recognition: yalnız Latin tanıyıcı paketliyoruz; eklenti diğer
# dillerin sınıflarına da referans verdiği için R8'e "yoklar, sorun değil" de.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
