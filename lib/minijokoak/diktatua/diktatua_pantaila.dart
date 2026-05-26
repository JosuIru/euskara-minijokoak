import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import '../entzumena/entzumena_datuak.dart';

/// Cuántas frases componen una partida de dictado.
const int _rondasPorPartida = 6;

/// Umbral de palabras acertadas para considerar la frase como un
/// "acierto" en el [ResultadoAriketa]. 0.7 deja margen para errores
/// ortográficos puntuales pero exige captar la frase entera.
const double _umbralAciertoPorFrase = 0.7;

class DiktatuaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  /// Frases precargadas. Si se aportan, se salta el selector de nivel y
  /// se arranca directamente con estas frases (modo "sortua").
  final List<FraseEntzumena>? frasesPredefinidas;

  const DiktatuaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
    this.frasesPredefinidas,
  });

  @override
  State<DiktatuaPantaila> createState() => _DiktatuaPantailaState();
}

class _DiktatuaPantailaState extends State<DiktatuaPantaila> {
  late final FlutterTts _tts;
  final TextEditingController _controladorTexto = TextEditingController();
  final FocusNode _focoTexto = FocusNode();
  List<FraseEntzumena>? _rondasSeleccionadas;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  int _indiceRondaActual = 0;
  int _aciertosFrases = 0;
  bool _reproduciendoAhora = false;
  bool _comprobado = false;
  _ResultadoCorreccion? _ultimoResultado;

  FraseEntzumena get _rondaActual => _rondasSeleccionadas![_indiceRondaActual];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _configurarTts();
    if (widget.frasesPredefinidas != null &&
        widget.frasesPredefinidas!.isNotEmpty) {
      _nivelElegido = NivelEuskera.c1;
      _momentoInicioPartida = DateTime.now();
      _rondasSeleccionadas =
          List<FraseEntzumena>.of(widget.frasesPredefinidas!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prepararRondaActual(reproducirAutomaticamente: true);
      });
    }
  }

  Future<void> _configurarTts() async {
    await _tts.setLanguage('eu-ES');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _reproduciendoAhora = false);
    });
    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _reproduciendoAhora = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _controladorTexto.dispose();
    _focoTexto.dispose();
    super.dispose();
  }

  void _empezarConNivel(NivelEuskera nivel) {
    setState(() {
      _nivelElegido = nivel;
      _momentoInicioPartida = DateTime.now();
      _rondasSeleccionadas = _seleccionarRondas(nivel);
    });
    _prepararRondaActual(reproducirAutomaticamente: true);
  }

  List<FraseEntzumena> _seleccionarRondas(NivelEuskera nivelMax) {
    final List<FraseEntzumena> copia =
        List<FraseEntzumena>.of(frasesEntzumenaParaNivel(nivelMax))..shuffle();
    if (copia.length >= _rondasPorPartida) {
      return copia.sublist(0, _rondasPorPartida);
    }
    return copia;
  }

  void _prepararRondaActual({required bool reproducirAutomaticamente}) {
    setState(() {
      _controladorTexto.clear();
      _comprobado = false;
      _ultimoResultado = null;
    });
    if (reproducirAutomaticamente) {
      Future<void>.delayed(const Duration(milliseconds: 350), _reproducir);
    }
  }

  Future<void> _reproducir() async {
    if (!mounted) return;
    await _tts.stop();
    setState(() => _reproduciendoAhora = true);
    await _tts.speak(_rondaActual.fraseEuskera);
  }

  void _egiaztatu() {
    if (_comprobado) return;
    final _ResultadoCorreccion resultado =
        _compararFrase(_controladorTexto.text, _rondaActual.fraseEuskera);
    setState(() {
      _comprobado = true;
      _ultimoResultado = resultado;
      if (resultado.proporcionAciertos >= _umbralAciertoPorFrase) {
        _aciertosFrases += 1;
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 2400), _avanzarOTerminar);
  }

  void _avanzarOTerminar() {
    if (!mounted) return;
    final bool fueUltima =
        _indiceRondaActual >= _rondasSeleccionadas!.length - 1;
    if (fueUltima) {
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: _aciertosFrases,
        intentosTotales: _rondasSeleccionadas!.length,
        tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
      ));
      return;
    }
    setState(() {
      _indiceRondaActual += 1;
    });
    _prepararRondaActual(reproducirAutomaticamente: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null || _rondasSeleccionadas == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Diktatua',
        alAukeratu: _empezarConNivel,
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 137,
          child: Column(
            children: <Widget>[
              _Cabecera(
                rondaActual: _indiceRondaActual + 1,
                rondasTotales: _rondasSeleccionadas!.length,
                aciertos: _aciertosFrases,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _BotonReproducir(
                            reproduciendo: _reproduciendoAhora,
                            alPulsar: _reproducir,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sakatu botoia berriz entzuteko.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: PaletaAek.tintaDiluida(0.55),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _CampoDictado(
                            controlador: _controladorTexto,
                            foco: _focoTexto,
                            desactivado: _comprobado,
                          ),
                          const SizedBox(height: 16),
                          if (!_comprobado)
                            _BotonEgiaztatu(alPulsar: _egiaztatu)
                          else
                            _PanelCorreccion(
                              esperada: _rondaActual.fraseEuskera,
                              traduccion:
                                  _rondaActual.traduccionCorrectaEspanol,
                              resultado: _ultimoResultado!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Comparación palabra a palabra entre lo que escribió el alumno y la
/// frase esperada. Normaliza minúsculas + quita puntuación de borde.
/// Devuelve la lista de palabras esperadas con su estado y la
/// proporción de aciertos sobre el total esperado.
_ResultadoCorreccion _compararFrase(String escrito, String esperada) {
  final List<String> palabrasEscritas = _tokenizarSimple(escrito);
  final List<String> palabrasEsperadas = _tokenizarSimple(esperada);
  final List<_PalabraEsperada> resultado = <_PalabraEsperada>[];
  int aciertos = 0;
  for (int indice = 0; indice < palabrasEsperadas.length; indice++) {
    final String objetivo = palabrasEsperadas[indice];
    final String? recibida =
        indice < palabrasEscritas.length ? palabrasEscritas[indice] : null;
    final bool acertada = recibida != null &&
        _normalizar(recibida) == _normalizar(objetivo);
    if (acertada) aciertos += 1;
    resultado.add(_PalabraEsperada(
      esperada: objetivo,
      escrita: recibida,
      acertada: acertada,
    ));
  }
  final List<String> sobrantes = palabrasEscritas.length > palabrasEsperadas.length
      ? palabrasEscritas.sublist(palabrasEsperadas.length)
      : const <String>[];
  return _ResultadoCorreccion(
    palabras: resultado,
    sobrantes: sobrantes,
    proporcionAciertos:
        palabrasEsperadas.isEmpty ? 0 : aciertos / palabrasEsperadas.length,
  );
}

List<String> _tokenizarSimple(String texto) {
  final String normalizado = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalizado.isEmpty) return const <String>[];
  return normalizado.split(' ');
}

String _normalizar(String palabra) {
  const String signosBorde = '.,;:!?()[]{}«»"\'`…¿¡';
  String resultado = palabra.toLowerCase();
  while (resultado.isNotEmpty && signosBorde.contains(resultado[0])) {
    resultado = resultado.substring(1);
  }
  while (resultado.isNotEmpty &&
      signosBorde.contains(resultado[resultado.length - 1])) {
    resultado = resultado.substring(0, resultado.length - 1);
  }
  return resultado;
}

class _PalabraEsperada {
  final String esperada;
  final String? escrita;
  final bool acertada;

  const _PalabraEsperada({
    required this.esperada,
    required this.escrita,
    required this.acertada,
  });
}

class _ResultadoCorreccion {
  final List<_PalabraEsperada> palabras;
  final List<String> sobrantes;
  final double proporcionAciertos;

  const _ResultadoCorreccion({
    required this.palabras,
    required this.sobrantes,
    required this.proporcionAciertos,
  });
}

class _Cabecera extends StatelessWidget {
  final int rondaActual;
  final int rondasTotales;
  final int aciertos;

  const _Cabecera({
    required this.rondaActual,
    required this.rondasTotales,
    required this.aciertos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          const Expanded(
            child: Text(
              'DIKTATUA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: PaletaAek.tintaNegra,
              ),
            ),
          ),
          Text(
            '$rondaActual / $rondasTotales',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.check, color: PaletaAek.rojoRotulador, size: 18),
          const SizedBox(width: 3),
          Text(
            '$aciertos',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonReproducir extends StatelessWidget {
  final bool reproduciendo;
  final VoidCallback alPulsar;

  const _BotonReproducir({required this.reproduciendo, required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: alPulsar,
        behavior: HitTestBehavior.opaque,
        child: MarcoRotulador(
          color: PaletaAek.rojoRotulador,
          grosor: 3.4,
          intensidadJitter: 1.5,
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            color: PaletaAek.papelViejo,
            child: Icon(
              reproduciendo ? Icons.volume_up : Icons.play_arrow,
              size: 60,
              color: PaletaAek.rojoRotulador,
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoDictado extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode foco;
  final bool desactivado;

  const _CampoDictado({
    required this.controlador,
    required this.foco,
    required this.desactivado,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      focusNode: foco,
      enabled: !desactivado,
      minLines: 2,
      maxLines: 4,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 18,
        color: PaletaAek.tintaNegra,
      ),
      decoration: InputDecoration(
        hintText: 'Idatzi hemen entzun duzuna…',
        hintStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          color: PaletaAek.tintaDiluida(0.45),
          fontStyle: FontStyle.italic,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PaletaAek.tintaNegra, width: 1.6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PaletaAek.rojoRotulador, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide:
              BorderSide(color: PaletaAek.tintaDiluida(0.4), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _BotonEgiaztatu extends StatelessWidget {
  final VoidCallback alPulsar;
  const _BotonEgiaztatu({required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: alPulsar,
        behavior: HitTestBehavior.opaque,
        child: MarcoRotulador(
          color: PaletaAek.rojoRotulador,
          grosor: 3.2,
          intensidadJitter: 1.3,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: const Text(
              'EGIAZTATU',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: PaletaAek.rojoRotulador,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelCorreccion extends StatelessWidget {
  final String esperada;
  final String traduccion;
  final _ResultadoCorreccion resultado;

  const _PanelCorreccion({
    required this.esperada,
    required this.traduccion,
    required this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    final int porcentaje = (resultado.proporcionAciertos * 100).round();
    final bool aprobado =
        resultado.proporcionAciertos >= _umbralAciertoPorFrase;
    final Color colorMarco =
        aprobado ? PaletaAek.rojoRotulador : PaletaAek.tintaDiluida(0.55);
    return MarcoRotulador(
      color: colorMarco,
      grosor: aprobado ? 3.2 : 2.2,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  aprobado ? Icons.check_circle : Icons.error_outline,
                  color: colorMarco,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  aprobado ? 'ONDO!' : 'BERRIRO',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2,
                    color: colorMarco,
                  ),
                ),
                const Spacer(),
                Text(
                  '$porcentaje%',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorMarco,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'JATORRIZKOA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: PaletaAek.tintaDiluida(0.6),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            _FraseDiff(palabras: resultado.palabras),
            if (resultado.sobrantes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'GEHIEGI: ${resultado.sobrantes.join(' ')}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: PaletaAek.tintaDiluida(0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (traduccion.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                traduccion,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: PaletaAek.tintaDiluida(0.65),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FraseDiff extends StatelessWidget {
  final List<_PalabraEsperada> palabras;

  const _FraseDiff({required this.palabras});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: palabras.map((_PalabraEsperada p) {
        final Color color = p.acertada
            ? PaletaAek.tintaNegra
            : PaletaAek.rojoRotulador;
        final TextDecoration decoracion = p.acertada
            ? TextDecoration.none
            : TextDecoration.underline;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              p.esperada,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight:
                    p.acertada ? FontWeight.normal : FontWeight.w900,
                color: color,
                decoration: decoracion,
                decorationColor: PaletaAek.rojoRotulador,
              ),
            ),
            if (!p.acertada && p.escrita != null)
              Text(
                p.escrita!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: PaletaAek.tintaDiluida(0.55),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        );
      }).toList(growable: false),
    );
  }
}
