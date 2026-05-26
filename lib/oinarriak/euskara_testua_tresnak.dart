/// Utilidades de texto en euskera para la generación heurística de
/// ejercicios desde un texto del profesor.
///
/// Nada de esto es un NLP "de verdad" — son heurísticas pragmáticas que
/// cubren bien A1-B1 en frases simples. Si más adelante se necesita
/// análisis morfológico real, el camino es integrar Eustagger o un
/// modelo on-device, pero hoy con esto basta.
library;

/// Palabras vacías (stopwords) más comunes del euskera: pronombres,
/// auxiliares, demostrativos, conjunciones, partículas frecuentes…
/// Las quitamos a la hora de elegir candidatas a hueco en Hutsuneak —
/// hacer un hueco con "eta" o "da" no enseña nada.
const Set<String> stopwordsEuskara = <String>{
  // Pronombres y demostrativos
  'ni', 'hi', 'hura', 'gu', 'zu', 'zuek', 'haiek', 'bera', 'beraiek',
  'hau', 'hori', 'honek', 'horrek', 'hark',
  'honi', 'horri', 'hari', 'hauei', 'horiei', 'haiei',
  // Auxiliares y verbos sintéticos cortos
  'da', 'naiz', 'gara', 'zara', 'zarete', 'dira',
  'dut', 'duzu', 'du', 'dugu', 'duzue', 'dute',
  'dit', 'dizu', 'dio', 'digu', 'dizue', 'die',
  'diot', 'diozu', 'diogu', 'diozue', 'diote',
  'zait', 'zaizu', 'zaio', 'zaigu', 'zaizue', 'zaie',
  'nago', 'zaude', 'dago', 'gaude', 'zaudete', 'daude',
  'izan', 'egon', 'eduki', 'ari',
  // Conjunciones y partículas
  'eta', 'edo', 'baina', 'ere', 'baizik', 'beraz',
  'ezen', 'zeren', 'eze', 'noiz', 'nola', 'non', 'nork', 'zer',
  'bai', 'ez', 'oso', 'asko', 'gehiago', 'gutxi', 'gutxiago',
  'gainera', 'ondoren', 'gero', 'lehen', 'orain',
  'hemen', 'hor', 'han',
  // Artículos y conectores cortos
  'bat', 'batzuk', 'edozein', 'guztia', 'guztiak', 'denak',
  'arte', 'kontra',
};

/// Tokeniza un texto en palabras conservando capitalización. Quita
/// signos de puntuación pegados a los extremos pero conserva apóstrofes
/// internos (no son habituales en euskera, pero por si acaso).
List<String> tokenizar(String texto) {
  // Reemplazamos saltos por espacios y separamos por whitespace.
  final String normalizado = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalizado.isEmpty) return const <String>[];
  final List<String> bruto = normalizado.split(' ');
  return bruto
      .map(_limpiarTokenDePuntuacion)
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);
}

/// Divide el texto en oraciones por puntos, signos de admiración y de
/// interrogación. Una versión perezosa pero suficiente.
List<String> dividirEnOraciones(String texto) {
  final RegExp finalOracion = RegExp(r'[.!?]+');
  return texto
      .split(finalOracion)
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList(growable: false);
}

/// Devuelve true si `palabra` es "candidata" a hueco: longitud >= 4
/// (filtra partículas), no en stopwords, sin dígitos.
bool esCandidataAHueco(String palabra) {
  if (palabra.length < 4) return false;
  final String minuscula = palabra.toLowerCase();
  if (stopwordsEuskara.contains(minuscula)) return false;
  if (RegExp(r'[0-9]').hasMatch(palabra)) return false;
  return true;
}

/// Quita signos de puntuación al principio y al final de un token.
/// Conserva caracteres internos como guiones.
String _limpiarTokenDePuntuacion(String token) {
  const String signosBorde = '.,;:!?()[]{}«»"\'`…¿¡';
  int inicio = 0;
  int fin = token.length;
  while (inicio < fin && signosBorde.contains(token[inicio])) {
    inicio += 1;
  }
  while (fin > inicio && signosBorde.contains(token[fin - 1])) {
    fin -= 1;
  }
  return token.substring(inicio, fin);
}
