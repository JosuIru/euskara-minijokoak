import 'package:aek_app/oinarriak/generador_heuristikoa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generarTodoHeuristico', () {
    const String textoCorto = 'Egun on.';
    const String textoTipico =
        'Iker bilbon bizi da. Goizean kafea hartzen du etxean. '
        'Gero, lanera doa autobusean. Arratsaldean, semearekin parkera joaten da. '
        'Gauean, liburu bat irakurtzen du. Asteburuetan mendira joaten dira lagunekin.';

    test('texto muy corto devuelve todos los campos null', () {
      final ResultadoGeneracion resultado =
          generarTodoHeuristico(textoCorto, semilla: 0);
      expect(resultado.hutsuneak, isNull);
      expect(resultado.esaldiEraikitzailea, isNull);
      expect(resultado.hitzZaparrada, isNull);
    });

    test('texto típico produce los tres tipos', () {
      final ResultadoGeneracion resultado =
          generarTodoHeuristico(textoTipico, semilla: 42);
      expect(resultado.hutsuneak, isNotNull);
      expect(resultado.esaldiEraikitzailea, isNotNull);
      expect(resultado.hitzZaparrada, isNotNull);
    });

    test('misma semilla produce mismos huecos', () {
      final ResultadoGeneracion primero =
          generarTodoHeuristico(textoTipico, semilla: 7);
      final ResultadoGeneracion segundo =
          generarTodoHeuristico(textoTipico, semilla: 7);
      expect(
        primero.hutsuneak!.posicionesHueco,
        equals(segundo.hutsuneak!.posicionesHueco),
      );
      expect(
        primero.hutsuneak!.bancoPalabras,
        equals(segundo.hutsuneak!.bancoPalabras),
      );
    });

    test('semillas distintas pueden producir distintos huecos', () {
      final ResultadoGeneracion uno =
          generarTodoHeuristico(textoTipico, semilla: 1);
      final ResultadoGeneracion dos =
          generarTodoHeuristico(textoTipico, semilla: 999);
      final bool distintos = uno.hutsuneak!.posicionesHueco.toString() !=
              dos.hutsuneak!.posicionesHueco.toString() ||
          uno.hutsuneak!.bancoPalabras.toString() !=
              dos.hutsuneak!.bancoPalabras.toString();
      expect(distintos, isTrue,
          reason:
              'Con dos semillas muy distintas debería variar la selección o el orden del banco');
    });
  });

  group('Hutsuneak heurístico', () {
    test('respeta cantidadHuecos cuando hay candidatas suficientes', () {
      const String texto =
          'Iker bilbon bizi da. Goizean kafea hartzen du etxean. '
          'Gero, lanera doa autobusean. Arratsaldean, semearekin parkera joaten da. '
          'Gauean, liburu bat irakurtzen du. Asteburuetan mendira joaten dira lagunekin.';
      final ResultadoGeneracion resultado = generarTodoHeuristico(
        texto,
        cantidadHuecos: 4,
        semilla: 0,
      );
      expect(resultado.hutsuneak!.posicionesHueco.length, equals(4));
    });

    test('posiciones de hueco están ordenadas crecientemente', () {
      const String texto =
          'Iker bilbon bizi da. Goizean kafea hartzen du etxean. '
          'Gero, lanera doa autobusean. Arratsaldean, semearekin parkera joaten da. '
          'Gauean, liburu bat irakurtzen du. Asteburuetan mendira joaten dira lagunekin.';
      final List<int> posiciones =
          generarTodoHeuristico(texto, semilla: 0).hutsuneak!.posicionesHueco;
      final List<int> ordenadas = List<int>.from(posiciones)..sort();
      expect(posiciones, equals(ordenadas));
    });

    test('banco contiene las palabras correctas más distractoras', () {
      const String texto =
          'Iker bilbon bizi da. Goizean kafea hartzen du etxean. '
          'Gero, lanera doa autobusean. Arratsaldean, semearekin parkera joaten da. '
          'Gauean, liburu bat irakurtzen du. Asteburuetan mendira joaten dira lagunekin.';
      final HutsuneakGeneratuta hutsuneak =
          generarTodoHeuristico(texto, semilla: 0).hutsuneak!;
      final Set<String> palabrasCorrectas = hutsuneak.posicionesHueco
          .map((int i) => hutsuneak.tokensOrden[i])
          .toSet();
      expect(
        palabrasCorrectas.every((String p) => hutsuneak.bancoPalabras.contains(p)),
        isTrue,
        reason: 'Todas las palabras correctas deben aparecer en el banco',
      );
      expect(
        hutsuneak.bancoPalabras.length,
        greaterThanOrEqualTo(palabrasCorrectas.length),
      );
    });
  });

  group('Esaldi-Eraikitzailea heurístico', () {
    test('filtra oraciones a longitud entre 3 y 8 palabras', () {
      const String texto =
          'Ni etorri. ' // 2 palabras: descartada
          'Iker bilbon bizi da. ' // 4 palabras: dentro
          'Goizean kafea hartzen du etxean berarekin lagunekin batera adiskidetasunean. ' // 9 palabras: descartada
          'Lanera doa autobusean. ' // 3 palabras: dentro
          'Asteburuetan mendira joaten dira lagunekin.'; // 5 palabras: dentro
      final EsaldiEraikitzaileaGeneratuta? esaldi =
          generarTodoHeuristico(texto, semilla: 0).esaldiEraikitzailea;
      expect(esaldi, isNotNull);
      for (final List<String> oracion in esaldi!.oraciones) {
        expect(oracion.length, inInclusiveRange(3, 8));
      }
    });

    test('preserva el orden original de las palabras de cada oración', () {
      const String texto =
          'Iker bilbon bizi da. Lanera doa autobusean.';
      final EsaldiEraikitzaileaGeneratuta esaldi =
          generarTodoHeuristico(texto, semilla: 0).esaldiEraikitzailea!;
      expect(esaldi.oraciones.first,
          equals(<String>['Iker', 'bilbon', 'bizi', 'da']));
      expect(esaldi.oraciones[1],
          equals(<String>['Lanera', 'doa', 'autobusean']));
    });
  });

  group('Diktatua heurístico', () {
    test('elige oraciones entre 4 y 12 palabras', () {
      const String texto =
          'Iker etorri da. ' // 3 palabras: descartada
          'Iker bilbon bizi da gaur egun. ' // 6: dentro
          'Goizean kafea hartzen du etxean. ' // 5: dentro
          'Asteburuetan mendira joan ohi dira lagun zaharrekin batera mendi guztiak ezagutuz. '; // 13: descartada
      final DiktatuaGeneratuta? diktatua =
          generarTodoHeuristico(texto, semilla: 0).diktatua;
      expect(diktatua, isNotNull);
      for (final FraseDictadoGenerada f in diktatua!.frases) {
        final int n = f.euskera.split(RegExp(r'\s+')).length;
        expect(n, inInclusiveRange(4, 12));
      }
    });

    test('heurístico no produce traducción al castellano', () {
      const String texto =
          'Iker bilbon bizi da gaur egun. Goizean kafea hartzen du etxean.';
      final DiktatuaGeneratuta diktatua =
          generarTodoHeuristico(texto, semilla: 0).diktatua!;
      for (final FraseDictadoGenerada f in diktatua.frases) {
        expect(f.traduccionEspanol, isNull);
      }
    });

    test('devuelve null si no hay oraciones en el rango de palabras', () {
      const String texto = 'Bai. Ez. Iker. Maite.';
      final DiktatuaGeneratuta? diktatua =
          generarTodoHeuristico(texto, semilla: 0).diktatua;
      expect(diktatua, isNull);
    });
  });

  group('Hitz-Zaparrada heurístico', () {
    test('elige palabras frecuentes y descarta stopwords', () {
      const String texto =
          'Liburua mahaian dago. Liburua zaharra da. Liburua amonarena izan zen. '
          'Mahaian beste gauza batzuk daude. Mahaian ogia ere badago.';
      final HitzZaparradaGeneratuta sopa =
          generarTodoHeuristico(texto, semilla: 0).hitzZaparrada!;
      expect(sopa.palabrasClave, contains('liburua'));
      expect(sopa.palabrasClave, contains('mahaian'));
      expect(sopa.palabrasClave.every((String p) => p.length <= 10), isTrue);
    });

    test('palabras devueltas en minúsculas', () {
      const String texto =
          'Liburua mahaian dago. Liburua zaharra da. Liburua amonarena izan zen.';
      final HitzZaparradaGeneratuta sopa =
          generarTodoHeuristico(texto, semilla: 0).hitzZaparrada!;
      for (final String palabra in sopa.palabrasClave) {
        expect(palabra, equals(palabra.toLowerCase()));
      }
    });

    test('devuelve null cuando no hay candidatas suficientes', () {
      const String textoSoloStopwords = 'Ni eta zu. Hura eta hori.';
      final HitzZaparradaGeneratuta? sopa =
          generarTodoHeuristico(textoSoloStopwords, semilla: 0).hitzZaparrada;
      expect(sopa, isNull);
    });
  });
}
