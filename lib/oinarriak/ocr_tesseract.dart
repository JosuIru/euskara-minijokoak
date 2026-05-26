import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'ocr_servicioa.dart';

@JS('Tesseract')
external _Tesseract get _tesseract;

extension type _Tesseract._(JSObject _) implements JSObject {
  external JSPromise<_TesseractResultado> recognize(
    JSAny imagen,
    String idioma,
    JSAny? opciones,
  );
}

extension type _TesseractResultado._(JSObject _) implements JSObject {
  external _TesseractDatos get data;
}

extension type _TesseractDatos._(JSObject _) implements JSObject {
  external String get text;
  external num get confidence;
}

@JS('URL.createObjectURL')
external String _crearObjectUrl(JSAny blob);

@JS('URL.revokeObjectURL')
external void _revocarObjectUrl(String url);

@JS('Blob')
external _BlobConstructor get _blobConstructor;

extension type _BlobConstructor._(JSObject _) implements JSObject {
  external JSAny call(JSArray<JSAny> partes, _BlobOpciones opciones);
}

extension type _BlobOpciones._(JSObject _) implements JSObject {
  external factory _BlobOpciones({required String type});
}

/// Implementación de [ServicioOcr] con Tesseract.js. Sólo disponible
/// cuando se compila para web — el conditional import en
/// `ocr_factoria.dart` evita que esto se cargue en builds nativas.
class ServicioOcrTesseract implements ServicioOcr {
  const ServicioOcrTesseract();

  @override
  Future<ResultadoOcr> reconocer(
    Uint8List bytesImagen, {
    String idioma = idiomaOcrPorDefecto,
  }) async {
    if (_tesseract.isUndefinedOrNull) {
      throw StateError(
        'Tesseract.js ez dago kargatuta. Egiaztatu web/index.html-eko scripta.',
      );
    }
    final JSAny blob = _construirBlobDesdeBytes(bytesImagen);
    final String urlBlob = _crearObjectUrl(blob);
    try {
      final _TesseractResultado resultado = await _tesseract
          .recognize(urlBlob.toJS, idioma, null)
          .toDart;
      return ResultadoOcr(
        textoReconocido: resultado.data.text,
        confianza: resultado.data.confidence.toDouble(),
      );
    } finally {
      _revocarObjectUrl(urlBlob);
    }
  }
}

JSAny _construirBlobDesdeBytes(Uint8List bytes) {
  final JSArray<JSAny> partes = <JSAny>[bytes.buffer.toJS as JSAny].toJS;
  return _blobConstructor.call(
    partes,
    _BlobOpciones(type: 'image/png'),
  );
}

/// Construye la implementación concreta. Cualquier llamador debería
/// llamarlo a través de `crearServicioOcr()` en `ocr_factoria.dart`,
/// que enruta a la plataforma correcta.
ServicioOcr crearServicioOcrImpl() => const ServicioOcrTesseract();
