import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'lotura_datuak.dart';

/// Cuánto tiempo permanece visible un par no-coincidente antes de
/// volverse a tapar. Suficiente para leer las dos cartas, no tanto que
/// el flujo se vuelva lento.
const Duration _duracionRevisionParejaErronea = Duration(milliseconds: 1200);

/// Estado de una carta concreta de la rejilla.
enum _EstadoCarta { tapada, destapada, casada }

/// Tipo de cara visible de una carta: euskera (palabra original) o
/// español (traducción). Lo necesitamos porque cada pareja genera DOS
/// cartas (una de cada idioma) en la rejilla.
enum _IdiomaCarta { euskera, espanol }

class _CartaDato {
  /// Índice de la pareja a la que pertenece (0..parejasPorPartida-1).
  final int indiceParejaAsociada;
  final _IdiomaCarta idioma;
  final String texto;
  _EstadoCarta estado;

  _CartaDato({
    required this.indiceParejaAsociada,
    required this.idioma,
    required this.texto,
  }) : estado = _EstadoCarta.tapada;
}

class LoturaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  /// Tema precargado. Si se aporta, se salta la pantalla de selección y
  /// se arranca directamente con este tema (usado cuando el ejercicio
  /// proviene de un texto generado por el profesor).
  final TemaVocabulario? temaPredefinido;

  const LoturaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
    this.temaPredefinido,
  });

  @override
  State<LoturaPantaila> createState() => _LoturaPantailaState();
}

class _LoturaPantailaState extends State<LoturaPantaila> {
  TemaVocabulario? _temaSeleccionado;
  NivelEuskera? _nivelElegido;
  late DateTime _momentoInicioPartida;
  late List<_CartaDato> _cartas;
  int _indiceCartaPrimeraDestapada = -1;
  bool _bloqueadoEsperandoRevision = false;
  int _intentosTotales = 0;
  int _paresCasados = 0;

  @override
  void initState() {
    super.initState();
    _momentoInicioPartida = DateTime.now();
    _cartas = const <_CartaDato>[];
    if (widget.temaPredefinido != null) {
      // Modo "generado desde texto": no preguntamos nivel, el tema ya
      // viene con sus parejas listas.
      _nivelElegido = NivelEuskera.c1;
      _comenzarConTema(widget.temaPredefinido!);
    }
  }

  void _comenzarConTema(TemaVocabulario tema) {
    final List<ParejaVocabulario> parejasBarajadas =
        List.of(tema.parejas)..shuffle();
    final int cuantasParejas = math.min(parejasPorPartida, parejasBarajadas.length);
    final List<_CartaDato> generadas = <_CartaDato>[];
    for (int indicePareja = 0; indicePareja < cuantasParejas; indicePareja++) {
      final ParejaVocabulario pareja = parejasBarajadas[indicePareja];
      generadas.add(_CartaDato(
        indiceParejaAsociada: indicePareja,
        idioma: _IdiomaCarta.euskera,
        texto: pareja.euskera,
      ));
      generadas.add(_CartaDato(
        indiceParejaAsociada: indicePareja,
        idioma: _IdiomaCarta.espanol,
        texto: pareja.espanol,
      ));
    }
    generadas.shuffle();
    setState(() {
      _temaSeleccionado = tema;
      _cartas = generadas;
      _indiceCartaPrimeraDestapada = -1;
      _intentosTotales = 0;
      _paresCasados = 0;
      _momentoInicioPartida = DateTime.now();
    });
  }

  void _alPulsarCarta(int indiceCarta) {
    if (_bloqueadoEsperandoRevision) return;
    final _CartaDato carta = _cartas[indiceCarta];
    if (carta.estado != _EstadoCarta.tapada) return;
    setState(() {
      carta.estado = _EstadoCarta.destapada;
    });
    if (_indiceCartaPrimeraDestapada == -1) {
      _indiceCartaPrimeraDestapada = indiceCarta;
      return;
    }
    // Segunda carta destapada — comprobamos pareja.
    final _CartaDato primera = _cartas[_indiceCartaPrimeraDestapada];
    final _CartaDato segunda = carta;
    _intentosTotales += 1;
    if (primera.indiceParejaAsociada == segunda.indiceParejaAsociada &&
        primera.idioma != segunda.idioma) {
      // Pareja correcta.
      setState(() {
        primera.estado = _EstadoCarta.casada;
        segunda.estado = _EstadoCarta.casada;
        _paresCasados += 1;
        _indiceCartaPrimeraDestapada = -1;
      });
      if (_paresCasados == _cartas.length ~/ 2) {
        Future<void>.delayed(const Duration(milliseconds: 600), _terminar);
      }
    } else {
      // Pareja errónea — tapar tras un momento de revisión.
      _bloqueadoEsperandoRevision = true;
      Future<void>.delayed(_duracionRevisionParejaErronea, () {
        if (!mounted) return;
        setState(() {
          primera.estado = _EstadoCarta.tapada;
          segunda.estado = _EstadoCarta.tapada;
          _indiceCartaPrimeraDestapada = -1;
          _bloqueadoEsperandoRevision = false;
        });
      });
    }
  }

  void _terminar() {
    if (!mounted) return;
    widget.amaitzean(ResultadoAriketa(
      identificadorAriketa: widget.identificadorAriketa,
      momentoFin: DateTime.now(),
      aciertos: _paresCasados,
      intentosTotales: _intentosTotales,
      tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Lotura',
        alAukeratu: (NivelEuskera nivel) {
          setState(() => _nivelElegido = nivel);
        },
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 31,
          child: _temaSeleccionado == null
              ? _PantallaSeleccionTema(
                  temasDisponiblesParaNivel:
                      temasLoturaParaNivel(_nivelElegido!),
                  alElegirTema: _comenzarConTema,
                )
              : _PantallaPartida(
                  tema: _temaSeleccionado!,
                  cartas: _cartas,
                  paresCasados: _paresCasados,
                  intentosTotales: _intentosTotales,
                  alPulsarCarta: _alPulsarCarta,
                ),
        ),
      ),
    );
  }
}

class _PantallaSeleccionTema extends StatelessWidget {
  final List<TemaVocabulario> temasDisponiblesParaNivel;
  final void Function(TemaVocabulario) alElegirTema;
  const _PantallaSeleccionTema({
    required this.temasDisponiblesParaNivel,
    required this.alElegirTema,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const BackButton(color: PaletaAek.tintaNegra),
                  const SizedBox(width: 8),
                  Text(
                    'GAIA AUKERATU',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: PaletaAek.tintaNegra,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Hautatu zer gairi buruzko hitzak ikasi nahi dituzun.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: PaletaAek.tintaDiluida(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ...temasDisponiblesParaNivel.map(
                (TemaVocabulario tema) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaSeleccionTema(
                    tema: tema,
                    alPulsar: () => alElegirTema(tema),
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

class _TarjetaSeleccionTema extends StatelessWidget {
  final TemaVocabulario tema;
  final VoidCallback alPulsar;

  const _TarjetaSeleccionTema({required this.tema, required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPulsar,
      behavior: HitTestBehavior.opaque,
      child: MarcoRotulador(
        grosor: 2.4,
        intensidadJitter: 1.1,
        child: Container(
          color: PaletaAek.papelViejo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: <Widget>[
              Text(
                tema.emojiRepresentativo,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tema.izenburuEuskera,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: PaletaAek.tintaNegra,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      tema.descripcionEspanol,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: PaletaAek.tintaDiluida(0.65),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${tema.parejas.length} bikote',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: PaletaAek.tintaDiluida(0.6),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios,
                  color: PaletaAek.rojoRotulador, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantallaPartida extends StatelessWidget {
  final TemaVocabulario tema;
  final List<_CartaDato> cartas;
  final int paresCasados;
  final int intentosTotales;
  final void Function(int) alPulsarCarta;

  const _PantallaPartida({
    required this.tema,
    required this.cartas,
    required this.paresCasados,
    required this.intentosTotales,
    required this.alPulsarCarta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: <Widget>[
              const BackButton(color: PaletaAek.tintaNegra),
              const SizedBox(width: 4),
              Text(
                tema.emojiRepresentativo,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Text(
                tema.izenburuEuskera.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: PaletaAek.tintaNegra,
                  letterSpacing: 2.5,
                ),
              ),
              const Spacer(),
              Text(
                '$paresCasados / ${cartas.length ~/ 2}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PaletaAek.tintaNegra,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.refresh,
                  color: PaletaAek.tintaDiluida(0.5), size: 18),
              const SizedBox(width: 4),
              Text(
                '$intentosTotales',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PaletaAek.tintaNegra,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: cartas.length,
                  itemBuilder: (BuildContext context, int indiceCarta) {
                    return _CartaWidget(
                      carta: cartas[indiceCarta],
                      semilla: indiceCarta * 13.0,
                      alPulsar: () => alPulsarCarta(indiceCarta),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartaWidget extends StatelessWidget {
  final _CartaDato carta;
  final double semilla;
  final VoidCallback alPulsar;

  const _CartaWidget({
    required this.carta,
    required this.semilla,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final bool destapada = carta.estado != _EstadoCarta.tapada;
    return GestureDetector(
      onTap: alPulsar,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (Widget? actual, List<Widget> previas) =>
            Stack(alignment: Alignment.center, children: <Widget>[
          ...previas,
          ?actual,
        ]),
        child: destapada
            ? _CaraDestapadaCarta(
                key: const ValueKey<String>('destapada'),
                carta: carta,
                semilla: semilla,
              )
            : _DorsoCarta(
                key: const ValueKey<String>('dorso'),
                semilla: semilla,
              ),
      ),
    );
  }
}

class _DorsoCarta extends StatelessWidget {
  final double semilla;
  const _DorsoCarta({super.key, required this.semilla});

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 2.6,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        alignment: Alignment.center,
        child: CustomPaint(
          painter: _PintorEstrellaDorso(semilla: semilla),
          size: const Size.square(60),
        ),
      ),
    );
  }
}

class _PintorEstrellaDorso extends CustomPainter {
  final double semilla;
  _PintorEstrellaDorso({required this.semilla});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final Paint pincel = Paint()
      ..color = PaletaAek.rojoRotulador
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    estrellaRotulador(canvas, centro, size.width * 0.42,
        pincel: pincel, intensidadJitter: 0.8, semilla: semilla);
    // Marco circular irregular alrededor.
    final Paint pincelMarco = Paint()
      ..color = PaletaAek.tintaDiluida(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    circuloRotulador(canvas, centro, size.width * 0.50,
        pincel: pincelMarco, intensidadJitter: 0.9, semilla: semilla + 7);
  }

  @override
  bool shouldRepaint(covariant _PintorEstrellaDorso viejo) =>
      viejo.semilla != semilla;
}

class _CaraDestapadaCarta extends StatelessWidget {
  final _CartaDato carta;
  final double semilla;

  const _CaraDestapadaCarta({
    super.key,
    required this.carta,
    required this.semilla,
  });

  @override
  Widget build(BuildContext context) {
    final bool yaCasada = carta.estado == _EstadoCarta.casada;
    final bool esEuskera = carta.idioma == _IdiomaCarta.euskera;
    final Color colorMarco =
        yaCasada ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra;
    return MarcoRotulador(
      color: colorMarco,
      grosor: yaCasada ? 3.0 : 2.4,
      intensidadJitter: 1.1,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              esEuskera ? 'EUS' : 'ES',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: yaCasada
                    ? PaletaAek.rojoRotulador
                    : PaletaAek.tintaDiluida(0.55),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                carta.texto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: yaCasada
                      ? PaletaAek.rojoRotulador
                      : PaletaAek.tintaNegra,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
