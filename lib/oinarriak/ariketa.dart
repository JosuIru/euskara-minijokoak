import 'package:flutter/material.dart';

/// Nivel del Marco Común Europeo de Referencia (MCER) aplicado al currículo
/// HABE de aprendizaje del euskera para adultos.
enum NivelEuskera {
  a1('A1', 'Hasiberria'),
  a2('A2', 'Hasiberria sakontzailea'),
  b1('B1', 'Tarteko maila'),
  b2('B2', 'Aurreratua'),
  c1('C1', 'Goi-maila'),
  c2('C2', 'Goren maila');

  final String etiqueta;
  final String descripcionEuskera;

  const NivelEuskera(this.etiqueta, this.descripcionEuskera);
}

/// Categoría temática alta de un ejercicio. Sirve al profesor para filtrar
/// por área de trabajo y al alumno para entender qué está practicando.
enum CategoriaAriketa {
  deklinabidea('Deklinabidea', 'Casos y declinación'),
  aditzak('Aditzak', 'Verbos y conjugación'),
  esaldiEraikuntza('Esaldi eraikuntza', 'Construcción de frases'),
  lexikoa('Lexikoa', 'Vocabulario'),
  entzumena('Entzumena', 'Comprensión oral'),
  irakurmena('Irakurmena', 'Comprensión escrita'),
  kantua('Kantua', 'Canción');

  final String etiquetaEuskera;
  final String descripcionEspanol;

  const CategoriaAriketa(this.etiquetaEuskera, this.descripcionEspanol);
}

/// Resultado de una ejecución de un ejercicio por parte del alumno.
class ResultadoAriketa {
  final String identificadorAriketa;
  final DateTime momentoFin;
  final int aciertos;
  final int intentosTotales;
  final Duration tiempoEmpleado;

  const ResultadoAriketa({
    required this.identificadorAriketa,
    required this.momentoFin,
    required this.aciertos,
    required this.intentosTotales,
    required this.tiempoEmpleado,
  });

  double get porcentajeAciertos =>
      intentosTotales == 0 ? 0 : aciertos / intentosTotales;
}

/// Contrato común que todo minijuego, ejercicio de canción o actividad
/// gramatical debe cumplir. Permite que el panel del profesor liste,
/// agrupe y asigne ejercicios sin conocer el detalle de cada uno.
abstract class Ariketa {
  /// Identificador estable (no localizado) para persistencia y URLs.
  String get identificador;

  /// Título mostrado al alumno, en euskera.
  String get izenburua;

  /// Descripción corta para el catálogo del profesor.
  String get azalpenLaburra;

  /// Categoría a la que pertenece.
  CategoriaAriketa get kategoria;

  /// Niveles del MCER recomendados para este ejercicio.
  List<NivelEuskera> get gomendatuMailak;

  /// Construye la pantalla del ejercicio. Recibe un callback que el
  /// ejercicio debe llamar cuando termina, pasando el resultado.
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  });
}
