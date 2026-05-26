/// Casos de la declinación vasca (deklinabidea) que practica este minijuego.
///
/// Empezamos con los más nucleares de A1-A2. Cuando ampliemos a B1+ habrá
/// que añadir norengan, norengandik, norengana, partitiboa, prolatiboa,
/// motibatiboa, instrumentala, etc.
enum CasoDeklinabidea {
  absolutiboa('ABS', 'absolutibo (zero marka)',
      'Sujeto de verbo intransitivo o OD de transitivo'),
  ergatiboa('NORK', 'ergatibo (-k/-ak)', 'Sujeto de verbo transitivo'),
  datiboa('NORI', 'datibo (-ri/-ari)', 'Complemento indirecto'),
  inesiboa('NON', 'inesibo (-n/-an)', 'Lugar donde / momento en'),
  ablatiboa('NONDIK', 'ablatibo (-tik/-etik)', 'Procedencia / desde'),
  adlatiboa('NORA', 'adlatibo (-ra/-era)', 'Destino / hacia'),
  soziatiboa('NOREKIN', 'soziatibo (-rekin/-ekin)', 'Compañía / con'),
  destinatiboa('NORENTZAT', 'destinatibo (-rentzat/-entzat)',
      'Beneficiario / para');

  final String laburpena;
  final String izenOsoa;
  final String azalpenEspaniera;

  const CasoDeklinabidea(this.laburpena, this.izenOsoa, this.azalpenEspaniera);
}

/// Una ronda del minijuego: una palabra declinada que el alumno debe
/// clasificar en el caso correcto. Lleva además la frase original (con
/// hueco) que ayuda a deducir el contexto.
class RondaDeklinatzailea {
  final String palabraDeclinada;
  final String formaAbsoluto;
  final CasoDeklinabidea casoCorrecto;
  final String fraseContexto;
  final String traduccionEspanol;

  const RondaDeklinatzailea({
    required this.palabraDeclinada,
    required this.formaAbsoluto,
    required this.casoCorrecto,
    required this.fraseContexto,
    required this.traduccionEspanol,
  });
}

/// Banco inicial de rondas para A1-A2. Cubrimos los 6 casos básicos de
/// los primeros niveles AEK. Mantener variedad de raíces para no marear
/// con la misma palabra todo el rato.
const List<RondaDeklinatzailea> bancoDeRondas = <RondaDeklinatzailea>[
  RondaDeklinatzailea(
    palabraDeclinada: 'etxean',
    formaAbsoluto: 'etxe',
    casoCorrecto: CasoDeklinabidea.inesiboa,
    fraseContexto: '_____ nago.',
    traduccionEspanol: 'Estoy en casa.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'etxera',
    formaAbsoluto: 'etxe',
    casoCorrecto: CasoDeklinabidea.adlatiboa,
    fraseContexto: '_____ noa.',
    traduccionEspanol: 'Voy a casa.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'etxetik',
    formaAbsoluto: 'etxe',
    casoCorrecto: CasoDeklinabidea.ablatiboa,
    fraseContexto: '_____ nator.',
    traduccionEspanol: 'Vengo de casa.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'lagunak',
    formaAbsoluto: 'lagun',
    casoCorrecto: CasoDeklinabidea.ergatiboa,
    fraseContexto: '_____ liburua ekarri du.',
    traduccionEspanol: 'El amigo ha traído el libro.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'lagunari',
    formaAbsoluto: 'lagun',
    casoCorrecto: CasoDeklinabidea.datiboa,
    fraseContexto: 'Liburua _____ eman diot.',
    traduccionEspanol: 'Le he dado el libro al amigo.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'lagunarekin',
    formaAbsoluto: 'lagun',
    casoCorrecto: CasoDeklinabidea.soziatiboa,
    fraseContexto: '_____ joan naiz.',
    traduccionEspanol: 'He ido con el amigo.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'Bilbon',
    formaAbsoluto: 'Bilbo',
    casoCorrecto: CasoDeklinabidea.inesiboa,
    fraseContexto: '_____ bizi naiz.',
    traduccionEspanol: 'Vivo en Bilbao.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'Donostiara',
    formaAbsoluto: 'Donostia',
    casoCorrecto: CasoDeklinabidea.adlatiboa,
    fraseContexto: 'Bihar _____ joango naiz.',
    traduccionEspanol: 'Mañana iré a Donostia.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'Gasteizetik',
    formaAbsoluto: 'Gasteiz',
    casoCorrecto: CasoDeklinabidea.ablatiboa,
    fraseContexto: '_____ etorri da trena.',
    traduccionEspanol: 'El tren ha venido desde Vitoria.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'amari',
    formaAbsoluto: 'ama',
    casoCorrecto: CasoDeklinabidea.datiboa,
    fraseContexto: 'Lorea _____ eman diot.',
    traduccionEspanol: 'Le he dado una flor a mamá.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'amak',
    formaAbsoluto: 'ama',
    casoCorrecto: CasoDeklinabidea.ergatiboa,
    fraseContexto: '_____ afaria prestatu du.',
    traduccionEspanol: 'Mamá ha preparado la cena.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'aitarentzat',
    formaAbsoluto: 'aita',
    casoCorrecto: CasoDeklinabidea.destinatiboa,
    fraseContexto: 'Oparia _____ da.',
    traduccionEspanol: 'El regalo es para papá.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'kafea',
    formaAbsoluto: 'kafe',
    casoCorrecto: CasoDeklinabidea.absolutiboa,
    fraseContexto: '_____ edaten dut goizean.',
    traduccionEspanol: 'Bebo café por la mañana.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'eskolara',
    formaAbsoluto: 'eskola',
    casoCorrecto: CasoDeklinabidea.adlatiboa,
    fraseContexto: 'Haurrak _____ doaz.',
    traduccionEspanol: 'Los niños van a la escuela.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'eskolan',
    formaAbsoluto: 'eskola',
    casoCorrecto: CasoDeklinabidea.inesiboa,
    fraseContexto: 'Irakaslea _____ dago.',
    traduccionEspanol: 'El profesor está en la escuela.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'irakaslearekin',
    formaAbsoluto: 'irakasle',
    casoCorrecto: CasoDeklinabidea.soziatiboa,
    fraseContexto: 'Ikaslea _____ hitz egiten ari da.',
    traduccionEspanol: 'El estudiante está hablando con el profesor.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'mendira',
    formaAbsoluto: 'mendi',
    casoCorrecto: CasoDeklinabidea.adlatiboa,
    fraseContexto: 'Igandean _____ goaz.',
    traduccionEspanol: 'El domingo vamos al monte.',
  ),
  RondaDeklinatzailea(
    palabraDeclinada: 'menditik',
    formaAbsoluto: 'mendi',
    casoCorrecto: CasoDeklinabidea.ablatiboa,
    fraseContexto: 'Nekatuta _____ jaitsi gara.',
    traduccionEspanol: 'Hemos bajado del monte cansados.',
  ),
];
