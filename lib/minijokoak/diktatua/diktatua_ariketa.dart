import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'diktatua_pantaila.dart';

/// Diktatua — "Dictado en euskera".
///
/// El alumno pulsa ENTZUN, escucha una frase reproducida por el TTS
/// del sistema y la escribe en un campo de texto. Al pulsar EGIAZTATU
/// se comparan palabra a palabra (normalizando puntuación y mayúsculas)
/// para mostrar aciertos y errores. Trabaja **producción ortográfica
/// + audición fina** — destrezas que ningún otro minijuego cubría.
class DiktatuaAriketa implements Ariketa {
  @override
  String get identificador => 'diktatua';

  @override
  String get izenburua => 'Diktatua';

  @override
  String get azalpenLaburra =>
      'Entzun esaldia eta idatzi entzun duzuna ortografia zainduz.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.entzumena;

  @override
  List<NivelEuskera> get gomendatuMailak => const <NivelEuskera>[
        NivelEuskera.a2,
        NivelEuskera.b1,
        NivelEuskera.b2,
      ];

  @override
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  }) {
    return DiktatuaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
