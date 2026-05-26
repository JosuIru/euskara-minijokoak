import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../kantutegia/kantua.dart';
import '../../kantutegia/kantutegia_datuak.dart';
import '../../oinarriak/ariketa.dart';
import '../../oinarriak/paleta.dart';
import '../../oinarriak/pintor_rotulador.dart';

class HutsuneakPantaila extends StatefulWidget {
  final String identificadorAriketa;
  final void Function(ResultadoAriketa) amaitzean;

  const HutsuneakPantaila({
    super.key,
    required this.identificadorAriketa,
    required this.amaitzean,
  });

  @override
  State<HutsuneakPantaila> createState() => _HutsuneakPantailaState();
}

class _HutsuneakPantailaState extends State<HutsuneakPantaila> {
  Kantua? _kantuaAukeratuta;
  late DateTime _momentoInicioPartida;

  /// Asignación de palabra por hueco. Clave = índice del hueco (en orden
  /// de aparición en la letra), valor = palabra elegida por el alumno o
  /// null si todavía no la ha rellenado.
  Map<int, String?> _palabrasPorHueco = const <int, String?>{};

  /// Banco visible — palabras que aún no se han colocado.
  List<String> _bancoPalabrasDisponibles = const <String>[];

  /// Índice del hueco actualmente seleccionado (-1 si ninguno).
  int _indiceHuecoActivo = -1;

  /// true después de pulsar EGIAZTATU: bloquea cambios y muestra
  /// feedback (rojo = correcto, gris = incorrecto).
  bool _comprobado = false;

  void _empezarConKantua(Kantua kantua) {
    final List<String> palabras = <String>[
      ...kantua.palabrasEsperadasOrdenadas,
      ...kantua.distraktoreak,
    ]..shuffle();
    setState(() {
      _kantuaAukeratuta = kantua;
      _bancoPalabrasDisponibles = List<String>.from(palabras);
      _palabrasPorHueco = <int, String?>{
        for (int indiceHueco = 0;
            indiceHueco < kantua.cantidadDeHuecos;
            indiceHueco++)
          indiceHueco: null,
      };
      _indiceHuecoActivo = -1;
      _comprobado = false;
      _momentoInicioPartida = DateTime.now();
    });
  }

  void _reiniciarKantuaActual() {
    if (_kantuaAukeratuta == null) return;
    _empezarConKantua(_kantuaAukeratuta!);
  }

  void _pulsarHueco(int indiceHueco) {
    if (_comprobado) return;
    final String? palabraAsignada = _palabrasPorHueco[indiceHueco];
    if (palabraAsignada != null) {
      // Devolver la palabra al banco y dejar el hueco activo.
      setState(() {
        _bancoPalabrasDisponibles = <String>[
          ..._bancoPalabrasDisponibles,
          palabraAsignada,
        ];
        _palabrasPorHueco[indiceHueco] = null;
        _indiceHuecoActivo = indiceHueco;
      });
      return;
    }
    setState(() {
      _indiceHuecoActivo = indiceHueco;
    });
  }

  void _pulsarPalabraBanco(String palabra) {
    if (_comprobado) return;
    int huecoDestino = _indiceHuecoActivo;
    if (huecoDestino == -1) {
      // Si no hay hueco activo, asignar al primer hueco vacío en orden.
      huecoDestino = _palabrasPorHueco.entries
          .firstWhere(
            (entrada) => entrada.value == null,
            orElse: () => const MapEntry<int, String?>(-1, null),
          )
          .key;
      if (huecoDestino == -1) return;
    }
    setState(() {
      _palabrasPorHueco[huecoDestino] = palabra;
      _bancoPalabrasDisponibles = List<String>.from(_bancoPalabrasDisponibles)
        ..remove(palabra);
      // Mover el foco al siguiente hueco vacío.
      final List<int> indicesVacios = _palabrasPorHueco.entries
          .where((entrada) => entrada.value == null)
          .map((entrada) => entrada.key)
          .toList();
      _indiceHuecoActivo = indicesVacios.isEmpty ? -1 : indicesVacios.first;
    });
  }

  void _egiaztatu() {
    if (_kantuaAukeratuta == null) return;
    setState(() {
      _comprobado = true;
    });
    final List<String> esperadas = _kantuaAukeratuta!.palabrasEsperadasOrdenadas;
    int aciertos = 0;
    for (int indiceHueco = 0; indiceHueco < esperadas.length; indiceHueco++) {
      final String? asignada = _palabrasPorHueco[indiceHueco];
      if (asignada != null &&
          asignada.toLowerCase() == esperadas[indiceHueco].toLowerCase()) {
        aciertos += 1;
      }
    }
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      widget.amaitzean(ResultadoAriketa(
        identificadorAriketa: widget.identificadorAriketa,
        momentoFin: DateTime.now(),
        aciertos: aciertos,
        intentosTotales: esperadas.length,
        tiempoEmpleado: DateTime.now().difference(_momentoInicioPartida),
      ));
    });
  }

  bool get _todosHuecosLlenos =>
      _palabrasPorHueco.values.every((palabra) => palabra != null);

  Future<void> _abrirYoutube() async {
    final String? url = _kantuaAukeratuta?.urlYoutube;
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 41,
          child: _kantuaAukeratuta == null
              ? _SeleccionKantua(alElegir: _empezarConKantua)
              : _PantallaKantuLanean(
                  kantua: _kantuaAukeratuta!,
                  palabrasPorHueco: _palabrasPorHueco,
                  bancoPalabras: _bancoPalabrasDisponibles,
                  indiceHuecoActivo: _indiceHuecoActivo,
                  comprobado: _comprobado,
                  todosHuecosLlenos: _todosHuecosLlenos,
                  alPulsarHueco: _pulsarHueco,
                  alPulsarPalabra: _pulsarPalabraBanco,
                  alEgiaztatu: _egiaztatu,
                  alReiniciar: _reiniciarKantuaActual,
                  alAbrirYoutube: _abrirYoutube,
                ),
        ),
      ),
    );
  }
}

class _SeleccionKantua extends StatelessWidget {
  final void Function(Kantua) alElegir;
  const _SeleccionKantua({required this.alElegir});

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
                children: const <Widget>[
                  BackButton(color: PaletaAek.tintaNegra),
                  SizedBox(width: 8),
                  Text(
                    'KANTUA AUKERATU',
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
                'Aukeratu kantu bat eta letrako hutsuneak bete.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: PaletaAek.tintaDiluida(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ...kantutegiaInicial.map(
                (Kantua kantua) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaSeleccionKantua(
                    kantua: kantua,
                    alPulsar: () => alElegir(kantua),
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

class _TarjetaSeleccionKantua extends StatelessWidget {
  final Kantua kantua;
  final VoidCallback alPulsar;

  const _TarjetaSeleccionKantua({required this.kantua, required this.alPulsar});

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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: <Widget>[
              const Icon(Icons.music_note,
                  size: 32, color: PaletaAek.rojoRotulador),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      kantua.izenburua,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: PaletaAek.tintaNegra,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      kantua.egileaEdoIturria,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.tintaDiluida(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kantua.azalpenLaburra,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: PaletaAek.tintaDiluida(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${kantua.cantidadDeHuecos} hutsune',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: PaletaAek.tintaDiluida(0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_ios,
                      color: PaletaAek.rojoRotulador, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantallaKantuLanean extends StatelessWidget {
  final Kantua kantua;
  final Map<int, String?> palabrasPorHueco;
  final List<String> bancoPalabras;
  final int indiceHuecoActivo;
  final bool comprobado;
  final bool todosHuecosLlenos;
  final void Function(int) alPulsarHueco;
  final void Function(String) alPulsarPalabra;
  final VoidCallback alEgiaztatu;
  final VoidCallback alReiniciar;
  final VoidCallback alAbrirYoutube;

  const _PantallaKantuLanean({
    required this.kantua,
    required this.palabrasPorHueco,
    required this.bancoPalabras,
    required this.indiceHuecoActivo,
    required this.comprobado,
    required this.todosHuecosLlenos,
    required this.alPulsarHueco,
    required this.alPulsarPalabra,
    required this.alEgiaztatu,
    required this.alReiniciar,
    required this.alAbrirYoutube,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> palabrasEsperadas = kantua.palabrasEsperadasOrdenadas;
    return Column(
      children: <Widget>[
        _Cabecera(
          kantua: kantua,
          alAbrirYoutube: alAbrirYoutube,
          alReiniciar: alReiniciar,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: <Widget>[
                    _LetraCantada(
                      kantua: kantua,
                      palabrasPorHueco: palabrasPorHueco,
                      palabrasEsperadas: palabrasEsperadas,
                      indiceHuecoActivo: indiceHuecoActivo,
                      comprobado: comprobado,
                      alPulsarHueco: alPulsarHueco,
                    ),
                    const SizedBox(height: 24),
                    _BancoPalabras(
                      palabras: bancoPalabras,
                      desactivado: comprobado,
                      alPulsar: alPulsarPalabra,
                    ),
                    const SizedBox(height: 18),
                    _BotonEgiaztatu(
                      activo: todosHuecosLlenos && !comprobado,
                      alPulsar: alEgiaztatu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Cabecera extends StatelessWidget {
  final Kantua kantua;
  final VoidCallback alAbrirYoutube;
  final VoidCallback alReiniciar;

  const _Cabecera({
    required this.kantua,
    required this.alAbrirYoutube,
    required this.alReiniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  kantua.izenburua.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: PaletaAek.tintaNegra,
                    letterSpacing: 2.5,
                  ),
                ),
                Text(
                  kantua.egileaEdoIturria,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: PaletaAek.tintaDiluida(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (kantua.urlYoutube != null)
            TextButton.icon(
              onPressed: alAbrirYoutube,
              icon: const Icon(Icons.play_circle_outline,
                  color: PaletaAek.rojoRotulador),
              label: const Text(
                'ENTZUN',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  color: PaletaAek.rojoRotulador,
                  letterSpacing: 1.5,
                ),
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

class _LetraCantada extends StatelessWidget {
  final Kantua kantua;
  final Map<int, String?> palabrasPorHueco;
  final List<String> palabrasEsperadas;
  final int indiceHuecoActivo;
  final bool comprobado;
  final void Function(int) alPulsarHueco;

  const _LetraCantada({
    required this.kantua,
    required this.palabrasPorHueco,
    required this.palabrasEsperadas,
    required this.indiceHuecoActivo,
    required this.comprobado,
    required this.alPulsarHueco,
  });

  @override
  Widget build(BuildContext context) {
    int indiceHuecoCorriente = -1;
    return MarcoRotulador(
      grosor: 2.4,
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        width: double.infinity,
        child: Column(
          children: kantua.versoak.map((List<FragmentoVerso> verso) {
            final List<Widget> piezasVerso = <Widget>[];
            for (final FragmentoVerso fragmento in verso) {
              if (fragmento.esHueco) {
                indiceHuecoCorriente += 1;
                final int indiceLocal = indiceHuecoCorriente;
                final String? palabraAsignada = palabrasPorHueco[indiceLocal];
                final bool esActivo = indiceHuecoActivo == indiceLocal;
                final bool esCorrecto = comprobado &&
                    palabraAsignada != null &&
                    palabraAsignada.toLowerCase() ==
                        palabrasEsperadas[indiceLocal].toLowerCase();
                final bool esIncorrecto = comprobado &&
                    !esCorrecto &&
                    palabraAsignada != null;
                piezasVerso.add(_HuecoWidget(
                  palabraAsignada: palabraAsignada,
                  esActivo: esActivo,
                  esCorrecto: esCorrecto,
                  esIncorrecto: esIncorrecto,
                  palabraEsperada: palabrasEsperadas[indiceLocal],
                  mostrarRespuestaCorrecta: comprobado,
                  alPulsar: () => alPulsarHueco(indiceLocal),
                ));
              } else {
                piezasVerso.add(Text(
                  fragmento.textoFijo!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    color: PaletaAek.tintaNegra,
                    height: 1.6,
                  ),
                ));
              }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: piezasVerso,
              ),
            );
          }).toList(growable: false),
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
    final String textoMostrado =
        palabraAsignada ?? '________';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    width: esActivo || esCorrecto ? 2.6 : 1.8,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                textoMostrado,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
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
                    fontSize: 14,
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
                fontSize: 18,
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
