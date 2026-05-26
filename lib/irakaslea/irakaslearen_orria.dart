import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../oinarriak/ariketa.dart';
import '../oinarriak/katalogoa.dart';
import '../oinarriak/kodigo_klase.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Panel del profesor: genera códigos de clase autocontenidos que el
/// irakasle comparte con su alumnado. Cada código encapsula nombre de
/// clase + identificadores de los ejercicios asignados. No requiere
/// servidor: el código viaja por sí solo.
class IrakaslearenOrria extends StatefulWidget {
  const IrakaslearenOrria({super.key});

  @override
  State<IrakaslearenOrria> createState() => _IrakaslearenOrriaState();
}

class _IrakaslearenOrriaState extends State<IrakaslearenOrria> {
  final TextEditingController _controladorNombreClase =
      TextEditingController(text: 'Nire klasea');
  late final Map<String, bool> _ejerciciosSeleccionados;
  String? _codigoGenerado;

  @override
  void initState() {
    super.initState();
    _ejerciciosSeleccionados = <String, bool>{
      for (final Ariketa ariketa in KatalogoAek.ariketaGuztiak)
        ariketa.identificador: true,
    };
  }

  @override
  void dispose() {
    _controladorNombreClase.dispose();
    super.dispose();
  }

  void _generarCodigo() {
    final String nombreClase = _controladorNombreClase.text.trim();
    if (nombreClase.isEmpty) return;
    final List<String> identificadoresAsignados = _ejerciciosSeleccionados
        .entries
        .where((entrada) => entrada.value)
        .map((entrada) => entrada.key)
        .toList(growable: false);
    if (identificadoresAsignados.isEmpty) return;
    final String codigo = generarKodigoKlase(
      izenaKlasea: nombreClase,
      identificadoresAriketak: identificadoresAsignados,
    );
    setState(() {
      _codigoGenerado = codigo;
    });
  }

  Future<void> _copiarCodigoAlPortapapeles() async {
    if (_codigoGenerado == null) return;
    await Clipboard.setData(ClipboardData(text: _codigoGenerado!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kodea kopiatu da arbelean',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: PaletaAek.tintaNegra,
        duration: Duration(seconds: 2),
      ),
    );
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
          'IRAKASLEA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: PaletaAek.tintaNegra,
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed('/irakaslea/testutik'),
            icon: const Icon(Icons.auto_awesome_outlined,
                color: PaletaAek.rojoRotulador),
            label: const Text(
              'TESTUTIK SORTU',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: PaletaAek.rojoRotulador,
                letterSpacing: 1.5,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context)
                .pushNamed('/irakaslea/pertsonalak'),
            icon: const Icon(Icons.folder_outlined,
                color: PaletaAek.tintaNegra),
            label: const Text(
              'NIRE ARIKETAK',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: PaletaAek.tintaNegra,
                letterSpacing: 1.5,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/irakaslea/ezarpenak'),
            icon: const Icon(Icons.settings_outlined,
                color: PaletaAek.tintaNegra),
            tooltip: 'Ezarpenak',
          ),
        ],
      ),
      body: FondoPapelEnvejecido(
        semilla: 5,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _CajaSeccion(
                    titulo: 'KLASE-KODE BERRIA SORTU',
                    contenido: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Klasearen izena',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: PaletaAek.tintaDiluida(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _controladorNombreClase,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
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
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ariketak aukeratu',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: PaletaAek.tintaDiluida(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...KatalogoAek.ariketaGuztiak.map(
                          (Ariketa ariketa) => CheckboxListTile(
                            value: _ejerciciosSeleccionados[ariketa.identificador],
                            onChanged: (bool? nuevoValor) {
                              setState(() {
                                _ejerciciosSeleccionados[ariketa.identificador] =
                                    nuevoValor ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: PaletaAek.rojoRotulador,
                            title: Text(
                              ariketa.izenburua,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PaletaAek.tintaNegra,
                              ),
                            ),
                            subtitle: Text(
                              ariketa.kategoria.etiquetaEuskera,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: PaletaAek.tintaDiluida(0.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _generarCodigo,
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
                                  'SORTU KODEA',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 15,
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
                  if (_codigoGenerado != null) ...<Widget>[
                    const SizedBox(height: 20),
                    _CajaCodigoGenerado(
                      codigo: _codigoGenerado!,
                      alCopiar: _copiarCodigoAlPortapapeles,
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

class _CajaCodigoGenerado extends StatelessWidget {
  final String codigo;
  final VoidCallback alCopiar;

  const _CajaCodigoGenerado({required this.codigo, required this.alCopiar});

  /// Lo que va dentro del QR. Sólo el código plano — escaneado con
  /// cualquier app de cámara devuelve la cadena, que el alumno pega en
  /// la pantalla KLASEA. Si más adelante desplegamos la PWA en un
  /// dominio público, podríamos volver a codificar URL completa para
  /// abrir directo, pero por ahora la portabilidad gana.
  String get _contenidoQr => codigo;

  @override
  Widget build(BuildContext context) {
    return MarcoRotulador(
      color: PaletaAek.rojoRotulador,
      grosor: 3,
      intensidadJitter: 1.4,
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
                const Text(
                  'KODE SORTUTAKOA',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2.5,
                    color: PaletaAek.rojoRotulador,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ikasleek QR kodea kameraz eskaneatu dezakete edo testua '
              'eskuz kopiatu. Gero KLASEA pantailan itsatsi behar dute.',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: PaletaAek.tintaDiluida(0.75),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: PaletaAek.papelViejo,
                  child: QrImageView(
                    data: _contenidoQr,
                    size: 180,
                    backgroundColor: PaletaAek.papelViejo,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: PaletaAek.tintaNegra,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: PaletaAek.tintaNegra,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'KLASE-KODEA',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: PaletaAek.tintaDiluida(0.65),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: PaletaAek.tintaDiluida(0.4), width: 1),
                          color: PaletaAek.papelSucio,
                        ),
                        child: SelectableText(
                          codigo,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: PaletaAek.tintaNegra,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: alCopiar,
                          icon: const Icon(Icons.copy,
                              color: PaletaAek.rojoRotulador),
                          label: const Text(
                            'KOPIATU',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              color: PaletaAek.rojoRotulador,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
