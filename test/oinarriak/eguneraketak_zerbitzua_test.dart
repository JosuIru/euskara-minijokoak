import 'dart:convert';

import 'package:aek_app/oinarriak/eguneraketak_zerbitzua.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Crea un servicio cuyo cliente HTTP devuelve siempre `respuesta`, sin
/// salir a la red. Captura de paso la URL pedida para poder verificarla.
EguneraketakZerbitzua servicioConRespuesta(
  http.Response respuesta, {
  void Function(Uri)? capturarUrl,
}) {
  final MockClient clienteSimulado = MockClient((http.Request peticion) async {
    capturarUrl?.call(peticion.url);
    return respuesta;
  });
  return EguneraketakZerbitzua(
    urlManifestua: Uri.parse('https://probak.eus/manifestua.json'),
    cliente: clienteSimulado,
  );
}

http.Response manifiestoOk({
  String version = '1.2.0',
  int build = 5,
  String url = 'https://probak.eus/aek.apk',
  String? oharrak,
  bool derrigorrezkoa = false,
}) {
  return http.Response(
    jsonEncode(<String, Object?>{
      'azken_bertsioa': version,
      'build_zenbakia': build,
      'deskarga_url': url,
      'oharrak': ?oharrak,
      'derrigorrezkoa': derrigorrezkoa,
    }),
    200,
  );
}

void main() {
  group('bertsioaBerriagoaDa (comparación pura)', () {
    test('versión semántica mayor es más nueva', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.0.0',
          buildInstalatua: 1,
          bertsioCandidata: '1.1.0',
          buildCandidata: 1,
        ),
        isTrue,
      );
    });

    test('versión semántica menor no es más nueva', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '2.0.0',
          buildInstalatua: 9,
          bertsioCandidata: '1.9.9',
          buildCandidata: 99,
        ),
        isFalse,
      );
    });

    test('a igualdad de versión, manda el número de build', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.0.0',
          buildInstalatua: 3,
          bertsioCandidata: '1.0.0',
          buildCandidata: 4,
        ),
        isTrue,
      );
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.0.0',
          buildInstalatua: 4,
          bertsioCandidata: '1.0.0',
          buildCandidata: 4,
        ),
        isFalse,
      );
    });

    test('compara el patch correctamente', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.2.3',
          buildInstalatua: 1,
          bertsioCandidata: '1.2.10',
          buildCandidata: 1,
        ),
        isTrue,
        reason: '10 > 3 numéricamente, no lexicográficamente',
      );
    });

    test('"1.2" y "1.2.0" se tratan como iguales', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.2',
          buildInstalatua: 7,
          bertsioCandidata: '1.2.0',
          buildCandidata: 7,
        ),
        isFalse,
      );
    });

    test('ignora sufijo de build pegado con + y pre-release', () {
      expect(
        bertsioaBerriagoaDa(
          bertsioInstalatua: '1.0.0+1',
          buildInstalatua: 1,
          bertsioCandidata: '1.0.0-beta',
          buildCandidata: 1,
        ),
        isFalse,
      );
    });
  });

  group('ManifestuEguneraketa.fromJson', () {
    test('parsea todos los campos', () {
      final ManifestuEguneraketa m = ManifestuEguneraketa.fromJson(
        <String, dynamic>{
          'azken_bertsioa': '2.1.0',
          'build_zenbakia': 12,
          'deskarga_url': 'https://probak.eus/aek.apk',
          'oharrak': 'Akats batzuk konponduta.',
          'derrigorrezkoa': true,
        },
      );
      expect(m.bertsioa, equals('2.1.0'));
      expect(m.buildZenbakia, equals(12));
      expect(m.deskargaUrl, equals('https://probak.eus/aek.apk'));
      expect(m.oharrak, equals('Akats batzuk konponduta.'));
      expect(m.derrigorrezkoa, isTrue);
    });

    test('oharrak ausente o vacío queda null; derrigorrezkoa por defecto false',
        () {
      final ManifestuEguneraketa m = ManifestuEguneraketa.fromJson(
        <String, dynamic>{
          'azken_bertsioa': '2.1.0',
          'build_zenbakia': 12,
          'deskarga_url': 'https://probak.eus/aek.apk',
          'oharrak': '   ',
        },
      );
      expect(m.oharrak, isNull);
      expect(m.derrigorrezkoa, isFalse);
    });

    test('falta azken_bertsioa lanza FormatException', () {
      expect(
        () => ManifestuEguneraketa.fromJson(<String, dynamic>{
          'build_zenbakia': 1,
          'deskarga_url': 'https://probak.eus/aek.apk',
        }),
        throwsFormatException,
      );
    });

    test('build_zenbakia no numérico lanza FormatException', () {
      expect(
        () => ManifestuEguneraketa.fromJson(<String, dynamic>{
          'azken_bertsioa': '1.0.0',
          'build_zenbakia': 'bost',
          'deskarga_url': 'https://probak.eus/aek.apk',
        }),
        throwsFormatException,
      );
    });

    test('falta deskarga_url lanza FormatException', () {
      expect(
        () => ManifestuEguneraketa.fromJson(<String, dynamic>{
          'azken_bertsioa': '1.0.0',
          'build_zenbakia': 1,
        }),
        throwsFormatException,
      );
    });
  });

  group('EguneraketakZerbitzua.egiaztatu', () {
    test('detecta actualización disponible', () async {
      final EguneraketakZerbitzua zerbitzua = servicioConRespuesta(
          manifiestoOk(version: '1.2.0', build: 5, oharrak: 'Berria.'));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.eskuragarri));
      expect(emaitza.badagoEguneraketa, isTrue);
      expect(emaitza.manifestua!.bertsioa, equals('1.2.0'));
      expect(emaitza.manifestua!.oharrak, equals('Berria.'));
    });

    test('si la versión instalada es la última, está al día', () async {
      final EguneraketakZerbitzua zerbitzua =
          servicioConRespuesta(manifiestoOk(version: '1.0.0', build: 1));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.eguneratuta));
      expect(emaitza.manifestua, isNull);
    });

    test('versión instalada más nueva que el manifiesto: al día', () async {
      final EguneraketakZerbitzua zerbitzua =
          servicioConRespuesta(manifiestoOk(version: '1.0.0', build: 1));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.5.0',
        buildInstalatua: 9,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.eguneratuta));
    });

    test('HTTP >=400 devuelve error, no lanza', () async {
      final EguneraketakZerbitzua zerbitzua =
          servicioConRespuesta(http.Response('not found', 404));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.errorea));
      expect(emaitza.erroreMezua, contains('404'));
    });

    test('manifiesto con JSON inválido devuelve error', () async {
      final EguneraketakZerbitzua zerbitzua =
          servicioConRespuesta(http.Response('esto no es json', 200));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.errorea));
    });

    test('manifiesto sin campos obligatorios devuelve error claro', () async {
      final EguneraketakZerbitzua zerbitzua = servicioConRespuesta(
          http.Response(jsonEncode(<String, Object?>{'foo': 'bar'}), 200));
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.errorea));
      expect(emaitza.erroreMezua, contains('Manifestu okerra'));
    });

    test('error de red se traduce a estado de error, no propaga', () async {
      final MockClient clienteQueFalla = MockClient(
          (http.Request _) async => throw const _ErrorRedFalso());
      final EguneraketakZerbitzua zerbitzua = EguneraketakZerbitzua(
        urlManifestua: Uri.parse('https://probak.eus/manifestua.json'),
        cliente: clienteQueFalla,
      );
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: '1.0.0',
        buildInstalatua: 1,
      );
      zerbitzua.cerrar();
      expect(emaitza.egoera, equals(EgoeraEguneraketa.errorea));
      expect(emaitza.erroreMezua, contains('Sareko errorea'));
    });

    test('pide la URL del manifiesto configurada', () async {
      Uri? urlPedida;
      final EguneraketakZerbitzua zerbitzua = servicioConRespuesta(
        manifiestoOk(),
        capturarUrl: (Uri u) => urlPedida = u,
      );
      await zerbitzua.egiaztatu(bertsioInstalatua: '1.0.0', buildInstalatua: 1);
      zerbitzua.cerrar();
      expect(urlPedida.toString(), equals('https://probak.eus/manifestua.json'));
    });
  });
}

/// Excepción de juguete para simular una caída de red sin `dart:io`.
class _ErrorRedFalso implements Exception {
  const _ErrorRedFalso();
  @override
  String toString() => 'Konexioa galdu da';
}
