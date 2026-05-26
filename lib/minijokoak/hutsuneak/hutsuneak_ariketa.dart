import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'hutsuneak_pantaila.dart';

/// Hutsuneak — "Huecos en la canción".
///
/// El alumno elige una canción del catálogo, ve la letra con algunas
/// palabras ausentes (huecos) y debe completarla con las palabras
/// disponibles en un banco al pie. Trabaja vocabulario y comprensión
/// lectora en contextos musicales reales.
class HutsuneakAriketa implements Ariketa {
  @override
  String get identificador => 'hutsuneak';

  @override
  String get izenburua => 'Hutsuneak';

  @override
  String get azalpenLaburra =>
      'Kantu baten letrako hutsuneak hitz egokiekin bete.';

  @override
  CategoriaAriketa get kategoria => CategoriaAriketa.kantua;

  @override
  List<NivelEuskera> get gomendatuMailak =>
      const <NivelEuskera>[NivelEuskera.a1, NivelEuskera.a2, NivelEuskera.b1];

  @override
  Widget eraikiPantaila({
    required void Function(ResultadoAriketa) amaitzean,
  }) {
    return HutsuneakPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
