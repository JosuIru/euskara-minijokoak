import 'dart:math' as math;

import '../../oinarriak/ariketa.dart';

/// Una rejilla de sopa de letras lista para jugar: tablero con letras,
/// lista de palabras a encontrar y, para cada palabra, las posiciones
/// concretas que ocupa (para poder pintarlas como descubiertas).
class TableroSopa {
  final List<List<String>> celdas;
  final List<String> palabras;
  final Map<String, List<Punto>> posicionesPorPalabra;

  const TableroSopa({
    required this.celdas,
    required this.palabras,
    required this.posicionesPorPalabra,
  });

  int get filas => celdas.length;
  int get columnas => celdas.first.length;
}

/// Posición discreta en el tablero (fila, columna).
class Punto {
  final int fila;
  final int columna;

  const Punto(this.fila, this.columna);

  @override
  bool operator ==(Object other) =>
      other is Punto && other.fila == fila && other.columna == columna;

  @override
  int get hashCode => Object.hash(fila, columna);
}

/// Tema disponible en la sopa de letras. Reutilizamos la idea de los
/// temas del Lotura, pero aquí necesitamos palabras cortas y sin signos
/// de declinación finales (sopa = forma absolutiva pelada).
class TemaSopa {
  final String identificador;
  final String izenburuEuskera;
  final String descripcionEspanol;
  final List<String> palabras;

  /// Nivel MCER del tema. La pantalla filtra los temas con nivel >
  /// nivelMax para no presentarle "aurrekontu" a un alumno A1.
  final NivelEuskera nivel;

  const TemaSopa({
    required this.identificador,
    required this.izenburuEuskera,
    required this.descripcionEspanol,
    required this.palabras,
    this.nivel = NivelEuskera.a1,
  });
}

const List<TemaSopa> temasSopa = <TemaSopa>[
  TemaSopa(
    identificador: 'animaliak',
    izenburuEuskera: 'Animaliak',
    descripcionEspanol: 'Animales',
    palabras: <String>[
      'txakurra',
      'katua',
      'ardia',
      'behia',
      'zaldia',
      'oiloa',
    ],
  ),
  TemaSopa(
    identificador: 'jakiak',
    izenburuEuskera: 'Jakiak',
    descripcionEspanol: 'Comida',
    palabras: <String>['ogia', 'ura', 'esnea', 'gazta', 'sagarra'],
  ),
  TemaSopa(
    identificador: 'familia',
    izenburuEuskera: 'Familia',
    descripcionEspanol: 'Familia',
    palabras: <String>['ama', 'aita', 'anaia', 'amona', 'aitona', 'osaba'],
  ),
  TemaSopa(
    identificador: 'koloreak',
    izenburuEuskera: 'Koloreak',
    descripcionEspanol: 'Colores',
    palabras: <String>['gorria', 'urdina', 'horia', 'berdea', 'beltza', 'zuria'],
  ),
  // ─── A2: VIDA COTIDIANA ──────────────────────────────────────────
  TemaSopa(
    identificador: 'eguraldia',
    izenburuEuskera: 'Eguraldia',
    descripcionEspanol: 'El tiempo (meteorológico)',
    palabras: <String>['euria', 'haizea', 'eguzkia', 'elurra', 'hodeia', 'beroa'],
    nivel: NivelEuskera.a2,
  ),
  TemaSopa(
    identificador: 'kirolak',
    izenburuEuskera: 'Kirolak',
    descripcionEspanol: 'Deportes',
    palabras: <String>['futbola', 'igeriketa', 'pilota', 'eskalada', 'txirrindula', 'mendia'],
    nivel: NivelEuskera.a2,
  ),
  // ─── B1: TRABAJO Y CIUDAD ────────────────────────────────────────
  TemaSopa(
    identificador: 'lanbideak',
    izenburuEuskera: 'Lanbideak',
    descripcionEspanol: 'Profesiones',
    palabras: <String>['medikua', 'arotza', 'sukaldari', 'ikertzaile', 'idazkaria', 'igeltsero'],
    nivel: NivelEuskera.b1,
  ),
  TemaSopa(
    identificador: 'hiria',
    izenburuEuskera: 'Hiria',
    descripcionEspanol: 'La ciudad',
    palabras: <String>['kalea', 'plaza', 'liburutegi', 'auzoa', 'merkatu', 'gunea'],
    nivel: NivelEuskera.b1,
  ),
  // ─── B2: ÁMBITO INSTITUCIONAL / ABSTRACTO ────────────────────────
  TemaSopa(
    identificador: 'erakundeak',
    izenburuEuskera: 'Erakundeak',
    descripcionEspanol: 'Instituciones',
    palabras: <String>['udala', 'gobernua', 'epaitegi', 'aldundia', 'parlamentu', 'enpresa'],
    nivel: NivelEuskera.b2,
  ),
  TemaSopa(
    identificador: 'kontzeptuak',
    izenburuEuskera: 'Kontzeptuak',
    descripcionEspanol: 'Conceptos abstractos',
    palabras: <String>['askatasun', 'berdintasun', 'erabakia', 'akordioa', 'helburua', 'iritzia'],
    nivel: NivelEuskera.b2,
  ),
  // ─── C1: DISCURSO ELABORADO ──────────────────────────────────────
  TemaSopa(
    identificador: 'legedia',
    izenburuEuskera: 'Legedia',
    descripcionEspanol: 'Derecho y legislación',
    palabras: <String>['legea', 'eskumena', 'auzia', 'epaia', 'salaketa', 'agindua'],
    nivel: NivelEuskera.c1,
  ),
  TemaSopa(
    identificador: 'ingurumena',
    izenburuEuskera: 'Ingurumena',
    descripcionEspanol: 'Medio ambiente',
    palabras: <String>['kutsadura', 'iturria', 'baliabide', 'birziklatu', 'klima', 'isuria'],
    nivel: NivelEuskera.c1,
  ),
];

/// Filtra los temas de sopa de letras al subconjunto cuyos nivel ≤
/// [nivelMax]. Usado por la pantalla cuando el alumno elige su nivel.
List<TemaSopa> temasParaNivel(NivelEuskera nivelMax) {
  return temasSopa
      .where((TemaSopa t) => t.nivel.index <= nivelMax.index)
      .toList(growable: false);
}

/// Tamaño del tablero. 10×10 es suficiente para palabras de hasta ~9
/// letras (txakurra) sin apretar demasiado.
const int tamanoTablero = 10;

/// Alfabeto vasco usado para rellenar las casillas vacías. Sin algunas
/// letras poco habituales (c, q, v, w, y) para que el "ruido" parezca
/// realmente texto en euskera y la dificultad sea razonable.
const List<String> alfabetoEuskaraz = <String>[
  'a','b','d','e','f','g','h','i','j','k','l','m','n',
  'o','p','r','s','t','u','x','z',
];

/// Genera un tablero válido para [tema]. Coloca cada palabra en
/// horizontal o vertical (sin diagonales — más amable para A1) sin
/// solapamientos incompatibles, y rellena el resto de casillas con
/// letras aleatorias del alfabeto euskaraz.
TableroSopa generarTablero(TemaSopa tema, {int? semilla}) {
  final math.Random rng = math.Random(semilla);
  final List<List<String>> celdas = List<List<String>>.generate(
    tamanoTablero,
    (_) => List<String>.filled(tamanoTablero, '', growable: false),
  );
  final Map<String, List<Punto>> posicionesPorPalabra =
      <String, List<Punto>>{};

  for (final String palabra in tema.palabras) {
    final List<Punto>? colocacion =
        _intentarColocar(celdas, palabra, rng);
    if (colocacion != null) {
      posicionesPorPalabra[palabra] = colocacion;
    }
  }

  // Rellenar huecos con letras aleatorias.
  for (int indiceFila = 0; indiceFila < tamanoTablero; indiceFila++) {
    for (int indiceColumna = 0; indiceColumna < tamanoTablero; indiceColumna++) {
      if (celdas[indiceFila][indiceColumna].isEmpty) {
        celdas[indiceFila][indiceColumna] =
            alfabetoEuskaraz[rng.nextInt(alfabetoEuskaraz.length)];
      }
    }
  }

  return TableroSopa(
    celdas: celdas,
    palabras: posicionesPorPalabra.keys.toList(growable: false),
    posicionesPorPalabra: posicionesPorPalabra,
  );
}

List<Punto>? _intentarColocar(
    List<List<String>> celdas, String palabra, math.Random rng) {
  const int maxIntentos = 80;
  for (int intento = 0; intento < maxIntentos; intento++) {
    final bool horizontal = rng.nextBool();
    final int filaInicio = rng.nextInt(tamanoTablero);
    final int columnaInicio = rng.nextInt(tamanoTablero);
    if (horizontal) {
      if (columnaInicio + palabra.length > tamanoTablero) continue;
    } else {
      if (filaInicio + palabra.length > tamanoTablero) continue;
    }
    bool encaja = true;
    final List<Punto> caminoCandidato = <Punto>[];
    for (int indiceLetra = 0; indiceLetra < palabra.length; indiceLetra++) {
      final int fila = horizontal ? filaInicio : filaInicio + indiceLetra;
      final int columna = horizontal ? columnaInicio + indiceLetra : columnaInicio;
      final String celdaActual = celdas[fila][columna];
      if (celdaActual.isNotEmpty && celdaActual != palabra[indiceLetra]) {
        encaja = false;
        break;
      }
      caminoCandidato.add(Punto(fila, columna));
    }
    if (!encaja) continue;
    for (int indiceLetra = 0; indiceLetra < palabra.length; indiceLetra++) {
      final Punto punto = caminoCandidato[indiceLetra];
      celdas[punto.fila][punto.columna] = palabra[indiceLetra];
    }
    return caminoCandidato;
  }
  return null;
}

/// Comprueba si dos puntos están alineados en horizontal o vertical y
/// devuelve el camino (incluidos ambos extremos). Si no están
/// alineados, devuelve null.
List<Punto>? caminoEntre(Punto inicio, Punto fin) {
  if (inicio.fila == fin.fila) {
    final int paso = inicio.columna < fin.columna ? 1 : -1;
    final List<Punto> camino = <Punto>[];
    for (int columna = inicio.columna; columna != fin.columna + paso; columna += paso) {
      camino.add(Punto(inicio.fila, columna));
    }
    return camino;
  }
  if (inicio.columna == fin.columna) {
    final int paso = inicio.fila < fin.fila ? 1 : -1;
    final List<Punto> camino = <Punto>[];
    for (int fila = inicio.fila; fila != fin.fila + paso; fila += paso) {
      camino.add(Punto(fila, inicio.columna));
    }
    return camino;
  }
  return null;
}
