import 'package:flutter/material.dart';

import '../oinarriak/almacen_local.dart';
import '../oinarriak/ariketa.dart';
import '../oinarriak/katalogoa.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Resumen agregado por ejercicio, calculado a partir del historial.
class _EstadisticaPorAriketa {
  final String identificadorAriketa;
  final List<ResultadoAriketa> partidas;

  _EstadisticaPorAriketa({
    required this.identificadorAriketa,
    required this.partidas,
  });

  int get cantidadPartidas => partidas.length;

  double get porcentajePromedio {
    if (partidas.isEmpty) return 0;
    final double sumaPorcentajes =
        partidas.fold(0, (acumulado, resultado) =>
            acumulado + resultado.porcentajeAciertos);
    return sumaPorcentajes / partidas.length;
  }

  double get mejorPorcentaje {
    if (partidas.isEmpty) return 0;
    return partidas
        .map((resultado) => resultado.porcentajeAciertos)
        .reduce((maximo, actual) => actual > maximo ? actual : maximo);
  }

  DateTime get ultimaPartida {
    return partidas
        .map((resultado) => resultado.momentoFin)
        .reduce((mayor, actual) => actual.isAfter(mayor) ? actual : mayor);
  }
}

class NireJarraipenaOrria extends StatefulWidget {
  const NireJarraipenaOrria({super.key});

  @override
  State<NireJarraipenaOrria> createState() => _NireJarraipenaOrriaState();
}

class _NireJarraipenaOrriaState extends State<NireJarraipenaOrria> {
  Future<List<ResultadoAriketa>>? _futuroHistorial;
  NivelEuskera? _mailaGordeta;

  @override
  void initState() {
    super.initState();
    _recargarHistorial();
    _cargarMaila();
  }

  void _recargarHistorial() {
    setState(() {
      _futuroHistorial = AlmacenLocal.instancia.cargarHistorial();
    });
  }

  Future<void> _cargarMaila() async {
    final NivelEuskera? maila =
        await AlmacenLocal.instancia.cargarMailaAukeratutakoa();
    if (!mounted) return;
    setState(() => _mailaGordeta = maila);
  }

  Future<void> _aldatuMaila() async {
    await AlmacenLocal.instancia.borrarMailaAukeratutakoa();
    if (!mounted) return;
    setState(() => _mailaGordeta = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mailaren ahaztu da. Hurrengo minijokoan berriz hautatu ahal izango duzu.',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: PaletaAek.tintaNegra,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmarBorrarHistorial() async {
    final bool? confirma = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: PaletaAek.papelViejo,
        title: const Text(
          'Historiala garbitu?',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: PaletaAek.tintaNegra,
          ),
        ),
        content: const Text(
          'Egindako ariketa guztien emaitzak ezabatuko dira. '
          'Ekintza hau ezin da desegin.',
          style: TextStyle(
            fontFamily: 'monospace',
            color: PaletaAek.tintaNegra,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'UTZI',
              style: TextStyle(
                fontFamily: 'monospace',
                color: PaletaAek.tintaNegra,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'GARBITU',
              style: TextStyle(
                fontFamily: 'monospace',
                color: PaletaAek.rojoRotulador,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirma == true) {
      await AlmacenLocal.instancia.borrarHistorial();
      _recargarHistorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 53,
          child: Column(
            children: <Widget>[
              _Cabecera(alGarbitu: _confirmarBorrarHistorial),
              if (_mailaGordeta != null)
                _BannerMaila(
                  maila: _mailaGordeta!,
                  alAldatu: _aldatuMaila,
                ),
              Expanded(
                child: FutureBuilder<List<ResultadoAriketa>>(
                  future: _futuroHistorial,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ResultadoAriketa>> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: PaletaAek.tintaNegra),
                      );
                    }
                    final List<ResultadoAriketa> historial =
                        snapshot.data ?? <ResultadoAriketa>[];
                    if (historial.isEmpty) {
                      return const _EstadoVacio();
                    }
                    return _ListaEstadisticas(historial: historial);
                  },
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
  final VoidCallback alGarbitu;
  const _Cabecera({required this.alGarbitu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: <Widget>[
          const BackButton(color: PaletaAek.tintaNegra),
          const SizedBox(width: 4),
          const Text(
            'NIRE JARRAIPENA',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: PaletaAek.tintaNegra,
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: alGarbitu,
            icon: const Icon(Icons.delete_outline,
                color: PaletaAek.tintaNegra),
            label: const Text(
              'GARBITU',
              style: TextStyle(
                fontFamily: 'monospace',
                color: PaletaAek.tintaNegra,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMaila extends StatelessWidget {
  final NivelEuskera maila;
  final VoidCallback alAldatu;

  const _BannerMaila({required this.maila, required this.alAldatu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: PaletaAek.rojoRotulador, width: 1.6),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.school_outlined,
                color: PaletaAek.rojoRotulador, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Zure maila: ${maila.etiqueta} — ${maila.descripcionEuskera}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: PaletaAek.tintaNegra,
                ),
              ),
            ),
            TextButton(
              onPressed: alAldatu,
              child: const Text(
                'ALDATU',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: PaletaAek.rojoRotulador,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.menu_book_outlined,
                  size: 64, color: PaletaAek.tintaDiluida(0.35)),
              const SizedBox(height: 16),
              const Text(
                'Oraindik ez duzu ariketarik egin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PaletaAek.tintaNegra,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hasi jolasten eta hemen agertuko da zure aurrerapena.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: PaletaAek.tintaDiluida(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaEstadisticas extends StatelessWidget {
  final List<ResultadoAriketa> historial;
  const _ListaEstadisticas({required this.historial});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<ResultadoAriketa>> partidasPorAriketa =
        <String, List<ResultadoAriketa>>{};
    for (final ResultadoAriketa resultado in historial) {
      partidasPorAriketa
          .putIfAbsent(resultado.identificadorAriketa, () => <ResultadoAriketa>[])
          .add(resultado);
    }
    final List<_EstadisticaPorAriketa> estadisticas = partidasPorAriketa.entries
        .map(
          (entrada) => _EstadisticaPorAriketa(
            identificadorAriketa: entrada.key,
            partidas: entrada.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.ultimaPartida.compareTo(a.ultimaPartida));

    final int totalPartidas = historial.length;
    final double porcentajeGlobal = historial.isEmpty
        ? 0
        : historial.fold<double>(0,
                (acumulado, resultado) => acumulado + resultado.porcentajeAciertos) /
            historial.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ResumenGlobal(
                totalPartidas: totalPartidas,
                porcentajeMedio: porcentajeGlobal,
              ),
              const SizedBox(height: 20),
              ...estadisticas.map(
                (_EstadisticaPorAriketa estadistica) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaEstadisticaAriketa(estadistica: estadistica),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenGlobal extends StatelessWidget {
  final int totalPartidas;
  final double porcentajeMedio;

  const _ResumenGlobal({
    required this.totalPartidas,
    required this.porcentajeMedio,
  });

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 3,
      intensidadJitter: 1.4,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PARTIDA GUZTIRA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: PaletaAek.tintaDiluida(0.65),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '$totalPartidas',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.tintaNegra,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BATEZ BESTEKO ASMATZE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: PaletaAek.tintaDiluida(0.65),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '${(porcentajeMedio * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.rojoRotulador,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEstadisticaAriketa extends StatelessWidget {
  final _EstadisticaPorAriketa estadistica;
  const _TarjetaEstadisticaAriketa({required this.estadistica});

  @override
  Widget build(BuildContext context) {
    final Ariketa? ariketa = KatalogoAek.identifikatzaileagatik(
        estadistica.identificadorAriketa);
    final String tituloMostrado =
        ariketa?.izenburua ?? estadistica.identificadorAriketa;
    final String categoriaMostrada =
        ariketa?.kategoria.etiquetaEuskera ?? '—';
    final int porcentajeMedioRedondeado =
        (estadistica.porcentajePromedio * 100).round();
    final int mejorPorcentajeRedondeado =
        (estadistica.mejorPorcentaje * 100).round();

    return MarcoRotulador(
      grosor: 2.4,
      intensidadJitter: 1.1,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tituloMostrado,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: PaletaAek.tintaNegra,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        categoriaMostrada,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: PaletaAek.tintaDiluida(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: PaletaAek.rojoRotulador,
                      width: 1.4,
                    ),
                  ),
                  child: Text(
                    '$porcentajeMedioRedondeado%',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.rojoRotulador,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _Estadistica(
                    etiqueta: 'Partidak',
                    valor: '${estadistica.cantidadPartidas}'),
                const SizedBox(width: 24),
                _Estadistica(
                    etiqueta: 'Onena',
                    valor: '$mejorPorcentajeRedondeado%'),
                const SizedBox(width: 24),
                _Estadistica(
                    etiqueta: 'Azken aldia',
                    valor: _formatearFecha(estadistica.ultimaPartida)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Devuelve un texto tipo "Gaur", "Atzo" o "DD/MM" según cuán cerca está
  /// la fecha del momento actual.
  String _formatearFecha(DateTime fecha) {
    final DateTime ahora = DateTime.now();
    final int diasDeDiferencia =
        DateTime(ahora.year, ahora.month, ahora.day)
            .difference(DateTime(fecha.year, fecha.month, fecha.day))
            .inDays;
    if (diasDeDiferencia == 0) return 'Gaur';
    if (diasDeDiferencia == 1) return 'Atzo';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}';
  }
}

class _Estadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Estadistica({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          etiqueta.toUpperCase(),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: PaletaAek.tintaDiluida(0.6),
            letterSpacing: 1.5,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ],
    );
  }
}
