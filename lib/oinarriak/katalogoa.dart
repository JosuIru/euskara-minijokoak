import '../minijokoak/aditzen_tailerra/aditzen_tailerra_ariketa.dart';
import '../minijokoak/deklinatzailea/deklinatzailea_ariketa.dart';
import '../minijokoak/diktatua/diktatua_ariketa.dart';
import '../minijokoak/entzumena/entzumena_ariketa.dart';
import '../minijokoak/esaldi_eraikitzailea/esaldi_eraikitzailea_ariketa.dart';
import '../minijokoak/hitz_zaparrada/hitz_zaparrada_ariketa.dart';
import '../minijokoak/hutsuneak/hutsuneak_ariketa.dart';
import '../minijokoak/lotura/lotura_ariketa.dart';
import 'ariketa.dart';

/// Catálogo único con todos los ejercicios disponibles en la app.
///
/// Para añadir un minijuego nuevo:
/// 1. Crear su carpeta bajo `lib/minijokoak/<izen_motza>/`
/// 2. Implementar una clase que extienda [Ariketa]
/// 3. Añadir una instancia en [_ariketaGuztiak] aquí abajo
class KatalogoAek {
  static final List<Ariketa> _ariketaGuztiak = <Ariketa>[
    DeklinatzaileaAriketa(),
    AditzenTailerraAriketa(),
    EsaldiEraikitzaileaAriketa(),
    LoturaAriketa(),
    HitzZaparradaAriketa(),
    EntzumenaAriketa(),
    DiktatuaAriketa(),
    HutsuneakAriketa(),
  ];

  /// Todos los ejercicios disponibles.
  static List<Ariketa> get ariketaGuztiak =>
      List<Ariketa>.unmodifiable(_ariketaGuztiak);

  /// Devuelve los ejercicios que coinciden con una categoría dada.
  static List<Ariketa> kategoriarenArabera(CategoriaAriketa kategoria) {
    return _ariketaGuztiak
        .where((ariketa) => ariketa.kategoria == kategoria)
        .toList(growable: false);
  }

  /// Busca un ejercicio por su identificador estable. Devuelve null si
  /// no existe (la ruta puede estar caducada o mal escrita).
  static Ariketa? identifikatzaileagatik(String identifikatzailea) {
    for (final ariketa in _ariketaGuztiak) {
      if (ariketa.identificador == identifikatzailea) {
        return ariketa;
      }
    }
    return null;
  }
}
