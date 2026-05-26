/// Representación de una canción del catálogo. Cada canción es una
/// lista de versos; cada verso es una lista de fragmentos. Un fragmento
/// es o bien texto fijo o bien un hueco que el alumno debe rellenar con
/// una palabra concreta. Esto permite que un mismo verso pueda mezclar
/// texto + huecos sin tener que partir manualmente.
class FragmentoVerso {
  final String? textoFijo;
  final String? palabraEsperada;

  const FragmentoVerso.texto(String texto)
      : textoFijo = texto,
        palabraEsperada = null;

  const FragmentoVerso.hueco(String palabra)
      : textoFijo = null,
        palabraEsperada = palabra;

  bool get esHueco => palabraEsperada != null;
}

class Kantua {
  final String identificador;
  final String izenburua;
  final String egileaEdoIturria;
  final String azalpenLaburra;
  final String? urlYoutube;
  final List<List<FragmentoVerso>> versoak;

  /// Palabras adicionales que aparecerán en el banco junto a las
  /// correctas para que el ejercicio tenga distractores. Si está vacío,
  /// el banco se forma sólo con las palabras correctas.
  final List<String> distraktoreak;

  const Kantua({
    required this.identificador,
    required this.izenburua,
    required this.egileaEdoIturria,
    required this.azalpenLaburra,
    required this.versoak,
    this.urlYoutube,
    this.distraktoreak = const <String>[],
  });

  /// Todas las palabras esperadas en los huecos, en orden de aparición.
  List<String> get palabrasEsperadasOrdenadas {
    final List<String> palabras = <String>[];
    for (final List<FragmentoVerso> verso in versoak) {
      for (final FragmentoVerso fragmento in verso) {
        if (fragmento.esHueco) {
          palabras.add(fragmento.palabraEsperada!);
        }
      }
    }
    return palabras;
  }

  /// Número total de huecos.
  int get cantidadDeHuecos => palabrasEsperadasOrdenadas.length;
}
