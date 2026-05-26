import 'package:flutter/material.dart';

import '../oinarriak/ariketa.dart';
import '../oinarriak/ariketa_sortua.dart';
import '../oinarriak/ezarpenak.dart';
import '../oinarriak/generador_heuristikoa.dart';
import '../oinarriak/generador_llm.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla con la lista de ejercicios generados a partir de textos del
/// profesor. Desde aquí se entra al creador y se ven/borran los que ya
/// existen. Cada entrada de la lista corresponde a un minijuego concreto
/// (Hutsuneak, Esaldi-Eraikitzailea o Hitz-Zaparrada).
class TestutikSortuZerrenda extends StatefulWidget {
  const TestutikSortuZerrenda({super.key});

  @override
  State<TestutikSortuZerrenda> createState() => _TestutikSortuZerrendaState();
}

class _TestutikSortuZerrendaState extends State<TestutikSortuZerrenda> {
  Future<List<AriketaSortua>>? _futuroLista;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _futuroLista = AlmacenAriketaSortua.instancia.cargarTodas();
    });
  }

  Future<void> _navegarASortzailea() async {
    final bool? hayCambios = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const TestutikSortuSortzailea(),
      ),
    );
    if (hayCambios == true) _recargar();
  }

  Future<void> _confirmarEzabaketa(AriketaSortua ariketa) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: PaletaAek.papelViejo,
        title: const Text(
          'Ariketa hau ezabatu?',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: PaletaAek.tintaNegra,
          ),
        ),
        content: Text(
          '"${ariketa.izenburua}" ezabatuko da. Ezin da desegin.',
          style: const TextStyle(
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
              'EZABATU',
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
    if (confirmado == true) {
      await AlmacenAriketaSortua.instancia.ezabatu(ariketa.id);
      _recargar();
    }
  }

  void _jugarAriketa(AriketaSortua ariketa) {
    Navigator.of(context).pushNamed(
      '/minijokoa/${_identificadorMinijuegoPara(ariketa.tipoMinijuegoa)}'
      '?sortua=${ariketa.id}',
    );
  }

  String _identificadorMinijuegoPara(TipoMinijuegoSortua tipo) {
    switch (tipo) {
      case TipoMinijuegoSortua.hutsuneak:
        return 'hutsuneak';
      case TipoMinijuegoSortua.esaldiEraikitzailea:
        return 'esaldi_eraikitzailea';
      case TipoMinijuegoSortua.hitzZaparrada:
        return 'hitz_zaparrada';
      case TipoMinijuegoSortua.lotura:
        return 'lotura';
      case TipoMinijuegoSortua.diktatua:
        return 'diktatua';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      appBar: AppBar(
        backgroundColor: PaletaAek.papelViejo,
        surfaceTintColor: PaletaAek.papelViejo,
        elevation: 0,
        iconTheme: const IconThemeData(color: PaletaAek.tintaNegra),
        title: const Text(
          'TESTUTIK SORTU',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarASortzailea,
        backgroundColor: PaletaAek.rojoRotulador,
        foregroundColor: PaletaAek.papelViejo,
        icon: const Icon(Icons.add),
        label: const Text(
          'TESTU BERRIA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: FondoPapelEnvejecido(
        semilla: 11,
        child: FutureBuilder<List<AriketaSortua>>(
          future: _futuroLista,
          builder: (BuildContext context,
              AsyncSnapshot<List<AriketaSortua>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                    color: PaletaAek.rojoRotulador),
              );
            }
            final List<AriketaSortua> lista = snapshot.data!;
            if (lista.isEmpty) {
              return _ListaHutsa(onNuevoTexto: _navegarASortzailea);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: lista.length,
              itemBuilder: (BuildContext context, int indice) {
                final AriketaSortua ariketa = lista[indice];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TarjetaAriketaSortua(
                    ariketa: ariketa,
                    alJugar: () => _jugarAriketa(ariketa),
                    alEliminar: () => _confirmarEzabaketa(ariketa),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ListaHutsa extends StatelessWidget {
  final VoidCallback onNuevoTexto;

  const _ListaHutsa({required this.onNuevoTexto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.menu_book_outlined,
                size: 56, color: PaletaAek.tintaNegra),
            const SizedBox(height: 16),
            const Text(
              'Oraindik ez dago testu sorturik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: PaletaAek.tintaNegra,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Itsasi euskarazko testu bat eta appak hutsuneak, '
              'esaldi-puzzleak eta hitz-zaparrada sortuko ditu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: PaletaAek.tintaDiluida(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onNuevoTexto,
              behavior: HitTestBehavior.opaque,
              child: MarcoRotulador(
                color: PaletaAek.rojoRotulador,
                grosor: 3,
                intensidadJitter: 1.3,
                child: Container(
                  color: PaletaAek.papelViejo,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  child: const Text(
                    'TESTU BERRIA ITSATSI',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.rojoRotulador,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAriketaSortua extends StatelessWidget {
  final AriketaSortua ariketa;
  final VoidCallback alJugar;
  final VoidCallback alEliminar;

  const _TarjetaAriketaSortua({
    required this.ariketa,
    required this.alJugar,
    required this.alEliminar,
  });

  String get _etiquetaTipo {
    switch (ariketa.tipoMinijuegoa) {
      case TipoMinijuegoSortua.hutsuneak:
        return 'HUTSUNEAK';
      case TipoMinijuegoSortua.esaldiEraikitzailea:
        return 'ESALDI-ERAIKITZAILEA';
      case TipoMinijuegoSortua.hitzZaparrada:
        return 'HITZ-ZAPARRADA';
      case TipoMinijuegoSortua.lotura:
        return 'LOTURA';
      case TipoMinijuegoSortua.diktatua:
        return 'DIKTATUA';
    }
  }

  String get _etiquetaOrigen =>
      ariketa.jatorria == OrigenGeneracion.llm ? 'LLM' : 'HEURISTIKO';

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      intensidadJitter: 1.1,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: PaletaAek.rojoRotulador, width: 1.4),
                  ),
                  child: Text(
                    _etiquetaTipo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: PaletaAek.rojoRotulador,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _etiquetaOrigen,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: PaletaAek.tintaDiluida(0.55),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: alEliminar,
                  tooltip: 'Ezabatu',
                  icon: const Icon(Icons.delete_outline,
                      color: PaletaAek.tintaNegra),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              ariketa.izenburua,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: PaletaAek.tintaNegra,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ariketa.testuJatorria.length > 110
                  ? '${ariketa.testuJatorria.substring(0, 110)}…'
                  : ariketa.testuJatorria,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: PaletaAek.tintaDiluida(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: alJugar,
                behavior: HitTestBehavior.opaque,
                child: MarcoRotulador(
                  color: PaletaAek.rojoRotulador,
                  grosor: 2,
                  intensidadJitter: 1.0,
                  child: Container(
                    color: PaletaAek.papelViejo,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    child: const Text(
                      'JOLASTU',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: PaletaAek.rojoRotulador,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla del creador: TextArea grande con el texto + selectores de
/// qué tipos generar. Pulsar SORTU lanza la generación heurística, que
/// se ejecuta en milisegundos. Si se confirma, se guardan las
/// `AriketaSortua` resultantes en el almacén y se vuelve atrás.
class TestutikSortuSortzailea extends StatefulWidget {
  const TestutikSortuSortzailea({super.key});

  @override
  State<TestutikSortuSortzailea> createState() =>
      _TestutikSortuSortzaileaState();
}

class _TestutikSortuSortzaileaState extends State<TestutikSortuSortzailea> {
  final TextEditingController _controladorTitulo =
      TextEditingController(text: 'Testu berria');
  final TextEditingController _controladorTexto = TextEditingController();
  bool _generarHutsuneak = true;
  bool _generarEsaldi = true;
  bool _generarSopa = true;
  bool _generarLotura = false;
  bool _generarDiktatua = false;
  bool _usarLlm = false;
  bool _llmDisponible = false;
  NivelEuskera _nivelObjetivo = NivelEuskera.a2;
  ResultadoGeneracion? _previa;
  OrigenGeneracion _origenPrevia = OrigenGeneracion.heuristico;
  bool _generando = false;
  String? _errorMensaje;

  @override
  void initState() {
    super.initState();
    _comprobarDisponibilidadLlm();
  }

  Future<void> _comprobarDisponibilidadLlm() async {
    final String? apiKey =
        await AlmacenEzarpenak.instancia.leerApiKeyAnthropic();
    if (!mounted) return;
    setState(() => _llmDisponible = apiKey != null);
  }

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorTexto.dispose();
    super.dispose();
  }

  Future<void> _generarPrevia() async {
    final String texto = _controladorTexto.text.trim();
    if (texto.length < 30) {
      setState(() {
        _errorMensaje =
            'Itsatsi gutxienez 30 karaktere — testu hain laburrak ez du nahikoa ematen.';
        _previa = null;
      });
      return;
    }
    setState(() {
      _generando = true;
      _errorMensaje = null;
    });

    try {
      ResultadoGeneracion resultado;
      OrigenGeneracion origen;
      if (_usarLlm && _llmDisponible) {
        final String apiKey =
            (await AlmacenEzarpenak.instancia.leerApiKeyAnthropic()) ?? '';
        final String modelo =
            await AlmacenEzarpenak.instancia.leerModeloAnthropic();
        final GeneradorLlm cliente =
            GeneradorLlm(apiKey: apiKey, modelo: modelo);
        try {
          resultado = await cliente.generar(
            texto: texto,
            incluirHutsuneak: _generarHutsuneak,
            incluirEsaldi: _generarEsaldi,
            incluirSopa: _generarSopa,
            incluirLotura: _generarLotura,
            incluirDiktatua: _generarDiktatua,
            nivelObjetivo: _nivelObjetivo,
          );
        } finally {
          cliente.cerrar();
        }
        origen = OrigenGeneracion.llm;
      } else {
        resultado = await Future<ResultadoGeneracion>(
            () => generarTodoHeuristico(texto));
        origen = OrigenGeneracion.heuristico;
      }
      if (!mounted) return;
      setState(() {
        _previa = resultado;
        _origenPrevia = origen;
        _generando = false;
      });
    } on ErrorGeneradorLlm catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMensaje = 'LLM-erroa: ${e.mensaje}';
        _generando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMensaje = 'Errore ezezaguna: ${e.toString()}';
        _generando = false;
      });
    }
  }

  Future<void> _gordeyirten() async {
    if (_previa == null) return;
    final String tituloBase = _controladorTitulo.text.trim().isEmpty
        ? 'Testu berria'
        : _controladorTitulo.text.trim();
    final ResultadoGeneracion filtrado = ResultadoGeneracion(
      hutsuneak: _generarHutsuneak ? _previa!.hutsuneak : null,
      esaldiEraikitzailea:
          _generarEsaldi ? _previa!.esaldiEraikitzailea : null,
      hitzZaparrada: _generarSopa ? _previa!.hitzZaparrada : null,
      lotura: _generarLotura ? _previa!.lotura : null,
      diktatua: _generarDiktatua ? _previa!.diktatua : null,
    );
    final List<AriketaSortua> generadas =
        construirAriketakSortuakDesdeResultado(
      tituloBase: tituloBase,
      testuJatorria: _controladorTexto.text.trim(),
      jatorria: _origenPrevia,
      resultado: filtrado,
    );
    if (generadas.isEmpty) {
      setState(() {
        _errorMensaje =
            'Aukeratu gutxienez minijoko mota bat eta egiaztatu sortu dela.';
      });
      return;
    }
    for (final AriketaSortua ariketa in generadas) {
      await AlmacenAriketaSortua.instancia.gordeBerria(ariketa);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      appBar: AppBar(
        backgroundColor: PaletaAek.papelViejo,
        surfaceTintColor: PaletaAek.papelViejo,
        elevation: 0,
        iconTheme: const IconThemeData(color: PaletaAek.tintaNegra),
        title: const Text(
          'TESTU BERRIA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ),
      body: FondoPapelEnvejecido(
        semilla: 17,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _CajaSeccion(
                    titulo: 'TESTUA',
                    contenido: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _CampoTexto(
                          etiqueta: 'Izenburua',
                          controlador: _controladorTitulo,
                          lineas: 1,
                        ),
                        const SizedBox(height: 14),
                        _CampoTexto(
                          etiqueta: 'Itsatsi euskarazko testua hemen',
                          controlador: _controladorTexto,
                          lineas: 10,
                          ayuda:
                              'Adibidez: ipuin labur bat, kantu baten letra edo egunkari pasarte bat.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ZER SORTU',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 2,
                            color: PaletaAek.tintaNegra,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CheckMinijuego(
                          titulo: 'Hutsuneak',
                          descripcion: 'Hitz batzuk testuko hutsuneetan jartzeko.',
                          valor: _generarHutsuneak,
                          alCambiar: (bool? v) =>
                              setState(() => _generarHutsuneak = v ?? false),
                        ),
                        _CheckMinijuego(
                          titulo: 'Esaldi-Eraikitzailea',
                          descripcion: 'Testuko esaldiak desordenatuta berreraikitzeko.',
                          valor: _generarEsaldi,
                          alCambiar: (bool? v) =>
                              setState(() => _generarEsaldi = v ?? false),
                        ),
                        _CheckMinijuego(
                          titulo: 'Hitz-Zaparrada',
                          descripcion: 'Testuko hitz garrantzitsuekin hitz-zopa.',
                          valor: _generarSopa,
                          alCambiar: (bool? v) =>
                              setState(() => _generarSopa = v ?? false),
                        ),
                        _CheckMinijuego(
                          titulo: 'Lotura',
                          descripcion: _llmDisponible
                              ? 'Testuko hiztegiarekin euskera-gaztelania bikoteak (LLM-rekin bakarrik).'
                              : 'Testuko hiztegiarekin bikoteak. LLM behar du (ezarpenetan API key sartu).',
                          valor: _generarLotura && _llmDisponible,
                          alCambiar: _llmDisponible
                              ? (bool? v) =>
                                  setState(() => _generarLotura = v ?? false)
                              : null,
                        ),
                        _CheckMinijuego(
                          titulo: 'Diktatua',
                          descripcion:
                              'Testuko esaldiak entzun eta idatzi ortografia zainduz.',
                          valor: _generarDiktatua,
                          alCambiar: (bool? v) =>
                              setState(() => _generarDiktatua = v ?? false),
                        ),
                        const SizedBox(height: 10),
                        _SelectorNivelObjetivo(
                          nivel: _nivelObjetivo,
                          alCambiar: (NivelEuskera nivel) =>
                              setState(() => _nivelObjetivo = nivel),
                        ),
                        const SizedBox(height: 10),
                        _SelectorModoGeneracion(
                          usarLlm: _usarLlm,
                          llmDisponible: _llmDisponible,
                          alCambiar: (bool valor) =>
                              setState(() => _usarLlm = valor),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _generando ? null : _generarPrevia,
                            behavior: HitTestBehavior.opaque,
                            child: MarcoRotulador(
                              color: PaletaAek.rojoRotulador,
                              grosor: 3,
                              intensidadJitter: 1.3,
                              child: Container(
                                color: PaletaAek.papelViejo,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 12),
                                child: Text(
                                  _generando ? 'SORTZEN…' : 'AURREIKUSPENA',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: PaletaAek.rojoRotulador,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMensaje != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: PaletaAek.rojoRotulador, width: 1.4),
                      ),
                      child: Text(
                        _errorMensaje!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: PaletaAek.rojoRotulador,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (_previa != null) ...<Widget>[
                    const SizedBox(height: 18),
                    _PrevisualizacionGeneracion(
                      previa: _previa!,
                      activarHutsuneak: _generarHutsuneak,
                      activarEsaldi: _generarEsaldi,
                      activarSopa: _generarSopa,
                      activarLotura: _generarLotura,
                      activarDiktatua: _generarDiktatua,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: _gordeyirten,
                        behavior: HitTestBehavior.opaque,
                        child: MarcoRotulador(
                          color: PaletaAek.tintaNegra,
                          grosor: 3,
                          intensidadJitter: 1.3,
                          child: Container(
                            color: PaletaAek.tintaNegra,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 13),
                            child: const Text(
                              'GORDE ETA IRTEN',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: PaletaAek.papelViejo,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final int lineas;
  final String? ayuda;

  const _CampoTexto({
    required this.etiqueta,
    required this.controlador,
    required this.lineas,
    this.ayuda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          etiqueta,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controlador,
          minLines: lineas,
          maxLines: lineas == 1 ? 1 : lineas + 4,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: PaletaAek.tintaNegra,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: PaletaAek.tintaNegra,
                width: 1.4,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
          ),
        ),
        if (ayuda != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            ayuda!,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: PaletaAek.tintaDiluida(0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckMinijuego extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final bool valor;
  final ValueChanged<bool?>? alCambiar;

  const _CheckMinijuego({
    required this.titulo,
    required this.descripcion,
    required this.valor,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: valor,
      onChanged: alCambiar,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: PaletaAek.rojoRotulador,
      title: Text(
        titulo,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: PaletaAek.tintaNegra,
        ),
      ),
      subtitle: Text(
        descripcion,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: PaletaAek.tintaDiluida(0.6),
        ),
      ),
    );
  }
}

class _PrevisualizacionGeneracion extends StatelessWidget {
  final ResultadoGeneracion previa;
  final bool activarHutsuneak;
  final bool activarEsaldi;
  final bool activarSopa;
  final bool activarLotura;
  final bool activarDiktatua;

  const _PrevisualizacionGeneracion({
    required this.previa,
    required this.activarHutsuneak,
    required this.activarEsaldi,
    required this.activarSopa,
    required this.activarLotura,
    required this.activarDiktatua,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> filas = <Widget>[];

    final HutsuneakGeneratuta? hutsuneak = previa.hutsuneak;
    if (activarHutsuneak && hutsuneak != null) {
      filas.add(_FilaResumen(
        etiqueta: 'HUTSUNEAK',
        descripcion:
            '${hutsuneak.posicionesHueco.length} hutsune, ${hutsuneak.bancoPalabras.length} hitz aukerako bankuan.',
      ));
    } else if (activarHutsuneak && hutsuneak == null) {
      filas.add(const _FilaResumen(
        etiqueta: 'HUTSUNEAK',
        descripcion: 'Testua motzegia da hutsuneak sortzeko.',
        ausente: true,
      ));
    }

    final EsaldiEraikitzaileaGeneratuta? esaldi = previa.esaldiEraikitzailea;
    if (activarEsaldi && esaldi != null) {
      filas.add(_FilaResumen(
        etiqueta: 'ESALDI-ERAIKITZAILEA',
        descripcion:
            '${esaldi.oraciones.length} esaldi berreraikitzeko (3-8 hitz luzeera).',
      ));
    } else if (activarEsaldi && esaldi == null) {
      filas.add(const _FilaResumen(
        etiqueta: 'ESALDI-ERAIKITZAILEA',
        descripcion: 'Ez dago tarteko luzerako esaldirik.',
        ausente: true,
      ));
    }

    final HitzZaparradaGeneratuta? sopa = previa.hitzZaparrada;
    if (activarSopa && sopa != null) {
      filas.add(_FilaResumen(
        etiqueta: 'HITZ-ZAPARRADA',
        descripcion: sopa.palabrasClave.join(', '),
      ));
    } else if (activarSopa && sopa == null) {
      filas.add(const _FilaResumen(
        etiqueta: 'HITZ-ZAPARRADA',
        descripcion: 'Ez dira hitz baliodun nahikoa aurkitu.',
        ausente: true,
      ));
    }

    final LoturaGeneratuta? lotura = previa.lotura;
    if (activarLotura && lotura != null) {
      filas.add(_FilaResumen(
        etiqueta: 'LOTURA',
        descripcion: lotura.parejas
            .map((ParejaGenerada p) => '${p.euskera} = ${p.espanol}')
            .join(' · '),
      ));
    } else if (activarLotura && lotura == null) {
      filas.add(const _FilaResumen(
        etiqueta: 'LOTURA',
        descripcion: 'Ez da bikoterik sortu.',
        ausente: true,
      ));
    }

    final DiktatuaGeneratuta? diktatua = previa.diktatua;
    if (activarDiktatua && diktatua != null) {
      filas.add(_FilaResumen(
        etiqueta: 'DIKTATUA',
        descripcion:
            '${diktatua.frases.length} esaldi diktatzeko: ${diktatua.frases.first.euskera}…',
      ));
    } else if (activarDiktatua && diktatua == null) {
      filas.add(const _FilaResumen(
        etiqueta: 'DIKTATUA',
        descripcion: 'Ez dago tarteko luzerako esaldirik diktatzeko.',
        ausente: true,
      ));
    }

    return MarcoRotulador(
      intensidadJitter: 1.2,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    width: 18, height: 2, color: PaletaAek.rojoRotulador),
                const SizedBox(width: 8),
                const Text(
                  'AURREIKUSPENA',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2.5,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...filas,
          ],
        ),
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String etiqueta;
  final String descripcion;
  final bool ausente;

  const _FilaResumen({
    required this.etiqueta,
    required this.descripcion,
    this.ausente = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorEtiqueta =
        ausente ? PaletaAek.tintaDiluida(0.45) : PaletaAek.rojoRotulador;
    final Color colorDescripcion =
        ausente ? PaletaAek.tintaDiluida(0.55) : PaletaAek.tintaNegra;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: colorEtiqueta, width: 1.2),
            ),
            child: Text(
              etiqueta,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
                color: colorEtiqueta,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: colorDescripcion,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorModoGeneracion extends StatelessWidget {
  final bool usarLlm;
  final bool llmDisponible;
  final ValueChanged<bool> alCambiar;

  const _SelectorModoGeneracion({
    required this.usarLlm,
    required this.llmDisponible,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
            color: PaletaAek.tintaDiluida(0.4), width: 1.4),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            usarLlm && llmDisponible
                ? Icons.auto_awesome
                : Icons.calculate_outlined,
            color: usarLlm && llmDisponible
                ? PaletaAek.rojoRotulador
                : PaletaAek.tintaNegra,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  usarLlm && llmDisponible
                      ? 'LLM-modua: Claude-rekin sortuko da'
                      : 'Modu heuristikoa: tokian sortuko da',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
                Text(
                  llmDisponible
                      ? 'Aldatu LLM-mailara emaitza aberatsagoa lortzeko.'
                      : 'LLM-modua aktibatzeko, sartu API key bat ezarpenetan.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: PaletaAek.tintaDiluida(0.65),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: usarLlm && llmDisponible,
            onChanged: llmDisponible ? alCambiar : null,
            activeThumbColor: PaletaAek.rojoRotulador,
          ),
        ],
      ),
    );
  }
}

class _SelectorNivelObjetivo extends StatelessWidget {
  final NivelEuskera nivel;
  final ValueChanged<NivelEuskera> alCambiar;

  const _SelectorNivelObjetivo({
    required this.nivel,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border:
            Border.all(color: PaletaAek.tintaDiluida(0.4), width: 1.4),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.school_outlined,
              color: PaletaAek.tintaNegra, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'IKASLEAREN MAILA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.8,
                color: PaletaAek.tintaDiluida(0.85),
              ),
            ),
          ),
          DropdownButton<NivelEuskera>(
            value: nivel,
            underline: const SizedBox.shrink(),
            isDense: true,
            iconEnabledColor: PaletaAek.rojoRotulador,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: PaletaAek.tintaNegra,
            ),
            items: NivelEuskera.values
                .where((NivelEuskera v) => v != NivelEuskera.c2)
                .map(
                  (NivelEuskera valor) => DropdownMenuItem<NivelEuskera>(
                    value: valor,
                    child: Text(
                      '${valor.etiqueta} — ${valor.descripcionEuskera}',
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (NivelEuskera? valor) {
              if (valor != null) alCambiar(valor);
            },
          ),
        ],
      ),
    );
  }
}

class _CajaSeccion extends StatelessWidget {
  final String titulo;
  final Widget contenido;

  const _CajaSeccion({required this.titulo, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      intensidadJitter: 1.1,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    width: 18, height: 2, color: PaletaAek.rojoRotulador),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2.5,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }
}
