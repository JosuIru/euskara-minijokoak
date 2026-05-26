import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import 'ocr_servicioa.dart';

/// Implementación de [ServicioOcr] con Google ML Kit on-device.
/// Funciona en Android e iOS. El reconocedor cubre el alfabeto latín
/// (suficiente para euskera) — el parámetro `idioma` se ignora; ML Kit
/// detecta automáticamente.
///
/// On-device significa: sin red, sin coste por consulta, sin enviar
/// imágenes del alumno fuera de su dispositivo.
class ServicioOcrMlkit implements ServicioOcr {
  const ServicioOcrMlkit();

  @override
  Future<ResultadoOcr> reconocer(
    Uint8List bytesImagen, {
    String idioma = idiomaOcrPorDefecto,
  }) async {
    final TextRecognizer reconocedor =
        TextRecognizer(script: TextRecognitionScript.latin);
    final File ficheroTemporal = await _escribirComoFicheroTemporal(bytesImagen);
    try {
      final InputImage imagen = InputImage.fromFile(ficheroTemporal);
      final RecognizedText resultado =
          await reconocedor.processImage(imagen);
      return ResultadoOcr(
        textoReconocido: resultado.text,
        // ML Kit no expone confianza global — devolvemos 0 y la UI
        // omite el indicador en este caso.
        confianza: 0,
      );
    } finally {
      await reconocedor.close();
      if (await ficheroTemporal.exists()) {
        await ficheroTemporal.delete();
      }
    }
  }

  Future<File> _escribirComoFicheroTemporal(Uint8List bytes) async {
    final Directory directorioTemporal = await getTemporaryDirectory();
    final String rutaUnica =
        '${directorioTemporal.path}/aek_ocr_${DateTime.now().microsecondsSinceEpoch}.png';
    final File fichero = File(rutaUnica);
    await fichero.writeAsBytes(bytes, flush: true);
    return fichero;
  }
}

/// Construido vía el conditional import de `ocr_factoria.dart` cuando
/// `dart:io` está disponible (móvil/desktop).
ServicioOcr crearServicioOcrImpl() => const ServicioOcrMlkit();
