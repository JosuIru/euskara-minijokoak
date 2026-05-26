import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'aditzen_tailerra_datuak.dart';
import 'aditzen_tailerra_plantillak.dart';

const int _rondasPorPartida = 10;
const int _vidasIniciales = 3;
const int _opcionesPorRonda = 4;

class AditzenTailerraPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  const AditzenTailerraPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
  });

  @override
  State<AditzenTailerraPantaila> createState() =>
      _AditzenTailerraPantailaState();
}

class _AditzenTailerraPantailaState extends State<AditzenTailerraPantaila> {
  List<RondaAditza>? _rondasSeleccionadas;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  int _indiceRondaActual = 0;
  int _vidasRestantes = _vidasIniciales;
  int _aciertos = 0;
  int _intentosTotales = 0;
  List<String> _opcionesRondaActual = const <String>[];
  String? _opcionElegidaPorAlumno;
  bool _rondaResuelta = false;

  RondaAditza get _rondaActual => _rondasSeleccionadas![_indiceRondaActual];

  void _empezarConNivel(NivelEuskera nivel) {
    setState(() {
      _nivelElegido = nivel;
      _momentoInicioPartida = DateTime.now();
      _rondasSeleccionadas = _seleccionarRondas(nivel);
    });
    _prepararRondaActual();
  }

  List<RondaAditza> _seleccionarRondas(NivelEuskera nivelMax) {
    return generarRondasProcedimentalmenteAditza(
      cantidad: _rondasPorPartida,
      semilla: DateTime.now().millisecondsSinceEpoch,
      nivelMax: nivelMax,
    );
  }

  void _prepararRondaActual() {
    final RondaAditza ronda = _rondaActual;
    final List<String> distractores = generarDistractores(
      verbo: ronda.verbo,
      pronombreCorrecto: ronda.pronombre,
      cantidadDistractores: _opcionesPorRonda - 1,
      aldia: ronda.aldia,
    );
    final List<String> opciones = <String>[
      ronda.formaCorrecta,
      ...distractores,
    ]..shuffle();
    setState(() {
      _opcionesRondaActual = opciones;
      _opcionElegidaPorAlumno = null;
      _rondaResuelta = false;
    });
  }

  void _elegirOpcion(String opcion) {
    if (_rondaResuelta) return;
    final bool acierta = opcion == _rondaActual.formaCorrecta;
    setState(() {
      _opcionElegidaPorAlumno = opcion;
      _rondaResuelta = true;
      _intentosTotales += 1;
      if (acierta) {
        _aciertos += 1;
      } else {
        _vidasRestantes = (_vidasRestantes - 1).clamp(0, _vidasIniciales);
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 1700), _avanzarOTerminar);
  }

  void _avanzarOTerminar() {
    if (!mounted) return;
    final bool sinVidas = _vidasRestantes <= 0;
    final bool fueUltimaRonda =
        _indiceRondaActual >= _rondasSeleccionadas!.length - 1;
    if (sinVidas || fueUltimaRonda) {
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
    _prepararRondaActual();
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null || _rondasSeleccionadas == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Aditzen Tailerra',
        alAukeratu: _empezarConNivel,
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 23,
          child: Column(
            children: <Widget>[
              _BarraEstadoSuperior(
                vidasRestantes: _vidasRestantes,
                rondaActual: _indiceRondaActual + 1,
                rondasTotales: _rondasSeleccionadas!.length,
                aciertos: _aciertos,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Column(
                          children: <Widget>[
                            _TarjetaPrescripcion(ronda: _rondaActual),
                            const SizedBox(height: 18),
                            _FraseContextoTaller(ronda: _rondaActual),
                            const SizedBox(height: 18),
                            _RejillaOpciones(
                              opciones: _opcionesRondaActual,
                              opcionCorrecta: _rondaActual.formaCorrecta,
                              opcionElegida: _opcionElegidaPorAlumno,
                              rondaResuelta: _rondaResuelta,
                              alElegir: _elegirOpcion,
                            ),
                            if (_rondaResuelta) ...<Widget>[
                              const SizedBox(height: 14),
                              _FeedbackTaller(
                                acertado: _opcionElegidaPorAlumno ==
                                    _rondaActual.formaCorrecta,
                                formaCorrecta: _rondaActual.formaCorrecta,
                              ),
                            ],
                          ],
                        ),
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

class _BarraEstadoSuperior extends StatelessWidget {
  final int vidasRestantes;
  final int rondaActual;
  final int rondasTotales;
  final int aciertos;

  const _BarraEstadoSuperior({
    required this.vidasRestantes,
    required this.rondaActual,
    required this.rondasTotales,
    required this.aciertos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(_vidasIniciales, (indice) {
                  final bool sigueViva = indice < vidasRestantes;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: CustomPaint(
                      size: const Size(26, 26),
                      painter: _PintorEstrellaVida(activa: sigueViva),
                    ),
                  );
                }),
              ),
            ),
          ),
          Text(
            '$rondaActual / $rondasTotales',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: PaletaAek.tintaNegra,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.check, color: PaletaAek.rojoRotulador, size: 20),
              const SizedBox(width: 4),
              Text(
                '$aciertos',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: PaletaAek.tintaNegra,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PintorEstrellaVida extends CustomPainter {
  final bool activa;
  _PintorEstrellaVida({required this.activa});

  @override
  void paint(Canvas canvas, Size size) {
    final Color color = activa
        ? PaletaAek.rojoRotulador
        : PaletaAek.tintaDiluida(0.25);
    final Paint pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    estrellaRotulador(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width * 0.42,
      pincel: pincel,
      intensidadJitter: 0.7,
      semilla: 21,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorEstrellaVida viejo) =>
      viejo.activa != activa;
}

/// Tarjeta con la "receta" de la conjugación: pronombre + flecha + verbo.
/// El bloque grande visual que diferencia este minijuego del Deklinatzailea.
class _TarjetaPrescripcion extends StatelessWidget {
  final RondaAditza ronda;
  const _TarjetaPrescripcion({required this.ronda});

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 3,
      intensidadJitter: 1.4,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _CajaTermino(
                tituloPequeno: 'NORK',
                contenido: ronda.pronombre.formaEuskera,
                subtituloTraduccion: ronda.pronombre.traduccionEspanol,
              ),
            ),
            const _FlechaEntreCajas(),
            Expanded(
              child: _CajaTermino(
                tituloPequeno: 'ADITZA',
                contenido: ronda.verbo.infinitivo,
                subtituloTraduccion: ronda.verbo.traduccionEspanol,
                acentuada: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CajaTermino extends StatelessWidget {
  final String tituloPequeno;
  final String contenido;
  final String subtituloTraduccion;
  final bool acentuada;

  const _CajaTermino({
    required this.tituloPequeno,
    required this.contenido,
    required this.subtituloTraduccion,
    this.acentuada = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorContenido =
        acentuada ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra;
    return Column(
      children: <Widget>[
        Text(
          tituloPequeno,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: PaletaAek.tintaDiluida(0.6),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          contenido,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: colorContenido,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtituloTraduccion,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: PaletaAek.tintaDiluida(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _FlechaEntreCajas extends StatelessWidget {
  const _FlechaEntreCajas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomPaint(painter: _PintorFlecha()),
    );
  }
}

class _PintorFlecha extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint pincel = Paint()
      ..color = PaletaAek.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final double medioAlto = size.height / 2;
    final Offset inicio = Offset(4, medioAlto);
    final Offset finPunta = Offset(size.width - 4, medioAlto);
    trazoTembloroso(canvas, inicio, finPunta,
        pincel: pincel, intensidadJitter: 1.0, segmentos: 6, semilla: 5);
    // Punta de flecha.
    final Offset puntaArriba =
        Offset(size.width - 12, medioAlto - 8);
    final Offset puntaAbajo =
        Offset(size.width - 12, medioAlto + 8);
    trazoTembloroso(canvas, puntaArriba, finPunta,
        pincel: pincel, intensidadJitter: 0.7, segmentos: 3, semilla: 7);
    trazoTembloroso(canvas, puntaAbajo, finPunta,
        pincel: pincel, intensidadJitter: 0.7, segmentos: 3, semilla: 9);
  }

  @override
  bool shouldRepaint(covariant _PintorFlecha oldDelegate) => false;
}

class _FraseContextoTaller extends StatelessWidget {
  final RondaAditza ronda;
  const _FraseContextoTaller({required this.ronda});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: PaletaAek.rojoRotulador, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ronda.fraseContextoConHueco,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ronda.traduccionEspanol,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: PaletaAek.tintaDiluida(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4 botones en rejilla 2×2 — distinto layout que la fila inferior de
/// Deklinatzailea, para reforzar la sensación de "minijuego distinto".
class _RejillaOpciones extends StatelessWidget {
  final List<String> opciones;
  final String opcionCorrecta;
  final String? opcionElegida;
  final bool rondaResuelta;
  final void Function(String) alElegir;

  const _RejillaOpciones({
    required this.opciones,
    required this.opcionCorrecta,
    required this.opcionElegida,
    required this.rondaResuelta,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 3.6,
      children: opciones.map((String opcion) {
        final bool esCorrectaResaltada = rondaResuelta && opcion == opcionCorrecta;
        final bool esElegidaErronea = rondaResuelta &&
            opcion == opcionElegida &&
            opcion != opcionCorrecta;
        return _BotonOpcion(
          texto: opcion,
          resaltadaComoCorrecta: esCorrectaResaltada,
          resaltadaComoErronea: esElegidaErronea,
          pulsable: !rondaResuelta,
          alPulsar: () => alElegir(opcion),
        );
      }).toList(growable: false),
    );
  }
}

class _BotonOpcion extends StatelessWidget {
  final String texto;
  final bool resaltadaComoCorrecta;
  final bool resaltadaComoErronea;
  final bool pulsable;
  final VoidCallback alPulsar;

  const _BotonOpcion({
    required this.texto,
    required this.resaltadaComoCorrecta,
    required this.resaltadaComoErronea,
    required this.pulsable,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorMarco = resaltadaComoCorrecta
        ? PaletaAek.rojoRotulador
        : resaltadaComoErronea
            ? PaletaAek.tintaDiluida(0.4)
            : PaletaAek.tintaNegra;
    return Opacity(
      opacity: !pulsable && !resaltadaComoCorrecta && !resaltadaComoErronea
          ? 0.45
          : 1.0,
      child: GestureDetector(
        onTap: pulsable ? alPulsar : null,
        child: MarcoRotulador(
          color: colorMarco,
          grosor: resaltadaComoCorrecta ? 3.2 : 2.4,
          intensidadJitter: 1.2,
          child: Container(
            color: PaletaAek.papelViejo,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              texto,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: colorMarco,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackTaller extends StatelessWidget {
  final bool acertado;
  final String formaCorrecta;

  const _FeedbackTaller({required this.acertado, required this.formaCorrecta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          acertado ? 'BIKAIN!' : 'EZ DA HORI',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: acertado ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra,
          ),
        ),
        const SizedBox(height: 4),
        if (!acertado)
          Text(
            'Forma zuzena: $formaCorrecta',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: PaletaAek.tintaDiluida(0.7),
            ),
          ),
      ],
    );
  }
}
