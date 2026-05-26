import 'dart:math' as math;

import 'euskara_testua_tresnak.dart';

/// Una palabra del texto marcada para convertirse en hueco. Lleva la
/// palabra original (que el alumno tendrá que recordar/elegir) y su
/// posición lineal en el texto, para poder reconstruir.
class HuecoGenerado {
  final String palabraOriginal;
  final int posicionToken;

  const HuecoGenerado({
    required this.palabraOriginal,
    required this.posicionToken,
  });
}

/// Datos para una partida Hutsuneak generada heurísticamente desde un
/// texto. La pantalla del minijuego lo recibirá tal cual.
class HutsuneakGeneratuta {
  /// Tokens originales del texto en orden.
  final List<String> tokensOrden;

  /// Posiciones (índices en `tokensOrden`) que serán huecos.
  final List<int> posicionesHueco;

  /// Banco de palabras candidatas presentadas al alumno: las
  /// correctas + algunas distractoras del propio texto.
  final List<String> bancoPalabras;

  const HutsuneakGeneratuta({
    required this.tokensOrden,
    required this.posicionesHueco,
    required this.bancoPalabras,
  });
}

/// Datos para una partida Esaldi-Eraikitzailea generada desde un texto.
/// Cada elemento es una oración del texto que el alumno deberá
/// reconstruir desordenada.
class EsaldiEraikitzaileaGeneratuta {
  final List<List<String>> oraciones;

  const EsaldiEraikitzaileaGeneratuta({required this.oraciones});
}

/// Datos para una partida Hitz-Zaparrada con las palabras clave del
/// texto. El tablero se generará después con el motor existente.
class HitzZaparradaGeneratuta {
  final List<String> palabrasClave;

  const HitzZaparradaGeneratuta({required this.palabrasClave});
}

/// Una pareja euskera–castellano para el memory Lotura. La generación
/// heurística no la rellena (no hay diccionario embebido); sólo la
/// produce el motor LLM, que sí puede traducir.
class ParejaGenerada {
  final String euskera;
  final String espanol;

  const ParejaGenerada({required this.euskera, required this.espanol});
}

class LoturaGeneratuta {
  final List<ParejaGenerada> parejas;

  const LoturaGeneratuta({required this.parejas});
}

/// Una frase para dictar al alumno. Heurístico la produce sin
/// traducción; el LLM puede añadirla para que el panel de corrección
/// muestre el sentido al alumno tras escribir.
class FraseDictadoGenerada {
  final String euskera;
  final String? traduccionEspanol;

  const FraseDictadoGenerada({
    required this.euskera,
    this.traduccionEspanol,
  });
}

class DiktatuaGeneratuta {
  final List<FraseDictadoGenerada> frases;

  const DiktatuaGeneratuta({required this.frases});
}

/// Conjunto de tipos de ejercicios generados a partir de un mismo
/// texto. Una sola llamada al generador devuelve todo lo que se puede
/// sacar; la UI decide qué guardar.
class ResultadoGeneracion {
  final HutsuneakGeneratuta? hutsuneak;
  final EsaldiEraikitzaileaGeneratuta? esaldiEraikitzailea;
  final HitzZaparradaGeneratuta? hitzZaparrada;
  final LoturaGeneratuta? lotura;
  final DiktatuaGeneratuta? diktatua;

  const ResultadoGeneracion({
    this.hutsuneak,
    this.esaldiEraikitzailea,
    this.hitzZaparrada,
    this.lotura,
    this.diktatua,
  });
}

/// Genera todo lo que puede a partir de `texto`. Si el texto es muy
/// corto algunos tipos quedan `null` (no había suficiente material).
///
/// Parámetros con valores por defecto razonables. `semilla` permite
/// reproducir un resultado concreto durante tests o vista previa.
ResultadoGeneracion generarTodoHeuristico(
  String texto, {
  int cantidadHuecos = 6,
  int oracionesMaxEsaldi = 6,
  int palabrasParaSopa = 6,
  int oracionesMaxDiktatua = 6,
  int? semilla,
}) {
  final math.Random rng = math.Random(semilla);
  final HutsuneakGeneratuta? hutsuneak = _generarHutsuneak(
    texto,
    cantidadHuecos: cantidadHuecos,
    rng: rng,
  );
  final EsaldiEraikitzaileaGeneratuta? esaldi = _generarEsaldiEraikitzailea(
    texto,
    oracionesMax: oracionesMaxEsaldi,
  );
  final HitzZaparradaGeneratuta? sopa = _generarHitzZaparrada(
    texto,
    cantidadPalabras: palabrasParaSopa,
  );
  final DiktatuaGeneratuta? diktatua = _generarDiktatua(
    texto,
    oracionesMax: oracionesMaxDiktatua,
  );
  return ResultadoGeneracion(
    hutsuneak: hutsuneak,
    esaldiEraikitzailea: esaldi,
    hitzZaparrada: sopa,
    diktatua: diktatua,
  );
}

HutsuneakGeneratuta? _generarHutsuneak(
  String texto, {
  required int cantidadHuecos,
  required math.Random rng,
}) {
  final List<String> tokens = tokenizar(texto);
  if (tokens.length < 6) return null;

  // Índices candidatos: posiciones cuyo token es palabra "interesante".
  final List<int> indicesCandidatos = <int>[];
  for (int indice = 0; indice < tokens.length; indice++) {
    if (esCandidataAHueco(tokens[indice])) {
      indicesCandidatos.add(indice);
    }
  }
  if (indicesCandidatos.isEmpty) return null;

  // Espaciamos los huecos: tomamos uno de cada bloque de tamaño
  // `tokens.length / cantidadHuecos` para evitar concentrarlos al
  // principio. Si no hay suficientes candidatos, tomamos lo que haya.
  final int cantidadObjetivo =
      math.min(cantidadHuecos, indicesCandidatos.length);
  final List<int> elegidos = <int>[];
  if (cantidadObjetivo == indicesCandidatos.length) {
    elegidos.addAll(indicesCandidatos);
  } else {
    final int paso =
        (indicesCandidatos.length / cantidadObjetivo).floor().clamp(1, 9999);
    int cursor = rng.nextInt(paso);
    while (elegidos.length < cantidadObjetivo &&
        cursor < indicesCandidatos.length) {
      elegidos.add(indicesCandidatos[cursor]);
      cursor += paso;
    }
    // Si por redondeo no llenamos, completar con aleatorios libres.
    final List<int> sobrantes = indicesCandidatos
        .where((int i) => !elegidos.contains(i))
        .toList()
      ..shuffle(rng);
    while (elegidos.length < cantidadObjetivo && sobrantes.isNotEmpty) {
      elegidos.add(sobrantes.removeLast());
    }
  }
  elegidos.sort();

  // Distractoras = otras candidatas no usadas, hasta llegar a 4 extras.
  final List<String> palabrasCorrectas =
      elegidos.map((int i) => tokens[i]).toList();
  final List<String> distractorasPosibles = indicesCandidatos
      .where((int i) => !elegidos.contains(i))
      .map((int i) => tokens[i])
      .toSet()
      .toList()
    ..shuffle(rng);
  final List<String> distractoras =
      distractorasPosibles.take(4).toList(growable: false);

  final List<String> banco = <String>[...palabrasCorrectas, ...distractoras]
    ..shuffle(rng);

  return HutsuneakGeneratuta(
    tokensOrden: tokens,
    posicionesHueco: elegidos,
    bancoPalabras: banco,
  );
}

EsaldiEraikitzaileaGeneratuta? _generarEsaldiEraikitzailea(
  String texto, {
  required int oracionesMax,
}) {
  final List<String> oraciones = dividirEnOraciones(texto);
  if (oraciones.isEmpty) return null;
  // Sólo oraciones que tengan entre 3 y 8 palabras — las muy largas se
  // vuelven imposibles de reconstruir y las muy cortas son triviales.
  final List<List<String>> filtradas = <List<String>>[];
  for (final String oracion in oraciones) {
    final List<String> palabras = tokenizar(oracion);
    if (palabras.length >= 3 && palabras.length <= 8) {
      filtradas.add(palabras);
      if (filtradas.length >= oracionesMax) break;
    }
  }
  if (filtradas.isEmpty) return null;
  return EsaldiEraikitzaileaGeneratuta(oraciones: filtradas);
}

DiktatuaGeneratuta? _generarDiktatua(
  String texto, {
  required int oracionesMax,
}) {
  // El dictado funciona mejor con frases ni triviales ni interminables:
  // 4-12 palabras dan margen para errores ortográficos sin volverse
  // memorización.
  final List<String> oraciones = dividirEnOraciones(texto);
  if (oraciones.isEmpty) return null;
  final List<FraseDictadoGenerada> frases = <FraseDictadoGenerada>[];
  for (final String oracion in oraciones) {
    final int numPalabras = tokenizar(oracion).length;
    if (numPalabras < 4 || numPalabras > 12) continue;
    frases.add(FraseDictadoGenerada(euskera: oracion));
    if (frases.length >= oracionesMax) break;
  }
  if (frases.isEmpty) return null;
  return DiktatuaGeneratuta(frases: frases);
}

HitzZaparradaGeneratuta? _generarHitzZaparrada(
  String texto, {
  required int cantidadPalabras,
}) {
  final List<String> tokens = tokenizar(texto);
  // Frecuencia por palabra (en minúsculas, sin diacríticos especiales).
  final Map<String, int> frecuencia = <String, int>{};
  for (final String token in tokens) {
    if (!esCandidataAHueco(token)) continue;
    final String clave = token.toLowerCase();
    // Filtrar palabras con más de 10 letras (no caben en sopa 10×10).
    if (clave.length > 10) continue;
    frecuencia[clave] = (frecuencia[clave] ?? 0) + 1;
  }
  if (frecuencia.isEmpty) return null;
  // Ordenar primero por frecuencia descendente, después por longitud
  // descendente (palabras más largas son más "didácticas").
  final List<MapEntry<String, int>> ordenadas = frecuencia.entries.toList()
    ..sort((a, b) {
      final int cmpFrec = b.value.compareTo(a.value);
      if (cmpFrec != 0) return cmpFrec;
      return b.key.length.compareTo(a.key.length);
    });
  final List<String> seleccion = ordenadas
      .take(cantidadPalabras)
      .map((MapEntry<String, int> entrada) => entrada.key)
      .toList(growable: false);
  if (seleccion.length < 3) return null;
  return HitzZaparradaGeneratuta(palabrasClave: seleccion);
}
