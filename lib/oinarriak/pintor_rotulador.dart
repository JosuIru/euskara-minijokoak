import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'paleta.dart';

/// PINTOR ROTULADOR.
///
/// Primitivas de dibujo con estética de rotulador / sketch a mano alzada.
/// Todos los minijuegos y elementos visuales comparten este lenguaje:
/// blanco y negro con un único rojo de acento. Los trazos llevan
/// micro-jitter para parecer hechos a mano y las superficies se rellenan
/// con rayado paralelo (hatching), no con colores planos.

/// Generador determinista para que el jitter de un punto concreto siempre
/// dé el mismo desplazamiento — evita que las líneas "vibren" frame a
/// frame, que cansa la vista.
double _ruidoDeterminista(double semilla) {
  final double s = math.sin(semilla * 12.9898) * 43758.5453;
  return s - s.floorToDouble();
}

double _jitter(double semilla, double amplitud) {
  return (_ruidoDeterminista(semilla) - 0.5) * 2 * amplitud;
}

/// Dibuja una línea entre [inicio] y [fin] con micro-temblor para que
/// parezca hecha con rotulador a mano alzada. [intensidadJitter] en
/// píxeles: 0.6 para trazo limpio, 1.5 para trazo nervioso.
void trazoTembloroso(
  Canvas canvas,
  Offset inicio,
  Offset fin, {
  required Paint pincel,
  double intensidadJitter = 0.7,
  int segmentos = 6,
  double semilla = 0,
}) {
  final Path camino = Path()..moveTo(inicio.dx, inicio.dy);
  for (int indiceSegmento = 1; indiceSegmento <= segmentos; indiceSegmento++) {
    final double t = indiceSegmento / segmentos;
    final double x = inicio.dx + (fin.dx - inicio.dx) * t;
    final double y = inicio.dy + (fin.dy - inicio.dy) * t;
    final double jitterX = _jitter(semilla + indiceSegmento * 1.7, intensidadJitter);
    final double jitterY = _jitter(semilla + indiceSegmento * 3.1, intensidadJitter);
    camino.lineTo(x + jitterX, y + jitterY);
  }
  canvas.drawPath(camino, pincel);
}

/// Dibuja un rectángulo a rotulador (4 trazos temblorosos).
void rectanguloRotulador(
  Canvas canvas,
  Rect rect, {
  required Paint pincel,
  double intensidadJitter = 0.7,
  bool doblePasada = false,
  double semilla = 0,
}) {
  trazoTembloroso(canvas, rect.topLeft, rect.topRight,
      pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla);
  trazoTembloroso(canvas, rect.topRight, rect.bottomRight,
      pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla + 10);
  trazoTembloroso(canvas, rect.bottomRight, rect.bottomLeft,
      pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla + 20);
  trazoTembloroso(canvas, rect.bottomLeft, rect.topLeft,
      pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla + 30);
  if (doblePasada) {
    final Rect rectInterior = rect.deflate(1.2);
    trazoTembloroso(canvas, rectInterior.topLeft, rectInterior.topRight,
        pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla + 40);
    trazoTembloroso(canvas, rectInterior.bottomLeft, rectInterior.bottomRight,
        pincel: pincel, intensidadJitter: intensidadJitter, semilla: semilla + 50);
  }
}

/// Dibuja un círculo a rotulador como polígono de 18 lados con jitter.
void circuloRotulador(
  Canvas canvas,
  Offset centro,
  double radio, {
  required Paint pincel,
  double intensidadJitter = 0.8,
  int segmentos = 18,
  double semilla = 0,
}) {
  final Path camino = Path();
  for (int indicePunto = 0; indicePunto <= segmentos; indicePunto++) {
    final double angulo = (indicePunto / segmentos) * math.pi * 2;
    final double radioVariado =
        radio + _jitter(semilla + indicePunto * 0.91, intensidadJitter);
    final double x = centro.dx + math.cos(angulo) * radioVariado;
    final double y = centro.dy + math.sin(angulo) * radioVariado;
    if (indicePunto == 0) {
      camino.moveTo(x, y);
    } else {
      camino.lineTo(x, y);
    }
  }
  camino.close();
  canvas.drawPath(camino, pincel);
}

/// Rellena [rect] con un rayado paralelo diagonal (hatching).
void rayadoParalelo(
  Canvas canvas,
  Rect rect, {
  required Paint pincel,
  double espaciado = 6,
  double anguloRayas = -math.pi / 4,
  double intensidadJitter = 0.4,
}) {
  canvas.save();
  canvas.clipRect(rect);
  final double cosA = math.cos(anguloRayas);
  final double senA = math.sin(anguloRayas);
  final double diagonal = rect.longestSide * 1.5;
  for (double desplaza = -diagonal; desplaza < diagonal; desplaza += espaciado) {
    final Offset p1 = rect.center +
        Offset(cosA * desplaza - senA * diagonal,
            senA * desplaza + cosA * diagonal);
    final Offset p2 = rect.center +
        Offset(cosA * desplaza + senA * diagonal,
            senA * desplaza - cosA * diagonal);
    trazoTembloroso(canvas, p1, p2,
        pincel: pincel,
        intensidadJitter: intensidadJitter,
        segmentos: 4,
        semilla: desplaza);
  }
  canvas.restore();
}

/// Rellena [rect] con un rayado cruzado (cross-hatch) para sombras densas.
void rayadoCruzado(
  Canvas canvas,
  Rect rect, {
  required Paint pincel,
  double espaciado = 6,
  double intensidadJitter = 0.4,
}) {
  rayadoParalelo(canvas, rect,
      pincel: pincel,
      espaciado: espaciado,
      anguloRayas: -math.pi / 4,
      intensidadJitter: intensidadJitter);
  rayadoParalelo(canvas, rect,
      pincel: pincel,
      espaciado: espaciado,
      anguloRayas: math.pi / 4,
      intensidadJitter: intensidadJitter);
}

/// Dibuja una estampilla roja con [texto] dentro.
void estampillaRoja(
  Canvas canvas, {
  required Offset posicion,
  required String texto,
  required double anchoEstampilla,
  required double altoEstampilla,
  double rotacionRadianes = -0.10,
  double opacidad = 0.95,
}) {
  canvas.save();
  canvas.translate(posicion.dx, posicion.dy);
  canvas.rotate(rotacionRadianes);
  final Rect rectEstampilla = Rect.fromCenter(
    center: Offset.zero,
    width: anchoEstampilla,
    height: altoEstampilla,
  );
  final Paint pincelMarco = Paint()
    ..color = PaletaAek.rojoRotulador.withValues(alpha: opacidad)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4;
  rectanguloRotulador(canvas, rectEstampilla,
      pincel: pincelMarco, intensidadJitter: 1.2, doblePasada: true);
  final TextPainter pintor = TextPainter(
    text: TextSpan(
      text: texto,
      style: TextStyle(
        color: PaletaAek.rojoRotulador.withValues(alpha: opacidad),
        fontFamily: 'monospace',
        fontSize: altoEstampilla * 0.55,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  pintor.paint(canvas, Offset(-pintor.width / 2, -pintor.height / 2));
  canvas.restore();
}

/// Dibuja una estrella de 5 puntas con jitter de rotulador.
void estrellaRotulador(
  Canvas canvas,
  Offset centro,
  double radio, {
  required Paint pincel,
  double intensidadJitter = 0.6,
  double semilla = 0,
}) {
  final Path camino = Path();
  for (int indicePunta = 0; indicePunta < 10; indicePunta++) {
    final bool esPuntaExterior = indicePunta.isEven;
    final double radioActual = esPuntaExterior ? radio : radio * 0.42;
    final double angulo = -math.pi / 2 + indicePunta * math.pi / 5;
    final double jitterRadio =
        _jitter(semilla + indicePunta * 1.7, intensidadJitter);
    final double x = centro.dx + math.cos(angulo) * (radioActual + jitterRadio);
    final double y = centro.dy + math.sin(angulo) * (radioActual + jitterRadio);
    if (indicePunta == 0) {
      camino.moveTo(x, y);
    } else {
      camino.lineTo(x, y);
    }
  }
  camino.close();
  canvas.drawPath(camino, pincel);
}

/// Widget que añade un marco tembloroso a [child] sin alterar su layout.
class MarcoRotulador extends StatelessWidget {
  final Widget child;
  final Color color;
  final double grosor;
  final double intensidadJitter;
  final double margenInterior;

  const MarcoRotulador({
    super.key,
    required this.child,
    this.color = PaletaAek.tintaNegra,
    this.grosor = 2.4,
    this.intensidadJitter = 1.0,
    this.margenInterior = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PintorMarcoRotulador(
                color: color,
                grosor: grosor,
                intensidadJitter: intensidadJitter,
                margenInterior: margenInterior,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PintorMarcoRotulador extends CustomPainter {
  final Color color;
  final double grosor;
  final double intensidadJitter;
  final double margenInterior;

  _PintorMarcoRotulador({
    required this.color,
    required this.grosor,
    required this.intensidadJitter,
    required this.margenInterior,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect =
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(margenInterior);
    final Paint pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    rectanguloRotulador(canvas, rect,
        pincel: pincel, intensidadJitter: intensidadJitter, doblePasada: true);
  }

  @override
  bool shouldRepaint(covariant _PintorMarcoRotulador viejo) =>
      viejo.color != color ||
      viejo.grosor != grosor ||
      viejo.intensidadJitter != intensidadJitter ||
      viejo.margenInterior != margenInterior;
}

/// Fondo de papel envejecido con manchas y arrugas. Acepta cualquier
/// semilla para que distintas pantallas tengan distintos patrones.
class FondoPapelEnvejecido extends StatelessWidget {
  final double semilla;
  final Widget child;

  const FondoPapelEnvejecido({
    super.key,
    required this.child,
    this.semilla = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PaletaAek.papelViejo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _PintorFondoPapel(semilla: semilla),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PintorFondoPapel extends CustomPainter {
  final double semilla;
  _PintorFondoPapel({required this.semilla});

  @override
  void paint(Canvas canvas, Size size) {
    fondoPapelEnvejecido(canvas, Offset.zero & size, semilla: semilla);
  }

  @override
  bool shouldRepaint(covariant _PintorFondoPapel viejo) =>
      viejo.semilla != semilla;
}

/// Pinta un fondo de "papel viejo" con micro-textura de arrugas y manchas.
void fondoPapelEnvejecido(Canvas canvas, Rect area, {double semilla = 0}) {
  canvas.drawRect(area, Paint()..color = PaletaAek.papelViejo);
  final math.Random rngTextura = math.Random(semilla.floor() + 7);
  final Paint pincelMancha = Paint()
    ..color = PaletaAek.tintaDiluida(0.04);
  for (int indiceMancha = 0; indiceMancha < 14; indiceMancha++) {
    final double xMancha = area.left + rngTextura.nextDouble() * area.width;
    final double yMancha = area.top + rngTextura.nextDouble() * area.height;
    final double radioMancha = 3 + rngTextura.nextDouble() * 12;
    canvas.drawCircle(Offset(xMancha, yMancha), radioMancha, pincelMancha);
  }
  final Paint pincelArruga = Paint()
    ..color = PaletaAek.tintaDiluida(0.05)
    ..strokeWidth = 0.6;
  for (int indiceArruga = 0; indiceArruga < 5; indiceArruga++) {
    final double y0 = area.top + rngTextura.nextDouble() * area.height;
    trazoTembloroso(
      canvas,
      Offset(area.left, y0),
      Offset(area.right, y0 + rngTextura.nextDouble() * 30 - 15),
      pincel: pincelArruga,
      intensidadJitter: 1.0,
      semilla: indiceArruga * 17.0,
    );
  }
}
