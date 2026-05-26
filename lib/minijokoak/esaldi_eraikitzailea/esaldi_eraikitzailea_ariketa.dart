import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'esaldi_eraikitzailea_pantaila.dart';

/// Esaldi-Eraikitzailea — "Constructor de frases".
///
/// El alumno recibe una traducción al español y un conjunto desordenado
/// de palabras en euskera. Debe ordenarlas para componer la frase
/// correcta en euskera, respetando el orden SOV característico.
class EsaldiEraikitzaileaAriketa implements Ariketa {
  @override
  String get identificador => 'esaldi_eraikitzailea';

  @override
  String get izenburua => 'Esaldi-Eraikitzailea';

  @override
  String get azalpenLaburra =>
      'Hitzak ordenatu euskarazko esaldi zuzen bat osatzeko.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.esaldiEraikuntza;

  @override
  List<NivelEuskera> get gomendatuMailak => const <NivelEuskera>[
        NivelEuskera.b1,
        NivelEuskera.b2,
        NivelEuskera.c1,
      ];

  @override
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  }) {
    return EsaldiEraikitzaileaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
