import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'lotura_pantaila.dart';

/// Lotura — "Memory de parejas".
///
/// El alumno destapa cartas de dos en dos, buscando que la palabra en
/// euskera y su traducción al español coincidan. Una partida son 8 pares
/// (16 cartas) de un único tema, seleccionado al principio. Trabaja
/// vocabulario A1-A2 con la mecánica universal del memory game, ideal
/// para sesiones cortas o como calentamiento de clase.
class LoturaAriketa implements Ariketa {
  @override
  String get identificador => 'lotura';

  @override
  String get izenburua => 'Lotura';

  @override
  String get azalpenLaburra =>
      'Bikoteen jolasa: euskerazko hitza eta gaztelaniazkoa lotu.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.lexikoa;

  @override
  List<NivelEuskera> get gomendatuMailak => const <NivelEuskera>[
        NivelEuskera.a2,
        NivelEuskera.b1,
        NivelEuskera.b2,
        NivelEuskera.c1,
      ];

  @override
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  }) {
    return LoturaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
