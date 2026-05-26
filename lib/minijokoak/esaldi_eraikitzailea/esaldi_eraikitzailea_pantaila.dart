import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';
import '../../oinarriak/selector_maila_orria.dart';
import 'esaldi_eraikitzailea_datuak.dart';

class EsaldiEraikitzaileaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  const EsaldiEraikitzaileaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
  });

  @override
  State<EsaldiEraikitzaileaPantaila> createState() =>
      _EsaldiEraikitzaileaPantailaState();
}

class _EsaldiEraikitzaileaPantailaState
    extends State<EsaldiEraikitzaileaPantaila> {
  List<FraseAConstruir>? _frasesSeleccionadas;
  late DateTime _momentoInicioPartida;
  NivelEuskera? _nivelElegido;

  int _indiceFraseActual = 0;
  int _aciertos = 0;
  List<String> _palabrasEnBancoDesordenadas = const <String>[];
  List<String> _palabrasComposicionAlumno = const <String>[];
  bool _comprobado = false;

  FraseAConstruir get _fraseActual =>
      _frasesSeleccionadas![_indiceFraseActual];

  void _empezarConNivel(NivelEuskera nivel) {
    setState(() {
      _nivelElegido = nivel;
      _momentoInicioPartida = DateTime.now();
      _frasesSeleccionadas = _seleccionarFrases(nivel);
    });
    _prepararFraseActual();
  }

  List<FraseAConstruir> _seleccionarFrases(NivelEuskera nivelMax) {
    final List<FraseAConstruir> baraja =
        List<FraseAConstruir>.of(frasesParaNivel(nivelMax))..shuffle();
    if (baraja.length >= frasesPorPartida) {
      return baraja.sublist(0, frasesPorPartida);
    }
    return baraja;
  }

  void _prepararFraseActual() {
    final List<String> palabrasOrdenadas =
        List<String>.from(_fraseActual.palabrasOrdenadas)..shuffle();
    setState(() {
      _palabrasEnBancoDesordenadas = palabrasOrdenadas;
      _palabrasComposicionAlumno = const <String>[];
      _comprobado = false;
    });
  }

  void _pulsarPalabraBanco(int indiceEnBanco) {
    if (_comprobado) return;
    final String palabraTocada =
        _palabrasEnBancoDesordenadas[indiceEnBanco];
    setState(() {
      _palabrasEnBancoDesordenadas = List<String>.from(
          _palabrasEnBancoDesordenadas)
        ..removeAt(indiceEnBanco);
      _palabrasComposicionAlumno = <String>[
        ..._palabrasComposicionAlumno,
        palabraTocada,
      ];
    });
  }

  void _pulsarPalabraComposicion(int indiceEnComposicion) {
    if (_comprobado) return;
    final String palabraDevuelta =
        _palabrasComposicionAlumno[indiceEnComposicion];
    setState(() {
      _palabrasComposicionAlumno = List<String>.from(_palabrasComposicionAlumno)
        ..removeAt(indiceEnComposicion);
      _palabrasEnBancoDesordenadas = <String>[
        ..._palabrasEnBancoDesordenadas,
        palabraDevuelta,
      ];
    });
  }

  void _egiaztatu() {
    if (_palabrasEnBancoDesordenadas.isNotEmpty) return;
    setState(() {
      _comprobado = true;
    });
    final bool esCorrecto =
        _esComposicionCorrecta(_palabrasComposicionAlumno, _fraseActual);
    if (esCorrecto) {
      _aciertos += 1;
    }
    Future<void>.delayed(const Duration(milliseconds: 1700), _avanzarOTerminar);
  }

  bool _esComposicionCorrecta(
      List<String> composicion, FraseAConstruir esperada) {
    if (composicion.length != esperada.palabrasOrdenadas.length) return false;
    for (int indice = 0; indice < composicion.length; indice++) {
      if (composicion[indice].toLowerCase() !=
          esperada.palabrasOrdenadas[indice].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  void _avanzarOTerminar() {
    if (!mounted) return;
    final bool fueUltima =
        _indiceFraseActual >= _frasesSeleccionadas!.length - 1;
    if (fueUltima) {
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: _aciertos,
        intentosTotales: _frasesSeleccionadas!.length,
        tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
      ));
      return;
    }
    setState(() {
      _indiceFraseActual += 1;
    });
    _prepararFraseActual();
  }

  @override
  Widget build(BuildContext context) {
    if (_nivelElegido == null || _frasesSeleccionadas == null) {
      return SelectorMailaOrria(
        izenburuMinijokoa: 'Esaldi-Eraikitzailea',
        alAukeratu: _empezarConNivel,
      );
    }
    final bool esComposicionCorrectaAhora =
        _comprobado && _esComposicionCorrecta(
            _palabrasComposicionAlumno, _fraseActual);

    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 73,
          child: Column(
            children: <Widget>[
              _CabeceraBarra(
                indiceFraseActual: _indiceFraseActual + 1,
                frasesTotales: _frasesSeleccionadas!.length,
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
                          _CajaTraduccionPista(
                              traduccion: _fraseActual.traduccionEspanol),
                          const SizedBox(height: 20),
                          _ZonaComposicion(
                            palabras: _palabrasComposicionAlumno,
                            comprobado: _comprobado,
                            esCorrecto: esComposicionCorrectaAhora,
                            alPulsarPalabra: _pulsarPalabraComposicion,
                          ),
                          const SizedBox(height: 16),
                          _BancoPalabrasDesordenadas(
                            palabras: _palabrasEnBancoDesordenadas,
                            desactivado: _comprobado,
                            alPulsar: _pulsarPalabraBanco,
                          ),
                          const SizedBox(height: 20),
                          _BotonEgiaztatu(
                            activo: _palabrasEnBancoDesordenadas.isEmpty &&
                                !_comprobado,
                            alPulsar: _egiaztatu,
                          ),
                          if (_comprobado && !esComposicionCorrectaAhora)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: _PistaRespuesta(
                                fraseCorrecta:
                                    _fraseActual.fraseCompletaEuskera,
                              ),
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

class _CabeceraBarra extends StatelessWidget {
  final int indiceFraseActual;
  final int frasesTotales;
  final int aciertos;

  const _CabeceraBarra({
    required this.indiceFraseActual,
    required this.frasesTotales,
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
              'ESALDI-ERAIKITZAILEA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
                letterSpacing: 2.5,
              ),
            ),
          ),
          Text(
            '$indiceFraseActual / $frasesTotales',
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

class _CajaTraduccionPista extends StatelessWidget {
  final String traduccion;
  const _CajaTraduccionPista({required this.traduccion});

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
            'GAZTELANIAZ',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: PaletaAek.tintaDiluida(0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            traduccion,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PaletaAek.tintaNegra,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonaComposicion extends StatelessWidget {
  final List<String> palabras;
  final bool comprobado;
  final bool esCorrecto;
  final void Function(int) alPulsarPalabra;

  const _ZonaComposicion({
    required this.palabras,
    required this.comprobado,
    required this.esCorrecto,
    required this.alPulsarPalabra,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorMarco = comprobado
        ? (esCorrecto
            ? PaletaAek.rojoRotulador
            : PaletaAek.tintaDiluida(0.5))
        : PaletaAek.tintaNegra;
    return MarcoRotulador(
      color: colorMarco,
      grosor: comprobado && esCorrecto ? 3.2 : 2.4,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        constraints: const BoxConstraints(minHeight: 68),
        width: double.infinity,
        child: palabras.isEmpty
            ? Center(
                child: Text(
                  'Hemen idatzi esaldia…',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: PaletaAek.tintaDiluida(0.45),
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(palabras.length, (indice) {
                  return _FichaPalabra(
                    texto: palabras[indice],
                    color: comprobado
                        ? (esCorrecto
                            ? PaletaAek.rojoRotulador
                            : PaletaAek.tintaDiluida(0.55))
                        : PaletaAek.tintaNegra,
                    alPulsar: comprobado ? null : () => alPulsarPalabra(indice),
                  );
                }),
              ),
      ),
    );
  }
}

class _BancoPalabrasDesordenadas extends StatelessWidget {
  final List<String> palabras;
  final bool desactivado;
  final void Function(int) alPulsar;

  const _BancoPalabrasDesordenadas({
    required this.palabras,
    required this.desactivado,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    if (palabras.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          'Hitz guztiak erabilita — EGIAZTATU.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: PaletaAek.tintaDiluida(0.6),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(palabras.length, (indice) {
        return _FichaPalabra(
          texto: palabras[indice],
          color: PaletaAek.tintaNegra,
          alPulsar: desactivado ? null : () => alPulsar(indice),
        );
      }),
    );
  }
}

class _FichaPalabra extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback? alPulsar;

  const _FichaPalabra({
    required this.texto,
    required this.color,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: alPulsar == null ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: alPulsar,
        behavior: HitTestBehavior.opaque,
        child: MarcoRotulador(
          color: color,
          grosor: 2.2,
          intensidadJitter: 1.0,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              texto,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonEgiaztatu extends StatelessWidget {
  final bool activo;
  final VoidCallback alPulsar;

  const _BotonEgiaztatu({required this.activo, required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: activo ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: activo ? alPulsar : null,
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

class _PistaRespuesta extends StatelessWidget {
  final String fraseCorrecta;
  const _PistaRespuesta({required this.fraseCorrecta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          'ZUZENA HAU DA:',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: PaletaAek.rojoRotulador,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          fraseCorrecta,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ],
    );
  }
}
