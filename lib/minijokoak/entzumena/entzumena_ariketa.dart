import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'entzumena_pantaila.dart';

/// Entzumena — "Escucha y elige".
///
/// El alumno pulsa un botón, oye una frase en euskera reproducida por
/// el TTS del sistema y elige el significado correcto entre 4
/// traducciones al español. Trabaja comprensión auditiva — la única
/// destreza nuclear que el resto de minijuegos no cubren.
class EntzumenaAriketa implements Ariketa {
  @override
  String get identificador => 'entzumena';

  @override
  String get izenburua => 'Entzun eta Hautatu';

  @override
  String get azalpenLaburra =>
      'Esaldia entzun eta esanahi zuzena aukeratu lau aukeren artean.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.entzumena;

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
    return EntzumenaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
