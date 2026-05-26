import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'aditzen_tailerra_pantaila.dart';

/// Aditzen Tailerra — "Taller de verbos sintéticos".
///
/// El alumno ve un pronombre + un verbo en infinitivo + una frase con
/// hueco, y debe elegir la forma conjugada correcta entre 4 opciones
/// del mismo verbo (distractores = otras personas). Trabaja
/// específicamente los aditz trinkoak nucleares: izan, egon, joan,
/// etorri, jakin, eduki.
class AditzenTailerraAriketa implements Ariketa {
  @override
  String get identificador => 'aditzen_tailerra';

  @override
  String get izenburua => 'Aditzen Tailerra';

  @override
  String get azalpenLaburra =>
      'Aditz trinkoen forma egokia aukeratu izenordainaren arabera.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.aditzak;

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
    return AditzenTailerraPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
