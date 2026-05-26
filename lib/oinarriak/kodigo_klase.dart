import 'dart:convert';

/// Representación decodificada de un código de clase.
///
/// El código es autocontenido: lleva el nombre de la clase y los
/// identificadores de los ejercicios que el irakasle ha decidido
/// asignar. No necesita servidor — toda la información viaja dentro
/// del propio código.
class KodigoKlase {
  final String izenaKlasea;
  final List<String> identificadoresAriketak;

  const KodigoKlase({
    required this.izenaKlasea,
    required this.identificadoresAriketak,
  });
}

/// Prefijo legible para que el alumno reconozca el código como uno de
/// AEK app y no se equivoque con códigos de otras herramientas.
const String _prefijoCodigo = 'AEK-';

/// Codifica los datos en una cadena legible por humanos:
/// `AEK-<base64_url_safe>`. La parte base64 lleva un JSON pequeño con
/// el nombre y los identificadores.
String generarKodigoKlase({
  required String izenaKlasea,
  required List<String> identificadoresAriketak,
}) {
  final Map<String, dynamic> contenido = <String, dynamic>{
    'i': izenaKlasea,
    'a': identificadoresAriketak,
  };
  final String jsonContenido = jsonEncode(contenido);
  final String codificado = base64UrlEncode(utf8.encode(jsonContenido));
  return '$_prefijoCodigo$codificado';
}

/// Intenta decodificar un código de clase. Devuelve null si el código no
/// tiene formato válido o si el contenido no es interpretable.
KodigoKlase? parsearKodigoKlase(String codigo) {
  final String codigoLimpio = codigo.trim();
  if (!codigoLimpio.startsWith(_prefijoCodigo)) {
    return null;
  }
  final String parteCodificada =
      codigoLimpio.substring(_prefijoCodigo.length);
  try {
    final List<int> bytesDecodificados = base64Url.decode(parteCodificada);
    final String jsonDecodificado = utf8.decode(bytesDecodificados);
    final Map<String, dynamic> contenido =
        jsonDecode(jsonDecodificado) as Map<String, dynamic>;
    final String? nombre = contenido['i'] as String?;
    final List<dynamic>? listaArbitraria = contenido['a'] as List<dynamic>?;
    if (nombre == null || listaArbitraria == null) {
      return null;
    }
    final List<String> identificadores = listaArbitraria
        .whereType<String>()
        .toList(growable: false);
    if (identificadores.isEmpty) {
      return null;
    }
    return KodigoKlase(
      izenaKlasea: nombre,
      identificadoresAriketak: identificadores,
    );
  } catch (_) {
    return null;
  }
}
