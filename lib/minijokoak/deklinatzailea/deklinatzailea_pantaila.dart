import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'deklinatzailea_datuak.dart';
import 'deklinatzailea_plantillak.dart';

/// Configuración del juego: número de rondas y vidas iniciales.
const int _rondasPorPartida = 10;
const int _vidasIniciales = 3;
const int _opcionesPorRonda = 4;

/// Duración de la caída de cada palabra. A mayor duración, más fácil:
/// el alumno tiene más tiempo para leer la frase y razonar el caso.
const Duration _duracionCaida = Duration(seconds: 7);

/// Resultado de una ronda concreta — se usa para acumular estadísticas.
enum _ResultadoRonda { acierto, fallo, tiempoAgotado }

class DeklinatzaileaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  const DeklinatzaileaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
  });

  @override
  State<DeklinatzaileaPantaila> createState() => _DeklinatzaileaPantailaState();
}

class _DeklinatzaileaPantailaState extends State<DeklinatzaileaPantaila>
    with SingleTickerProviderStateMixin {
  AnimationController? _controladorCaida;
  List<RondaDeklinatzailea>? _rondasSeleccionadas;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  int _indiceRondaActual = 0;
  int _vidasRestantes = _vidasIniciales;
  int _aciertos = 0;
  int _intentosTotales = 0;
  List<CasoDeklinabidea> _cestasRondaActual = const <CasoDeklinabidea>[];
  CasoDeklinabidea? _casoElegidoPorAlumno;
  bool _rondaResuelta = false;

  RondaDeklinatzailea get _rondaActual =>
      _rondasSeleccionadas![_indiceRondaActual];

  @override
  void dispose() {
    _controladorCaida?.dispose();
    super.dispose();
  }

  /// Arranca la partida después de que el alumno elige nivel MCER.
  void _empezarConNivel(NivelEuskera nivel) {
    setState(() {
      _nivelElegido = nivel;
      _momentoInicioPartida = DateTime.now();
      _rondasSeleccionadas = _seleccionarRondas(nivel);
      _controladorCaida = AnimationController(
        vsync: this,
        duration: _duracionCaida,
      )..addStatusListener(_alCambiarEstadoCaida);
    });
    _prepararRondaActual();
  }

  /// Genera 10 rondas únicas combinando plantillas de frase × palabras
  /// del banco filtradas por el [nivelMax] elegido.
  List<RondaDeklinatzailea> _seleccionarRondas(NivelEuskera nivelMax) {
    return generarRondasProcedimentalmente(
      cantidad: _rondasPorPartida,
      semilla: DateTime.now().millisecondsSinceEpoch,
      nivelMax: nivelMax,
    );
  }

  /// Prepara la siguiente ronda: elige distractores y arranca la caída.
  void _prepararRondaActual() {
    final RondaDeklinatzailea ronda = _rondaActual;
    final List<CasoDeklinabidea> distractoresPosibles = CasoDeklinabidea.values
        .where((caso) => caso != ronda.casoCorrecto)
        .toList()
      ..shuffle();
    final List<CasoDeklinabidea> cestas = <CasoDeklinabidea>[
      ronda.casoCorrecto,
      ...distractoresPosibles.take(_opcionesPorRonda - 1),
    ]..shuffle();
    setState(() {
      _cestasRondaActual = cestas;
      _casoElegidoPorAlumno = null;
      _rondaResuelta = false;
    });
    _controladorCaida!
      ..reset()
      ..forward();
  }

  void _alCambiarEstadoCaida(AnimationStatus estado) {
    if (estado == AnimationStatus.completed && !_rondaResuelta) {
      _resolverRonda(null, _ResultadoRonda.tiempoAgotado);
    }
  }

  /// El alumno toca una cesta — comprobamos si es la correcta.
  void _seleccionarCesta(CasoDeklinabidea cesta) {
    if (_rondaResuelta) return;
    final bool acierta = cesta == _rondaActual.casoCorrecto;
    _resolverRonda(
      cesta,
      acierta ? _ResultadoRonda.acierto : _ResultadoRonda.fallo,
    );
  }

  void _resolverRonda(CasoDeklinabidea? eleccion, _ResultadoRonda resultado) {
    _controladorCaida?.stop();
    setState(() {
      _casoElegidoPorAlumno = eleccion;
      _rondaResuelta = true;
      _intentosTotales += 1;
      if (resultado == _ResultadoRonda.acierto) {
        _aciertos += 1;
      } else {
        _vidasRestantes = math.max(0, _vidasRestantes - 1);
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 1600), _avanzarOTerminar);
  }

  void _avanzarOTerminar() {
    if (!mounted) return;
    final bool sinVidas = _vidasRestantes <= 0;
    final bool fueUltimaRonda =
        _indiceRondaActual >= _rondasSeleccionadas!.length - 1;
    if (sinVidas || fueUltimaRonda) {
      _terminarPartida();
      return;
    }
    setState(() {
      _indiceRondaActual += 1;
    });
    _prepararRondaActual();
  }

  void _terminarPartida() {
    final ResultadoAriketa resultado = ResultadoAriketa(
      identificadorAriketa: widget.identificadorAriketa,
      momentoFin: DateTime.now(),
      aciertos: _aciertos,
      intentosTotales: _intentosTotales,
      tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
    );
    widget.amaitzean(resultado);
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null || _rondasSeleccionadas == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Deklinatzailea',
        alAukeratu: _empezarConNivel,
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 7,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  _BarraEstadoSuperior(
                    vidasRestantes: _vidasRestantes,
                    rondaActual: _indiceRondaActual + 1,
                    rondasTotales: _rondasSeleccionadas!.length,
                    aciertos: _aciertos,
                  ),
                  _PanelFraseContexto(ronda: _rondaActual),
                  Expanded(
                    child: _ZonaDeCaida(
                      ronda: _rondaActual,
                      controladorCaida: _controladorCaida!,
                      rondaResuelta: _rondaResuelta,
                      casoElegido: _casoElegidoPorAlumno,
                    ),
                  ),
                  _FilaDeCestas(
                    cestas: _cestasRondaActual,
                    casoCorrecto: _rondaActual.casoCorrecto,
                    casoElegido: _casoElegidoPorAlumno,
                    rondaResuelta: _rondaResuelta,
                    alSeleccionar: _seleccionarCesta,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera con vidas (estampillas rojas), ronda actual y aciertos.
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          BackButton(color: PaletaAek.tintaNegra),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _IndicadorVidas(vidasRestantes: vidasRestantes),
              ],
            ),
          ),
          Text(
            '$rondaActual / $rondasTotales',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: PaletaAek.tintaNegra,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.star, color: PaletaAek.rojoRotulador, size: 22),
                const SizedBox(width: 4),
                Text(
                  '$aciertos',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: PaletaAek.tintaNegra,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadorVidas extends StatelessWidget {
  final int vidasRestantes;
  const _IndicadorVidas({required this.vidasRestantes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(_vidasIniciales, (indice) {
        final bool sigueViva = indice < vidasRestantes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: CustomPaint(
            size: const Size(28, 28),
            painter: _PintorCorazonRotulador(activo: sigueViva),
          ),
        );
      }),
    );
  }
}

class _PintorCorazonRotulador extends CustomPainter {
  final bool activo;
  _PintorCorazonRotulador({required this.activo});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final Color color = activo
        ? PaletaAek.rojoRotulador
        : PaletaAek.tintaDiluida(0.25);
    final Paint pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    estrellaRotulador(canvas, centro, size.width * 0.42,
        pincel: pincel, intensidadJitter: 0.7, semilla: 13);
  }

  @override
  bool shouldRepaint(covariant _PintorCorazonRotulador viejo) =>
      viejo.activo != activo;
}

/// Tarjeta con la frase de contexto (con hueco) y su traducción.
class _PanelFraseContexto extends StatelessWidget {
  final RondaDeklinatzailea ronda;
  const _PanelFraseContexto({required this.ronda});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: MarcoRotulador(
        intensidadJitter: 1.1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                ronda.fraseContexto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  color: PaletaAek.tintaNegra,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ronda.traduccionEspanol,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: PaletaAek.tintaDiluida(0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zona central donde cae la palabra declinada. Mientras la animación
/// avanza, la palabra desciende. Cuando se resuelve la ronda se queda
/// quieta y aparece el feedback.
class _ZonaDeCaida extends StatelessWidget {
  final RondaDeklinatzailea ronda;
  final AnimationController controladorCaida;
  final bool rondaResuelta;
  final CasoDeklinabidea? casoElegido;

  const _ZonaDeCaida({
    required this.ronda,
    required this.controladorCaida,
    required this.rondaResuelta,
    required this.casoElegido,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controladorCaida,
      builder: (BuildContext context, Widget? hijoFijo) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const double margenSuperior = 8;
            const double margenInferior = 24;
            final double alturaDisponible =
                constraints.maxHeight - margenSuperior - margenInferior - 64;
            final double progresoEfectivo = rondaResuelta
                ? controladorCaida.value
                : controladorCaida.value;
            final double posicionY =
                margenSuperior + alturaDisponible * progresoEfectivo;

            return Stack(
              children: <Widget>[
                // Pista de caída: una guía vertical tenue.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PintorPistaDeCaida(),
                  ),
                ),
                Positioned(
                  top: posicionY,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _TarjetaPalabra(
                      palabra: ronda.palabraDeclinada,
                      resaltada: rondaResuelta,
                    ),
                  ),
                ),
                if (rondaResuelta)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _FeedbackInline(
                        casoCorrecto: ronda.casoCorrecto,
                        casoElegido: casoElegido,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PintorPistaDeCaida extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint pincel = Paint()
      ..color = PaletaAek.tintaDiluida(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final double centroX = size.width / 2;
    trazoTembloroso(
      canvas,
      Offset(centroX, 0),
      Offset(centroX, size.height),
      pincel: pincel,
      intensidadJitter: 1.8,
      segmentos: 24,
      semilla: 99,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorPistaDeCaida oldDelegate) => false;
}

class _TarjetaPalabra extends StatelessWidget {
  final String palabra;
  final bool resaltada;
  const _TarjetaPalabra({required this.palabra, required this.resaltada});

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      color: resaltada ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra,
      grosor: 3,
      intensidadJitter: 1.4,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Text(
          palabra,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: resaltada
                ? PaletaAek.rojoRotulador
                : PaletaAek.tintaNegra,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _FeedbackInline extends StatelessWidget {
  final CasoDeklinabidea casoCorrecto;
  final CasoDeklinabidea? casoElegido;

  const _FeedbackInline({required this.casoCorrecto, required this.casoElegido});

  @override
  Widget build(BuildContext context) {
    final bool acertado = casoElegido == casoCorrecto;
    final String mensaje = acertado
        ? 'BIKAIN!'
        : casoElegido == null
            ? 'DENBORA AGORTUTA'
            : 'EZ DA HORI';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensaje,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: acertado
                  ? PaletaAek.rojoRotulador
                  : PaletaAek.tintaNegra,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Erantzun zuzena: ${casoCorrecto.laburpena} '
            '(${casoCorrecto.izenOsoa})',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: PaletaAek.tintaDiluida(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Fila inferior con las 4 cestas (casos disponibles esta ronda).
class _FilaDeCestas extends StatelessWidget {
  final List<CasoDeklinabidea> cestas;
  final CasoDeklinabidea casoCorrecto;
  final CasoDeklinabidea? casoElegido;
  final bool rondaResuelta;
  final void Function(CasoDeklinabidea) alSeleccionar;

  const _FilaDeCestas({
    required this.cestas,
    required this.casoCorrecto,
    required this.casoElegido,
    required this.rondaResuelta,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: cestas.map((CasoDeklinabidea caso) {
          final bool esCorrectaResaltada =
              rondaResuelta && caso == casoCorrecto;
          final bool esElegidaErronea = rondaResuelta &&
              caso == casoElegido &&
              caso != casoCorrecto;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Cesta(
                caso: caso,
                resaltadaComoCorrecta: esCorrectaResaltada,
                resaltadaComoErronea: esElegidaErronea,
                pulsable: !rondaResuelta,
                alPulsar: () => alSeleccionar(caso),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _Cesta extends StatelessWidget {
  final CasoDeklinabidea caso;
  final bool resaltadaComoCorrecta;
  final bool resaltadaComoErronea;
  final bool pulsable;
  final VoidCallback alPulsar;

  const _Cesta({
    required this.caso,
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
            ? PaletaAek.tintaDiluida(0.35)
            : PaletaAek.tintaNegra;
    return Opacity(
      opacity: pulsable || resaltadaComoCorrecta || resaltadaComoErronea
          ? 1.0
          : 0.55,
      child: GestureDetector(
        onTap: pulsable ? alPulsar : null,
        child: MarcoRotulador(
          color: colorMarco,
          grosor: 2.6,
          intensidadJitter: 1.2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            constraints: const BoxConstraints(minHeight: 90),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  caso.laburpena,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: colorMarco,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caso.izenOsoa,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
