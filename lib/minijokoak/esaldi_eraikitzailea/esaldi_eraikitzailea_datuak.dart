import '../../oinarriak/ariketa.dart';

/// Una frase a construir: el orden correcto en euskera y su traducción.
/// El minijuego presentará al alumno las palabras desordenadas + la
/// traducción al español como pista. El alumno debe reconstruir el
/// orden SOV propio del euskera.
class FraseAConstruir {
  final List<String> palabrasOrdenadas;
  final String traduccionEspanol;

  /// Nivel MCER de la frase. El selector de partida filtra para que un
  /// alumno A2 no se encuentre frases C1 con subordinadas y conectores.
  final NivelEuskera nivel;

  const FraseAConstruir({
    required this.palabrasOrdenadas,
    required this.traduccionEspanol,
    this.nivel = NivelEuskera.a1,
  });

  String get fraseCompletaEuskera => palabrasOrdenadas.join(' ');
}

/// Banco amplio de frases A1-B1 cubriendo:
/// — verbos transitivos (auxiliar du/dut + sujeto ergativo en -k)
/// — verbos intransitivos (auxiliar da/naiz + sujeto absolutivo)
/// — verbos sintéticos (joan, etorri, egon, izan, jakin, eduki)
/// — construcciones NOR-NORI-NORK (diot/dit/diozu/diogu…)
/// — temas variados: familia, escuela, trabajo, naturaleza, comida,
///   sentimientos, viajes, comunicación.
///
/// Si añades una frase nueva: verifica concordancia sujeto-auxiliar
/// (transitivo→du, intransitivo→da) y casos (-k para ergativo).
const List<FraseAConstruir> bancoDeFrasesAConstruir = <FraseAConstruir>[
  // ─── BÁSICAS A1 ──────────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Lagunak', 'liburua', 'ekartzen', 'du'],
    traduccionEspanol: 'El amigo trae el libro.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Aitak', 'afaria', 'prestatzen', 'du'],
    traduccionEspanol: 'Papá prepara la cena.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Haurrak', 'eskolara', 'doaz'],
    traduccionEspanol: 'Los niños van a la escuela.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Ikasleak', 'euskaraz', 'hitz egiten', 'du'],
    traduccionEspanol: 'El estudiante habla en euskera.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Nik', 'kafe', 'bat', 'edaten', 'dut'],
    traduccionEspanol: 'Yo bebo un café.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Trena', 'Bilbora', 'doa'],
    traduccionEspanol: 'El tren va a Bilbao.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Zuek', 'liburuak', 'irakurtzen', 'dituzue'],
    traduccionEspanol: 'Vosotros leéis los libros.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Berak', 'telebista', 'ikusten', 'du'],
    traduccionEspanol: 'Él/ella ve la televisión.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Aitona', 'mendian', 'bizi', 'da'],
    traduccionEspanol: 'El abuelo vive en el monte.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Gu', 'hondartzara', 'goaz'],
    traduccionEspanol: 'Nosotros vamos a la playa.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Amak', 'oparia', 'eman', 'dit'],
    traduccionEspanol: 'Mamá me ha dado el regalo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Ikaslea',
      'irakaslearekin',
      'mintzatzen',
      'da'
    ],
    traduccionEspanol: 'El alumno habla con el profesor.',
  ),

  // ─── FAMILIA Y CASA ──────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Amak', 'afaria', 'prestatzen', 'du', 'egunero'],
    traduccionEspanol: 'Mamá prepara la cena todos los días.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Aita', 'garaiz', 'iristen', 'da'],
    traduccionEspanol: 'Papá llega a tiempo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Anaiak', 'bizikleta', 'hartu', 'du'],
    traduccionEspanol: 'El hermano ha cogido la bicicleta.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Arrebak', 'telebista', 'ikusten', 'du'],
    traduccionEspanol: 'La hermana ve la televisión.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Amonak', 'gozokia', 'eman', 'dit'],
    traduccionEspanol: 'La abuela me ha dado un caramelo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Aitonak',
      'kontu zaharrak',
      'kontatzen',
      'dizkigu',
    ],
    traduccionEspanol: 'El abuelo nos cuenta historias antiguas.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Osabak', 'parrila', 'prestatzen', 'du'],
    traduccionEspanol: 'El tío prepara la parrilla.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Familia osoa', 'mahaian', 'dago'],
    traduccionEspanol: 'Toda la familia está en la mesa.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Aitak', 'liburua', 'irakurtzen', 'du', 'salan'],
    traduccionEspanol: 'Papá lee el libro en el salón.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Amak', 'loreak', 'landatu', 'ditu'],
    traduccionEspanol: 'Mamá ha plantado las flores.',
  ),

  // ─── ESKOLAN ─────────────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Irakasleak', 'ariketa', 'azaldu', 'du'],
    traduccionEspanol: 'El profesor ha explicado el ejercicio.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Ikasleak', 'euskara', 'ikasten', 'du'],
    traduccionEspanol: 'El estudiante aprende euskera.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Haurrak', 'patioan', 'jolasten', 'dira'],
    traduccionEspanol: 'Los niños juegan en el patio.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Irakurketa', 'gustatzen', 'zait'],
    traduccionEspanol: 'Me gusta la lectura.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Galderak', 'egiten', 'ditugu', 'klasean'],
    traduccionEspanol: 'Hacemos preguntas en clase.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Idazten', 'ari naiz', 'koadernoan'],
    traduccionEspanol: 'Estoy escribiendo en el cuaderno.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Bihar', 'azterketa', 'daukagu'],
    traduccionEspanol: 'Mañana tenemos examen.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Ikasleek',
      'irakaslearekin',
      'hitz egiten',
      'dute',
    ],
    traduccionEspanol: 'Los alumnos hablan con el profesor.',
  ),

  // ─── LANA ETA HIRIA ──────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Aitak', 'bulegoan', 'lan egiten', 'du'],
    traduccionEspanol: 'Papá trabaja en la oficina.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Goizean', 'autobusa', 'hartzen', 'dut'],
    traduccionEspanol: 'Por la mañana cojo el autobús.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Dendara', 'joan', 'naiz'],
    traduccionEspanol: 'He ido a la tienda.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Ostiraletan',
      'lagunekin',
      'egoten',
      'naiz',
    ],
    traduccionEspanol: 'Los viernes estoy con los amigos.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Tabernan', 'kafea', 'hartu', 'dugu'],
    traduccionEspanol: 'Hemos tomado el café en el bar.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Kalean', 'jende', 'asko', 'dago'],
    traduccionEspanol: 'Hay mucha gente en la calle.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Plaza handia', 'ikusi', 'dugu'],
    traduccionEspanol: 'Hemos visto la plaza grande.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Medikuak', 'pazientea', 'artatzen', 'du'],
    traduccionEspanol: 'El médico atiende al paciente.',
  ),

  // ─── MENDIA ETA NATURA ───────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Mendira', 'igo', 'gara'],
    traduccionEspanol: 'Hemos subido al monte.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Itsasoa', 'urrun', 'ikusten', 'da'],
    traduccionEspanol: 'El mar se ve a lo lejos.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Eguzkia',
      'mendiaren gainetik',
      'ateratzen',
      'da',
    ],
    traduccionEspanol: 'El sol sale por encima del monte.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Txoria', 'kantatzen', 'ari da'],
    traduccionEspanol: 'El pájaro está cantando.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Hondartzan', 'bainatu', 'gara'],
    traduccionEspanol: 'Nos hemos bañado en la playa.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Basoan', 'oinez', 'ibili', 'gara'],
    traduccionEspanol: 'Hemos caminado por el bosque.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Euria', 'goian', 'egiten', 'du'],
    traduccionEspanol: 'Está lloviendo arriba.',
  ),

  // ─── GUSTUAK ETA SENTIMENDUAK ───────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Liburu hau', 'gustatzen', 'zait'],
    traduccionEspanol: 'Me gusta este libro.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Pelikula honek', 'harritu', 'nau'],
    traduccionEspanol: 'Esta película me ha sorprendido.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Bidaiak', 'maite', 'ditut'],
    traduccionEspanol: 'Me encantan los viajes.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Festa polita', 'izan', 'da'],
    traduccionEspanol: 'Ha sido una fiesta bonita.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Nekatuta', 'nago'],
    traduccionEspanol: 'Estoy cansado.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Goseak', 'nago'],
    traduccionEspanol: 'Tengo hambre.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Lo egin', 'nahi dut'],
    traduccionEspanol: 'Quiero dormir.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Musika', 'asko', 'gustatzen', 'zait'],
    traduccionEspanol: 'Me gusta mucho la música.',
  ),

  // ─── KOMUNIKAZIOA ────────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Lagunari', 'deitu', 'diot'],
    traduccionEspanol: 'He llamado al amigo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Lagunari',
      'email bat',
      'idatzi',
      'diozu',
    ],
    traduccionEspanol: 'Le has escrito un email al amigo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Mezua', 'jaso', 'dut'],
    traduccionEspanol: 'He recibido el mensaje.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Kaixo', 'esan', 'diogu'],
    traduccionEspanol: 'Le hemos dicho hola.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Albistea', 'entzun', 'dugu', 'irratian'],
    traduccionEspanol: 'Hemos escuchado la noticia en la radio.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Argazkia',
      'atera',
      'diot',
      'lagunari',
    ],
    traduccionEspanol: 'Le he hecho una foto al amigo.',
  ),

  // ─── JANARIA ─────────────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Goizean', 'ogia', 'jaten', 'dut'],
    traduccionEspanol: 'Por la mañana como pan.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Kafea',
      'esnearekin',
      'hartzen',
      'dut',
    ],
    traduccionEspanol: 'Tomo el café con leche.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Aitak',
      'oso ondo',
      'sukaldatzen',
      'du',
    ],
    traduccionEspanol: 'Papá cocina muy bien.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Jatetxean', 'afaldu', 'dugu'],
    traduccionEspanol: 'Hemos cenado en el restaurante.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Haurrak', 'sagarra', 'jan', 'du'],
    traduccionEspanol: 'El niño se ha comido la manzana.',
  ),

  // ─── BIDAIAK ─────────────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Bilbora', 'joan', 'gara'],
    traduccionEspanol: 'Hemos ido a Bilbao.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Trena', 'garaiz', 'heldu', 'da'],
    traduccionEspanol: 'El tren ha llegado a tiempo.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Aireportura',
      'goaz',
      'arratsaldean',
    ],
    traduccionEspanol: 'Vamos al aeropuerto por la tarde.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Mendian',
      'hilabete bat',
      'eman',
      'dugu',
    ],
    traduccionEspanol: 'Hemos pasado un mes en el monte.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Etxera', 'itzuli', 'gara'],
    traduccionEspanol: 'Hemos vuelto a casa.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Gasteizetik', 'gatoz'],
    traduccionEspanol: 'Venimos desde Vitoria.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Donostian', 'lau egun', 'eman', 'ditugu'],
    traduccionEspanol: 'Hemos pasado cuatro días en Donostia.',
  ),

  // ─── ACCIONES DIARIAS ────────────────────────────────────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>['Goizean', 'goiz', 'jaikitzen', 'naiz'],
    traduccionEspanol: 'Por la mañana me levanto temprano.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Dutxa', 'hartzen', 'dut'],
    traduccionEspanol: 'Me ducho.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Hortzak', 'garbitzen', 'ditut'],
    traduccionEspanol: 'Me lavo los dientes.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Arratsaldean', 'kirola', 'egiten', 'dut'],
    traduccionEspanol: 'Por la tarde hago deporte.',
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>['Gauean', 'lo', 'egiten', 'dut'],
    traduccionEspanol: 'Por la noche duermo.',
  ),

  // ─── B1: ORACIONES MÁS LARGAS CON CONECTORES BÁSICOS ─────────────
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Atzo', 'lanetik', 'irten', 'nintzen', 'eta', 'parkera', 'joan', 'nintzen',
    ],
    traduccionEspanol: 'Ayer salí del trabajo y fui al parque.',
    nivel: NivelEuskera.b1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Goizean', 'esnatu', 'nintzenean', 'euria', 'ari', 'zuen',
    ],
    traduccionEspanol: 'Cuando me desperté por la mañana, llovía.',
    nivel: NivelEuskera.b1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Liburu', 'hau', 'oso', 'interesgarria', 'iruditzen', 'zait',
    ],
    traduccionEspanol: 'Este libro me parece muy interesante.',
    nivel: NivelEuskera.b1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Bilerara', 'joango', 'naiz', 'baina', 'beranduago', 'iritsiko', 'naiz',
    ],
    traduccionEspanol: 'Iré a la reunión pero llegaré más tarde.',
    nivel: NivelEuskera.b1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Lankideak', 'esan', 'dit', 'bihar', 'ez', 'datorrela', 'lanera',
    ],
    traduccionEspanol: 'El compañero me ha dicho que mañana no viene a trabajar.',
    nivel: NivelEuskera.b1,
  ),
  // ─── B2: SUBORDINACIÓN, FORMAS RELATIVAS, REGISTRO MÁS FORMAL ────
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Erabakia', 'hartu', 'aurretik', 'denok', 'iritzia', 'eman', 'beharko', 'genuke',
    ],
    traduccionEspanol: 'Antes de tomar la decisión, todos deberíamos dar nuestra opinión.',
    nivel: NivelEuskera.b2,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Atzo', 'aurkeztu', 'zen', 'proiektua', 'oso', 'interesgarria', 'da',
    ],
    traduccionEspanol: 'El proyecto que se presentó ayer es muy interesante.',
    nivel: NivelEuskera.b2,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Udaletxeak', 'iragarri', 'duenez', 'aurrekontuak', 'handitu', 'egingo', 'ditu',
    ],
    traduccionEspanol: 'Según ha anunciado el ayuntamiento, ampliará el presupuesto.',
    nivel: NivelEuskera.b2,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Helburua', 'lortzeko', 'denbora', 'eta', 'baliabide', 'gehiago', 'behar', 'ditugu',
    ],
    traduccionEspanol: 'Para alcanzar el objetivo necesitamos más tiempo y recursos.',
    nivel: NivelEuskera.b2,
  ),
  // ─── C1: REGISTRO INSTITUCIONAL Y CONECTORES COMPLEJOS ───────────
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Azterketaren', 'ondorioak', 'argitaratu', 'ostean', 'eztabaida', 'piztu', 'da',
    ],
    traduccionEspanol: 'Tras publicarse las conclusiones del análisis, se ha desatado el debate.',
    nivel: NivelEuskera.c1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Eskumena', 'gobernuari', 'badagokio', 'ere', 'udalak', 'parte', 'hartzen', 'du',
    ],
    traduccionEspanol: 'Aunque la competencia corresponde al gobierno, el ayuntamiento también participa.',
    nivel: NivelEuskera.c1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Legea', 'aldatzeko', 'proposamena', 'parlamentuan', 'aztertuko', 'da', 'astebete', 'barru',
    ],
    traduccionEspanol: 'La propuesta para modificar la ley se examinará en el parlamento dentro de una semana.',
    nivel: NivelEuskera.c1,
  ),
  FraseAConstruir(
    palabrasOrdenadas: <String>[
      'Adituek', 'azpimarratu', 'dute', 'gizarteak', 'ahalegin', 'kolektibo', 'bat', 'egin', 'behar', 'duela',
    ],
    traduccionEspanol: 'Los expertos han subrayado que la sociedad debe hacer un esfuerzo colectivo.',
    nivel: NivelEuskera.c1,
  ),
];

/// Número de frases por partida. Con un banco de 60+ frases, una
/// partida de 8 ya tiene variedad suficiente sin agotar el banco rápido.
const int frasesPorPartida = 8;

/// Filtra el banco de frases a las que tienen nivel ≤ [nivelMax]. Lo
/// usa la pantalla cuando el alumno elige un nivel concreto.
List<FraseAConstruir> frasesParaNivel(NivelEuskera nivelMax) {
  return bancoDeFrasesAConstruir
      .where((FraseAConstruir f) => f.nivel.index <= nivelMax.index)
      .toList(growable: false);
}
