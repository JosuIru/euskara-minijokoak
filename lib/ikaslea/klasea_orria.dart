import 'package:flutter/material.dart';

import '../oinarriak/almacen_local.dart';
import '../oinarriak/ariketa.dart';
import '../oinarriak/katalogoa.dart';
import '../oinarriak/kodigo_klase.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla del alumno para gestionar su pertenencia a una clase. Si no
/// ha introducido código, muestra el campo para hacerlo. Si lo hay,
/// muestra los ejercicios asignados por el irakasle, filtrados del
/// catálogo común.
class KlaseaOrria extends StatefulWidget {
  /// Código que llega desde la URL (`?kodea=AEK-...`). Si está presente
  /// se aplica automáticamente al abrir la pantalla — pensado para QR
  /// escaneado por el alumno: con un solo gesto está dentro de la clase.
  final String? codigoPrecargado;

  const KlaseaOrria({super.key, this.codigoPrecargado});

  @override
  State<KlaseaOrria> createState() => _KlaseaOrriaState();
}

class _KlaseaOrriaState extends State<KlaseaOrria> {
  final TextEditingController _controladorCodigoIntroducido =
      TextEditingController();

  KodigoKlase? _kodigoActivoParseado;
  String? _mensajeError;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCodigoGuardado();
  }

  @override
  void dispose() {
    _controladorCodigoIntroducido.dispose();
    super.dispose();
  }

  Future<void> _cargarCodigoGuardado() async {
    // Si llega un código precargado por URL (escaneo de QR), prevalece
    // sobre el guardado: el alumno está intentando unirse a una clase
    // nueva, así que ese es el código que queremos aplicar.
    final String? codigoEntrante = widget.codigoPrecargado;
    if (codigoEntrante != null && codigoEntrante.isNotEmpty) {
      final KodigoKlase? interpretado = parsearKodigoKlase(codigoEntrante);
      if (interpretado != null) {
        await AlmacenLocal.instancia.guardarCodigoClase(codigoEntrante);
        setState(() {
          _kodigoActivoParseado = interpretado;
          _cargando = false;
        });
        return;
      }
    }
    final String? codigoGuardado =
        await AlmacenLocal.instancia.cargarCodigoClase();
    setState(() {
      _kodigoActivoParseado =
          codigoGuardado == null ? null : parsearKodigoKlase(codigoGuardado);
      _cargando = false;
    });
  }

  Future<void> _intentarUnirseConCodigo() async {
    final String codigoIntroducido =
        _controladorCodigoIntroducido.text.trim();
    if (codigoIntroducido.isEmpty) {
      setState(() {
        _mensajeError = 'Idatzi klase-kodea jarraitzeko.';
      });
      return;
    }
    final KodigoKlase? interpretado = parsearKodigoKlase(codigoIntroducido);
    if (interpretado == null) {
      setState(() {
        _mensajeError = 'Kode hori ez da baliozkoa.';
      });
      return;
    }
    await AlmacenLocal.instancia.guardarCodigoClase(codigoIntroducido);
    setState(() {
      _kodigoActivoParseado = interpretado;
      _mensajeError = null;
      _controladorCodigoIntroducido.clear();
    });
  }

  Future<void> _abandonarClase() async {
    await AlmacenLocal.instancia.borrarCodigoClase();
    setState(() {
      _kodigoActivoParseado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 67,
          child: Column(
            children: <Widget>[
              _Cabecera(),
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: PaletaAek.tintaNegra),
                      )
                    : _kodigoActivoParseado == null
                        ? _PantallaSinClase(
                            controlador: _controladorCodigoIntroducido,
                            mensajeError: _mensajeError,
                            alIntentar: _intentarUnirseConCodigo,
                          )
                        : _PantallaConClase(
                            kodigoKlase: _kodigoActivoParseado!,
                            alAbandonar: _abandonarClase,
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: const <Widget>[
          BackButton(color: PaletaAek.tintaNegra),
          SizedBox(width: 4),
          Text(
            'NIRE KLASEA',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: PaletaAek.tintaNegra,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PantallaSinClase extends StatelessWidget {
  final TextEditingController controlador;
  final String? mensajeError;
  final VoidCallback alIntentar;

  const _PantallaSinClase({
    required this.controlador,
    required this.mensajeError,
    required this.alIntentar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: MarcoRotulador(
            grosor: 3,
            intensidadJitter: 1.4,
            child: Container(
              color: PaletaAek.papelViejo,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.qr_code_2,
                      size: 48, color: PaletaAek.tintaNegra),
                  const SizedBox(height: 12),
                  const Text(
                    'IRAKASLEAREN KODEA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: PaletaAek.tintaNegra,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Idatzi irakasleak eman dizun kodea zure '
                    'klaserako ariketak ikusteko.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: PaletaAek.tintaDiluida(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controlador,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: PaletaAek.tintaNegra,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      hintText: 'AEK-...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0x66000000),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => alIntentar(),
                  ),
                  if (mensajeError != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      mensajeError!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.rojoRotulador,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: alIntentar,
                    behavior: HitTestBehavior.opaque,
                    child: MarcoRotulador(
                      color: PaletaAek.rojoRotulador,
                      grosor: 3,
                      intensidadJitter: 1.3,
                      child: Container(
                        color: PaletaAek.papelViejo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        alignment: Alignment.center,
                        child: const Text(
                          'SARTU',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: PaletaAek.rojoRotulador,
                            letterSpacing: 3,
                          ),
                        ),
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

class _PantallaConClase extends StatelessWidget {
  final KodigoKlase kodigoKlase;
  final VoidCallback alAbandonar;

  const _PantallaConClase({
    required this.kodigoKlase,
    required this.alAbandonar,
  });

  @override
  Widget build(BuildContext context) {
    final List<Ariketa> ariketasAsignadas = kodigoKlase
        .identificadoresAriketak
        .map(KatalogoAek.identifikatzaileagatik)
        .whereType<Ariketa>()
        .toList(growable: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MarcoRotulador(
                color: PaletaAek.rojoRotulador,
                grosor: 3,
                intensidadJitter: 1.3,
                child: Container(
                  color: PaletaAek.papelViejo,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'KLASEA',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: PaletaAek.rojoRotulador,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              kodigoKlase.izenaKlasea,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: PaletaAek.tintaNegra,
                              ),
                            ),
                            Text(
                              '${ariketasAsignadas.length} ariketa esleituta',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: PaletaAek.tintaDiluida(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: alAbandonar,
                        child: const Text(
                          'UTZI',
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
                ),
              ),
              const SizedBox(height: 18),
              ...ariketasAsignadas.map(
                (Ariketa ariketa) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaAriketaAsignada(ariketa: ariketa),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAriketaAsignada extends StatelessWidget {
  final Ariketa ariketa;
  const _TarjetaAriketaAsignada({required this.ariketa});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/minijokoa/${ariketa.identificador}'),
      behavior: HitTestBehavior.opaque,
      child: MarcoRotulador(
        grosor: 2.4,
        intensidadJitter: 1.1,
        child: Container(
          color: PaletaAek.papelViejo,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ariketa.izenburua,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: PaletaAek.tintaNegra,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${ariketa.kategoria.etiquetaEuskera} '
                      '· ${ariketa.azalpenLaburra}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.tintaDiluida(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios,
                  color: PaletaAek.rojoRotulador, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
