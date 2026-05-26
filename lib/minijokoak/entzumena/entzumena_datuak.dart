import '../../oinarriak/ariketa.dart';

/// Una frase en euskera + opciones de significado para elegir tras
/// escucharla. El alumno oye `fraseEuskera` y debe identificar
/// `traduccionCorrectaEspanol` entre 4 candidatos (esa + 3 distractores).
class FraseEntzumena {
  final String fraseEuskera;
  final String traduccionCorrectaEspanol;
  final List<String> distractoresEspanol;

  /// Nivel MCER de la frase. La pantalla filtra el banco al elegir
  /// nivel para que un alumno A1 no oiga frases con subordinadas C1.
  final NivelEuskera nivel;

  const FraseEntzumena({
    required this.fraseEuskera,
    required this.traduccionCorrectaEspanol,
    required this.distractoresEspanol,
    this.nivel = NivelEuskera.a1,
  });
}

/// Banco inicial de frases A1-A2. Los distractores se eligen para que
/// suenen plausibles — comparten o tema (lugares, familia, comida) o
/// estructura (tiempo verbal, número), para que el alumno tenga que
/// distinguir realmente lo que ha oído, no descartar lo absurdo.
const List<FraseEntzumena> bancoFrasesEntzumena = <FraseEntzumena>[
  // ─── PRESENTACIONES Y BÁSICOS ───────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Ni Bilbokoa naiz.',
    traduccionCorrectaEspanol: 'Yo soy de Bilbao.',
    distractoresEspanol: <String>[
      'Yo voy a Bilbao.',
      'Tú eres de Bilbao.',
      'Bilbao es bonito.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Nire izena Maite da.',
    traduccionCorrectaEspanol: 'Me llamo Maite.',
    distractoresEspanol: <String>[
      'Tú te llamas Maite.',
      'Maite es mi amiga.',
      'Yo quiero a Maite.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Bi anaia ditut.',
    traduccionCorrectaEspanol: 'Tengo dos hermanos.',
    distractoresEspanol: <String>[
      'Tengo dos hermanas.',
      'Tienes dos hermanos.',
      'Soy dos hermanos.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Hogeita hamar urte ditut.',
    traduccionCorrectaEspanol: 'Tengo treinta años.',
    distractoresEspanol: <String>[
      'Tengo trece años.',
      'Tengo veinte años.',
      'Tengo treinta amigos.',
    ],
  ),

  // ─── LUGARES ──────────────────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Etxean nago.',
    traduccionCorrectaEspanol: 'Estoy en casa.',
    distractoresEspanol: <String>[
      'Voy a casa.',
      'Vivo en casa.',
      'Vengo de casa.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Donostiara joango naiz bihar.',
    traduccionCorrectaEspanol: 'Iré a Donostia mañana.',
    distractoresEspanol: <String>[
      'Fui a Donostia ayer.',
      'Voy desde Donostia.',
      'Vivo en Donostia.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Mendian bizi naiz.',
    traduccionCorrectaEspanol: 'Vivo en el monte.',
    distractoresEspanol: <String>[
      'Voy al monte.',
      'Vengo del monte.',
      'El monte es alto.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Bilbotik nator.',
    traduccionCorrectaEspanol: 'Vengo de Bilbao.',
    distractoresEspanol: <String>[
      'Voy a Bilbao.',
      'Estoy en Bilbao.',
      'Soy de Bilbao.',
    ],
  ),

  // ─── COMIDA Y RUTINA ─────────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Goizean kafea hartzen dut.',
    traduccionCorrectaEspanol: 'Por la mañana tomo café.',
    distractoresEspanol: <String>[
      'Por la mañana tomas café.',
      'Por la tarde tomo café.',
      'Por la mañana tomo leche.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Ogia eta gazta jaten ditut.',
    traduccionCorrectaEspanol: 'Como pan y queso.',
    distractoresEspanol: <String>[
      'Como pan y manzana.',
      'Bebo pan y queso.',
      'Tengo pan y queso.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Ura edaten dut.',
    traduccionCorrectaEspanol: 'Bebo agua.',
    distractoresEspanol: <String>[
      'Como agua.',
      'Tengo agua.',
      'Bebes agua.',
    ],
  ),

  // ─── FAMILIA ─────────────────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Amak afaria prestatzen du.',
    traduccionCorrectaEspanol: 'Mamá prepara la cena.',
    distractoresEspanol: <String>[
      'Papá prepara la cena.',
      'Mamá prepara la comida.',
      'Yo preparo la cena.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Aitona mendian bizi da.',
    traduccionCorrectaEspanol: 'El abuelo vive en el monte.',
    distractoresEspanol: <String>[
      'La abuela vive en el monte.',
      'El abuelo va al monte.',
      'El abuelo viene del monte.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Anaia eskolara doa.',
    traduccionCorrectaEspanol: 'El hermano va a la escuela.',
    distractoresEspanol: <String>[
      'La hermana va a la escuela.',
      'El hermano está en la escuela.',
      'El hermano viene de la escuela.',
    ],
  ),

  // ─── TIEMPO Y CLIMA ─────────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Gaur euria egiten du.',
    traduccionCorrectaEspanol: 'Hoy llueve.',
    distractoresEspanol: <String>[
      'Ayer llovió.',
      'Hoy hace sol.',
      'Hoy hace frío.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Eguzkia ageri da.',
    traduccionCorrectaEspanol: 'Sale el sol.',
    distractoresEspanol: <String>[
      'Hace sol.',
      'El sol es amarillo.',
      'Vemos el sol.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Hotz handia egiten du.',
    traduccionCorrectaEspanol: 'Hace mucho frío.',
    distractoresEspanol: <String>[
      'Hace mucho calor.',
      'Tengo mucho frío.',
      'Hace algo de frío.',
    ],
  ),

  // ─── ACCIONES ────────────────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Liburu bat irakurtzen ari naiz.',
    traduccionCorrectaEspanol: 'Estoy leyendo un libro.',
    distractoresEspanol: <String>[
      'Estoy escribiendo un libro.',
      'Tengo un libro.',
      'Compré un libro.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Euskara ikasten dut.',
    traduccionCorrectaEspanol: 'Aprendo euskera.',
    distractoresEspanol: <String>[
      'Hablo euskera.',
      'Sé euskera.',
      'Enseño euskera.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Lo egin nahi dut.',
    traduccionCorrectaEspanol: 'Quiero dormir.',
    distractoresEspanol: <String>[
      'Estoy durmiendo.',
      'No puedo dormir.',
      'Tengo sueño.',
    ],
  ),
  FraseEntzumena(
    fraseEuskera: 'Lagunarekin hitz egin dut.',
    traduccionCorrectaEspanol: 'He hablado con el amigo.',
    distractoresEspanol: <String>[
      'Hablo con el amigo.',
      'Voy con el amigo.',
      'He visto al amigo.',
    ],
  ),

  // ─── A2: PASADO SIMPLE Y RUTINA AMPLIADA ─────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Atzo arratsaldean parkera joan nintzen.',
    traduccionCorrectaEspanol: 'Ayer por la tarde fui al parque.',
    distractoresEspanol: <String>[
      'Mañana por la tarde iré al parque.',
      'Ayer por la mañana fui al parque.',
      'Ayer por la tarde vine del parque.',
    ],
    nivel: NivelEuskera.a2,
  ),
  FraseEntzumena(
    fraseEuskera: 'Larunbatean lagunekin afaldu nuen.',
    traduccionCorrectaEspanol: 'El sábado cené con los amigos.',
    distractoresEspanol: <String>[
      'El domingo cené con los amigos.',
      'El sábado comí con los amigos.',
      'El sábado cenaré con los amigos.',
    ],
    nivel: NivelEuskera.a2,
  ),
  FraseEntzumena(
    fraseEuskera: 'Bilbon bizi naiz hamar urte daramatzat.',
    traduccionCorrectaEspanol: 'Vivo en Bilbao desde hace diez años.',
    distractoresEspanol: <String>[
      'Vivo en Bilbao desde hace diez meses.',
      'Voy a Bilbao desde hace diez años.',
      'Vivía en Bilbao hace diez años.',
    ],
    nivel: NivelEuskera.a2,
  ),
  // ─── B1: ORACIONES CON CONECTORES ────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Lana amaitu eta gero ikastarora joan nintzen.',
    traduccionCorrectaEspanol: 'Al terminar el trabajo fui al curso.',
    distractoresEspanol: <String>[
      'Antes de empezar el trabajo fui al curso.',
      'Mientras trabajaba fui al curso.',
      'Después del curso fui al trabajo.',
    ],
    nivel: NivelEuskera.b1,
  ),
  FraseEntzumena(
    fraseEuskera: 'Goizean esnatu nintzenean euria ari zuen.',
    traduccionCorrectaEspanol: 'Cuando me desperté por la mañana llovía.',
    distractoresEspanol: <String>[
      'Cuando me desperté por la mañana nevaba.',
      'Cuando me dormí por la noche llovía.',
      'Cuando llovió me desperté.',
    ],
    nivel: NivelEuskera.b1,
  ),
  FraseEntzumena(
    fraseEuskera: 'Bilerara joango naiz baina beranduago iritsiko naiz.',
    traduccionCorrectaEspanol: 'Iré a la reunión pero llegaré más tarde.',
    distractoresEspanol: <String>[
      'No iré a la reunión porque llegaré tarde.',
      'Voy a la reunión más tarde.',
      'Llegaré pronto a la reunión.',
    ],
    nivel: NivelEuskera.b1,
  ),
  // ─── B2: SUBORDINACIÓN Y REGISTRO FORMAL ─────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Udaletxeak aurrekontuak handitu egingo dituela iragarri du.',
    traduccionCorrectaEspanol: 'El ayuntamiento ha anunciado que ampliará los presupuestos.',
    distractoresEspanol: <String>[
      'El ayuntamiento ha reducido los presupuestos.',
      'El gobierno ha anunciado nuevos presupuestos.',
      'Los presupuestos del ayuntamiento son grandes.',
    ],
    nivel: NivelEuskera.b2,
  ),
  FraseEntzumena(
    fraseEuskera: 'Erabakia hartu baino lehen denok iritzia eman beharko genuke.',
    traduccionCorrectaEspanol: 'Antes de tomar la decisión todos deberíamos dar nuestra opinión.',
    distractoresEspanol: <String>[
      'Después de tomar la decisión daremos nuestra opinión.',
      'Todos hemos dado nuestra opinión sobre la decisión.',
      'La decisión depende de nuestra opinión.',
    ],
    nivel: NivelEuskera.b2,
  ),
  FraseEntzumena(
    fraseEuskera: 'Lankideak bihar lanera ez datorrela jakinarazi dit.',
    traduccionCorrectaEspanol: 'El compañero me ha avisado de que mañana no viene a trabajar.',
    distractoresEspanol: <String>[
      'El compañero me ha pedido que mañana no vaya a trabajar.',
      'El compañero me ha dicho que ayer no vino a trabajar.',
      'Mañana iré a trabajar con el compañero.',
    ],
    nivel: NivelEuskera.b2,
  ),
  // ─── C1: DISCURSO ELABORADO ──────────────────────────────────────
  FraseEntzumena(
    fraseEuskera: 'Azterketaren ondorioak argitaratu ostean, eztabaida piztu da.',
    traduccionCorrectaEspanol: 'Tras publicarse las conclusiones del análisis, se ha desatado el debate.',
    distractoresEspanol: <String>[
      'Antes de publicar el análisis ha habido debate.',
      'Las conclusiones del análisis han sido publicadas sin debate.',
      'El debate ha acabado con la publicación del análisis.',
    ],
    nivel: NivelEuskera.c1,
  ),
  FraseEntzumena(
    fraseEuskera: 'Adituek azpimarratu dute gizarteak ahalegin kolektibo bat egin behar duela.',
    traduccionCorrectaEspanol: 'Los expertos han subrayado que la sociedad debe hacer un esfuerzo colectivo.',
    distractoresEspanol: <String>[
      'La sociedad subraya que los expertos deben hacer un esfuerzo.',
      'Los expertos han pedido a la sociedad esfuerzos individuales.',
      'La sociedad y los expertos han hecho un esfuerzo.',
    ],
    nivel: NivelEuskera.c1,
  ),
  FraseEntzumena(
    fraseEuskera: 'Legea aldatzeko proposamena parlamentuan aztertuko da astebete barru.',
    traduccionCorrectaEspanol: 'La propuesta para modificar la ley se examinará en el parlamento dentro de una semana.',
    distractoresEspanol: <String>[
      'La ley se aprobará en el parlamento dentro de una semana.',
      'Hace una semana el parlamento aprobó la ley.',
      'La propuesta se rechazó en el parlamento hace una semana.',
    ],
    nivel: NivelEuskera.c1,
  ),
];

const int rondasPorPartidaEntzumena = 8;
const int opcionesPorRondaEntzumena = 4;

/// Filtra el banco a las frases con nivel ≤ [nivelMax].
List<FraseEntzumena> frasesEntzumenaParaNivel(NivelEuskera nivelMax) {
  return bancoFrasesEntzumena
      .where((FraseEntzumena f) => f.nivel.index <= nivelMax.index)
      .toList(growable: false);
}
