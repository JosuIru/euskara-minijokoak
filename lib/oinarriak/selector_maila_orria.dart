import 'package:flutter/material.dart';

import 'almacen_local.dart';
import 'ariketa.dart';
import 'paleta.dart';
import 'pintor_rotulador.dart';

/// Pantalla de selección de nivel MCER (A1, A2, B1, B2, C1) previa a
/// arrancar un minijuego procedural. Devuelve el nivel elegido vía
/// callback. Si el alumno pulsa "EZ DAKIT", se elige A2 por defecto —
/// es el nivel más usado en AEK y suficiente para empezar.
///
/// Si el alumno ya ha elegido un nivel en una sesión anterior, lo
/// aplicamos automáticamente sin mostrar la UI — para que no tenga
/// que reelegir cada vez que entra en un minijuego. Para volver al
/// selector, las pantallas exponen un botón "ALDATU MAILA" que borra
/// el nivel guardado.
///
/// Mantenemos C2 fuera: no hay material específico para ese nivel en
/// los bancos de contenido.
class SelectorMailaOrria extends StatefulWidget {
  final String izenburuMinijokoa;
  final ValueChanged<NivelEuskera> alAukeratu;

  const SelectorMailaOrria({
    super.key,
    required this.izenburuMinijokoa,
    required this.alAukeratu,
  });

  static const List<NivelEuskera> nivelesDisponibles = <NivelEuskera>[
    NivelEuskera.a1,
    NivelEuskera.a2,
    NivelEuskera.b1,
    NivelEuskera.b2,
    NivelEuskera.c1,
  ];

  @override
  State<SelectorMailaOrria> createState() => _SelectorMailaOrriaState();
}

class _SelectorMailaOrriaState extends State<SelectorMailaOrria> {
  bool _comprobandoMailaGuardada = true;

  @override
  void initState() {
    super.initState();
    _aplicarMailaGuardadaSiExiste();
  }

  Future<void> _aplicarMailaGuardadaSiExiste() async {
    final NivelEuskera? guardado =
        await AlmacenLocal.instancia.cargarMailaAukeratutakoa();
    if (!mounted) return;
    if (guardado != null) {
      widget.alAukeratu(guardado);
      return;
    }
    setState(() => _comprobandoMailaGuardada = false);
  }

  Future<void> _elegirYGuardar(NivelEuskera nivel) async {
    await AlmacenLocal.instancia.guardarMailaAukeratutakoa(nivel);
    if (!mounted) return;
    widget.alAukeratu(nivel);
  }

  @override
  Widget build(BuildContext context) {
    if (_comprobandoMailaGuardada) {
      return const Scaffold(
        backgroundColor: PaletaAek.papelViejo,
        body: Center(
          child:
              CircularProgressIndicator(color: PaletaAek.rojoRotulador),
        ),
      );
    }
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 51,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const BackButton(color: PaletaAek.tintaNegra),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.izenburuMinijokoa.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: PaletaAek.tintaNegra,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AUKERATU MAILA',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.5,
                        color: PaletaAek.rojoRotulador,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Zure mailaren araberako edukia jasoko duzu. Goragoko '
                      'mailak hitzkeria abstraktoa eta esaldi konplexuagoak '
                      'erabiltzen ditu.',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: PaletaAek.tintaDiluida(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...SelectorMailaOrria.nivelesDisponibles.map(
                      (NivelEuskera nivel) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaMaila(
                          nivel: nivel,
                          alPulsar: () => _elegirYGuardar(nivel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: TextButton(
                        onPressed: () => _elegirYGuardar(NivelEuskera.a2),
                        child: Text(
                          'EZ DAKIT — HASI A2-N',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PaletaAek.tintaDiluida(0.7),
                            letterSpacing: 1.5,
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
      ),
    );
  }
}

class _TarjetaMaila extends StatelessWidget {
  final NivelEuskera nivel;
  final VoidCallback alPulsar;

  const _TarjetaMaila({required this.nivel, required this.alPulsar});

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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: PaletaAek.rojoRotulador, width: 2.4),
                ),
                child: Text(
                  nivel.etiqueta,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: PaletaAek.rojoRotulador,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      nivel.descripcionEuskera,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: PaletaAek.tintaNegra,
                      ),
                    ),
                    Text(
                      _resumenEspanolPara(nivel),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: PaletaAek.tintaDiluida(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: PaletaAek.rojoRotulador, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _resumenEspanolPara(NivelEuskera nivel) {
    switch (nivel) {
      case NivelEuskera.a1:
        return 'Saludos, familia, vocabulario básico.';
      case NivelEuskera.a2:
        return 'Vida cotidiana, pasados sencillos.';
      case NivelEuskera.b1:
        return 'Trabajo, planes, pasado simple.';
      case NivelEuskera.b2:
        return 'Subordinación, registro formal.';
      case NivelEuskera.c1:
        return 'Discurso abstracto e institucional.';
      case NivelEuskera.c2:
        return 'Dominio nativo (no disponible aún).';
    }
  }
}
