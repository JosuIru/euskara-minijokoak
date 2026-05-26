import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/generador_heuristikoa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';

/// Variante de Esaldi-Eraikitzailea que parte de oraciones extraídas
/// del texto del profesor. No hay traducción al español: el alumno
/// reconstruye el orden recordando lo leído.
class EsaldiSortuaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final String izenburua;
  final EsaldiEraikitzaileaGeneratuta datuak;
  final void Function(ResultadoAriketa) amaitzean;

  const EsaldiSortuaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.izenburua,
    required this.datuak,
    required this.amaitzean,
  });

  @override
  State<EsaldiSortuaPantaila> createState() => _EsaldiSortuaPantailaState();
}

class _EsaldiSortuaPantailaState extends State<EsaldiSortuaPantaila> {
  late DateTime _momentoInicio;
  int _indiceFrase = 0;
  int _aciertos = 0;
  List<String> _banco = const <String>[];
  List<String> _composicion = const <String>[];
  bool _comprobado = false;

  List<String> get _fraseActualEsperada => widget.datuak.oraciones[_indiceFrase];

  @override
  void initState() {
    super.initState();
    _momentoInicio = DateTime.now();
    _prepararFrase();
  }

  void _prepararFrase() {
    final List<String> desordenadas = List<String>.from(_fraseActualEsperada)
      ..shuffle();
    // Re-mezclar si por casualidad salió ya en orden (poco didáctico).
    if (_listaIguales(desordenadas, _fraseActualEsperada) &&
        desordenadas.length > 1) {
      desordenadas.shuffle();
    }
    setState(() {
      _banco = desordenadas;
      _composicion = const <String>[];
      _comprobado = false;
    });
  }

  bool _listaIguales(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _pulsarBanco(int indice) {
    if (_comprobado) return;
    final String palabra = _banco[indice];
    setState(() {
      _banco = List<String>.from(_banco)..removeAt(indice);
      _composicion = <String>[..._composicion, palabra];
    });
  }

  void _pulsarComposicion(int indice) {
    if (_comprobado) return;
    final String palabra = _composicion[indice];
    setState(() {
      _composicion = List<String>.from(_composicion)..removeAt(indice);
      _banco = <String>[..._banco, palabra];
    });
  }

  bool _esCorrecta() {
    if (_composicion.length != _fraseActualEsperada.length) return false;
    for (int i = 0; i < _composicion.length; i++) {
      if (_composicion[i].toLowerCase() !=
          _fraseActualEsperada[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  void _egiaztatu() {
    if (_banco.isNotEmpty) return;
    setState(() => _comprobado = true);
    if (_esCorrecta()) _aciertos += 1;
    Future<void>.delayed(const Duration(milliseconds: 1700), _avanzar);
  }

  void _avanzar() {
    if (!mounted) return;
    final bool fueUltima = _indiceFrase >= widget.datuak.oraciones.length - 1;
    if (fueUltima) {
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: _aciertos,
        intentosTotales: widget.datuak.oraciones.length,
        tiempoEmpleado: DateTime.now().difference(_momentoInicio),
      ));
      return;
    }
    setState(() => _indiceFrase += 1);
    _prepararFrase();
  }

  @override
  Widget build(BuildContext context) {
    final bool correcta = _comprobado && _esCorrecta();
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 91,
          child: Column(
            children: <Widget>[
              _Cabecera(
                titulo: widget.izenburua,
                indice: _indiceFrase + 1,
                total: widget.datuak.oraciones.length,
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
                          _PistaInstruccion(),
                          const SizedBox(height: 16),
                          _ZonaComposicion(
                            palabras: _composicion,
                            comprobado: _comprobado,
                            correcta: correcta,
                            alPulsar: _pulsarComposicion,
                          ),
                          const SizedBox(height: 16),
                          _BancoPalabras(
                            palabras: _banco,
                            desactivado: _comprobado,
                            alPulsar: _pulsarBanco,
                          ),
                          const SizedBox(height: 18),
                          _BotonEgiaztatu(
                            activo: _banco.isEmpty && !_comprobado,
                            alPulsar: _egiaztatu,
                          ),
                          if (_comprobado && !correcta)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: _PistaRespuestaCorrecta(
                                  fraseCorrecta:
                                      _fraseActualEsperada.join(' ')),
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

class _Cabecera extends StatelessWidget {
  final String titulo;
  final int indice;
  final int total;
  final int aciertos;

  const _Cabecera({
    required this.titulo,
    required this.indice,
    required this.total,
    required this.aciertos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          Expanded(
            child: Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
                letterSpacing: 2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$indice / $total',
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

class _PistaInstruccion extends StatelessWidget {
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
            'JARRAIBIDEA',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: PaletaAek.tintaDiluida(0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Esaldia hitzez hitz berreraiki. Gogoratu testuaren ordena.',
            style: TextStyle(
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

class _ZonaComposicion extends StatelessWidget {
  final List<String> palabras;
  final bool comprobado;
  final bool correcta;
  final void Function(int) alPulsar;

  const _ZonaComposicion({
    required this.palabras,
    required this.comprobado,
    required this.correcta,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorMarco = comprobado
        ? (correcta ? PaletaAek.rojoRotulador : PaletaAek.tintaDiluida(0.5))
        : PaletaAek.tintaNegra;
    return MarcoRotulador(
      color: colorMarco,
      grosor: comprobado && correcta ? 3.2 : 2.4,
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
                children: List<Widget>.generate(palabras.length, (int indice) {
                  return _FichaPalabra(
                    texto: palabras[indice],
                    color: comprobado
                        ? (correcta
                            ? PaletaAek.rojoRotulador
                            : PaletaAek.tintaDiluida(0.55))
                        : PaletaAek.tintaNegra,
                    alPulsar: comprobado ? null : () => alPulsar(indice),
                  );
                }),
              ),
      ),
    );
  }
}

class _BancoPalabras extends StatelessWidget {
  final List<String> palabras;
  final bool desactivado;
  final void Function(int) alPulsar;

  const _BancoPalabras({
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
      children: List<Widget>.generate(palabras.length, (int indice) {
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

class _PistaRespuestaCorrecta extends StatelessWidget {
  final String fraseCorrecta;

  const _PistaRespuestaCorrecta({required this.fraseCorrecta});

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
