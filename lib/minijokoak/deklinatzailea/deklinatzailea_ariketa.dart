import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'deklinatzailea_pantaila.dart';

/// Deklinatzailea — "Tetris de casos".
///
/// Cae una palabra ya declinada y el alumno debe encestarla en la ranura
/// del caso correcto (NORK / NORI / NON / NORA / NONDIK / NOREKIN /
/// NORENTZAT). Una frase con hueco da el contexto.
class DeklinatzaileaAriketa implements Ariketa {
  @override
  String get identificador => 'deklinatzailea';

  @override
  String get izenburua => 'Deklinatzailea';

  @override
  String get azalpenLaburra =>
      'Erori den hitz deklinatua kasu egokiaren saskian sartu.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.deklinabidea;

  @override
  List<NivelEuskera> get gomendatuMailak => const <NivelEuskera>[
        NivelEuskera.a1,
        NivelEuskera.a2,
        NivelEuskera.b1,
        NivelEuskera.b2,
        NivelEuskera.c1,
      ];

  @override
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  }) {
    return DeklinatzaileaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
