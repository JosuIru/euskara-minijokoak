# Reglas ProGuard/R8 para el build de release.

# Google ML Kit Text Recognition: el plugin Flutter declara hooks para
# scripts (japonés, coreano, chino, devanagari) que no incluimos como
# dependencias separadas — sólo necesitamos latín. Decimos a R8 que no
# se queje por las clases que faltan.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Mantener las clases de ML Kit text recognition que sí usamos.
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
