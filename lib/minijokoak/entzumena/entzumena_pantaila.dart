import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/euskarazko_ahotsa_abisua.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'entzumena_datuak.dart';

class EntzumenaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  const EntzumenaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
  });

  @override
  State<EntzumenaPantaila> createState() => _EntzumenaPantailaState();
}

class _EntzumenaPantailaState extends State<EntzumenaPantaila> {
  late final FlutterTts _tts;
  List<FraseEntzumena>? _rondasSeleccionadas;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  int _indiceRondaActual = 0;
  int _aciertos = 0;
  int _intentosTotales = 0;
  bool _reproduciendoAhora = false;
  List<String> _opcionesRondaActual = const <String>[];
  String? _opcionElegidaPorAlumno;
  bool _rondaResuelta = false;

  FraseEntzumena get _rondaActual => _rondasSeleccionadas![_indiceRondaActual];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _configurarTts();
  }

  void _empezarConNivel(NivelEuskera nivel) {
    setState(() {
      _nivelElegido = nivel;
      _momentoInicioPartida = DateTime.now();
      _rondasSeleccionadas = _seleccionarRondas(nivel);
    });
    _prepararRondaActual(reproducirAutomaticamente: true);
  }

  /// Configura el TTS para euskera (eu-ES). Si el sistema no tiene voz
  /// para euskera, internamente flutter_tts cae al locale por defecto.
  /// Lo notamos cuando la pronunciación suena "a español" — funciona
  /// igual pero pierde calidad. En Android pueden instalar la voz EUS
  /// desde Google TTS Settings; en web depende del navegador.
  Future<void> _configurarTts() async {
    await _tts.setLanguage('eu-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _reproduciendoAhora = false;
      });
    });
    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _reproduciendoAhora = false;
      });
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  List<FraseEntzumena> _seleccionarRondas(NivelEuskera nivelMax) {
    final List<FraseEntzumena> copia =
        List<FraseEntzumena>.of(frasesEntzumenaParaNivel(nivelMax))..shuffle();
    if (copia.length >= rondasPorPartidaEntzumena) {
      return copia.sublist(0, rondasPorPartidaEntzumena);
    }
    return copia;
  }

  void _prepararRondaActual({required bool reproducirAutomaticamente}) {
    final FraseEntzumena ronda = _rondaActual;
    final List<String> distractores =
        List<String>.from(ronda.distractoresEspanol)..shuffle();
    final List<String> opciones = <String>[
      ronda.traduccionCorrectaEspanol,
      ...distractores.take(opcionesPorRondaEntzumena - 1),
    ]..shuffle();
    setState(() {
      _opcionesRondaActual = opciones;
      _opcionElegidaPorAlumno = null;
      _rondaResuelta = false;
    });
    if (reproducirAutomaticamente) {
      // Pequeño retardo para que el setState propague la UI antes de
      // empezar a hablar — evita que el botón salte de estado al vuelo.
      Future<void>.delayed(const Duration(milliseconds: 350), _reproducir);
    }
  }

  Future<void> _reproducir() async {
    if (!mounted) return;
    await _tts.stop();
    setState(() {
      _reproduciendoAhora = true;
    });
    await _tts.speak(_rondaActual.fraseEuskera);
  }

  void _elegirOpcion(String opcion) {
    if (_rondaResuelta) return;
    final bool acierta = opcion == _rondaActual.traduccionCorrectaEspanol;
    setState(() {
      _opcionElegidaPorAlumno = opcion;
      _rondaResuelta = true;
      _intentosTotales += 1;
      if (acierta) {
        _aciertos += 1;
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 1900), _avanzarOTerminar);
  }

  void _avanzarOTerminar() {
    if (!mounted) return;
    final bool fueUltima =
        _indiceRondaActual >= _rondasSeleccionadas!.length - 1;
    if (fueUltima) {
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: _aciertos,
        intentosTotales: _intentosTotales,
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
        izenburuMinijokoa: 'Entzumena',
        alAukeratu: _empezarConNivel,
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 109,
          child: Column(
            children: <Widget>[
              _Cabecera(
                rondaActual: _indiceRondaActual + 1,
                rondasTotales: _rondasSeleccionadas!.length,
                aciertos: _aciertos,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
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
                          EuskarazkoAhotsaAbisua(tts: _tts),
                          const SizedBox(height: 24),
                          _GrupoOpciones(
                            opciones: _opcionesRondaActual,
                            opcionCorrecta:
                                _rondaActual.traduccionCorrectaEspanol,
                            opcionElegida: _opcionElegidaPorAlumno,
                            rondaResuelta: _rondaResuelta,
                            alElegir: _elegirOpcion,
                          ),
                          if (_rondaResuelta) ...<Widget>[
                            const SizedBox(height: 20),
                            _PistaFraseRevelada(
                              frase: _rondaActual.fraseEuskera,
                            ),
                          ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'ENTZUN ETA HAUTATU',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
                letterSpacing: 2.2,
              ),
            ),
          ),
          Text(
            '$rondaActual / $rondasTotales',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.check, color: PaletaAek.rojoRotulador, size: 20),
          const SizedBox(width: 4),
          Text(
            '$aciertos',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
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

  const _BotonReproducir({
    required this.reproduciendo,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPulsar,
      behavior: HitTestBehavior.opaque,
      child: MarcoRotulador(
        color: PaletaAek.rojoRotulador,
        grosor: 3.6,
        intensidadJitter: 1.4,
        child: Container(
          color: PaletaAek.papelViejo,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomPaint(
                size: const Size(36, 36),
                painter: _PintorOndasSonoras(activo: reproduciendo),
              ),
              const SizedBox(width: 14),
              Text(
                reproduciendo ? 'ENTZUTEN…' : 'ENTZUN',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: PaletaAek.rojoRotulador,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PintorOndasSonoras extends CustomPainter {
  final bool activo;
  _PintorOndasSonoras({required this.activo});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final Paint pincelRelleno = Paint()
      ..color = PaletaAek.rojoRotulador
      ..style = PaintingStyle.fill;
    final Paint pincelTrazo = Paint()
      ..color = PaletaAek.rojoRotulador
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    // Altavoz triangular sólido.
    final Path altavoz = Path()
      ..moveTo(centro.dx - 8, centro.dy - 6)
      ..lineTo(centro.dx - 2, centro.dy - 6)
      ..lineTo(centro.dx + 4, centro.dy - 10)
      ..lineTo(centro.dx + 4, centro.dy + 10)
      ..lineTo(centro.dx - 2, centro.dy + 6)
      ..lineTo(centro.dx - 8, centro.dy + 6)
      ..close();
    canvas.drawPath(altavoz, pincelRelleno);

    // Ondas sonoras (más onda si activo).
    for (int indiceOnda = 1; indiceOnda <= (activo ? 3 : 2); indiceOnda++) {
      final double radio = 6.0 + indiceOnda * 4.5;
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(centro.dx + 5, centro.dy), radius: radio),
        -math.pi / 4,
        math.pi / 2,
        false,
        pincelTrazo,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorOndasSonoras viejo) =>
      viejo.activo != activo;
}

class _GrupoOpciones extends StatelessWidget {
  final List<String> opciones;
  final String opcionCorrecta;
  final String? opcionElegida;
  final bool rondaResuelta;
  final void Function(String) alElegir;

  const _GrupoOpciones({
    required this.opciones,
    required this.opcionCorrecta,
    required this.opcionElegida,
    required this.rondaResuelta,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: opciones.map((String opcion) {
        final bool resaltadaCorrecta =
            rondaResuelta && opcion == opcionCorrecta;
        final bool resaltadaErronea = rondaResuelta &&
            opcion == opcionElegida &&
            opcion != opcionCorrecta;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _BotonOpcion(
            texto: opcion,
            resaltadaCorrecta: resaltadaCorrecta,
            resaltadaErronea: resaltadaErronea,
            pulsable: !rondaResuelta,
            alPulsar: () => alElegir(opcion),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _BotonOpcion extends StatelessWidget {
  final String texto;
  final bool resaltadaCorrecta;
  final bool resaltadaErronea;
  final bool pulsable;
  final VoidCallback alPulsar;

  const _BotonOpcion({
    required this.texto,
    required this.resaltadaCorrecta,
    required this.resaltadaErronea,
    required this.pulsable,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = resaltadaCorrecta
        ? PaletaAek.rojoRotulador
        : resaltadaErronea
            ? PaletaAek.tintaDiluida(0.45)
            : PaletaAek.tintaNegra;
    return Opacity(
      opacity: !pulsable && !resaltadaCorrecta && !resaltadaErronea
          ? 0.55
          : 1.0,
      child: GestureDetector(
        onTap: pulsable ? alPulsar : null,
        behavior: HitTestBehavior.opaque,
        child: MarcoRotulador(
          color: color,
          grosor: resaltadaCorrecta ? 3.2 : 2.4,
          intensidadJitter: 1.1,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            width: double.infinity,
            child: Text(
              texto,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PistaFraseRevelada extends StatelessWidget {
  final String frase;
  const _PistaFraseRevelada({required this.frase});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'ENTZUN DUZUNA:',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.6),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          frase,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ],
    );
  }
}
