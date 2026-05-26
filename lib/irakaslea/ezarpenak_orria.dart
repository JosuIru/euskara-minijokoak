import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../oinarriak/eguneraketak_zerbitzua.dart';
import '../oinarriak/ezarpenak.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla de configuración avanzada del profesor. De momento aloja
/// las credenciales del LLM (Anthropic) y el modelo a usar. Es un
/// panel "tras bambalinas" — no se muestra al alumno.
class EzarpenakOrria extends StatefulWidget {
  const EzarpenakOrria({super.key});

  @override
  State<EzarpenakOrria> createState() => _EzarpenakOrriaState();
}

class _EzarpenakOrriaState extends State<EzarpenakOrria> {
  final TextEditingController _controladorApiKey = TextEditingController();
  final TextEditingController _controladorModelo = TextEditingController();
  bool _cargando = true;
  bool _hayClaveGuardada = false;
  bool _mostrarApiKey = false;
  String? _mensajeEstado;

  String? _bertsioUnekoa;
  bool _egiaztatzenEguneraketa = false;
  EmaitzaEguneraketa? _emaitzaEguneraketa;

  @override
  void initState() {
    super.initState();
    _cargarValoresActuales();
    _cargarBertsioUnekoa();
  }

  Future<void> _cargarBertsioUnekoa() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() =>
          _bertsioUnekoa = '${info.version} (build ${info.buildNumber})');
    } catch (_) {
      if (!mounted) return;
      setState(() => _bertsioUnekoa = '—');
    }
  }

  Future<void> _egiaztatuEguneraketak() async {
    setState(() {
      _egiaztatzenEguneraketa = true;
      _emaitzaEguneraketa = null;
    });
    final EguneraketakZerbitzua zerbitzua = EguneraketakZerbitzua();
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: info.version,
        buildInstalatua: int.tryParse(info.buildNumber) ?? 0,
      );
      if (!mounted) return;
      setState(() {
        _emaitzaEguneraketa = emaitza;
        _egiaztatzenEguneraketa = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emaitzaEguneraketa =
            EmaitzaEguneraketa.errorea('Errore ezezaguna: ${e.toString()}');
        _egiaztatzenEguneraketa = false;
      });
    } finally {
      zerbitzua.cerrar();
    }
  }

  Future<void> _abrirDescargaEguneraketa(ManifestuEguneraketa manifestua) async {
    final Uri? uri = Uri.tryParse(manifestua.deskargaUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _controladorApiKey.dispose();
    _controladorModelo.dispose();
    super.dispose();
  }

  Future<void> _cargarValoresActuales() async {
    final String? apiKey =
        await AlmacenEzarpenak.instancia.leerApiKeyAnthropic();
    final String modelo =
        await AlmacenEzarpenak.instancia.leerModeloAnthropic();
    if (!mounted) return;
    setState(() {
      _hayClaveGuardada = apiKey != null;
      // No precargamos la propia clave por seguridad visual — el
      // profesor verá un placeholder informativo en su lugar.
      _controladorApiKey.text = '';
      _controladorModelo.text = modelo;
      _cargando = false;
    });
  }

  Future<void> _gordeApiKey() async {
    final String texto = _controladorApiKey.text.trim();
    if (texto.isEmpty) {
      setState(() => _mensajeEstado = 'Sartu balio bat lehenik.');
      return;
    }
    await AlmacenEzarpenak.instancia.gordeApiKeyAnthropic(texto);
    await AlmacenEzarpenak.instancia
        .gordeModeloAnthropic(_controladorModelo.text.trim().isEmpty
            ? AlmacenEzarpenak.modeloAnthropicPorDefecto
            : _controladorModelo.text.trim());
    if (!mounted) return;
    setState(() {
      _hayClaveGuardada = true;
      _controladorApiKey.text = '';
      _mensajeEstado = 'API key gorde da.';
    });
  }

  Future<void> _ezabatuApiKey() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: PaletaAek.papelViejo,
        title: const Text(
          'API key ezabatu?',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            color: PaletaAek.tintaNegra,
          ),
        ),
        content: const Text(
          'LLM-modua desgaitu egingo da. Berriz erabiltzeko, key bat sartu beharko duzu.',
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
    if (confirmado != true) return;
    await AlmacenEzarpenak.instancia.ezabatuApiKeyAnthropic();
    if (!mounted) return;
    setState(() {
      _hayClaveGuardada = false;
      _mensajeEstado = 'API key ezabatu da.';
    });
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
          'EZARPENAK',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ),
      body: FondoPapelEnvejecido(
        semilla: 29,
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(
                    color: PaletaAek.rojoRotulador))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _CajaSeccion(
                          titulo: 'ANTHROPIC API (LLM-modua)',
                          contenido: _construirContenidoLlm(),
                        ),
                        const SizedBox(height: 16),
                        _CajaSeccion(
                          titulo: 'EGUNERAKETAK',
                          contenido: _construirContenidoEguneraketak(),
                        ),
                        if (_mensajeEstado != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: PaletaAek.rojoRotulador, width: 1.4),
                            ),
                            child: Text(
                              _mensajeEstado!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: PaletaAek.rojoRotulador,
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

  Widget _construirContenidoLlm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
                color: _hayClaveGuardada
                    ? PaletaAek.rojoRotulador
                    : PaletaAek.tintaDiluida(0.4),
                width: 1.4),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                _hayClaveGuardada
                    ? Icons.check_circle_outline
                    : Icons.do_not_disturb_alt,
                size: 18,
                color: _hayClaveGuardada
                    ? PaletaAek.rojoRotulador
                    : PaletaAek.tintaDiluida(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                _hayClaveGuardada
                    ? 'API key gordeta — LLM-modua aktibatuta.'
                    : 'Ez dago API key-rik. LLM-modua desgaituta.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: _hayClaveGuardada
                      ? PaletaAek.rojoRotulador
                      : PaletaAek.tintaDiluida(0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'API key berria',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controladorApiKey,
          obscureText: !_mostrarApiKey,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: PaletaAek.tintaNegra,
          ),
          decoration: InputDecoration(
            hintText: _hayClaveGuardada
                ? 'sk-ant-… (gordeta — sartu berria aldatzeko)'
                : 'sk-ant-…',
            hintStyle: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: PaletaAek.tintaDiluida(0.45),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: PaletaAek.tintaNegra,
                width: 1.4,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(
                _mostrarApiKey
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: PaletaAek.tintaNegra,
              ),
              onPressed: () =>
                  setState(() => _mostrarApiKey = !_mostrarApiKey),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Modeloa',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.7),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controladorModelo,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lehenetsia: ${AlmacenEzarpenak.modeloAnthropicPorDefecto}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.55),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (_hayClaveGuardada)
              TextButton.icon(
                onPressed: _ezabatuApiKey,
                icon: const Icon(Icons.delete_outline,
                    color: PaletaAek.tintaNegra),
                label: const Text(
                  'EZABATU',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: PaletaAek.tintaNegra,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _gordeApiKey,
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
                    'GORDE',
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
        const SizedBox(height: 10),
        Text(
          'API key console.anthropic.com webgunean lortzen da. Tokian gordetzen '
          'da nabigatzaileko biltegian — ez da inora bidaltzen Anthropic-en '
          'apira eskaerak egitean izan ezik.',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: PaletaAek.tintaDiluida(0.6),
            height: 1.4,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _construirContenidoEguneraketak() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.info_outline,
                size: 18, color: PaletaAek.tintaNegra),
            const SizedBox(width: 6),
            Text(
              'Instalatutako bertsioa: ${_bertsioUnekoa ?? '…'}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: PaletaAek.tintaNegra,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_emaitzaEguneraketa != null)
          _construirResultadoEguneraketa(_emaitzaEguneraketa!),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _egiaztatzenEguneraketa ? null : _egiaztatuEguneraketak,
            behavior: HitTestBehavior.opaque,
            child: MarcoRotulador(
              color: PaletaAek.rojoRotulador,
              grosor: 3,
              intensidadJitter: 1.3,
              child: Container(
                color: PaletaAek.papelViejo,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  _egiaztatzenEguneraketa ? 'EGIAZTATZEN…' : 'EGUNERAKETAK BILATU',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    color: PaletaAek.rojoRotulador,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirResultadoEguneraketa(EmaitzaEguneraketa emaitza) {
    switch (emaitza.egoera) {
      case EgoeraEguneraketa.eguneratuta:
        return _FilaEstadoEguneraketa(
          icono: Icons.check_circle_outline,
          texto: 'Azken bertsioa duzu. Dena egunean.',
        );
      case EgoeraEguneraketa.errorea:
        return _FilaEstadoEguneraketa(
          icono: Icons.cloud_off_outlined,
          texto: emaitza.erroreMezua ?? 'Ezin izan da egiaztatu.',
          atenuado: true,
        );
      case EgoeraEguneraketa.eskuragarri:
        final ManifestuEguneraketa manifestua = emaitza.manifestua!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: PaletaAek.rojoRotulador, width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.system_update_alt,
                      size: 18, color: PaletaAek.rojoRotulador),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bertsio berria: ${manifestua.bertsioa}'
                      '${manifestua.derrigorrezkoa ? ' (beharrezkoa)' : ''}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: PaletaAek.rojoRotulador,
                      ),
                    ),
                  ),
                ],
              ),
              if (manifestua.oharrak != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  manifestua.oharrak!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: PaletaAek.tintaDiluida(0.75),
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _abrirDescargaEguneraketa(manifestua),
                  behavior: HitTestBehavior.opaque,
                  child: MarcoRotulador(
                    color: PaletaAek.rojoRotulador,
                    grosor: 2,
                    intensidadJitter: 1.0,
                    child: Container(
                      color: PaletaAek.papelViejo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: const Text(
                        'DESKARGATU',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: PaletaAek.rojoRotulador,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _FilaEstadoEguneraketa extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool atenuado;

  const _FilaEstadoEguneraketa({
    required this.icono,
    required this.texto,
    this.atenuado = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        atenuado ? PaletaAek.tintaDiluida(0.6) : PaletaAek.tintaNegra;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icono, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
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
                    fontSize: 15,
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
