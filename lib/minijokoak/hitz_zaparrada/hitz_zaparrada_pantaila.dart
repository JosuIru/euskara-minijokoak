import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'hitz_zaparrada_datuak.dart';

class HitzZaparradaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  /// Tema precargado. Si se aporta, se salta la pantalla de selección
  /// y se arranca directamente con este tema (usado cuando el ejercicio
  /// proviene de un texto generado por el profesor).
  final TemaSopa? temaPredefinido;

  const HitzZaparradaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
    this.temaPredefinido,
  });

  @override
  State<HitzZaparradaPantaila> createState() => _HitzZaparradaPantailaState();
}

class _HitzZaparradaPantailaState extends State<HitzZaparradaPantaila> {
  TemaSopa? _temaSeleccionado;
  TableroSopa? _tableroActual;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  Punto? _puntoSeleccionadoOrigen;
  final Set<String> _palabrasEncontradas = <String>{};
  final Set<Punto> _celdasMarcadasComoEncontradas = <Punto>{};

  @override
  void initState() {
    super.initState();
    if (widget.temaPredefinido != null) {
      // En el modo "generado desde texto" no preguntamos nivel — el
      // tema ya viene con sus palabras y no tiene sentido filtrar.
      _nivelElegido = NivelEuskera.c1;
      _empezarConTema(widget.temaPredefinido!);
    }
  }

  void _empezarConTema(TemaSopa tema) {
    final TableroSopa tablero =
        generarTablero(tema, semilla: DateTime.now().millisecondsSinceEpoch);
    setState(() {
      _temaSeleccionado = tema;
      _tableroActual = tablero;
      _puntoSeleccionadoOrigen = null;
      _palabrasEncontradas.clear();
      _celdasMarcadasComoEncontradas.clear();
      _momentoInicioPartida = DateTime.now();
    });
  }

  void _pulsarCelda(int fila, int columna) {
    if (_tableroActual == null) return;
    final Punto puntoPulsado = Punto(fila, columna);
    if (_puntoSeleccionadoOrigen == null) {
      setState(() {
        _puntoSeleccionadoOrigen = puntoPulsado;
      });
      return;
    }
    final Punto origen = _puntoSeleccionadoOrigen!;
    if (origen == puntoPulsado) {
      // Click en el mismo: cancelar selección.
      setState(() {
        _puntoSeleccionadoOrigen = null;
      });
      return;
    }
    final List<Punto>? camino = caminoEntre(origen, puntoPulsado);
    if (camino == null) {
      // No alineados — tratar el nuevo punto como nuevo origen.
      setState(() {
        _puntoSeleccionadoOrigen = puntoPulsado;
      });
      return;
    }
    final String palabraConstruida = camino
        .map((Punto p) => _tableroActual!.celdas[p.fila][p.columna])
        .join();
    final String palabraInvertida =
        palabraConstruida.split('').reversed.join();

    final String coincidente = _tableroActual!.palabras.firstWhere(
      (String objetivo) =>
          objetivo == palabraConstruida || objetivo == palabraInvertida,
      orElse: () => '',
    );
    if (coincidente.isNotEmpty &&
        !_palabrasEncontradas.contains(coincidente)) {
      setState(() {
        _palabrasEncontradas.add(coincidente);
        _celdasMarcadasComoEncontradas.addAll(camino);
        _puntoSeleccionadoOrigen = null;
      });
      if (_palabrasEncontradas.length == _tableroActual!.palabras.length) {
        Future<void>.delayed(const Duration(milliseconds: 700), _terminar);
      }
    } else {
      setState(() {
        _puntoSeleccionadoOrigen = null;
      });
    }
  }

  void _terminar() {
    if (!mounted || _tableroActual == null) return;
    widget.amaitzean(ResultadoAriketa(
      identificadorAriketa: widget.identificadorAriketa,
      momentoFin: DateTime.now(),
      aciertos: _palabrasEncontradas.length,
      intentosTotales: _tableroActual!.palabras.length,
      tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Hitz-Zaparrada',
        alAukeratu: (NivelEuskera nivel) {
          setState(() => _nivelElegido = nivel);
        },
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 89,
          child: _temaSeleccionado == null || _tableroActual == null
              ? _SeleccionTemaSopa(
                  temasDisponibles: temasParaNivel(_nivelElegido!),
                  alElegir: _empezarConTema,
                )
              : _PantallaPartidaSopa(
                  tema: _temaSeleccionado!,
                  tablero: _tableroActual!,
                  palabrasEncontradas: _palabrasEncontradas,
                  celdasMarcadas: _celdasMarcadasComoEncontradas,
                  puntoOrigenSeleccionado: _puntoSeleccionadoOrigen,
                  alPulsarCelda: _pulsarCelda,
                ),
        ),
      ),
    );
  }
}

class _SeleccionTemaSopa extends StatelessWidget {
  final List<TemaSopa> temasDisponibles;
  final void Function(TemaSopa) alElegir;
  const _SeleccionTemaSopa({
    required this.temasDisponibles,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  BackButton(color: PaletaAek.tintaNegra),
                  SizedBox(width: 8),
                  Text(
                    'GAIA AUKERATU',
                    style: TextStyle(
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
                'Hautatu zer gairi buruzko hitzak bilatu nahi dituzun.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: PaletaAek.tintaDiluida(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ...temasDisponibles.map(
                (TemaSopa tema) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => alElegir(tema),
                    behavior: HitTestBehavior.opaque,
                    child: MarcoRotulador(
                      grosor: 2.4,
                      intensidadJitter: 1.1,
                      child: Container(
                        color: PaletaAek.papelViejo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.grid_view,
                                color: PaletaAek.rojoRotulador, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    tema.izenburuEuskera,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: PaletaAek.tintaNegra,
                                    ),
                                  ),
                                  Text(
                                    '${tema.palabras.length} hitz · '
                                    '${tema.descripcionEspanol}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: PaletaAek.tintaDiluida(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: PaletaAek.rojoRotulador, size: 18),
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

class _PantallaPartidaSopa extends StatelessWidget {
  final TemaSopa tema;
  final TableroSopa tablero;
  final Set<String> palabrasEncontradas;
  final Set<Punto> celdasMarcadas;
  final Punto? puntoOrigenSeleccionado;
  final void Function(int fila, int columna) alPulsarCelda;

  const _PantallaPartidaSopa({
    required this.tema,
    required this.tablero,
    required this.palabrasEncontradas,
    required this.celdasMarcadas,
    required this.puntoOrigenSeleccionado,
    required this.alPulsarCelda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _Cabecera(
          tema: tema,
          encontradas: palabrasEncontradas.length,
          total: tablero.palabras.length,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool layoutHorizontal = constraints.maxWidth > 760;
              final Widget tableroWidget = _TableroWidget(
                tablero: tablero,
                celdasMarcadas: celdasMarcadas,
                puntoOrigenSeleccionado: puntoOrigenSeleccionado,
                alPulsarCelda: alPulsarCelda,
              );
              final Widget listaWidget = _ListaPalabras(
                palabras: tablero.palabras,
                encontradas: palabrasEncontradas,
              );
              if (layoutHorizontal) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 3, child: tableroWidget),
                      const SizedBox(width: 20),
                      Expanded(flex: 1, child: listaWidget),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    tableroWidget,
                    const SizedBox(height: 16),
                    listaWidget,
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Cabecera extends StatelessWidget {
  final TemaSopa tema;
  final int encontradas;
  final int total;

  const _Cabecera({
    required this.tema,
    required this.encontradas,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              tema.izenburuEuskera.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
                letterSpacing: 2.5,
              ),
            ),
          ),
          Text(
            '$encontradas / $total',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableroWidget extends StatelessWidget {
  final TableroSopa tablero;
  final Set<Punto> celdasMarcadas;
  final Punto? puntoOrigenSeleccionado;
  final void Function(int fila, int columna) alPulsarCelda;

  const _TableroWidget({
    required this.tablero,
    required this.celdasMarcadas,
    required this.puntoOrigenSeleccionado,
    required this.alPulsarCelda,
  });

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 2.6,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: tablero.columnas,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: tablero.filas * tablero.columnas,
            itemBuilder: (BuildContext context, int indice) {
              final int fila = indice ~/ tablero.columnas;
              final int columna = indice % tablero.columnas;
              final Punto punto = Punto(fila, columna);
              final bool yaEncontrada = celdasMarcadas.contains(punto);
              final bool esOrigen = puntoOrigenSeleccionado == punto;
              return GestureDetector(
                onTap: () => alPulsarCelda(fila, columna),
                behavior: HitTestBehavior.opaque,
                child: _CeldaLetra(
                  letra: tablero.celdas[fila][columna],
                  yaEncontrada: yaEncontrada,
                  esOrigen: esOrigen,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CeldaLetra extends StatelessWidget {
  final String letra;
  final bool yaEncontrada;
  final bool esOrigen;

  const _CeldaLetra({
    required this.letra,
    required this.yaEncontrada,
    required this.esOrigen,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = yaEncontrada
        ? PaletaAek.rojoDiluido(0.18)
        : esOrigen
            ? PaletaAek.tintaDiluida(0.18)
            : Colors.transparent;
    final Color colorTexto = yaEncontrada
        ? PaletaAek.rojoRotulador
        : PaletaAek.tintaNegra;
    return Container(
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border.all(
          color: yaEncontrada
              ? PaletaAek.rojoRotulador
              : PaletaAek.tintaDiluida(0.3),
          width: yaEncontrada ? 1.4 : 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letra.toUpperCase(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          fontWeight: yaEncontrada ? FontWeight.w900 : FontWeight.bold,
          color: colorTexto,
        ),
      ),
    );
  }
}

class _ListaPalabras extends StatelessWidget {
  final List<String> palabras;
  final Set<String> encontradas;

  const _ListaPalabras({
    required this.palabras,
    required this.encontradas,
  });

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 2,
      intensidadJitter: 1.0,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'AURKITU BEHARREKO HITZAK',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: PaletaAek.tintaDiluida(0.65),
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 8),
            ...palabras.map(
              (String palabra) {
                final bool encontrada = encontradas.contains(palabra);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        encontrada
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: encontrada
                            ? PaletaAek.rojoRotulador
                            : PaletaAek.tintaDiluida(0.4),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        palabra,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: encontrada
                              ? PaletaAek.rojoRotulador
                              : PaletaAek.tintaNegra,
                          decoration: encontrada
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
