import 'package:flutter/material.dart';

import '../oinarriak/ariketa.dart';
import '../oinarriak/katalogoa.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Página del alumno: lista los ejercicios disponibles agrupados por
/// categoría. Por ahora, hasta que añadamos códigos de clase, todo está
/// abierto a todo el mundo.
class IkaslearenOrria extends StatelessWidget {
  const IkaslearenOrria({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<CategoriaAriketa, List<Ariketa>> ariketakKategoriaka =
        <CategoriaAriketa, List<Ariketa>>{};
    for (final Ariketa ariketa in KatalogoAek.ariketaGuztiak) {
      ariketakKategoriaka.putIfAbsent(ariketa.kategoria, () => <Ariketa>[]);
      ariketakKategoriaka[ariketa.kategoria]!.add(ariketa);
    }

    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 11,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: PaletaAek.papelViejo,
                surfaceTintColor: PaletaAek.papelViejo,
                elevation: 0,
                title: const Text(
                  'IKASLEA',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: PaletaAek.tintaNegra,
                  ),
                ),
                iconTheme: const IconThemeData(color: PaletaAek.tintaNegra),
                pinned: true,
                actions: <Widget>[
                  TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/ikaslea/klasea'),
                    icon: const Icon(Icons.qr_code_2,
                        color: PaletaAek.tintaNegra),
                    label: const Text(
                      'KLASEA',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: PaletaAek.tintaNegra,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/ikaslea/jarraipena'),
                    icon: const Icon(Icons.insights_outlined,
                        color: PaletaAek.tintaNegra),
                    label: const Text(
                      'JARRAIPENA',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: PaletaAek.tintaNegra,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.list(
                  children: <Widget>[
                    Text(
                      'Aukeratu ariketa bat',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        color: PaletaAek.tintaDiluida(0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...ariketakKategoriaka.entries.expand(
                      (MapEntry<CategoriaAriketa, List<Ariketa>> entrada) =>
                          <Widget>[
                        _TituloCategoria(categoria: entrada.key),
                        const SizedBox(height: 10),
                        ...entrada.value.map(
                          (Ariketa ariketa) =>
                              _TarjetaAriketa(ariketa: ariketa),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloCategoria extends StatelessWidget {
  final CategoriaAriketa categoria;
  const _TituloCategoria({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 28,
          height: 2,
          color: PaletaAek.rojoRotulador,
        ),
        const SizedBox(width: 10),
        Text(
          categoria.etiquetaEuskera.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2.5,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ],
    );
  }
}

class _TarjetaAriketa extends StatelessWidget {
  final Ariketa ariketa;
  const _TarjetaAriketa({required this.ariketa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          '/minijokoa/${ariketa.identificador}',
        ),
        child: MarcoRotulador(
          grosor: 2.4,
          intensidadJitter: 1.1,
          child: Container(
            color: PaletaAek.papelViejo,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: PaletaAek.tintaNegra,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ariketa.azalpenLaburra,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: PaletaAek.tintaDiluida(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: ariketa.gomendatuMailak
                            .map((NivelEuskera maila) => _ChipMaila(maila: maila))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: PaletaAek.rojoRotulador,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipMaila extends StatelessWidget {
  final NivelEuskera maila;
  const _ChipMaila({required this.maila});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: PaletaAek.tintaDiluida(0.6), width: 1),
      ),
      child: Text(
        maila.etiqueta,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: PaletaAek.tintaNegra,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
