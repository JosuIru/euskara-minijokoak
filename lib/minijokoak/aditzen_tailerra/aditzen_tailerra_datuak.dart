/// Pronombres personales del euskera. Mantenemos la sucesión clásica
/// que aparece en cualquier libro AEK: ni, hi, hura, gu, zu, zuek, haiek.
/// `hi` se usa en hitano (trato familiar) y es relativamente raro en A1;
/// lo dejamos fuera del banco inicial para no marear y lo introducimos
/// más adelante.
enum PronombreEuskera {
  ni('Ni', 'yo'),
  hura('Hura', 'él/ella'),
  gu('Gu', 'nosotros/as'),
  zu('Zu', 'tú/usted'),
  zuek('Zuek', 'vosotros/as'),
  haiek('Haiek', 'ellos/as');

  final String formaEuskera;
  final String traduccionEspanol;

  const PronombreEuskera(this.formaEuskera, this.traduccionEspanol);
}

/// Verbos sintéticos (aditz trinkoak) más nucleares del A1-A2 AEK.
/// Son los que se conjugan directamente sin auxiliar.
enum AditzTrinkoa {
  izan('izan', 'ser/estar (cópula)'),
  egon('egon', 'estar (localización)'),
  joan('joan', 'ir'),
  etorri('etorri', 'venir'),
  jakin('jakin', 'saber'),
  eduki('eduki', 'tener');

  final String infinitivo;
  final String traduccionEspanol;

  const AditzTrinkoa(this.infinitivo, this.traduccionEspanol);
}

/// Tiempo gramatical en el que se conjuga el verbo. Ampliamos el
/// minijuego de presente (A1-A2) a pasado simple (B1) e hipotético
/// (B2) para cubrir los niveles superiores sin cambiar la mecánica.
enum AldiaAditza {
  oraina('Orainaldia', 'Presente'),
  iragana('Iraganaldia', 'Pasado'),
  hipotetikoa('Hipotetikoa', 'Hipotético/Condicional');

  final String izenburua;
  final String descripcionEspanol;

  const AldiaAditza(this.izenburua, this.descripcionEspanol);
}

/// Tabla de conjugación de presente para los aditz trinkoak básicos.
/// Las claves son `(verbo, pronombre)` codificadas como string. Lo
/// llevamos a mano porque son sólo 36 entradas y así el alumno ve la
/// forma exacta que usaría AEK en clase, sin reglas regulares falsas.
const Map<String, String> conjugacionPresente = <String, String>{
  'izan|ni': 'naiz',
  'izan|hura': 'da',
  'izan|gu': 'gara',
  'izan|zu': 'zara',
  'izan|zuek': 'zarete',
  'izan|haiek': 'dira',

  'egon|ni': 'nago',
  'egon|hura': 'dago',
  'egon|gu': 'gaude',
  'egon|zu': 'zaude',
  'egon|zuek': 'zaudete',
  'egon|haiek': 'daude',

  'joan|ni': 'noa',
  'joan|hura': 'doa',
  'joan|gu': 'goaz',
  'joan|zu': 'zoaz',
  'joan|zuek': 'zoazte',
  'joan|haiek': 'doaz',

  'etorri|ni': 'nator',
  'etorri|hura': 'dator',
  'etorri|gu': 'gatoz',
  'etorri|zu': 'zatoz',
  'etorri|zuek': 'zatozte',
  'etorri|haiek': 'datoz',

  'jakin|ni': 'dakit',
  'jakin|hura': 'daki',
  'jakin|gu': 'dakigu',
  'jakin|zu': 'dakizu',
  'jakin|zuek': 'dakizue',
  'jakin|haiek': 'dakite',

  'eduki|ni': 'daukat',
  'eduki|hura': 'dauka',
  'eduki|gu': 'daukagu',
  'eduki|zu': 'daukazu',
  'eduki|zuek': 'daukazue',
  'eduki|haiek': 'daukate',
};

/// Conjugación de pasado simple (iraganaldia) de los aditz trinkoak.
/// B1 — la forma que aparece en frases tipo "atzo nintzen, joan zen…".
const Map<String, String> conjugacionIragana = <String, String>{
  'izan|ni': 'nintzen',
  'izan|hura': 'zen',
  'izan|gu': 'ginen',
  'izan|zu': 'zinen',
  'izan|zuek': 'zineten',
  'izan|haiek': 'ziren',

  'egon|ni': 'nengoen',
  'egon|hura': 'zegoen',
  'egon|gu': 'geunden',
  'egon|zu': 'zeunden',
  'egon|zuek': 'zeundeten',
  'egon|haiek': 'zeuden',

  'joan|ni': 'nindoan',
  'joan|hura': 'zihoan',
  'joan|gu': 'gindoazen',
  'joan|zu': 'zindoazen',
  'joan|zuek': 'zindoazten',
  'joan|haiek': 'zihoazen',

  'etorri|ni': 'nentorren',
  'etorri|hura': 'zetorren',
  'etorri|gu': 'gentozen',
  'etorri|zu': 'zentozen',
  'etorri|zuek': 'zentozten',
  'etorri|haiek': 'zetozen',

  'jakin|ni': 'nekien',
  'jakin|hura': 'zekien',
  'jakin|gu': 'genekien',
  'jakin|zu': 'zenekien',
  'jakin|zuek': 'zenekiten',
  'jakin|haiek': 'zekiten',

  'eduki|ni': 'neukan',
  'eduki|hura': 'zeukan',
  'eduki|gu': 'geneukan',
  'eduki|zu': 'zeneukan',
  'eduki|zuek': 'zeneukaten',
  'eduki|haiek': 'zeukaten',
};

/// Modo hipotético / condicional (banintz, balitz…) usado en frases B2-C1
/// como "Bilbon banengo, telefonoz deituko nizuke". Sólo cubrimos `izan`,
/// `egon` y `eduki` porque son los productivos en este contexto.
const Map<String, String> conjugacionHipotetikoa = <String, String>{
  'izan|ni': 'banintz',
  'izan|hura': 'balitz',
  'izan|gu': 'bagina',
  'izan|zu': 'bazina',
  'izan|zuek': 'bazinete',
  'izan|haiek': 'balira',

  'egon|ni': 'banengo',
  'egon|hura': 'balego',
  'egon|gu': 'bageunde',
  'egon|zu': 'bazeunde',
  'egon|zuek': 'bazeundete',
  'egon|haiek': 'baleude',

  'eduki|ni': 'baneuka',
  'eduki|hura': 'baleuka',
  'eduki|gu': 'bageneuka',
  'eduki|zu': 'bazeneuka',
  'eduki|zuek': 'bazeneukate',
  'eduki|haiek': 'baleukate',
};

/// Devuelve la forma conjugada de [verbo] para [pronombre] en el tiempo
/// solicitado. Default `oraina` para mantener retrocompatibilidad con
/// las llamadas existentes.
String conjugar(
  AditzTrinkoa verbo,
  PronombreEuskera pronombre, {
  AldiaAditza aldia = AldiaAditza.oraina,
}) {
  final String clave = '${verbo.infinitivo}|${pronombre.name}';
  final Map<String, String> tabla;
  switch (aldia) {
    case AldiaAditza.oraina:
      tabla = conjugacionPresente;
      break;
    case AldiaAditza.iragana:
      tabla = conjugacionIragana;
      break;
    case AldiaAditza.hipotetikoa:
      tabla = conjugacionHipotetikoa;
      break;
  }
  final String? forma = tabla[clave];
  if (forma == null) {
    throw StateError('Conjugación no encontrada: $clave (${aldia.name})');
  }
  return forma;
}

/// Una ronda del taller: combinación pronombre+verbo + frase real con
/// hueco que el alumno verá. La frase ayuda a fijar el uso en contexto
/// (no solo conjugar de memoria, sino reconocer cuándo va cada forma).
class RondaAditza {
  final PronombreEuskera pronombre;
  final AditzTrinkoa verbo;
  final AldiaAditza aldia;
  final String fraseContextoConHueco;
  final String traduccionEspanol;

  const RondaAditza({
    required this.pronombre,
    required this.verbo,
    required this.fraseContextoConHueco,
    required this.traduccionEspanol,
    this.aldia = AldiaAditza.oraina,
  });

  /// La forma conjugada que el alumno debe identificar como correcta.
  String get formaCorrecta => conjugar(verbo, pronombre, aldia: aldia);
}

/// Banco inicial de rondas. Cubrimos las 6 personas con cada uno de los
/// 6 verbos trinkoak básicos. Frases breves, concretas, A1-A2.
const List<RondaAditza> bancoDeRondasAditza = <RondaAditza>[
  // IZAN
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.izan,
    fraseContextoConHueco: 'Ni Bilbokoa ___.',
    traduccionEspanol: 'Yo soy de Bilbao.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.hura,
    verbo: AditzTrinkoa.izan,
    fraseContextoConHueco: 'Bera nire laguna ___.',
    traduccionEspanol: 'Ella/él es mi amiga/o.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.gu,
    verbo: AditzTrinkoa.izan,
    fraseContextoConHueco: 'Gu ikasleak ___.',
    traduccionEspanol: 'Nosotros somos estudiantes.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.zu,
    verbo: AditzTrinkoa.izan,
    fraseContextoConHueco: 'Zu irakaslea ___.',
    traduccionEspanol: 'Tú eres profesor/a.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.haiek,
    verbo: AditzTrinkoa.izan,
    fraseContextoConHueco: 'Haiek euskaldunak ___.',
    traduccionEspanol: 'Ellos/as son vascoparlantes.',
  ),
  // EGON
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.egon,
    fraseContextoConHueco: 'Etxean ___.',
    traduccionEspanol: 'Estoy en casa.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.hura,
    verbo: AditzTrinkoa.egon,
    fraseContextoConHueco: 'Ama sukaldean ___.',
    traduccionEspanol: 'Mamá está en la cocina.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.gu,
    verbo: AditzTrinkoa.egon,
    fraseContextoConHueco: 'Lagunak eta ni mendian ___.',
    traduccionEspanol: 'Los amigos y yo estamos en el monte.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.zuek,
    verbo: AditzTrinkoa.egon,
    fraseContextoConHueco: 'Non ___ zuek?',
    traduccionEspanol: '¿Dónde estáis vosotros/as?',
  ),
  // JOAN
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.joan,
    fraseContextoConHueco: 'Bihar Donostiara ___.',
    traduccionEspanol: 'Mañana voy a Donostia.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.hura,
    verbo: AditzTrinkoa.joan,
    fraseContextoConHueco: 'Aita lanera ___.',
    traduccionEspanol: 'Papá va al trabajo.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.gu,
    verbo: AditzTrinkoa.joan,
    fraseContextoConHueco: 'Hondartzara ___ gaur.',
    traduccionEspanol: 'Hoy vamos a la playa.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.haiek,
    verbo: AditzTrinkoa.joan,
    fraseContextoConHueco: 'Umeak eskolara ___.',
    traduccionEspanol: 'Los niños van a la escuela.',
  ),
  // ETORRI
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.etorri,
    fraseContextoConHueco: 'Gasteizetik ___.',
    traduccionEspanol: 'Vengo desde Vitoria.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.hura,
    verbo: AditzTrinkoa.etorri,
    fraseContextoConHueco: 'Trena orain ___.',
    traduccionEspanol: 'El tren viene ahora.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.zu,
    verbo: AditzTrinkoa.etorri,
    fraseContextoConHueco: 'Nondik ___ zu?',
    traduccionEspanol: '¿De dónde vienes tú?',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.gu,
    verbo: AditzTrinkoa.etorri,
    fraseContextoConHueco: 'Bilbotik ___ autobusez.',
    traduccionEspanol: 'Venimos desde Bilbao en autobús.',
  ),
  // JAKIN
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.jakin,
    fraseContextoConHueco: 'Nik ez ___ erantzuna.',
    traduccionEspanol: 'Yo no sé la respuesta.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.zu,
    verbo: AditzTrinkoa.jakin,
    fraseContextoConHueco: 'Zuk euskaraz ___ ?',
    traduccionEspanol: '¿Tú sabes euskera?',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.haiek,
    verbo: AditzTrinkoa.jakin,
    fraseContextoConHueco: 'Haiek ondo ___ kantatzen.',
    traduccionEspanol: 'Ellos/as saben cantar bien.',
  ),
  // EDUKI
  RondaAditza(
    pronombre: PronombreEuskera.ni,
    verbo: AditzTrinkoa.eduki,
    fraseContextoConHueco: 'Nik bi anaia ___.',
    traduccionEspanol: 'Yo tengo dos hermanos.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.hura,
    verbo: AditzTrinkoa.eduki,
    fraseContextoConHueco: 'Berak auto berri bat ___.',
    traduccionEspanol: 'Él/ella tiene un coche nuevo.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.gu,
    verbo: AditzTrinkoa.eduki,
    fraseContextoConHueco: 'Etxe handi bat ___.',
    traduccionEspanol: 'Tenemos una casa grande.',
  ),
  RondaAditza(
    pronombre: PronombreEuskera.zuek,
    verbo: AditzTrinkoa.eduki,
    fraseContextoConHueco: 'Zuek liburuak ___ ?',
    traduccionEspanol: '¿Tenéis los libros?',
  ),
];

/// Devuelve [cantidadDistractores] formas conjugadas distintas a la
/// [formaCorrecta], priorizando otras personas del mismo verbo (mismo
/// "molde") para que parezcan opciones razonables, no aleatorias.
///
/// `aldia` indica el tiempo de la ronda — los distractores son del mismo
/// tiempo, si no, serían trivialmente descartables por el alumno.
List<String> generarDistractores({
  required AditzTrinkoa verbo,
  required PronombreEuskera pronombreCorrecto,
  required int cantidadDistractores,
  AldiaAditza aldia = AldiaAditza.oraina,
}) {
  final List<String> candidatosMismoVerbo = <String>[];
  for (final PronombreEuskera pronombre in PronombreEuskera.values) {
    if (pronombre == pronombreCorrecto) continue;
    try {
      candidatosMismoVerbo.add(conjugar(verbo, pronombre, aldia: aldia));
    } on StateError {
      // El verbo no tiene esta persona/tiempo (p.ej. hipotético sólo
      // cubre izan/egon/eduki). Lo saltamos sin más.
    }
  }
  candidatosMismoVerbo.shuffle();
  if (candidatosMismoVerbo.length >= cantidadDistractores) {
    return candidatosMismoVerbo.sublist(0, cantidadDistractores);
  }
  return candidatosMismoVerbo;
}
