import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import '../../oinarriak/generador_heuristikoa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';

/// Variante de Hutsuneak que se juega con datos generados a partir de
/// un texto del profesor (no un catálogo de canciones). Misma mecánica
/// de marcar huecos y arrastrar palabras del banco, pero el contenido
/// es prosa libre.
class HutsuneakSortuaPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final String izenburua;
  final HutsuneakGeneratuta datuak;
  final void Function(ResultadoAriketa) amaitzean;

  const HutsuneakSortuaPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.izenburua,
    required this.datuak,
    required this.amaitzean,
  });

  @override
  State<HutsuneakSortuaPantaila> createState() =>
      _HutsuneakSortuaPantailaState();
}

class _HutsuneakSortuaPantailaState extends State<HutsuneakSortuaPantaila> {
  late Map<int, String?> _palabrasPorHueco;
  late List<String> _bancoDisponible;
  int _indiceHuecoActivo = -1;
  bool _comprobado = false;
  late DateTime _momentoInicio;

  @override
  void initState() {
    super.initState();
    _reiniciar();
  }

  void _reiniciar() {
    setState(() {
      _palabrasPorHueco = <int, String?>{
        for (int indiceHueco = 0;
            indiceHueco < widget.datuak.posicionesHueco.length;
            indiceHueco++)
          indiceHueco: null,
      };
      _bancoDisponible = List<String>.from(widget.datuak.bancoPalabras);
      _indiceHuecoActivo = -1;
      _comprobado = false;
      _momentoInicio = DateTime.now();
    });
  }

  void _pulsarHueco(int indiceHueco) {
    if (_comprobado) return;
    final String? asignada = _palabrasPorHueco[indiceHueco];
    if (asignada != null) {
      setState(() {
        _bancoDisponible = <String>[..._bancoDisponible, asignada];
        _palabrasPorHueco[indiceHueco] = null;
        _indiceHuecoActivo = indiceHueco;
      });
      return;
    }
    setState(() => _indiceHuecoActivo = indiceHueco);
  }

  void _pulsarPalabra(String palabra) {
    if (_comprobado) return;
    int destino = _indiceHuecoActivo;
    if (destino == -1) {
      destino = _palabrasPorHueco.entries
          .firstWhere(
            (MapEntry<int, String?> e) => e.value == null,
            orElse: () => const MapEntry<int, String?>(-1, null),
          )
          .key;
      if (destino == -1) return;
    }
    setState(() {
      _palabrasPorHueco[destino] = palabra;
      _bancoDisponible = List<String>.from(_bancoDisponible)..remove(palabra);
      final List<int> vacios = _palabrasPorHueco.entries
          .where((MapEntry<int, String?> e) => e.value == null)
          .map((MapEntry<int, String?> e) => e.key)
          .toList();
      _indiceHuecoActivo = vacios.isEmpty ? -1 : vacios.first;
    });
  }

  void _egiaztatu() {
    setState(() => _comprobado = true);
    final List<int> posiciones = widget.datuak.posicionesHueco;
    final List<String> tokens = widget.datuak.tokensOrden;
    int aciertos = 0;
    for (int indiceHueco = 0; indiceHueco < posiciones.length; indiceHueco++) {
      final String? asignada = _palabrasPorHueco[indiceHueco];
      final String esperada = tokens[posiciones[indiceHueco]];
      if (asignada != null &&
          asignada.toLowerCase() == esperada.toLowerCase()) {
        aciertos += 1;
      }
    }
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: aciertos,
        intentosTotales: posiciones.length,
        tiempoEmpleado: DateTime.now().difference(_momentoInicio),
      ));
    });
  }

  bool get _todosLlenos =>
      _palabrasPorHueco.values.every((String? p) => p != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 23,
          child: Column(
            children: <Widget>[
              _Cabecera(titulo: widget.izenburua, alReiniciar: _reiniciar),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        children: <Widget>[
                          _BloqueTextoConHuecos(
                            tokens: widget.datuak.tokensOrden,
                            posicionesHueco: widget.datuak.posicionesHueco,
                            palabrasPorHueco: _palabrasPorHueco,
                            indiceHuecoActivo: _indiceHuecoActivo,
                            comprobado: _comprobado,
                            alPulsarHueco: _pulsarHueco,
                          ),
                          const SizedBox(height: 22),
                          _BancoPalabras(
                            palabras: _bancoDisponible,
                            desactivado: _comprobado,
                            alPulsar: _pulsarPalabra,
                          ),
                          const SizedBox(height: 18),
                          _BotonEgiaztatu(
                            activo: _todosLlenos && !_comprobado,
                            alPulsar: _egiaztatu,
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
  final VoidCallback alReiniciar;

  const _Cabecera({required this.titulo, required this.alReiniciar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          Expanded(
            child: Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
                letterSpacing: 2.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: alReiniciar,
            icon: const Icon(Icons.refresh, color: PaletaAek.tintaNegra),
            tooltip: 'Berrabiarazi',
          ),
        ],
      ),
    );
  }
}

class _BloqueTextoConHuecos extends StatelessWidget {
  final List<String> tokens;
  final List<int> posicionesHueco;
  final Map<int, String?> palabrasPorHueco;
  final int indiceHuecoActivo;
  final bool comprobado;
  final void Function(int) alPulsarHueco;

  const _BloqueTextoConHuecos({
    required this.tokens,
    required this.posicionesHueco,
    required this.palabrasPorHueco,
    required this.indiceHuecoActivo,
    required this.comprobado,
    required this.alPulsarHueco,
  });

  @override
  Widget build(BuildContext context) {
    final Set<int> posicionesSet = posicionesHueco.toSet();
    final Map<int, int> indiceHuecoPorPosicion = <int, int>{
      for (int i = 0; i < posicionesHueco.length; i++) posicionesHueco[i]: i,
    };
    final List<Widget> piezas = <Widget>[];
    for (int posicion = 0; posicion < tokens.length; posicion++) {
      if (posicionesSet.contains(posicion)) {
        final int indiceHueco = indiceHuecoPorPosicion[posicion]!;
        final String? asignada = palabrasPorHueco[indiceHueco];
        final String esperada = tokens[posicion];
        final bool esActivo = indiceHuecoActivo == indiceHueco;
        final bool esCorrecto = comprobado &&
            asignada != null &&
            asignada.toLowerCase() == esperada.toLowerCase();
        final bool esIncorrecto = comprobado && !esCorrecto && asignada != null;
        piezas.add(_HuecoWidget(
          palabraAsignada: asignada,
          esActivo: esActivo,
          esCorrecto: esCorrecto,
          esIncorrecto: esIncorrecto,
          palabraEsperada: esperada,
          mostrarRespuestaCorrecta: comprobado,
          alPulsar: () => alPulsarHueco(indiceHueco),
        ));
      } else {
        piezas.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Text(
            tokens[posicion],
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              color: PaletaAek.tintaNegra,
              height: 1.5,
            ),
          ),
        ));
      }
    }
    return MarcoRotulador(
      grosor: 2.4,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: piezas,
        ),
      ),
    );
  }
}

class _HuecoWidget extends StatelessWidget {
  final String? palabraAsignada;
  final bool esActivo;
  final bool esCorrecto;
  final bool esIncorrecto;
  final String palabraEsperada;
  final bool mostrarRespuestaCorrecta;
  final VoidCallback alPulsar;

  const _HuecoWidget({
    required this.palabraAsignada,
    required this.esActivo,
    required this.esCorrecto,
    required this.esIncorrecto,
    required this.palabraEsperada,
    required this.mostrarRespuestaCorrecta,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorBorde = esCorrecto
        ? PaletaAek.rojoRotulador
        : esIncorrecto
            ? PaletaAek.tintaDiluida(0.45)
            : esActivo
                ? PaletaAek.rojoRotulador
                : PaletaAek.tintaNegra;
    final Color colorTexto = esCorrecto
        ? PaletaAek.rojoRotulador
        : esIncorrecto
            ? PaletaAek.tintaDiluida(0.5)
            : PaletaAek.tintaNegra;
    final String textoMostrado = palabraAsignada ?? '________';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: alPulsar,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorBorde,
                    width: esActivo || esCorrecto ? 2.4 : 1.6,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                textoMostrado,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorTexto,
                  decoration: esIncorrecto
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: PaletaAek.tintaDiluida(0.5),
                ),
              ),
            ),
            if (esIncorrecto && mostrarRespuestaCorrecta)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  palabraEsperada,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: PaletaAek.rojoRotulador,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BancoPalabras extends StatelessWidget {
  final List<String> palabras;
  final bool desactivado;
  final void Function(String) alPulsar;

  const _BancoPalabras({
    required this.palabras,
    required this.desactivado,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    if (palabras.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          'Hitz guztiak erabili dituzu — EGIAZTATU sakatu.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: PaletaAek.tintaDiluida(0.7),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: palabras
          .map(
            (String palabra) => _ChipPalabra(
              palabra: palabra,
              desactivado: desactivado,
              alPulsar: () => alPulsar(palabra),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ChipPalabra extends StatelessWidget {
  final String palabra;
  final bool desactivado;
  final VoidCallback alPulsar;

  const _ChipPalabra({
    required this.palabra,
    required this.desactivado,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: desactivado ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: desactivado ? null : alPulsar,
        behavior: HitTestBehavior.opaque,
        child: MarcoRotulador(
          grosor: 2.2,
          intensidadJitter: 1.0,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              palabra,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: PaletaAek.tintaNegra,
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: const Text(
              'EGIAZTATU',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
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
