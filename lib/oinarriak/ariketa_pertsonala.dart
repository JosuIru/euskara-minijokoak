import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Ejercicio personalizado creado por el profesor desde una foto de
/// papel físico. Lo guardamos local en el navegador del profe, no se
/// comparte automáticamente con alumnos — sirve como cuaderno digital
/// que el irakasle proyecta en clase o referencia mientras prepara.
class AriketaPertsonala {
  /// Identificador único generado en el momento de creación.
  final String id;

  /// Título corto puesto por el profesor.
  final String izenburua;

  /// Notas/etiquetas opcionales (categoría, tema, nivel…).
  final String oharrak;

  /// Imagen original como data URL (base64, MIME prefijado). Permite
  /// volver a mostrarla sin servidor.
  final String imagenDataUrl;

  /// Texto bruto que devolvió Tesseract OCR antes de cualquier edición.
  final String textoOcrLatza;

  /// Texto definitivo tras corrección manual del profesor.
  final String testuKorregitua;

  /// Confianza OCR original (0-100). Sirve para mostrar un aviso si
  /// fue baja y conviene revisar.
  final double konfiantzaOcr;

  /// Cuándo se creó el ejercicio (ISO).
  final DateTime sortzeData;

  const AriketaPertsonala({
    required this.id,
    required this.izenburua,
    required this.oharrak,
    required this.imagenDataUrl,
    required this.textoOcrLatza,
    required this.testuKorregitua,
    required this.konfiantzaOcr,
    required this.sortzeData,
  });

  AriketaPertsonala copiaCon({
    String? izenburua,
    String? oharrak,
    String? testuKorregitua,
  }) {
    return AriketaPertsonala(
      id: id,
      izenburua: izenburua ?? this.izenburua,
      oharrak: oharrak ?? this.oharrak,
      imagenDataUrl: imagenDataUrl,
      textoOcrLatza: textoOcrLatza,
      testuKorregitua: testuKorregitua ?? this.testuKorregitua,
      konfiantzaOcr: konfiantzaOcr,
      sortzeData: sortzeData,
    );
  }

  Map<String, dynamic> aMapa() => <String, dynamic>{
        'id': id,
        'izenburua': izenburua,
        'oharrak': oharrak,
        'imagenDataUrl': imagenDataUrl,
        'textoOcrLatza': textoOcrLatza,
        'testuKorregitua': testuKorregitua,
        'konfiantzaOcr': konfiantzaOcr,
        'sortzeDataIso': sortzeData.toIso8601String(),
      };

  static AriketaPertsonala desdeMapa(Map<String, dynamic> mapa) {
    return AriketaPertsonala(
      id: mapa['id'] as String,
      izenburua: mapa['izenburua'] as String,
      oharrak: (mapa['oharrak'] as String?) ?? '',
      imagenDataUrl: mapa['imagenDataUrl'] as String,
      textoOcrLatza: mapa['textoOcrLatza'] as String,
      testuKorregitua: mapa['testuKorregitua'] as String,
      konfiantzaOcr: (mapa['konfiantzaOcr'] as num).toDouble(),
      sortzeData: DateTime.parse(mapa['sortzeDataIso'] as String),
    );
  }
}

/// Servicio CRUD de ejercicios personalizados. Usa shared_preferences
/// (= localStorage en web). Las imágenes en base64 pueden hacer que el
/// JSON crezca rápido; con localStorage real el límite suele ser ~5MB.
/// Para el MVP es suficiente — más adelante migrar a IndexedDB.
class AlmacenAriketaPertsonala {
  AlmacenAriketaPertsonala._();

  static final AlmacenAriketaPertsonala instancia = AlmacenAriketaPertsonala._();

  static const String _claveListaIds = 'aek_app.ariketa_pertsonala.lista';
  static const String _prefijoEntrada = 'aek_app.ariketa_pertsonala.entrada.';

  Future<List<AriketaPertsonala>> cargarTodas() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    final List<AriketaPertsonala> resultado = <AriketaPertsonala>[];
    for (final String id in ids) {
      final String? json = prefs.getString('$_prefijoEntrada$id');
      if (json == null) continue;
      try {
        resultado.add(
            AriketaPertsonala.desdeMapa(jsonDecode(json) as Map<String, dynamic>));
      } catch (_) {
        // Entrada corrupta — la saltamos sin romper la UI.
      }
    }
    // Más recientes primero.
    resultado.sort((a, b) => b.sortzeData.compareTo(a.sortzeData));
    return resultado;
  }

  Future<void> gordeBerria(AriketaPertsonala ariketa) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    if (!ids.contains(ariketa.id)) {
      await prefs.setStringList(_claveListaIds, <String>[...ids, ariketa.id]);
    }
    await prefs.setString(
      '$_prefijoEntrada${ariketa.id}',
      jsonEncode(ariketa.aMapa()),
    );
  }

  Future<void> eguneratu(AriketaPertsonala ariketa) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefijoEntrada${ariketa.id}',
      jsonEncode(ariketa.aMapa()),
    );
  }

  Future<void> ezabatu(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    final List<String> nuevaLista =
        ids.where((String idEntrada) => idEntrada != id).toList();
    await prefs.setStringList(_claveListaIds, nuevaLista);
    await prefs.remove('$_prefijoEntrada$id');
  }
}

/// Genera un identificador opaco basado en el momento + contador
/// aleatorio. No necesitamos UUID v4 para esto, solo unicidad práctica.
String generarIdAriketaPertsonala() {
  final int ahora = DateTime.now().millisecondsSinceEpoch;
  final int aleatorio = DateTime.now().microsecondsSinceEpoch & 0xFFFF;
  return 'ap-${ahora.toRadixString(36)}-${aleatorio.toRadixString(36)}';
}
