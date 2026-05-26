import 'package:flutter/material.dart';

import '../../oinarriak/ariketa.dart';
import 'hitz_zaparrada_pantaila.dart';

/// Hitz-Zaparrada — "Sopa de letras".
///
/// El alumno elige un tema, recibe un tablero 10×10 con palabras del
/// tema ocultas en horizontal y vertical, y debe encontrarlas tocando
/// la primera y la última letra de cada una. Trabaja reconocimiento
/// visual del léxico vasco.
class HitzZaparradaAriketa implements Ariketa {
  @override
  String get identificador => 'hitz_zaparrada';

  @override
  String get izenburua => 'Hitz-Zaparrada';

  @override
  String get azalpenLaburra =>
      'Hitz sopa: gaiari buruzko hitzak aurkitu letren artean.';

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
    return HitzZaparradaPantaila(
      identificadorAriketa: identificador,
      amaitzean: amaitzean,
    );
  }
}
