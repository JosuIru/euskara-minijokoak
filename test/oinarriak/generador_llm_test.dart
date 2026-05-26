import 'dart:convert';

import 'package:aek_app/oinarriak/ariketa.dart';
import 'package:aek_app/oinarriak/generador_heuristikoa.dart';
import 'package:aek_app/oinarriak/generador_llm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Envuelve un texto en la forma que devuelve `/v1/messages`: un único
/// bloque de tipo "text" cuyo contenido es lo que el modelo escribió.
http.Response respuestaMensajeConTexto(String textoBloque) {
  return http.Response(
    jsonEncode(<String, Object?>{
      'content': <Map<String, Object?>>[
        <String, Object?>{'type': 'text', 'text': textoBloque},
      ],
    }),
    200,
  );
}

/// Crea un generador cuyo cliente HTTP responde con `respuesta` sin
/// salir a la red, capturando de paso la petición enviada para poder
/// inspeccionar el cuerpo y las cabeceras.
GeneradorLlm generadorConRespuesta(
  http.Response respuesta, {
  String modelo = 'claude-test',
  void Function(http.Request)? capturarPeticion,
}) {
  final MockClient clienteSimulado = MockClient((http.Request peticion) async {
    capturarPeticion?.call(peticion);
    return respuesta;
  });
  return GeneradorLlm(
    apiKey: 'sk-test-1234',
    modelo: modelo,
    cliente: clienteSimulado,
  );
}

void main() {
  group('GeneradorLlm — parseo de respuesta correcta', () {
    const String jsonModeloCompleto = '''
{
  "hutsuneak": {
    "tokensOrden": ["Iker", "Bilbon", "bizi", "da", "gaur"],
    "posicionesHueco": [1, 3],
    "bancoPalabras": ["Bilbon", "da", "Donostian", "zen"]
  },
  "esaldi_eraikitzailea": {
    "oraciones": [["Iker", "Bilbon", "bizi", "da"], ["Kafea", "hartzen", "du"]]
  },
  "hitz_zaparrada": {
    "palabrasClave": ["bilbon", "kafea", "etxean"]
  },
  "lotura": {
    "parejas": [
      {"euskera": "etxea", "espanol": "casa"},
      {"euskera": "kafea", "espanol": "café"}
    ]
  },
  "diktatua": {
    "frases": [
      {"euskera": "Iker Bilbon bizi da.", "espanol": "Iker vive en Bilbao."}
    ]
  }
}
''';

    test('convierte cada sección al objeto correspondiente', () async {
      final GeneradorLlm generador =
          generadorConRespuesta(respuestaMensajeConTexto(jsonModeloCompleto));
      final ResultadoGeneracion resultado =
          await generador.generar(texto: 'Iker Bilbon bizi da gaur.');
      generador.cerrar();

      expect(resultado.hutsuneak, isNotNull);
      expect(resultado.hutsuneak!.tokensOrden,
          equals(<String>['Iker', 'Bilbon', 'bizi', 'da', 'gaur']));
      expect(resultado.hutsuneak!.posicionesHueco, equals(<int>[1, 3]));
      expect(resultado.hutsuneak!.bancoPalabras, contains('Donostian'));

      expect(resultado.esaldiEraikitzailea, isNotNull);
      expect(resultado.esaldiEraikitzailea!.oraciones.length, equals(2));
      expect(resultado.esaldiEraikitzailea!.oraciones.first,
          equals(<String>['Iker', 'Bilbon', 'bizi', 'da']));

      expect(resultado.hitzZaparrada, isNotNull);
      expect(resultado.hitzZaparrada!.palabrasClave,
          equals(<String>['bilbon', 'kafea', 'etxean']));

      expect(resultado.lotura, isNotNull);
      expect(resultado.lotura!.parejas.length, equals(2));
      expect(resultado.lotura!.parejas.first.euskera, equals('etxea'));
      expect(resultado.lotura!.parejas.first.espanol, equals('casa'));

      expect(resultado.diktatua, isNotNull);
      expect(resultado.diktatua!.frases.single.euskera,
          equals('Iker Bilbon bizi da.'));
      expect(resultado.diktatua!.frases.single.traduccionEspanol,
          equals('Iker vive en Bilbao.'));
    });

    test('acepta posicionesHueco con decimales del modelo (num→int)',
        () async {
      const String conDecimales = '''
{
  "hutsuneak": {
    "tokensOrden": ["bat", "bi", "hiru", "lau"],
    "posicionesHueco": [1.0, 3.0],
    "bancoPalabras": ["bi", "lau"]
  }
}
''';
      final GeneradorLlm generador =
          generadorConRespuesta(respuestaMensajeConTexto(conDecimales));
      final ResultadoGeneracion resultado =
          await generador.generar(texto: 'bat bi hiru lau bost sei');
      generador.cerrar();
      expect(resultado.hutsuneak!.posicionesHueco, equals(<int>[1, 3]));
    });

    test('recorta texto extra del modelo alrededor del JSON', () async {
      const String conRuido =
          'Hona hemen zure ariketa:\n```json\n'
          '{ "hitz_zaparrada": { "palabrasClave": ["etxea", "kafea"] } }\n'
          '```\nEspero baliagarria izatea!';
      final GeneradorLlm generador =
          generadorConRespuesta(respuestaMensajeConTexto(conRuido));
      final ResultadoGeneracion resultado =
          await generador.generar(texto: 'Testu nahikoa luzea da hau.');
      generador.cerrar();
      expect(resultado.hitzZaparrada, isNotNull);
      expect(resultado.hitzZaparrada!.palabrasClave,
          equals(<String>['etxea', 'kafea']));
      expect(resultado.lotura, isNull);
    });

    test('lotura con parejas vacías o incompletas queda null', () async {
      const String loturaInvalida = '''
{
  "lotura": {
    "parejas": [
      {"euskera": "", "espanol": "casa"},
      {"euskera": "kafea", "espanol": "   "}
    ]
  }
}
''';
      final GeneradorLlm generador =
          generadorConRespuesta(respuestaMensajeConTexto(loturaInvalida));
      final ResultadoGeneracion resultado =
          await generador.generar(texto: 'Testu nahikoa luzea da hau.');
      generador.cerrar();
      expect(resultado.lotura, isNull);
    });

    test('diktatua sin euskera se filtra; el traducido es opcional',
        () async {
      const String diktatuaMixto = '''
{
  "diktatua": {
    "frases": [
      {"euskera": "", "espanol": "vacío"},
      {"euskera": "Kafea hartzen du."}
    ]
  }
}
''';
      final GeneradorLlm generador =
          generadorConRespuesta(respuestaMensajeConTexto(diktatuaMixto));
      final ResultadoGeneracion resultado =
          await generador.generar(texto: 'Testu nahikoa luzea da hau.');
      generador.cerrar();
      expect(resultado.diktatua, isNotNull);
      expect(resultado.diktatua!.frases.single.euskera,
          equals('Kafea hartzen du.'));
      expect(resultado.diktatua!.frases.single.traduccionEspanol, isNull);
    });
  });

  group('GeneradorLlm — errores', () {
    test('401 devuelve mensaje específico de API key', () async {
      final GeneradorLlm generador = generadorConRespuesta(
          http.Response('{"error":{"message":"invalid key"}}', 401));
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>().having(
            (ErrorGeneradorLlm e) => e.mensaje, 'mensaje', contains('API key'))),
      );
      generador.cerrar();
    });

    test('error >=400 extrae el mensaje del cuerpo', () async {
      final GeneradorLlm generador = generadorConRespuesta(http.Response(
          '{"error":{"message":"rate limit exceeded"}}', 429));
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>().having((ErrorGeneradorLlm e) => e.mensaje,
            'mensaje', contains('rate limit exceeded'))),
      );
      generador.cerrar();
    });

    test('content vacío lanza error', () async {
      final GeneradorLlm generador = generadorConRespuesta(
          http.Response(jsonEncode(<String, Object?>{'content': <Object>[]}), 200));
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>()),
      );
      generador.cerrar();
    });

    test('texto sin llaves JSON lanza error de JSON inválido', () async {
      final GeneradorLlm generador = generadorConRespuesta(
          respuestaMensajeConTexto('Ez dago JSONik hemen, testua baino ez.'));
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>()),
      );
      generador.cerrar();
    });

    test('JSON malformado entre llaves lanza error de lectura', () async {
      final GeneradorLlm generador = generadorConRespuesta(
          respuestaMensajeConTexto('{ "hutsuneak": { roto, sin comillas } }'));
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>()),
      );
      generador.cerrar();
    });

    test('error de red se envuelve en ErrorGeneradorLlm', () async {
      final MockClient clienteQueFalla = MockClient(
          (http.Request peticion) async => throw const SocketExceptionFalsa());
      final GeneradorLlm generador = GeneradorLlm(
        apiKey: 'sk-test',
        modelo: 'claude-test',
        cliente: clienteQueFalla,
      );
      expect(
        () => generador.generar(texto: 'Testu nahikoa luzea da hau.'),
        throwsA(isA<ErrorGeneradorLlm>().having((ErrorGeneradorLlm e) => e.mensaje,
            'mensaje', contains('Sareko errorea'))),
      );
      generador.cerrar();
    });
  });

  group('GeneradorLlm — atajo sin tipos seleccionados', () {
    test('si todos los flags son false no llama a la red', () async {
      bool seLlamoARed = false;
      final MockClient clienteVigilante = MockClient((http.Request _) async {
        seLlamoARed = true;
        return respuestaMensajeConTexto('{}');
      });
      final GeneradorLlm generador = GeneradorLlm(
        apiKey: 'sk-test',
        modelo: 'claude-test',
        cliente: clienteVigilante,
      );
      final ResultadoGeneracion resultado = await generador.generar(
        texto: 'Testu nahikoa luzea da hau.',
        incluirHutsuneak: false,
        incluirEsaldi: false,
        incluirSopa: false,
        incluirLotura: false,
        incluirDiktatua: false,
      );
      generador.cerrar();
      expect(seLlamoARed, isFalse);
      expect(resultado.hutsuneak, isNull);
      expect(resultado.esaldiEraikitzailea, isNull);
      expect(resultado.hitzZaparrada, isNull);
      expect(resultado.lotura, isNull);
      expect(resultado.diktatua, isNull);
    });
  });

  group('GeneradorLlm — construcción de la petición', () {
    test('envía cabeceras de autenticación y acceso desde navegador',
        () async {
      http.Request? capturada;
      final GeneradorLlm generador = generadorConRespuesta(
        respuestaMensajeConTexto('{}'),
        capturarPeticion: (http.Request p) => capturada = p,
      );
      await generador.generar(texto: 'Testu nahikoa luzea da hau.');
      generador.cerrar();

      expect(capturada, isNotNull);
      expect(capturada!.headers['x-api-key'], equals('sk-test-1234'));
      expect(capturada!.headers['anthropic-version'], equals('2023-06-01'));
      expect(capturada!.headers['anthropic-dangerous-direct-browser-access'],
          equals('true'));
    });

    test('el cuerpo lleva el modelo y el texto del usuario', () async {
      http.Request? capturada;
      final GeneradorLlm generador = generadorConRespuesta(
        respuestaMensajeConTexto('{}'),
        modelo: 'claude-opus-test',
        capturarPeticion: (http.Request p) => capturada = p,
      );
      await generador.generar(texto: 'Testu oso berezia da hau.');
      generador.cerrar();

      final Map<String, dynamic> cuerpo =
          jsonDecode(capturada!.body) as Map<String, dynamic>;
      expect(cuerpo['model'], equals('claude-opus-test'));
      final List<dynamic> mensajes = cuerpo['messages'] as List<dynamic>;
      final Map<String, dynamic> primerMensaje =
          mensajes.first as Map<String, dynamic>;
      expect(primerMensaje['role'], equals('user'));
      expect(primerMensaje['content'] as String,
          contains('Testu oso berezia da hau.'));
    });

    test('el prompt de sistema solo lista los tipos solicitados', () async {
      http.Request? capturada;
      final GeneradorLlm generador = generadorConRespuesta(
        respuestaMensajeConTexto('{}'),
        capturarPeticion: (http.Request p) => capturada = p,
      );
      await generador.generar(
        texto: 'Testu nahikoa luzea da hau.',
        incluirHutsuneak: true,
        incluirEsaldi: true,
        incluirSopa: false,
        incluirLotura: false,
        incluirDiktatua: false,
      );
      generador.cerrar();

      final Map<String, dynamic> cuerpo =
          jsonDecode(capturada!.body) as Map<String, dynamic>;
      final String sistema = cuerpo['system'] as String;
      expect(sistema, contains('hutsuneak, esaldi_eraikitzailea eremuekin'));
    });

    test('el nivel objetivo orienta la descripción del prompt', () async {
      http.Request? capturadaA1;
      final GeneradorLlm generadorA1 = generadorConRespuesta(
        respuestaMensajeConTexto('{}'),
        capturarPeticion: (http.Request p) => capturadaA1 = p,
      );
      await generadorA1.generar(
        texto: 'Testu nahikoa luzea da hau.',
        nivelObjetivo: NivelEuskera.a1,
      );
      generadorA1.cerrar();
      final String sistemaA1 =
          (jsonDecode(capturadaA1!.body) as Map<String, dynamic>)['system']
              as String;
      expect(sistemaA1, contains('A1'));
      expect(sistemaA1, contains('Hasiberria'));

      http.Request? capturadaNull;
      final GeneradorLlm generadorNull = generadorConRespuesta(
        respuestaMensajeConTexto('{}'),
        capturarPeticion: (http.Request p) => capturadaNull = p,
      );
      await generadorNull.generar(texto: 'Testu nahikoa luzea da hau.');
      generadorNull.cerrar();
      final String sistemaNull =
          (jsonDecode(capturadaNull!.body) as Map<String, dynamic>)['system']
              as String;
      expect(sistemaNull, contains('A2-B1'));
    });
  });
}

/// Excepción de juguete para simular una caída de red en el cliente HTTP
/// sin depender de `dart:io` (no disponible en tests web).
class SocketExceptionFalsa implements Exception {
  const SocketExceptionFalsa();
  @override
  String toString() => 'Konexioa galdu da';
}
