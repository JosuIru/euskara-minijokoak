import 'package:flutter/material.dart';

import '../oinarriak/almacen_local.dart';
import '../oinarriak/ariketa.dart';
import '../oinarriak/ariketa_sortua.dart';
import '../oinarriak/generador_heuristikoa.dart';
import '../oinarriak/katalogoa.dart';
import '../oinarriak/paleta.dart';
import 'diktatua/diktatua_pantaila.dart';
import 'entzumena/entzumena_datuak.dart';
import 'esaldi_eraikitzailea/esaldi_sortua_pantaila.dart';
import 'hitz_zaparrada/hitz_zaparrada_datuak.dart';
import 'hitz_zaparrada/hitz_zaparrada_pantaila.dart';
import 'hutsuneak/hutsuneak_sortua_pantaila.dart';
import 'jolas_amaiera_orria.dart';
import 'lotura/lotura_datuak.dart';
import 'lotura/lotura_pantaila.dart';

/// Anfitrión genérico para cualquier [Ariketa]. Carga el ejercicio,
/// espera su callback de finalización y entonces muestra la pantalla
/// de cierre con el resultado.
///
/// Si recibe `idSortua`, carga del almacén una `AriketaSortua` y arranca
/// la variante "desde texto generado" del minijuego correspondiente.
class AnfitrioiAriketaOrria extends StatefulWidget {
  final String identificadorAriketa;
  final String? idSortua;

  const AnfitrioiAriketaOrria({
    super.key,
    required this.identificadorAriketa,
    this.idSortua,
  });

  @override
  State<AnfitrioiAriketaOrria> createState() => _AnfitrioiAriketaOrriaState();
}

class _AnfitrioiAriketaOrriaState extends State<AnfitrioiAriketaOrria> {
  ResultadoAriketa? _resultado;
  Key _claveReinicio = UniqueKey();
  Future<AriketaSortua?>? _futuroSortua;

  @override
  void initState() {
    super.initState();
    if (widget.idSortua != null) {
      _futuroSortua =
          AlmacenAriketaSortua.instancia.cargarUna(widget.idSortua!);
    }
  }

  void _recibirResultado(ResultadoAriketa resultado) {
    setState(() {
      _resultado = resultado;
    });
    AlmacenLocal.instancia.guardarResultado(resultado).catchError((_) {});
  }

  void _reintentar() {
    setState(() {
      _resultado = null;
      _claveReinicio = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_resultado != null) {
      return JolasAmaieraOrria(
        resultado: _resultado!,
        alReintentar: _reintentar,
      );
    }

    if (widget.idSortua != null) {
      return FutureBuilder<AriketaSortua?>(
        future: _futuroSortua,
        builder: (BuildContext context,
            AsyncSnapshot<AriketaSortua?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: PaletaAek.papelViejo,
              body: Center(
                child: CircularProgressIndicator(
                    color: PaletaAek.rojoRotulador),
              ),
            );
          }
          final AriketaSortua? ariketa = snapshot.data;
          if (ariketa == null) {
            return _PaginaErrorAriketa(
              identificadorAriketa:
                  'Sortua: ${widget.idSortua}',
            );
          }
          return KeyedSubtree(
            key: _claveReinicio,
            child: _construirPantallaSortua(ariketa),
          );
        },
      );
    }

    final Ariketa? ariketa =
        KatalogoAek.identifikatzaileagatik(widget.identificadorAriketa);
    if (ariketa == null) {
      return _PaginaErrorAriketa(
        identificadorAriketa: widget.identificadorAriketa,
      );
    }

    return KeyedSubtree(
      key: _claveReinicio,
      child: ariketa.eraikiPantaila(amaitzean: _recibirResultado),
    );
  }

  Widget _construirPantallaSortua(AriketaSortua ariketa) {
    switch (ariketa.tipoMinijuegoa) {
      case TipoMinijuegoSortua.hutsuneak:
        return HutsuneakSortuaPantaila(
          identificadorAriketa: 'hutsuneak',
          izenburua: ariketa.izenburua,
          datuak: SerializadorHutsuneak.desdeMapa(ariketa.datuak),
          amaitzean: _recibirResultado,
        );
      case TipoMinijuegoSortua.esaldiEraikitzailea:
        return EsaldiSortuaPantaila(
          identificadorAriketa: 'esaldi_eraikitzailea',
          izenburua: ariketa.izenburua,
          datuak: SerializadorEsaldiEraikitzailea.desdeMapa(ariketa.datuak),
          amaitzean: _recibirResultado,
        );
      case TipoMinijuegoSortua.hitzZaparrada:
        final HitzZaparradaGeneratuta datos =
            SerializadorHitzZaparrada.desdeMapa(ariketa.datuak);
        // Adaptamos los datos generados a la estructura `TemaSopa` que ya
        // espera la pantalla existente — así reutilizamos motor y UI.
        final TemaSopa temaSintetico = TemaSopa(
          identificador: 'sortua-${ariketa.id}',
          izenburuEuskera: ariketa.izenburua,
          descripcionEspanol: 'Testutik sortua',
          palabras: datos.palabrasClave,
        );
        return HitzZaparradaPantaila(
          identificadorAriketa: 'hitz_zaparrada',
          amaitzean: _recibirResultado,
          temaPredefinido: temaSintetico,
        );
      case TipoMinijuegoSortua.lotura:
        final LoturaGeneratuta datosLotura =
            SerializadorLotura.desdeMapa(ariketa.datuak);
        final TemaVocabulario temaSinteticoLotura = TemaVocabulario(
          identificador: 'sortua-${ariketa.id}',
          izenburuEuskera: ariketa.izenburua,
          descripcionEspanol: 'Testutik sortua',
          emojiRepresentativo: '📝',
          parejas: datosLotura.parejas
              .map((ParejaGenerada p) => ParejaVocabulario(
                    euskera: p.euskera,
                    espanol: p.espanol,
                  ))
              .toList(growable: false),
        );
        return LoturaPantaila(
          identificadorAriketa: 'lotura',
          amaitzean: _recibirResultado,
          temaPredefinido: temaSinteticoLotura,
        );
      case TipoMinijuegoSortua.diktatua:
        final DiktatuaGeneratuta datosDictado =
            SerializadorDiktatua.desdeMapa(ariketa.datuak);
        final List<FraseEntzumena> frasesAdaptadas = datosDictado.frases
            .map((FraseDictadoGenerada f) => FraseEntzumena(
                  fraseEuskera: f.euskera,
                  traduccionCorrectaEspanol: f.traduccionEspanol ?? '',
                  distractoresEspanol: const <String>[],
                ))
            .toList(growable: false);
        return DiktatuaPantaila(
          identificadorAriketa: 'diktatua',
          amaitzean: _recibirResultado,
          frasesPredefinidas: frasesAdaptadas,
        );
    }
  }
}

class _PaginaErrorAriketa extends StatelessWidget {
  final String identificadorAriketa;
  const _PaginaErrorAriketa({required this.identificadorAriketa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      appBar: AppBar(
        backgroundColor: PaletaAek.papelViejo,
        iconTheme: const IconThemeData(color: PaletaAek.tintaNegra),
        title: const Text(
          'EZ AURKITUA',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: PaletaAek.tintaNegra,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ariketa hau ($identificadorAriketa) ez dago katalogoan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              color: PaletaAek.tintaNegra,
            ),
          ),
        ),
      ),
    );
  }
}
