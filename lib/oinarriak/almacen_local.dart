import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ariketa.dart';

/// Servicio de almacenamiento local: persiste resultados de ejercicios y
/// preferencias del alumno entre sesiones.
///
/// En Flutter web, SharedPreferences usa `localStorage` por debajo — no
/// requiere servidor. Los datos persisten en el navegador del alumno y
/// no salen de su dispositivo.
class AlmacenLocal {
  AlmacenLocal._();

  static final AlmacenLocal _instancia = AlmacenLocal._();
  static AlmacenLocal get instancia => _instancia;

  static const String _claveHistorialResultados =
      'aek_app.historial_resultados';
  static const String _claveNombreAlumno = 'aek_app.nombre_alumno';
  static const String _claveCodigoClase = 'aek_app.codigo_clase';
  static const String _claveMailaAukeratutakoa =
      'aek_app.aukeratutako_maila';

  /// Lee el historial completo de resultados. Si está vacío o corrupto,
  /// devuelve lista vacía silenciosamente — no queremos romper la UI por
  /// un fallo de persistencia.
  Future<List<ResultadoAriketa>> cargarHistorial({
    String? filtrarPorIdentificadorAriketa,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cadenaJsonHistorial =
        prefs.getString(_claveHistorialResultados);
    if (cadenaJsonHistorial == null || cadenaJsonHistorial.isEmpty) {
      return <ResultadoAriketa>[];
    }
    try {
      final List<dynamic> arregloDecodificado = jsonDecode(cadenaJsonHistorial);
      final List<ResultadoAriketa> resultados = arregloDecodificado
          .map((dynamic entrada) => _deserializarResultado(
              (entrada as Map<String, dynamic>)))
          .toList();
      if (filtrarPorIdentificadorAriketa == null) {
        return resultados;
      }
      return resultados
          .where((ResultadoAriketa resultado) =>
              resultado.identificadorAriketa ==
              filtrarPorIdentificadorAriketa)
          .toList();
    } catch (_) {
      return <ResultadoAriketa>[];
    }
  }

  /// Añade [resultado] al historial. No deduplicamos: cada partida es
  /// una entrada propia para que el alumno pueda ver su progresión.
  Future<void> guardarResultado(ResultadoAriketa resultado) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ResultadoAriketa> historialActual = await cargarHistorial();
    historialActual.add(resultado);
    final List<Map<String, dynamic>> arregloSerializable = historialActual
        .map((ResultadoAriketa resultado) => _serializarResultado(resultado))
        .toList();
    await prefs.setString(
        _claveHistorialResultados, jsonEncode(arregloSerializable));
  }

  /// Borra todo el historial. Pensado para el botón "Garbitu" del panel
  /// del alumno.
  Future<void> borrarHistorial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveHistorialResultados);
  }

  Future<String?> cargarNombreAlumno() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveNombreAlumno);
  }

  Future<void> guardarNombreAlumno(String nombre) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveNombreAlumno, nombre);
  }

  Future<String?> cargarCodigoClase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveCodigoClase);
  }

  Future<void> guardarCodigoClase(String codigo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveCodigoClase, codigo);
  }

  Future<void> borrarCodigoClase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveCodigoClase);
  }

  /// Lee el nivel MCER que el alumno eligió la última vez. Si nunca ha
  /// elegido o el valor es inválido (versión antigua), devuelve null —
  /// el caller mostrará el selector de nivel.
  Future<NivelEuskera?> cargarMailaAukeratutakoa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? guardado = prefs.getString(_claveMailaAukeratutakoa);
    if (guardado == null || guardado.isEmpty) return null;
    for (final NivelEuskera nivel in NivelEuskera.values) {
      if (nivel.name == guardado) return nivel;
    }
    return null;
  }

  Future<void> guardarMailaAukeratutakoa(NivelEuskera nivel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveMailaAukeratutakoa, nivel.name);
  }

  Future<void> borrarMailaAukeratutakoa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveMailaAukeratutakoa);
  }

  Map<String, dynamic> _serializarResultado(ResultadoAriketa resultado) {
    return <String, dynamic>{
      'identificadorAriketa': resultado.identificadorAriketa,
      'momentoFinIso': resultado.momentoFin.toIso8601String(),
      'aciertos': resultado.aciertos,
      'intentosTotales': resultado.intentosTotales,
      'tiempoEmpleadoSegundos': resultado.tiempoEmpleado.inSeconds,
    };
  }

  ResultadoAriketa _deserializarResultado(Map<String, dynamic> entrada) {
    return ResultadoAriketa(
      identificadorAriketa: entrada['identificadorAriketa'] as String,
      momentoFin: DateTime.parse(entrada['momentoFinIso'] as String),
      aciertos: entrada['aciertos'] as int,
      intentosTotales: entrada['intentosTotales'] as int,
      tiempoEmpleado:
          Duration(seconds: entrada['tiempoEmpleadoSegundos'] as int),
    );
  }
}
