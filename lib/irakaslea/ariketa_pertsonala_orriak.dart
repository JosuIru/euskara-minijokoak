import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../oinarriak/ariketa_pertsonala.dart';
import '../oinarriak/ocr_factoria.dart';
import '../oinarriak/ocr_servicioa.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla con la lista de ejercicios personalizados ("carpeta del
/// profesor"). Permite añadir uno nuevo desde foto, editar el texto y
/// borrar entradas viejas. Es local del navegador del profesor — no se
/// sincroniza con alumnos en esta versión MVP.
class AriketaPertsonalakZerrenda extends StatefulWidget {
  const AriketaPertsonalakZerrenda({super.key});

  @override
  State<AriketaPertsonalakZerrenda> createState() =>
      _AriketaPertsonalakZerrendaState();
}

class _AriketaPertsonalakZerrendaState
    extends State<AriketaPertsonalakZerrenda> {
  Future<List<AriketaPertsonala>>? _futuroLista;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _futuroLista = AlmacenAriketaPertsonala.instancia.cargarTodas();
    });
  }

  Future<void> _navegarASortzailea() async {
    final bool? ahalbidetua = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const AriketaPertsonalaSortzaileaOrria(),
      ),
    );
    if (ahalbidetua == true) {
      _recargar();
    }
  }

  Future<void> _confirmarEzabaketa(AriketaPertsonala ariketa) async {
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
      await AlmacenAriketaPertsonala.instancia.ezabatu(ariketa.id);
      _recargar();
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
          'NIRE ARIKETAK',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: PaletaAek.tintaNegra,
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _navegarASortzailea,
            icon: const Icon(Icons.add_a_photo,
                color: PaletaAek.rojoRotulador),
            label: const Text(
              'BERRIA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                color: PaletaAek.rojoRotulador,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
      body: FondoPapelEnvejecido(
        semilla: 97,
        child: FutureBuilder<List<AriketaPertsonala>>(
          future: _futuroLista,
          builder: (BuildContext context,
              AsyncSnapshot<List<AriketaPertsonala>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: PaletaAek.tintaNegra),
              );
            }
            final List<AriketaPertsonala> lista =
                snapshot.data ?? <AriketaPertsonala>[];
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.collections_outlined,
                          size: 64, color: PaletaAek.tintaDiluida(0.35)),
                      const SizedBox(height: 16),
                      const Text(
                        'Oraindik ez duzu ariketa pertsonalik.',
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
                        'Sakatu BERRIA argazkitik bat sortzeko.',
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
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: lista
                        .map(
                          (AriketaPertsonala ariketa) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _TarjetaAriketaPertsonala(
                              ariketa: ariketa,
                              alAbatu: () => _confirmarEzabaketa(ariketa),
                              alEditatu: () async {
                                final bool? eguneratuta =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (_) =>
                                        AriketaPertsonalaEditatzaileaOrria(
                                      hasierakoa: ariketa,
                                    ),
                                  ),
                                );
                                if (eguneratuta == true) _recargar();
                              },
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaAriketaPertsonala extends StatelessWidget {
  final AriketaPertsonala ariketa;
  final VoidCallback alAbatu;
  final VoidCallback alEditatu;

  const _TarjetaAriketaPertsonala({
    required this.ariketa,
    required this.alAbatu,
    required this.alEditatu,
  });

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 2.4,
      intensidadJitter: 1.1,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _MiniaturaImagen(dataUrl: ariketa.imagenDataUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ariketa.izenburua.isEmpty
                        ? '(Izenburu gabe)'
                        : ariketa.izenburua,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.tintaNegra,
                    ),
                  ),
                  if (ariketa.oharrak.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      ariketa.oharrak,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.tintaDiluida(0.65),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    ariketa.testuKorregitua.length > 140
                        ? '${ariketa.testuKorregitua.substring(0, 140)}…'
                        : ariketa.testuKorregitua,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: PaletaAek.tintaNegra,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: <Widget>[
                IconButton(
                  onPressed: alEditatu,
                  icon: const Icon(Icons.edit_outlined,
                      color: PaletaAek.tintaNegra),
                  tooltip: 'Editatu',
                ),
                IconButton(
                  onPressed: alAbatu,
                  icon: Icon(Icons.delete_outline,
                      color: PaletaAek.tintaDiluida(0.6)),
                  tooltip: 'Ezabatu',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniaturaImagen extends StatelessWidget {
  final String dataUrl;
  const _MiniaturaImagen({required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = _bytesDesdeDataUrl(dataUrl);
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        border: Border.all(color: PaletaAek.tintaNegra, width: 1.4),
      ),
      child: bytes == null
          ? const Center(
              child: Icon(Icons.broken_image, color: PaletaAek.tintaNegra))
          : Image.memory(bytes, fit: BoxFit.cover),
    );
  }
}

Uint8List? _bytesDesdeDataUrl(String dataUrl) {
  final int comaIndice = dataUrl.indexOf(',');
  if (comaIndice == -1) return null;
  try {
    return base64Decode(dataUrl.substring(comaIndice + 1));
  } catch (_) {
    return null;
  }
}

/// Pantalla del flujo "crear ejercicio desde foto".
/// Pasos: 1) elegir/sacar foto → 2) OCR automático → 3) editar
/// texto + título → 4) guardar.
class AriketaPertsonalaSortzaileaOrria extends StatefulWidget {
  const AriketaPertsonalaSortzaileaOrria({super.key});

  @override
  State<AriketaPertsonalaSortzaileaOrria> createState() =>
      _AriketaPertsonalaSortzaileaOrriaState();
}

class _AriketaPertsonalaSortzaileaOrriaState
    extends State<AriketaPertsonalaSortzaileaOrria> {
  final ImagePicker _hartzaileaArgazkia = ImagePicker();
  final ServicioOcr _servicioOcr = crearServicioOcr();
  final TextEditingController _kontroladoreaIzenburua =
      TextEditingController();
  final TextEditingController _kontroladoreaOharrak =
      TextEditingController();
  final TextEditingController _kontroladoreaTestu = TextEditingController();

  Uint8List? _argazkiBytes;
  String? _imagenDataUrl;
  String _idiomaOcr = idiomaOcrPorDefecto;
  String _textoOcrLatza = '';
  double _confianzaOcr = 0;
  bool _ocrLanean = false;
  String? _mensajeErrore;

  @override
  void dispose() {
    _kontroladoreaIzenburua.dispose();
    _kontroladoreaOharrak.dispose();
    _kontroladoreaTestu.dispose();
    super.dispose();
  }

  Future<void> _aukeratuArgazkia(ImageSource iturria) async {
    setState(() {
      _mensajeErrore = null;
    });
    try {
      final XFile? xFile = await _hartzaileaArgazkia.pickImage(
        source: iturria,
        maxWidth: 1800,
        imageQuality: 78,
      );
      if (xFile == null) return;
      final Uint8List bytes = await xFile.readAsBytes();
      final String mime = xFile.mimeType ?? 'image/jpeg';
      final String dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      setState(() {
        _argazkiBytes = bytes;
        _imagenDataUrl = dataUrl;
      });
      await _ejecutarOcr(bytes);
    } catch (e) {
      setState(() {
        _mensajeErrore = 'Argazkia kargatzean errorea: $e';
      });
    }
  }

  Future<void> _ejecutarOcr(Uint8List bytes) async {
    setState(() {
      _ocrLanean = true;
      _mensajeErrore = null;
    });
    try {
      final ResultadoOcr resultado = await _servicioOcr.reconocer(
        bytes,
        idioma: _idiomaOcr,
      );
      setState(() {
        _textoOcrLatza = resultado.textoReconocido;
        _confianzaOcr = resultado.confianza;
        _kontroladoreaTestu.text = resultado.textoReconocido;
        _ocrLanean = false;
      });
    } catch (e) {
      setState(() {
        _ocrLanean = false;
        _mensajeErrore = 'OCR errorea: $e';
      });
    }
  }

  Future<void> _gorde() async {
    if (_imagenDataUrl == null || _kontroladoreaTestu.text.trim().isEmpty) {
      setState(() {
        _mensajeErrore = 'Argazkia eta testua behar dira gordetzeko.';
      });
      return;
    }
    final AriketaPertsonala berria = AriketaPertsonala(
      id: generarIdAriketaPertsonala(),
      izenburua: _kontroladoreaIzenburua.text.trim().isEmpty
          ? 'Ariketa berria'
          : _kontroladoreaIzenburua.text.trim(),
      oharrak: _kontroladoreaOharrak.text.trim(),
      imagenDataUrl: _imagenDataUrl!,
      textoOcrLatza: _textoOcrLatza,
      testuKorregitua: _kontroladoreaTestu.text,
      konfiantzaOcr: _confianzaOcr,
      sortzeData: DateTime.now(),
    );
    await AlmacenAriketaPertsonala.instancia.gordeBerria(berria);
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
          'ARIKETA BERRIA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ),
      body: FondoPapelEnvejecido(
        semilla: 101,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _SeccionPaso(
                    numero: 1,
                    titulo: 'ARGAZKIA AUKERATU',
                    cuerpo: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _BotonAccion(
                              etiqueta: 'KAMERA',
                              icono: Icons.photo_camera,
                              alPulsar: () =>
                                  _aukeratuArgazkia(ImageSource.camera),
                            ),
                            const SizedBox(width: 10),
                            _BotonAccion(
                              etiqueta: 'GALERIA',
                              icono: Icons.image,
                              alPulsar: () =>
                                  _aukeratuArgazkia(ImageSource.gallery),
                            ),
                          ],
                        ),
                        if (_argazkiBytes != null) ...<Widget>[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: Image.memory(
                              _argazkiBytes!,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SeccionPaso(
                    numero: 2,
                    titulo: 'TESTUA EZAGUTU',
                    cuerpo: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text(
                              'Hizkuntza:',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: PaletaAek.tintaNegra,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _idiomaOcr,
                              dropdownColor: PaletaAek.papelViejo,
                              underline: const SizedBox.shrink(),
                              items: const <DropdownMenuItem<String>>[
                                DropdownMenuItem(
                                    value: 'eus', child: Text('Euskera')),
                                DropdownMenuItem(
                                    value: 'spa', child: Text('Español')),
                                DropdownMenuItem(
                                    value: 'eng+spa',
                                    child: Text('English + Español')),
                              ],
                              onChanged: _ocrLanean
                                  ? null
                                  : (String? nuevoValor) {
                                      if (nuevoValor == null) return;
                                      setState(() {
                                        _idiomaOcr = nuevoValor;
                                      });
                                      if (_argazkiBytes != null) {
                                        _ejecutarOcr(_argazkiBytes!);
                                      }
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_ocrLanean)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PaletaAek.tintaNegra,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Testua ezagutzen…',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: PaletaAek.tintaNegra,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_argazkiBytes != null)
                          Text(
                            'Konfiantza: ${_confianzaOcr.toStringAsFixed(0)}%. '
                            'Behean testua editatu dezakezu.',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: PaletaAek.tintaDiluida(0.65),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SeccionPaso(
                    numero: 3,
                    titulo: 'EDITATU ETA GORDE',
                    cuerpo: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextField(
                          controller: _kontroladoreaIzenburua,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: PaletaAek.tintaNegra,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Izenburua',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _kontroladoreaOharrak,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: PaletaAek.tintaNegra,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Oharrak (kategoria, gaia, maila…)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _kontroladoreaTestu,
                          minLines: 4,
                          maxLines: 12,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: PaletaAek.tintaNegra,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Ezagutu eta egiaztatutako testua',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                        ),
                        if (_mensajeErrore != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            _mensajeErrore!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: PaletaAek.rojoRotulador,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _BotonAccion(
                            etiqueta: 'GORDE',
                            icono: Icons.save_outlined,
                            esPrincipal: true,
                            alPulsar: _gorde,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla para editar texto/título/notas de un ejercicio ya guardado.
class AriketaPertsonalaEditatzaileaOrria extends StatefulWidget {
  final AriketaPertsonala hasierakoa;

  const AriketaPertsonalaEditatzaileaOrria({
    super.key,
    required this.hasierakoa,
  });

  @override
  State<AriketaPertsonalaEditatzaileaOrria> createState() =>
      _AriketaPertsonalaEditatzaileaOrriaState();
}

class _AriketaPertsonalaEditatzaileaOrriaState
    extends State<AriketaPertsonalaEditatzaileaOrria> {
  late final TextEditingController _izenburuaCtrl;
  late final TextEditingController _oharrakCtrl;
  late final TextEditingController _testuCtrl;

  @override
  void initState() {
    super.initState();
    _izenburuaCtrl = TextEditingController(text: widget.hasierakoa.izenburua);
    _oharrakCtrl = TextEditingController(text: widget.hasierakoa.oharrak);
    _testuCtrl = TextEditingController(text: widget.hasierakoa.testuKorregitua);
  }

  @override
  void dispose() {
    _izenburuaCtrl.dispose();
    _oharrakCtrl.dispose();
    _testuCtrl.dispose();
    super.dispose();
  }

  Future<void> _gordeAldaketak() async {
    final AriketaPertsonala eguneratua = widget.hasierakoa.copiaCon(
      izenburua: _izenburuaCtrl.text.trim().isEmpty
          ? widget.hasierakoa.izenburua
          : _izenburuaCtrl.text.trim(),
      oharrak: _oharrakCtrl.text.trim(),
      testuKorregitua: _testuCtrl.text,
    );
    await AlmacenAriketaPertsonala.instancia.eguneratu(eguneratua);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes =
        _bytesDesdeDataUrl(widget.hasierakoa.imagenDataUrl);
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      appBar: AppBar(
        backgroundColor: PaletaAek.papelViejo,
        surfaceTintColor: PaletaAek.papelViejo,
        elevation: 0,
        iconTheme: const IconThemeData(color: PaletaAek.tintaNegra),
        title: const Text(
          'EDITATU',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: PaletaAek.tintaNegra,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _gordeAldaketak,
            child: const Text(
              'GORDE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                color: PaletaAek.rojoRotulador,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
      body: FondoPapelEnvejecido(
        semilla: 103,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (bytes != null)
                    Image.memory(bytes, height: 240, fit: BoxFit.contain),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _izenburuaCtrl,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: PaletaAek.tintaNegra,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Izenburua',
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _oharrakCtrl,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: PaletaAek.tintaNegra,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Oharrak',
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _testuCtrl,
                    minLines: 6,
                    maxLines: 20,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: PaletaAek.tintaNegra,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Testua',
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OCR jatorrizko testua (irakurtzeko soilik):',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: PaletaAek.tintaDiluida(0.6),
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: PaletaAek.papelSucio,
                    child: Text(
                      widget.hasierakoa.textoOcrLatza,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.tintaDiluida(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeccionPaso extends StatelessWidget {
  final int numero;
  final String titulo;
  final Widget cuerpo;

  const _SeccionPaso({
    required this.numero,
    required this.titulo,
    required this.cuerpo,
  });

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      grosor: 2.2,
      intensidadJitter: 1.0,
      child: Container(
        color: PaletaAek.papelViejo,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: PaletaAek.rojoRotulador, width: 1.4),
                  ),
                  child: Text(
                    '$numero',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.rojoRotulador,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            cuerpo,
          ],
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final bool esPrincipal;
  final VoidCallback alPulsar;

  const _BotonAccion({
    required this.etiqueta,
    required this.icono,
    required this.alPulsar,
    this.esPrincipal = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        esPrincipal ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra;
    return GestureDetector(
      onTap: alPulsar,
      behavior: HitTestBehavior.opaque,
      child: MarcoRotulador(
        color: color,
        grosor: esPrincipal ? 3 : 2.2,
        intensidadJitter: 1.2,
        child: Container(
          color: PaletaAek.papelViejo,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icono, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                etiqueta,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
