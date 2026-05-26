import 'dart:typed_data';

/// Resultado del reconocimiento OCR de una imagen.
class ResultadoOcr {
  final String textoReconocido;

  /// Confianza 0-100. Si la implementación nativa no expone confianza
  /// (Google ML Kit no lo da explícitamente), devolvemos 0 — la UI
  /// debe tolerar ese caso sin mostrar advertencia.
  final double confianza;

  const ResultadoOcr({
    required this.textoReconocido,
    required this.confianza,
  });
}

/// Idiomas conocidos por el sistema. Los códigos siguen ISO-639-3
/// (eus/spa/eng) para que sirva tanto a Tesseract como a ML Kit.
const String idiomaOcrPorDefecto = 'eus';

/// Servicio común de reconocimiento OCR. Implementado por
/// `ocr_web.dart` (Tesseract.js) cuando se compila para web y por
/// `ocr_mobile.dart` (Google ML Kit) cuando se compila para móvil.
abstract class ServicioOcr {
  Future<ResultadoOcr> reconocer(
    Uint8List bytesImagen, {
    String idioma = idiomaOcrPorDefecto,
  });
}
