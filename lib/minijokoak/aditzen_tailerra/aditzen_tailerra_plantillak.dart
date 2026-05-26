import 'dart:math' as math;

import '../../oinarriak/ariketa.dart';
import 'aditzen_tailerra_datuak.dart';

/// Tipo de slot que una plantilla puede pedir además del verbo. Sirve
/// para que el generador escoja un complemento apropiado: no lo mismo
/// es completar "Ni ___ {EGON}" con un lugar que con un atributo.
enum TipoSlot {
  ningunoExtra,
  lugarInesibo,
  lugarAdlatibo,
  lugarAblatibo,
  atributo,
  objetoDirecto,
  complementoJakin,
}

/// Plantilla parametrizada para una frase de Aditzen Tailerra. Lleva
/// pronombre fijo y verbo fijo + un slot que se rellena con un valor
/// del banco que corresponde al `tipoSlot`. `{V}` será el verbo
/// conjugado correcto; `{X}` el complemento elegido.
class PlantillaFraseAditza {
  final PronombreEuskera pronombre;
  final AditzTrinkoa verbo;
  final TipoSlot tipoSlot;
  final String plantillaEuskera;
  final String plantillaEspanol;

  const PlantillaFraseAditza({
    required this.pronombre,
    required this.verbo,
    required this.tipoSlot,
    required this.plantillaEuskera,
    required this.plantillaEspanol,
  });
}

/// Banco de complementos por tipo. Mantenidos como pares (forma_euskera,
/// traduccion_español) para construir la frase + su traducción.
class ComplementoEjemplo {
  final String formaEuskera;
  final String traduccionEspanol;

  const ComplementoEjemplo(this.formaEuskera, this.traduccionEspanol);
}

const Map<TipoSlot, List<ComplementoEjemplo>> bancosComplementos =
    <TipoSlot, List<ComplementoEjemplo>>{
  TipoSlot.lugarInesibo: <ComplementoEjemplo>[
    ComplementoEjemplo('etxean', 'en casa'),
    ComplementoEjemplo('eskolan', 'en la escuela'),
    ComplementoEjemplo('lanean', 'en el trabajo'),
    ComplementoEjemplo('sukaldean', 'en la cocina'),
    ComplementoEjemplo('mendian', 'en el monte'),
    ComplementoEjemplo('hondartzan', 'en la playa'),
    ComplementoEjemplo('parkean', 'en el parque'),
    ComplementoEjemplo('Bilbon', 'en Bilbao'),
    ComplementoEjemplo('Donostian', 'en Donostia'),
    ComplementoEjemplo('Gasteizen', 'en Vitoria'),
  ],
  TipoSlot.lugarAdlatibo: <ComplementoEjemplo>[
    ComplementoEjemplo('etxera', 'a casa'),
    ComplementoEjemplo('eskolara', 'a la escuela'),
    ComplementoEjemplo('lanera', 'al trabajo'),
    ComplementoEjemplo('mendira', 'al monte'),
    ComplementoEjemplo('hondartzara', 'a la playa'),
    ComplementoEjemplo('parkera', 'al parque'),
    ComplementoEjemplo('Bilbora', 'a Bilbao'),
    ComplementoEjemplo('Donostiara', 'a Donostia'),
    ComplementoEjemplo('Gasteizera', 'a Vitoria'),
  ],
  TipoSlot.lugarAblatibo: <ComplementoEjemplo>[
    ComplementoEjemplo('etxetik', 'desde casa'),
    ComplementoEjemplo('eskolatik', 'desde la escuela'),
    ComplementoEjemplo('lanetik', 'desde el trabajo'),
    ComplementoEjemplo('menditik', 'desde el monte'),
    ComplementoEjemplo('Bilbotik', 'desde Bilbao'),
    ComplementoEjemplo('Donostiatik', 'desde Donostia'),
    ComplementoEjemplo('Gasteiztik', 'desde Vitoria'),
  ],
  TipoSlot.atributo: <ComplementoEjemplo>[
    ComplementoEjemplo('ikaslea', 'estudiante'),
    ComplementoEjemplo('irakaslea', 'profesor/a'),
    ComplementoEjemplo('mediku ona', 'buen médico'),
    ComplementoEjemplo('langilea', 'trabajador/a'),
    ComplementoEjemplo('gaztea', 'joven'),
    ComplementoEjemplo('alaia', 'alegre'),
    ComplementoEjemplo('bilbotarra', 'de Bilbao'),
    ComplementoEjemplo('donostiarra', 'de Donostia'),
  ],
  TipoSlot.objetoDirecto: <ComplementoEjemplo>[
    ComplementoEjemplo('etxe bat', 'una casa'),
    ComplementoEjemplo('auto berri bat', 'un coche nuevo'),
    ComplementoEjemplo('liburu asko', 'muchos libros'),
    ComplementoEjemplo('lan ona', 'un buen trabajo'),
    ComplementoEjemplo('bi anaia', 'dos hermanos'),
    ComplementoEjemplo('lagun batzuk', 'algunos amigos'),
    ComplementoEjemplo('telefono berria', 'un teléfono nuevo'),
    ComplementoEjemplo('katu bat', 'un gato'),
  ],
  TipoSlot.complementoJakin: <ComplementoEjemplo>[
    ComplementoEjemplo('euskaraz', 'euskera'),
    ComplementoEjemplo('ingelesez', 'inglés'),
    ComplementoEjemplo('matematika', 'matemáticas'),
    ComplementoEjemplo('kantatzen', 'cantar'),
    ComplementoEjemplo('dantzatzen', 'bailar'),
    ComplementoEjemplo('gauza asko', 'muchas cosas'),
  ],
};

/// Plantillas por verbo. Cada verbo tiene varias plantillas y se
/// combina con todos los pronombres (excepto donde lingüísticamente no
/// cuadra). Generaremos en runtime las combinaciones reales.
class _PlantillaSemilla {
  final AditzTrinkoa verbo;
  final TipoSlot tipoSlot;
  final AldiaAditza aldia;
  final NivelEuskera nivel;
  final String plantillaEuskera;
  final String plantillaEspanolBase;

  const _PlantillaSemilla({
    required this.verbo,
    required this.tipoSlot,
    required this.plantillaEuskera,
    required this.plantillaEspanolBase,
    this.aldia = AldiaAditza.oraina,
    this.nivel = NivelEuskera.a1,
  });
}

/// Mapeo de pronombre vasco a forma verbal correspondiente en español
/// para la 3 personas comunes en estas frases. Lo usamos para que la
/// traducción sea natural, no robótica.
const Map<PronombreEuskera, String> _verboSerEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'soy',
  PronombreEuskera.hura: 'es',
  PronombreEuskera.gu: 'somos',
  PronombreEuskera.zu: 'eres',
  PronombreEuskera.zuek: 'sois',
  PronombreEuskera.haiek: 'son',
};
const Map<PronombreEuskera, String> _verboEstarEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'estoy',
  PronombreEuskera.hura: 'está',
  PronombreEuskera.gu: 'estamos',
  PronombreEuskera.zu: 'estás',
  PronombreEuskera.zuek: 'estáis',
  PronombreEuskera.haiek: 'están',
};
const Map<PronombreEuskera, String> _verboIrEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'voy',
  PronombreEuskera.hura: 'va',
  PronombreEuskera.gu: 'vamos',
  PronombreEuskera.zu: 'vas',
  PronombreEuskera.zuek: 'vais',
  PronombreEuskera.haiek: 'van',
};
const Map<PronombreEuskera, String> _verboVenirEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'vengo',
  PronombreEuskera.hura: 'viene',
  PronombreEuskera.gu: 'venimos',
  PronombreEuskera.zu: 'vienes',
  PronombreEuskera.zuek: 'venís',
  PronombreEuskera.haiek: 'vienen',
};
const Map<PronombreEuskera, String> _verboSaberEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'sé',
  PronombreEuskera.hura: 'sabe',
  PronombreEuskera.gu: 'sabemos',
  PronombreEuskera.zu: 'sabes',
  PronombreEuskera.zuek: 'sabéis',
  PronombreEuskera.haiek: 'saben',
};
const Map<PronombreEuskera, String> _verboTenerEspanolPresente =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'tengo',
  PronombreEuskera.hura: 'tiene',
  PronombreEuskera.gu: 'tenemos',
  PronombreEuskera.zu: 'tienes',
  PronombreEuskera.zuek: 'tenéis',
  PronombreEuskera.haiek: 'tienen',
};

// Pretérito perfecto simple (canté/cantó) para el iragana vasco.
const Map<PronombreEuskera, String> _verboSerEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'fui',
  PronombreEuskera.hura: 'fue',
  PronombreEuskera.gu: 'fuimos',
  PronombreEuskera.zu: 'fuiste',
  PronombreEuskera.zuek: 'fuisteis',
  PronombreEuskera.haiek: 'fueron',
};
const Map<PronombreEuskera, String> _verboEstarEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'estuve',
  PronombreEuskera.hura: 'estuvo',
  PronombreEuskera.gu: 'estuvimos',
  PronombreEuskera.zu: 'estuviste',
  PronombreEuskera.zuek: 'estuvisteis',
  PronombreEuskera.haiek: 'estuvieron',
};
const Map<PronombreEuskera, String> _verboIrEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'fui',
  PronombreEuskera.hura: 'fue',
  PronombreEuskera.gu: 'fuimos',
  PronombreEuskera.zu: 'fuiste',
  PronombreEuskera.zuek: 'fuisteis',
  PronombreEuskera.haiek: 'fueron',
};
const Map<PronombreEuskera, String> _verboVenirEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'vine',
  PronombreEuskera.hura: 'vino',
  PronombreEuskera.gu: 'vinimos',
  PronombreEuskera.zu: 'viniste',
  PronombreEuskera.zuek: 'vinisteis',
  PronombreEuskera.haiek: 'vinieron',
};
const Map<PronombreEuskera, String> _verboSaberEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'supe',
  PronombreEuskera.hura: 'supo',
  PronombreEuskera.gu: 'supimos',
  PronombreEuskera.zu: 'supiste',
  PronombreEuskera.zuek: 'supisteis',
  PronombreEuskera.haiek: 'supieron',
};
const Map<PronombreEuskera, String> _verboTenerEspanolPasado =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'tuve',
  PronombreEuskera.hura: 'tuvo',
  PronombreEuskera.gu: 'tuvimos',
  PronombreEuskera.zu: 'tuviste',
  PronombreEuskera.zuek: 'tuvisteis',
  PronombreEuskera.haiek: 'tuvieron',
};

// Pretérito imperfecto de subjuntivo (fuera/estuviera/tuviera) para el
// modo hipotético — encaja con "si yo fuera…" y similares.
const Map<PronombreEuskera, String> _verboSerEspanolHipotetico =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'fuera',
  PronombreEuskera.hura: 'fuera',
  PronombreEuskera.gu: 'fuéramos',
  PronombreEuskera.zu: 'fueras',
  PronombreEuskera.zuek: 'fuerais',
  PronombreEuskera.haiek: 'fueran',
};
const Map<PronombreEuskera, String> _verboEstarEspanolHipotetico =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'estuviera',
  PronombreEuskera.hura: 'estuviera',
  PronombreEuskera.gu: 'estuviéramos',
  PronombreEuskera.zu: 'estuvieras',
  PronombreEuskera.zuek: 'estuvierais',
  PronombreEuskera.haiek: 'estuvieran',
};
const Map<PronombreEuskera, String> _verboTenerEspanolHipotetico =
    <PronombreEuskera, String>{
  PronombreEuskera.ni: 'tuviera',
  PronombreEuskera.hura: 'tuviera',
  PronombreEuskera.gu: 'tuviéramos',
  PronombreEuskera.zu: 'tuvieras',
  PronombreEuskera.zuek: 'tuvierais',
  PronombreEuskera.haiek: 'tuvieran',
};

String _verboEspanolPara(
  AditzTrinkoa verbo,
  PronombreEuskera pronombre, {
  AldiaAditza aldia = AldiaAditza.oraina,
}) {
  switch (aldia) {
    case AldiaAditza.oraina:
      switch (verbo) {
        case AditzTrinkoa.izan:
          return _verboSerEspanolPresente[pronombre]!;
        case AditzTrinkoa.egon:
          return _verboEstarEspanolPresente[pronombre]!;
        case AditzTrinkoa.joan:
          return _verboIrEspanolPresente[pronombre]!;
        case AditzTrinkoa.etorri:
          return _verboVenirEspanolPresente[pronombre]!;
        case AditzTrinkoa.jakin:
          return _verboSaberEspanolPresente[pronombre]!;
        case AditzTrinkoa.eduki:
          return _verboTenerEspanolPresente[pronombre]!;
      }
    case AldiaAditza.iragana:
      switch (verbo) {
        case AditzTrinkoa.izan:
          return _verboSerEspanolPasado[pronombre]!;
        case AditzTrinkoa.egon:
          return _verboEstarEspanolPasado[pronombre]!;
        case AditzTrinkoa.joan:
          return _verboIrEspanolPasado[pronombre]!;
        case AditzTrinkoa.etorri:
          return _verboVenirEspanolPasado[pronombre]!;
        case AditzTrinkoa.jakin:
          return _verboSaberEspanolPasado[pronombre]!;
        case AditzTrinkoa.eduki:
          return _verboTenerEspanolPasado[pronombre]!;
      }
    case AldiaAditza.hipotetikoa:
      switch (verbo) {
        case AditzTrinkoa.izan:
          return _verboSerEspanolHipotetico[pronombre]!;
        case AditzTrinkoa.egon:
          return _verboEstarEspanolHipotetico[pronombre]!;
        case AditzTrinkoa.eduki:
          return _verboTenerEspanolHipotetico[pronombre]!;
        case AditzTrinkoa.joan:
        case AditzTrinkoa.etorri:
        case AditzTrinkoa.jakin:
          // No usamos estos verbos en modo hipotético — el generador los
          // filtra antes. Si alguno se cuela, devolvemos el infinitivo.
          return verbo.infinitivo;
      }
  }
}

String _sujetoEspanolPara(PronombreEuskera pronombre) {
  switch (pronombre) {
    case PronombreEuskera.ni:
      return 'Yo';
    case PronombreEuskera.hura:
      return 'Él/ella';
    case PronombreEuskera.gu:
      return 'Nosotros';
    case PronombreEuskera.zu:
      return 'Tú';
    case PronombreEuskera.zuek:
      return 'Vosotros';
    case PronombreEuskera.haiek:
      return 'Ellos';
  }
}

const List<_PlantillaSemilla> _plantillasSemilla = <_PlantillaSemilla>[
  // A1: Presente, las 6 estructuras básicas que ya estaban.
  _PlantillaSemilla(
    verbo: AditzTrinkoa.izan,
    tipoSlot: TipoSlot.atributo,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.egon,
    tipoSlot: TipoSlot.lugarInesibo,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.joan,
    tipoSlot: TipoSlot.lugarAdlatibo,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.etorri,
    tipoSlot: TipoSlot.lugarAblatibo,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.jakin,
    tipoSlot: TipoSlot.complementoJakin,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.eduki,
    tipoSlot: TipoSlot.objetoDirecto,
    plantillaEuskera: '{N} {X} ___.',
    plantillaEspanolBase: '{S} {V} {Xes}.',
  ),
  // A2: Negación e interrogación — mismas formas, contexto algo más rico.
  _PlantillaSemilla(
    verbo: AditzTrinkoa.eduki,
    tipoSlot: TipoSlot.objetoDirecto,
    plantillaEuskera: '{N} ez ___ {X}.',
    plantillaEspanolBase: '{S} no {V} {Xes}.',
    nivel: NivelEuskera.a2,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.egon,
    tipoSlot: TipoSlot.lugarInesibo,
    plantillaEuskera: 'Non ___ {N}? — {X}.',
    plantillaEspanolBase: '¿Dónde {V} {S}? — {Xes}.',
    nivel: NivelEuskera.a2,
  ),
  // B1: Pasado simple (iraganaldia).
  _PlantillaSemilla(
    verbo: AditzTrinkoa.izan,
    tipoSlot: TipoSlot.atributo,
    plantillaEuskera: 'Lehen, {N} {X} ___.',
    plantillaEspanolBase: 'Antes, {S} {V} {Xes}.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.b1,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.egon,
    tipoSlot: TipoSlot.lugarInesibo,
    plantillaEuskera: 'Atzo {N} {X} ___.',
    plantillaEspanolBase: 'Ayer {S} {V} {Xes}.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.b1,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.joan,
    tipoSlot: TipoSlot.lugarAdlatibo,
    plantillaEuskera: 'Iaz {N} {X} ___ udan.',
    plantillaEspanolBase: 'El año pasado {S} {V} {Xes} en verano.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.b1,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.etorri,
    tipoSlot: TipoSlot.lugarAblatibo,
    plantillaEuskera: 'Goizean {N} {X} ___ oinez.',
    plantillaEspanolBase: 'Por la mañana {S} {V} {Xes} andando.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.b1,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.eduki,
    tipoSlot: TipoSlot.objetoDirecto,
    plantillaEuskera: 'Garai hartan {N} {X} ___.',
    plantillaEspanolBase: 'En aquella época {S} {V} {Xes}.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.b1,
  ),
  // B2: Hipotético/condicional con izan/egon/eduki.
  _PlantillaSemilla(
    verbo: AditzTrinkoa.izan,
    tipoSlot: TipoSlot.atributo,
    plantillaEuskera: '{N} {X} ___, oso pozik geundeke.',
    plantillaEspanolBase: 'Si {S} {V} {Xes}, estaríamos muy contentos.',
    aldia: AldiaAditza.hipotetikoa,
    nivel: NivelEuskera.b2,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.egon,
    tipoSlot: TipoSlot.lugarInesibo,
    plantillaEuskera: '{N} {X} ___, lasaiago hitz egingo genuke.',
    plantillaEspanolBase: 'Si {S} {V} {Xes}, hablaríamos más tranquilos.',
    aldia: AldiaAditza.hipotetikoa,
    nivel: NivelEuskera.b2,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.eduki,
    tipoSlot: TipoSlot.objetoDirecto,
    plantillaEuskera: '{N} {X} ___, dena prest legoke.',
    plantillaEspanolBase: 'Si {S} {V} {Xes}, todo estaría listo.',
    aldia: AldiaAditza.hipotetikoa,
    nivel: NivelEuskera.b2,
  ),
  // C1: Registro abstracto con subordinación de propósito o condición.
  _PlantillaSemilla(
    verbo: AditzTrinkoa.jakin,
    tipoSlot: TipoSlot.complementoJakin,
    plantillaEuskera: 'Egia esan, {N} {X} ___ bere garaian.',
    plantillaEspanolBase: 'A decir verdad, {S} {V} {Xes} en su momento.',
    aldia: AldiaAditza.iragana,
    nivel: NivelEuskera.c1,
  ),
  _PlantillaSemilla(
    verbo: AditzTrinkoa.eduki,
    tipoSlot: TipoSlot.objetoDirecto,
    plantillaEuskera:
        'Aurrekontu nahikoa {N} ___, helburua erraz lortuko genuke {X}-rekin.',
    plantillaEspanolBase:
        'Con presupuesto suficiente, {S} {V} {Xes}, alcanzaríamos fácilmente el objetivo.',
    aldia: AldiaAditza.hipotetikoa,
    nivel: NivelEuskera.c1,
  ),
];

/// Genera [cantidad] rondas únicas combinando pronombres × verbos ×
/// complementos del banco. Con 6 verbos × 6 pronombres × ~8 complementos
/// por slot hay del orden de 250+ combinaciones posibles en presente,
/// más las plantillas en pasado e hipotético cuando se sube de nivel.
///
/// `nivelMax` filtra plantillas-semilla con nivel > nivelMax.
List<RondaAditza> generarRondasProcedimentalmenteAditza({
  required int cantidad,
  int? semilla,
  NivelEuskera nivelMax = NivelEuskera.c1,
}) {
  final math.Random rng = math.Random(semilla);
  final List<RondaAditza> rondas = <RondaAditza>[];
  final Set<String> combinacionesVistas = <String>{};

  final List<_PlantillaSemilla> plantillasDisponibles = _plantillasSemilla
      .where((_PlantillaSemilla p) => p.nivel.index <= nivelMax.index)
      .toList(growable: false);
  if (plantillasDisponibles.isEmpty) return rondas;

  int intentos = 0;
  const int maxIntentos = 500;

  while (rondas.length < cantidad && intentos < maxIntentos) {
    intentos += 1;
    final _PlantillaSemilla semilla =
        plantillasDisponibles[rng.nextInt(plantillasDisponibles.length)];
    final PronombreEuskera pronombre = PronombreEuskera
        .values[rng.nextInt(PronombreEuskera.values.length)];

    // Si la plantilla está en modo hipotético y el verbo no lo soporta
    // (joan/etorri/jakin), saltamos. Mejor descartarlo que conjugar mal.
    if (semilla.aldia == AldiaAditza.hipotetikoa) {
      const Set<AditzTrinkoa> soportanHipotetico = <AditzTrinkoa>{
        AditzTrinkoa.izan,
        AditzTrinkoa.egon,
        AditzTrinkoa.eduki,
      };
      if (!soportanHipotetico.contains(semilla.verbo)) continue;
    }

    final List<ComplementoEjemplo>? bancoSlot =
        bancosComplementos[semilla.tipoSlot];
    if (bancoSlot == null || bancoSlot.isEmpty) continue;
    final ComplementoEjemplo complemento =
        bancoSlot[rng.nextInt(bancoSlot.length)];

    final String clave =
        '${semilla.verbo.name}|${pronombre.name}|${semilla.aldia.name}|'
        '${complemento.formaEuskera}';
    if (combinacionesVistas.contains(clave)) continue;
    combinacionesVistas.add(clave);

    final String fraseConHueco = semilla.plantillaEuskera
        .replaceAll('{N}', pronombre.formaEuskera)
        .replaceAll('{X}', complemento.formaEuskera);
    final String traduccion = semilla.plantillaEspanolBase
        .replaceAll('{S}', _sujetoEspanolPara(pronombre))
        .replaceAll(
            '{V}',
            _verboEspanolPara(semilla.verbo, pronombre,
                aldia: semilla.aldia))
        .replaceAll('{Xes}', complemento.traduccionEspanol);

    rondas.add(RondaAditza(
      pronombre: pronombre,
      verbo: semilla.verbo,
      aldia: semilla.aldia,
      fraseContextoConHueco: fraseConHueco,
      traduccionEspanol: traduccion,
    ));
  }

  return rondas;
}
