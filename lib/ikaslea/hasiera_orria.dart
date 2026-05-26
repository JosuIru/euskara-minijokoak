import 'package:flutter/material.dart';

import '../oinarriak/eguneraketa_banderatxoa.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla de bienvenida. Dos puertas: ikaslea (alumno) e irakaslea
/// (profesor). Estilo rotulador en B/N + rojo.
class HasieraOrria extends StatelessWidget {
  const HasieraOrria({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 3,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool esLayoutAncho = constraints.maxWidth > 720;
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _CabeceraTitulo(),
                    const SizedBox(height: 8),
                    const EguneraketaBanderatxoa(),
                    Expanded(
                      child: Center(
                        child: esLayoutAncho
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Expanded(child: _TarjetaPuertaAlumno()),
                                  SizedBox(width: 24),
                                  Expanded(child: _TarjetaPuertaProfesor()),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  _TarjetaPuertaAlumno(),
                                  SizedBox(height: 24),
                                  _TarjetaPuertaProfesor(),
                                ],
                              ),
                      ),
                    ),
                    const _PieDePagina(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CabeceraTitulo extends StatelessWidget {
  const _CabeceraTitulo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const <Widget>[
        Text(
          'EUSKARAZ',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: PaletaAek.tintaNegra,
            letterSpacing: 6,
            height: 1.0,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'AEK-rentzako web aplikazioa',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            color: PaletaAek.rojoRotulador,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TarjetaPuertaAlumno extends StatelessWidget {
  const _TarjetaPuertaAlumno();

  @override
  Widget build(BuildContext context) {
    return _TarjetaPuerta(
      titulo: 'IKASLEA',
      subtitulo: 'Jolastu, kantatu, ikasi.',
      icono: Icons.school_outlined,
      alPulsar: () => Navigator.of(context).pushNamed('/ikaslea'),
    );
  }
}

class _TarjetaPuertaProfesor extends StatelessWidget {
  const _TarjetaPuertaProfesor();

  @override
  Widget build(BuildContext context) {
    return _TarjetaPuerta(
      titulo: 'IRAKASLEA',
      subtitulo: 'Klasea kudeatu eta ariketak banatu.',
      icono: Icons.menu_book_outlined,
      alPulsar: () => Navigator.of(context).pushNamed('/irakaslea'),
    );
  }
}

class _TarjetaPuerta extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final VoidCallback alPulsar;

  const _TarjetaPuerta({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minHeight: 220),
      child: GestureDetector(
        onTap: alPulsar,
        child: MarcoRotulador(
          grosor: 3,
          intensidadJitter: 1.4,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icono, size: 64, color: PaletaAek.tintaNegra),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: PaletaAek.tintaNegra,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: PaletaAek.tintaDiluida(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieDePagina extends StatelessWidget {
  const _PieDePagina();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        'Proiektu independentea · 2026',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: PaletaAek.tintaDiluida(0.45),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
