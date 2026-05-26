import 'dart:convert';

import 'package:http/http.dart' as http;

/// Estado del resultado de comprobar actualizaciones. Lo usa la UI para
/// decidir qué pintar: nada, un aviso, o un mensaje de error discreto.
enum EgoeraEguneraketa {
  /// La versión instalada es la última publicada (o más nueva).
  eguneratuta,

  /// Hay una versión más reciente en el manifiesto remoto.
  eskuragarri,

  /// No se pudo comprobar (red caída, manifiesto inválido…). No es un
  /// fallo crítico: la app sigue funcionando, sólo no sabemos si hay
  /// novedades.
  errorea,
}

/// Datos de la última versión publicada, leídos del manifiesto JSON
/// remoto que controla quien publica la app.
class ManifestuEguneraketa {
  /// Versión semántica publicada, p.ej. "1.2.0".
  final String bertsioa;

  /// Número de build monótono (el `+N` del pubspec). Es el criterio
  /// principal de comparación porque siempre crece.
  final int buildZenbakia;

  /// URL desde la que descargar/instalar la nueva versión (APK, página
  /// de release, etc). La UI la abre con `url_launcher`.
  final String deskargaUrl;

  /// Notas de la versión para mostrar al usuario. Opcional.
  final String? oharrak;

  /// Si es `true`, la UI debería insistir más (actualización
  /// recomendada con fuerza). De momento sólo cambia el texto del aviso.
  final bool derrigorrezkoa;

  const ManifestuEguneraketa({
    required this.bertsioa,
    required this.buildZenbakia,
    required this.deskargaUrl,
    this.oharrak,
    this.derrigorrezkoa = false,
  });

  /// Construye el manifiesto desde el JSON remoto. Lanza
  /// [FormatException] si faltan los campos imprescindibles, para que el
  /// servicio lo traduzca a [EgoeraEguneraketa.errorea].
  factory ManifestuEguneraketa.fromJson(Map<String, dynamic> json) {
    final String? bertsioa = (json['azken_bertsioa'] as String?)?.trim();
    final Object? buildBruto = json['build_zenbakia'];
    final String? deskargaUrl = (json['deskarga_url'] as String?)?.trim();
    if (bertsioa == null || bertsioa.isEmpty) {
      throw const FormatException('Manifestuak ez du "azken_bertsioa" eremurik.');
    }
    if (buildBruto is! num) {
      throw const FormatException('Manifestuak ez du "build_zenbakia" baliodunik.');
    }
    if (deskargaUrl == null || deskargaUrl.isEmpty) {
      throw const FormatException('Manifestuak ez du "deskarga_url" eremurik.');
    }
    final String? oharrak = (json['oharrak'] as String?)?.trim();
    return ManifestuEguneraketa(
      bertsioa: bertsioa,
      buildZenbakia: buildBruto.toInt(),
      deskargaUrl: deskargaUrl,
      oharrak: (oharrak == null || oharrak.isEmpty) ? null : oharrak,
      derrigorrezkoa: json['derrigorrezkoa'] == true,
    );
  }
}

/// Resultado de una comprobación. Sólo trae `manifestua` cuando hay
/// actualización disponible, y `erroreMezua` cuando falló.
class EmaitzaEguneraketa {
  final EgoeraEguneraketa egoera;
  final ManifestuEguneraketa? manifestua;
  final String? erroreMezua;

  const EmaitzaEguneraketa._({
    required this.egoera,
    this.manifestua,
    this.erroreMezua,
  });

  factory EmaitzaEguneraketa.eguneratuta() =>
      const EmaitzaEguneraketa._(egoera: EgoeraEguneraketa.eguneratuta);

  factory EmaitzaEguneraketa.eskuragarri(ManifestuEguneraketa manifestua) =>
      EmaitzaEguneraketa._(
        egoera: EgoeraEguneraketa.eskuragarri,
        manifestua: manifestua,
      );

  factory EmaitzaEguneraketa.errorea(String mezua) => EmaitzaEguneraketa._(
        egoera: EgoeraEguneraketa.errorea,
        erroreMezua: mezua,
      );

  bool get badagoEguneraketa => egoera == EgoeraEguneraketa.eskuragarri;
}

/// Compara dos versiones (semántica + número de build) y decide si la
/// `candidata` es más nueva que la `instalada`. Función pura para poder
/// testearla sin red ni plataforma.
///
/// Criterio: se comparan los componentes `major.minor.patch` en orden;
/// a igualdad, manda el número de build. Componentes no numéricos o
/// ausentes cuentan como 0, así "1.2" y "1.2.0" se consideran iguales.
bool bertsioaBerriagoaDa({
  required String bertsioInstalatua,
  required int buildInstalatua,
  required String bertsioCandidata,
  required int buildCandidata,
}) {
  final List<int> instalatua = _zatituBertsioa(bertsioInstalatua);
  final List<int> candidata = _zatituBertsioa(bertsioCandidata);
  final int luzera =
      instalatua.length > candidata.length ? instalatua.length : candidata.length;
  for (int i = 0; i < luzera; i++) {
    final int a = i < instalatua.length ? instalatua[i] : 0;
    final int b = i < candidata.length ? candidata[i] : 0;
    if (b != a) return b > a;
  }
  // Misma versión semántica: desempata el build.
  return buildCandidata > buildInstalatua;
}

List<int> _zatituBertsioa(String bertsioa) {
  // Quita un posible sufijo de build pegado con "+" ("1.2.0+5") y
  // cualquier pre-release ("-beta") antes de partir por puntos.
  final String soilik = bertsioa.split('+').first.split('-').first.trim();
  return soilik
      .split('.')
      .map((String parte) => int.tryParse(parte.trim()) ?? 0)
      .toList(growable: false);
}

/// Comprueba contra un manifiesto remoto si hay una versión más reciente
/// que la instalada. El `cliente` HTTP es inyectable para poder testear
/// con `MockClient`, igual que [GeneradorLlm].
class EguneraketakZerbitzua {
  /// Manifiesto por defecto. AJUSTAR a la URL real donde se publique el
  /// JSON de versiones antes de distribuir la app.
  static const String urlManifestuaLehenetsia =
      'https://aek-app.eus/eguneraketak.json';

  final Uri urlManifestua;
  final http.Client _cliente;

  EguneraketakZerbitzua({
    Uri? urlManifestua,
    http.Client? cliente,
  })  : urlManifestua = urlManifestua ?? Uri.parse(urlManifestuaLehenetsia),
        _cliente = cliente ?? http.Client();

  /// Descarga el manifiesto y lo compara con la versión instalada.
  /// Nunca lanza: cualquier fallo se devuelve como
  /// [EgoeraEguneraketa.errorea] para que el aviso de actualización no
  /// pueda romper la pantalla que lo invoca.
  Future<EmaitzaEguneraketa> egiaztatu({
    required String bertsioInstalatua,
    required int buildInstalatua,
  }) async {
    http.Response respuesta;
    try {
      respuesta = await _cliente.get(urlManifestua);
    } catch (e) {
      return EmaitzaEguneraketa.errorea('Sareko errorea: ${e.toString()}');
    }

    if (respuesta.statusCode >= 400) {
      return EmaitzaEguneraketa.errorea(
          'Manifestua ezin izan da jaitsi (${respuesta.statusCode}).');
    }

    final ManifestuEguneraketa manifestua;
    try {
      final Map<String, dynamic> json =
          jsonDecode(respuesta.body) as Map<String, dynamic>;
      manifestua = ManifestuEguneraketa.fromJson(json);
    } on FormatException catch (e) {
      return EmaitzaEguneraketa.errorea('Manifestu okerra: ${e.message}');
    } catch (e) {
      return EmaitzaEguneraketa.errorea(
          'Manifestua ezin izan da irakurri: ${e.toString()}');
    }

    final bool berriagoa = bertsioaBerriagoaDa(
      bertsioInstalatua: bertsioInstalatua,
      buildInstalatua: buildInstalatua,
      bertsioCandidata: manifestua.bertsioa,
      buildCandidata: manifestua.buildZenbakia,
    );
    return berriagoa
        ? EmaitzaEguneraketa.eskuragarri(manifestua)
        : EmaitzaEguneraketa.eguneratuta();
  }

  /// Cierra el cliente HTTP. Llamar al terminar para liberar conexiones.
  void cerrar() => _cliente.close();
}
