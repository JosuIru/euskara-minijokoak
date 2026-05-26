import '../../oinarriak/ariketa.dart';

/// Pareja de vocabulario que aparece en el memory: una cara en euskera,
/// la otra en español. Cada partida usa 8 pares (16 cartas en total) de
/// un solo tema, para que el aprendizaje sea cohesivo y no un revuelto.
class ParejaVocabulario {
  final String euskera;
  final String espanol;

  const ParejaVocabulario({required this.euskera, required this.espanol});
}

/// Tema de un set de vocabulario. El alumno elegirá el tema antes de
/// empezar la partida — esto sustituye el típico "nivel" del memory por
/// algo más útil pedagógicamente.
class TemaVocabulario {
  final String identificador;
  final String izenburuEuskera;
  final String descripcionEspanol;
  final String emojiRepresentativo;
  final List<ParejaVocabulario> parejas;

  /// Nivel MCER del tema. La pantalla filtra para que un alumno A1 no
  /// aterrice en un tema de derecho administrativo.
  final NivelEuskera nivel;

  const TemaVocabulario({
    required this.identificador,
    required this.izenburuEuskera,
    required this.descripcionEspanol,
    required this.emojiRepresentativo,
    required this.parejas,
    this.nivel = NivelEuskera.a1,
  });
}

/// Conjunto de temas iniciales A1-A2. Cada uno trae 8 pares — el
/// minijuego selecciona aleatoriamente 8 (los que quepan en la rejilla
/// 4×4 de pares = 8 cartas euskera + 8 cartas español).
const List<TemaVocabulario> temasDisponibles = <TemaVocabulario>[
  TemaVocabulario(
    identificador: 'etxea',
    izenburuEuskera: 'Etxea',
    descripcionEspanol: 'La casa',
    emojiRepresentativo: '🏠',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'atea', espanol: 'puerta'),
      ParejaVocabulario(euskera: 'leihoa', espanol: 'ventana'),
      ParejaVocabulario(euskera: 'gela', espanol: 'habitación'),
      ParejaVocabulario(euskera: 'mahaia', espanol: 'mesa'),
      ParejaVocabulario(euskera: 'aulkia', espanol: 'silla'),
      ParejaVocabulario(euskera: 'ohea', espanol: 'cama'),
      ParejaVocabulario(euskera: 'sukaldea', espanol: 'cocina'),
      ParejaVocabulario(euskera: 'bainugela', espanol: 'baño'),
    ],
  ),
  TemaVocabulario(
    identificador: 'familia',
    izenburuEuskera: 'Familia',
    descripcionEspanol: 'La familia',
    emojiRepresentativo: '👨‍👩‍👧',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'ama', espanol: 'madre'),
      ParejaVocabulario(euskera: 'aita', espanol: 'padre'),
      ParejaVocabulario(euskera: 'anaia', espanol: 'hermano'),
      ParejaVocabulario(euskera: 'arreba', espanol: 'hermana (de varón)'),
      ParejaVocabulario(euskera: 'amona', espanol: 'abuela'),
      ParejaVocabulario(euskera: 'aitona', espanol: 'abuelo'),
      ParejaVocabulario(euskera: 'osaba', espanol: 'tío'),
      ParejaVocabulario(euskera: 'izeba', espanol: 'tía'),
    ],
  ),
  TemaVocabulario(
    identificador: 'jakiak',
    izenburuEuskera: 'Jakiak',
    descripcionEspanol: 'Comida',
    emojiRepresentativo: '🍞',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'ogia', espanol: 'pan'),
      ParejaVocabulario(euskera: 'ura', espanol: 'agua'),
      ParejaVocabulario(euskera: 'esnea', espanol: 'leche'),
      ParejaVocabulario(euskera: 'arraina', espanol: 'pescado'),
      ParejaVocabulario(euskera: 'haragia', espanol: 'carne'),
      ParejaVocabulario(euskera: 'gazta', espanol: 'queso'),
      ParejaVocabulario(euskera: 'sagarra', espanol: 'manzana'),
      ParejaVocabulario(euskera: 'arrautza', espanol: 'huevo'),
    ],
  ),
  TemaVocabulario(
    identificador: 'animaliak',
    izenburuEuskera: 'Animaliak',
    descripcionEspanol: 'Animales',
    emojiRepresentativo: '🐑',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'txakurra', espanol: 'perro'),
      ParejaVocabulario(euskera: 'katua', espanol: 'gato'),
      ParejaVocabulario(euskera: 'ardia', espanol: 'oveja'),
      ParejaVocabulario(euskera: 'behia', espanol: 'vaca'),
      ParejaVocabulario(euskera: 'zaldia', espanol: 'caballo'),
      ParejaVocabulario(euskera: 'oiloa', espanol: 'gallina'),
      ParejaVocabulario(euskera: 'arratoia', espanol: 'rata'),
      ParejaVocabulario(euskera: 'hartza', espanol: 'oso'),
    ],
  ),
  TemaVocabulario(
    identificador: 'gorputza',
    izenburuEuskera: 'Gorputza',
    descripcionEspanol: 'El cuerpo',
    emojiRepresentativo: '👀',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'burua', espanol: 'cabeza'),
      ParejaVocabulario(euskera: 'begia', espanol: 'ojo'),
      ParejaVocabulario(euskera: 'ahoa', espanol: 'boca'),
      ParejaVocabulario(euskera: 'sudurra', espanol: 'nariz'),
      ParejaVocabulario(euskera: 'belarria', espanol: 'oreja'),
      ParejaVocabulario(euskera: 'eskua', espanol: 'mano'),
      ParejaVocabulario(euskera: 'oina', espanol: 'pie'),
      ParejaVocabulario(euskera: 'bihotza', espanol: 'corazón'),
    ],
  ),
  TemaVocabulario(
    identificador: 'koloreak',
    izenburuEuskera: 'Koloreak',
    descripcionEspanol: 'Colores',
    emojiRepresentativo: '🎨',
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'gorria', espanol: 'rojo'),
      ParejaVocabulario(euskera: 'urdina', espanol: 'azul'),
      ParejaVocabulario(euskera: 'horia', espanol: 'amarillo'),
      ParejaVocabulario(euskera: 'berdea', espanol: 'verde'),
      ParejaVocabulario(euskera: 'beltza', espanol: 'negro'),
      ParejaVocabulario(euskera: 'zuria', espanol: 'blanco'),
      ParejaVocabulario(euskera: 'arrosa', espanol: 'rosa'),
      ParejaVocabulario(euskera: 'morea', espanol: 'morado'),
    ],
  ),
  // ─── A2: VIDA COTIDIANA ──────────────────────────────────────────
  TemaVocabulario(
    identificador: 'eguraldia',
    izenburuEuskera: 'Eguraldia',
    descripcionEspanol: 'El tiempo (meteorológico)',
    emojiRepresentativo: '🌦',
    nivel: NivelEuskera.a2,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'euria', espanol: 'lluvia'),
      ParejaVocabulario(euskera: 'haizea', espanol: 'viento'),
      ParejaVocabulario(euskera: 'elurra', espanol: 'nieve'),
      ParejaVocabulario(euskera: 'eguzkia', espanol: 'sol'),
      ParejaVocabulario(euskera: 'hodeia', espanol: 'nube'),
      ParejaVocabulario(euskera: 'tximista', espanol: 'rayo'),
      ParejaVocabulario(euskera: 'beroa', espanol: 'calor'),
      ParejaVocabulario(euskera: 'hotza', espanol: 'frío'),
    ],
  ),
  TemaVocabulario(
    identificador: 'astia',
    izenburuEuskera: 'Astia',
    descripcionEspanol: 'Tiempo libre',
    emojiRepresentativo: '🎬',
    nivel: NivelEuskera.a2,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'pelikula', espanol: 'película'),
      ParejaVocabulario(euskera: 'liburua', espanol: 'libro'),
      ParejaVocabulario(euskera: 'kontzertua', espanol: 'concierto'),
      ParejaVocabulario(euskera: 'bidaia', espanol: 'viaje'),
      ParejaVocabulario(euskera: 'festa', espanol: 'fiesta'),
      ParejaVocabulario(euskera: 'kirola', espanol: 'deporte'),
      ParejaVocabulario(euskera: 'jolasa', espanol: 'juego'),
      ParejaVocabulario(euskera: 'irteera', espanol: 'salida'),
    ],
  ),
  // ─── B1: ÁMBITO LABORAL Y CIUDAD ─────────────────────────────────
  TemaVocabulario(
    identificador: 'lanbideak',
    izenburuEuskera: 'Lanbideak',
    descripcionEspanol: 'Profesiones',
    emojiRepresentativo: '🛠',
    nivel: NivelEuskera.b1,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'medikua', espanol: 'médico/a'),
      ParejaVocabulario(euskera: 'irakaslea', espanol: 'profesor/a'),
      ParejaVocabulario(euskera: 'arotza', espanol: 'carpintero/a'),
      ParejaVocabulario(euskera: 'sukaldari', espanol: 'cocinero/a'),
      ParejaVocabulario(euskera: 'idazkaria', espanol: 'secretario/a'),
      ParejaVocabulario(euskera: 'ikertzaile', espanol: 'investigador/a'),
      ParejaVocabulario(euskera: 'igeltsero', espanol: 'albañil'),
      ParejaVocabulario(euskera: 'kazetari', espanol: 'periodista'),
    ],
  ),
  TemaVocabulario(
    identificador: 'osasuna',
    izenburuEuskera: 'Osasuna',
    descripcionEspanol: 'La salud',
    emojiRepresentativo: '🏥',
    nivel: NivelEuskera.b1,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'gaixotasun', espanol: 'enfermedad'),
      ParejaVocabulario(euskera: 'osasuntsua', espanol: 'sano'),
      ParejaVocabulario(euskera: 'sukarra', espanol: 'fiebre'),
      ParejaVocabulario(euskera: 'mina', espanol: 'dolor'),
      ParejaVocabulario(euskera: 'sendagaia', espanol: 'medicamento'),
      ParejaVocabulario(euskera: 'ospitalea', espanol: 'hospital'),
      ParejaVocabulario(euskera: 'odola', espanol: 'sangre'),
      ParejaVocabulario(euskera: 'kontsulta', espanol: 'consulta'),
    ],
  ),
  // ─── B2: INSTITUCIONES Y ABSTRACTO ───────────────────────────────
  TemaVocabulario(
    identificador: 'erakundeak',
    izenburuEuskera: 'Erakundeak',
    descripcionEspanol: 'Instituciones',
    emojiRepresentativo: '🏛',
    nivel: NivelEuskera.b2,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'udala', espanol: 'ayuntamiento'),
      ParejaVocabulario(euskera: 'gobernua', espanol: 'gobierno'),
      ParejaVocabulario(euskera: 'aldundia', espanol: 'diputación'),
      ParejaVocabulario(euskera: 'parlamentua', espanol: 'parlamento'),
      ParejaVocabulario(euskera: 'epaitegia', espanol: 'juzgado'),
      ParejaVocabulario(euskera: 'enpresa', espanol: 'empresa'),
      ParejaVocabulario(euskera: 'sindikatua', espanol: 'sindicato'),
      ParejaVocabulario(euskera: 'elkartea', espanol: 'asociación'),
    ],
  ),
  TemaVocabulario(
    identificador: 'gizartea',
    izenburuEuskera: 'Gizartea',
    descripcionEspanol: 'Sociedad y valores',
    emojiRepresentativo: '🤝',
    nivel: NivelEuskera.b2,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'askatasuna', espanol: 'libertad'),
      ParejaVocabulario(euskera: 'berdintasuna', espanol: 'igualdad'),
      ParejaVocabulario(euskera: 'iritzia', espanol: 'opinión'),
      ParejaVocabulario(euskera: 'erabakia', espanol: 'decisión'),
      ParejaVocabulario(euskera: 'akordioa', espanol: 'acuerdo'),
      ParejaVocabulario(euskera: 'helburua', espanol: 'objetivo'),
      ParejaVocabulario(euskera: 'erronka', espanol: 'reto'),
      ParejaVocabulario(euskera: 'ardura', espanol: 'responsabilidad'),
    ],
  ),
  // ─── C1: DISCURSO ELABORADO ──────────────────────────────────────
  TemaVocabulario(
    identificador: 'zuzenbidea',
    izenburuEuskera: 'Zuzenbidea',
    descripcionEspanol: 'Derecho',
    emojiRepresentativo: '⚖',
    nivel: NivelEuskera.c1,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'legea', espanol: 'ley'),
      ParejaVocabulario(euskera: 'eskumena', espanol: 'competencia legal'),
      ParejaVocabulario(euskera: 'auzia', espanol: 'caso judicial'),
      ParejaVocabulario(euskera: 'epaia', espanol: 'sentencia'),
      ParejaVocabulario(euskera: 'salaketa', espanol: 'denuncia'),
      ParejaVocabulario(euskera: 'agindua', espanol: 'mandato/orden'),
      ParejaVocabulario(euskera: 'erreklamazioa', espanol: 'reclamación'),
      ParejaVocabulario(euskera: 'arautegia', espanol: 'normativa'),
    ],
  ),
  TemaVocabulario(
    identificador: 'ingurumena',
    izenburuEuskera: 'Ingurumena',
    descripcionEspanol: 'Medio ambiente',
    emojiRepresentativo: '🌍',
    nivel: NivelEuskera.c1,
    parejas: <ParejaVocabulario>[
      ParejaVocabulario(euskera: 'kutsadura', espanol: 'contaminación'),
      ParejaVocabulario(euskera: 'baliabidea', espanol: 'recurso'),
      ParejaVocabulario(euskera: 'birziklatu', espanol: 'reciclar'),
      ParejaVocabulario(euskera: 'iraunkortasuna', espanol: 'sostenibilidad'),
      ParejaVocabulario(euskera: 'klima-aldaketa', espanol: 'cambio climático'),
      ParejaVocabulario(euskera: 'isuria', espanol: 'emisión'),
      ParejaVocabulario(euskera: 'energia', espanol: 'energía'),
      ParejaVocabulario(euskera: 'basoa', espanol: 'bosque'),
    ],
  ),
];

/// Filtra `temasDisponibles` al subconjunto cuyo nivel ≤ [nivelMax].
List<TemaVocabulario> temasLoturaParaNivel(NivelEuskera nivelMax) {
  return temasDisponibles
      .where((TemaVocabulario t) => t.nivel.index <= nivelMax.index)
      .toList(growable: false);
}

/// Número de pares por partida. La rejilla del minijuego es 4×4 = 16
/// cartas = 8 pares. Si cambias esto, ajusta también la rejilla.
const int parejasPorPartida = 8;
