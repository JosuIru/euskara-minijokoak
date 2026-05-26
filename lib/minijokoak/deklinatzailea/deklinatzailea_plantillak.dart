import 'dart:math' as math;

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/deklinabidea_motorra.dart';
import 'deklinatzailea_datuak.dart';

/// Una plantilla parametrizable de frase. Contiene el texto en euskera
/// y la traducción al español, ambos con el marcador `{P}` que será
/// sustituido por la palabra declinada en el caso indicado.
///
/// `categoriasCompatibles` filtra qué fichas del banco pueden meterse
/// en este hueco — para que la plantilla "Bizi naiz {P}" sólo coja
/// lugares y no comidas o personas, por ejemplo.
class PlantillaFraseDeklinabidea {
  final String plantillaEuskera;
  final String plantillaEspanol;
  final CasoDeklinabidea casoRequerido;
  final List<CategoriaSemantica> categoriasCompatibles;

  /// Nivel MCER mínimo en el que esta plantilla aparece. El generador
  /// filtra plantillas con nivel > nivelMax — así un alumno de A1 nunca
  /// se encuentra con subordinadas C1.
  final NivelEuskera nivel;

  const PlantillaFraseDeklinabidea({
    required this.plantillaEuskera,
    required this.plantillaEspanol,
    required this.casoRequerido,
    required this.categoriasCompatibles,
    this.nivel = NivelEuskera.a1,
  });
}

/// Banco de plantillas. Cada caso tiene varias plantillas para que las
/// frases generadas se sientan variadas dentro de un mismo caso.
const List<PlantillaFraseDeklinabidea> bancoDePlantillas =
    <PlantillaFraseDeklinabidea>[
  // ─── ADLATIBOA (NORA) ─────────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ noa.',
    plantillaEspanol: 'Voy a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Bihar _____ joango gara.',
    plantillaEspanol: 'Mañana iremos a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Igandean _____ goaz.',
    plantillaEspanol: 'El domingo vamos a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Trena _____ doa.',
    plantillaEspanol: 'El tren va a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.toponimo],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Haurrak _____ doaz korrika.',
    plantillaEspanol: 'Los niños van corriendo a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.lugar],
  ),
  // ─── INESIBOA (NON) ───────────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ bizi naiz.',
    plantillaEspanol: 'Vivo en {P}.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ nago orain.',
    plantillaEspanol: 'Estoy ahora en {P}.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Asteburuan _____ egon nintzen.',
    plantillaEspanol: 'El fin de semana estuve en {P}.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Liburua _____ dago.',
    plantillaEspanol: 'El libro está en {P}.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.objeto],
  ),
  // ─── ABLATIBOA (NONDIK) ───────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ nator.',
    plantillaEspanol: 'Vengo de {P}.',
    casoRequerido: CasoDeklinabidea.ablatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ etorri da trena.',
    plantillaEspanol: 'El tren ha venido desde {P}.',
    casoRequerido: CasoDeklinabidea.ablatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.toponimo],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Nekatuta _____ jaitsi gara.',
    plantillaEspanol: 'Hemos bajado de {P} cansados.',
    casoRequerido: CasoDeklinabidea.ablatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.lugar],
  ),
  // ─── ERGATIBOA (NORK) ─────────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ liburua ekarri du.',
    plantillaEspanol: '{P} ha traído el libro.',
    casoRequerido: CasoDeklinabidea.ergatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ afaria prestatu du.',
    plantillaEspanol: '{P} ha preparado la cena.',
    casoRequerido: CasoDeklinabidea.ergatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ etxea garbitu du.',
    plantillaEspanol: '{P} ha limpiado la casa.',
    casoRequerido: CasoDeklinabidea.ergatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ giltza galdu du.',
    plantillaEspanol: '{P} ha perdido la llave.',
    casoRequerido: CasoDeklinabidea.ergatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.animal,
    ],
  ),
  // ─── DATIBOA (NORI) ───────────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Liburua _____ eman diot.',
    plantillaEspanol: 'Le he dado el libro a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Lorea _____ oparitu diot.',
    plantillaEspanol: 'Le he regalado una flor a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Kaixo esan diot _____.',
    plantillaEspanol: 'Le he dicho hola a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.animal,
    ],
  ),
  // ─── SOZIATIBOA (NOREKIN) ─────────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ hitz egin dut.',
    plantillaEspanol: 'He hablado con {P}.',
    casoRequerido: CasoDeklinabidea.soziatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ jolastu naiz.',
    plantillaEspanol: 'He jugado con {P}.',
    casoRequerido: CasoDeklinabidea.soziatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.animal,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ bizi naiz.',
    plantillaEspanol: 'Vivo con {P}.',
    casoRequerido: CasoDeklinabidea.soziatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  // ─── DESTINATIBOA (NORENTZAT) ─────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Oparia _____ da.',
    plantillaEspanol: 'El regalo es para {P}.',
    casoRequerido: CasoDeklinabidea.destinatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Afaria _____ prestatu dut.',
    plantillaEspanol: 'He preparado la cena para {P}.',
    casoRequerido: CasoDeklinabidea.destinatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Liburu hau _____ idatzi dut.',
    plantillaEspanol: 'He escrito este libro para {P}.',
    casoRequerido: CasoDeklinabidea.destinatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
  ),
  // ─── ABSOLUTIBOA (sin marca) ──────────────────────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ edaten dut goizean.',
    plantillaEspanol: 'Bebo {P} por la mañana.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.alimento],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ jaten dut etxean.',
    plantillaEspanol: 'Como {P} en casa.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.alimento],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ gustatzen zait asko.',
    plantillaEspanol: 'Me gusta mucho {P}.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.alimento,
      CategoriaSemantica.animal,
      CategoriaSemantica.objeto,
    ],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ erori da lurrera.',
    plantillaEspanol: '{P} se ha caído al suelo.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.objeto],
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ kalean dabil.',
    plantillaEspanol: '{P} anda por la calle.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.animal,
    ],
  ),
  // ─── A2: ESTRUCTURAS PRACTICADAS EN EL SEGUNDO CURSO ──────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Atzo _____ ikusi nuen.',
    plantillaEspanol: 'Ayer vi a/en {P}.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.animal,
    ],
    nivel: NivelEuskera.a2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ deitu diot telefonoz.',
    plantillaEspanol: 'He llamado por teléfono a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
    nivel: NivelEuskera.a2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ idatzi diot mezua.',
    plantillaEspanol: 'Le he escrito un mensaje a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
    nivel: NivelEuskera.a2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Larunbatean _____ joango gara afaltzera.',
    plantillaEspanol: 'El sábado iremos a {P} a cenar.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
    nivel: NivelEuskera.a2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ topatu dut metroan.',
    plantillaEspanol: 'Me he encontrado a {P} en el metro.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
    nivel: NivelEuskera.a2,
  ),
  // ─── B1: NEXOS Y CIRCUNSTANCIALES MÁS COMPLEJOS ───────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Asteazkenean _____ bildu ginen kafea hartzeko.',
    plantillaEspanol: 'El miércoles nos reunimos con {P} para tomar café.',
    casoRequerido: CasoDeklinabidea.soziatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
    nivel: NivelEuskera.b1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Lana amaitu eta gero _____ joan nintzen.',
    plantillaEspanol: 'Al terminar el trabajo, fui a {P}.',
    casoRequerido: CasoDeklinabidea.adlatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.toponimo,
    ],
    nivel: NivelEuskera.b1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Berriak _____ entzun nituen lehen aldiz.',
    plantillaEspanol: 'Oí las noticias por primera vez de {P}.',
    casoRequerido: CasoDeklinabidea.ablatiboa,
    categoriasCompatibles: <CategoriaSemantica>[CategoriaSemantica.persona],
    nivel: NivelEuskera.b1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Proiektu honek _____ asko eskatzen du.',
    plantillaEspanol: 'Este proyecto pide mucho a/de {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.instituzio,
    ],
    nivel: NivelEuskera.b1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ hasiko da bilera ofiziala.',
    plantillaEspanol: 'En {P} empezará la reunión oficial.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.lugar,
      CategoriaSemantica.instituzio,
      CategoriaSemantica.denbora,
    ],
    nivel: NivelEuskera.b1,
  ),
  // ─── B2: ÁMBITO INSTITUCIONAL, REGISTRO FORMAL ────────────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ aurkeztu beharko diogu txostena.',
    plantillaEspanol: 'Tendremos que presentar el informe a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.instituzio,
    ],
    nivel: NivelEuskera.b2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ hartu da azken erabakia.',
    plantillaEspanol: 'En {P} se ha tomado la decisión final.',
    casoRequerido: CasoDeklinabidea.inesiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.instituzio,
      CategoriaSemantica.lugar,
    ],
    nivel: NivelEuskera.b2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Komiteak _____ proposamen berria bidali du.',
    plantillaEspanol: 'El comité ha enviado una nueva propuesta a {P}.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.instituzio,
      CategoriaSemantica.persona,
    ],
    nivel: NivelEuskera.b2,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Helburu hori _____ lortuko dugu, denbora gutxian.',
    plantillaEspanol: 'Conseguiremos ese objetivo con/desde {P}, en poco tiempo.',
    casoRequerido: CasoDeklinabidea.soziatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.persona,
      CategoriaSemantica.instituzio,
    ],
    nivel: NivelEuskera.b2,
  ),
  // ─── C1: DISCURSO ABSTRACTO, SUBORDINACIÓN ELABORADA ──────────────
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ dagokio gaiari buruzko azken hitza.',
    plantillaEspanol: 'A {P} le corresponde la última palabra sobre el asunto.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.instituzio,
      CategoriaSemantica.persona,
    ],
    nivel: NivelEuskera.c1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Auzitegiak _____ aurka eman du epaia.',
    plantillaEspanol: 'El tribunal ha dictado sentencia contra {P}.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.instituzio,
      CategoriaSemantica.persona,
      CategoriaSemantica.abstrakto,
    ],
    nivel: NivelEuskera.c1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Adituak _____ buruz aritu dira hitzaldian.',
    plantillaEspanol: 'Los expertos han hablado sobre {P} en la conferencia.',
    casoRequerido: CasoDeklinabidea.absolutiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.abstrakto,
      CategoriaSemantica.instituzio,
    ],
    nivel: NivelEuskera.c1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: '_____ atera diren ondorioak argitaratu dituzte.',
    plantillaEspanol: 'Han publicado las conclusiones extraídas de {P}.',
    casoRequerido: CasoDeklinabidea.ablatiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.abstrakto,
      CategoriaSemantica.instituzio,
    ],
    nivel: NivelEuskera.c1,
  ),
  PlantillaFraseDeklinabidea(
    plantillaEuskera: 'Eskariaren arabera, _____ legokioke erantzukizuna.',
    plantillaEspanol: 'Según la petición, a {P} le correspondería la responsabilidad.',
    casoRequerido: CasoDeklinabidea.datiboa,
    categoriasCompatibles: <CategoriaSemantica>[
      CategoriaSemantica.instituzio,
      CategoriaSemantica.persona,
    ],
    nivel: NivelEuskera.c1,
  ),
];

/// Genera [cantidad] rondas únicas mezclando plantillas y palabras del
/// banco. Garantiza que no se repita la misma combinación palabra+caso
/// dentro de la partida (para no ver "etxera" dos veces seguidas).
///
/// `nivelMax` filtra plantillas y fichas por nivel MCER: sólo se usan
/// las que tengan `nivel.index <= nivelMax.index`. Default: C1 (todo).
List<RondaDeklinatzailea> generarRondasProcedimentalmente({
  required int cantidad,
  int? semilla,
  NivelEuskera nivelMax = NivelEuskera.c1,
}) {
  final math.Random rng = math.Random(semilla);
  final List<RondaDeklinatzailea> rondasGeneradas = <RondaDeklinatzailea>[];
  final Set<String> combinacionesYaUsadas = <String>{};

  final List<PlantillaFraseDeklinabidea> plantillasDisponibles =
      bancoDePlantillas
          .where((PlantillaFraseDeklinabidea p) =>
              p.nivel.index <= nivelMax.index)
          .toList(growable: false);
  if (plantillasDisponibles.isEmpty) return rondasGeneradas;

  final List<FichaPalabra> fichasDisponibles = bancoDePalabras
      .where((FichaPalabra f) => f.nivel.index <= nivelMax.index)
      .toList(growable: false);

  // Límite duro para evitar bucles infinitos si el banco se agota.
  int intentos = 0;
  const int maxIntentos = 500;

  while (rondasGeneradas.length < cantidad && intentos < maxIntentos) {
    intentos += 1;
    final PlantillaFraseDeklinabidea plantilla =
        plantillasDisponibles[rng.nextInt(plantillasDisponibles.length)];

    final List<FichaPalabra> palabrasCompatibles = fichasDisponibles
        .where((FichaPalabra ficha) => ficha.categorias.any(
            (CategoriaSemantica cat) =>
                plantilla.categoriasCompatibles.contains(cat)))
        .toList();
    if (palabrasCompatibles.isEmpty) continue;

    final FichaPalabra ficha =
        palabrasCompatibles[rng.nextInt(palabrasCompatibles.length)];
    final String? formaDeclinada = ficha.formas[plantilla.casoRequerido];
    if (formaDeclinada == null) continue;

    final String claveUnica =
        '${ficha.raizMostrable}|${plantilla.casoRequerido.name}|'
        '${plantilla.plantillaEuskera}';
    if (combinacionesYaUsadas.contains(claveUnica)) continue;
    combinacionesYaUsadas.add(claveUnica);

    final String fraseConHueco = plantilla.plantillaEuskera;
    final String traduccionFinal = plantilla.plantillaEspanol.replaceAll(
        '{P}', ficha.traduccionEspanol);

    rondasGeneradas.add(RondaDeklinatzailea(
      palabraDeclinada: formaDeclinada,
      formaAbsoluto: ficha.raizMostrable,
      casoCorrecto: plantilla.casoRequerido,
      fraseContexto: fraseConHueco,
      traduccionEspanol: traduccionFinal,
    ));
  }

  return rondasGeneradas;
}
