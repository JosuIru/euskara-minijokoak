import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ariketa.dart';
import 'generador_heuristikoa.dart';

/// Excepción de uso interno para distinguir errores del LLM (red, 401,
/// JSON inválido…) y mostrarlos en la UI sin pintar stack traces.
class ErrorGeneradorLlm implements Exception {
  final String mensaje;
  const ErrorGeneradorLlm(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Cliente fino para `POST /v1/messages` de la API de Anthropic. Envía
/// un prompt sistema instruyendo a Claude a producir un JSON con la
/// misma forma que el `ResultadoGeneracion` del motor heurístico, así
/// el resto del pipeline (almacén, pantallas) no se entera de la
/// diferencia.
class GeneradorLlm {
  final String apiKey;
  final String modelo;
  final Uri endpoint;
  final http.Client _cliente;

  GeneradorLlm({
    required this.apiKey,
    required this.modelo,
    Uri? endpoint,
    http.Client? cliente,
  })  : endpoint = endpoint ?? Uri.parse('https://api.anthropic.com/v1/messages'),
        _cliente = cliente ?? http.Client();

  /// Genera el `ResultadoGeneracion` desde un texto. Los flags permiten
  /// pedir sólo los minijuegos que el profesor seleccionó en la UI.
  /// [nivelObjetivo] orienta al modelo sobre vocabulario y complejidad
  /// gramatical esperados; si es null, el modelo asume nivel intermedio.
  Future<ResultadoGeneracion> generar({
    required String texto,
    bool incluirHutsuneak = true,
    bool incluirEsaldi = true,
    bool incluirSopa = true,
    bool incluirLotura = false,
    bool incluirDiktatua = false,
    NivelEuskera? nivelObjetivo,
  }) async {
    if (!incluirHutsuneak &&
        !incluirEsaldi &&
        !incluirSopa &&
        !incluirLotura &&
        !incluirDiktatua) {
      return const ResultadoGeneracion();
    }
    final String promptSistema = _construirPromptSistema(
      incluirHutsuneak: incluirHutsuneak,
      incluirEsaldi: incluirEsaldi,
      incluirSopa: incluirSopa,
      incluirLotura: incluirLotura,
      incluirDiktatua: incluirDiktatua,
      nivelObjetivo: nivelObjetivo,
    );
    final Map<String, Object?> cuerpo = <String, Object?>{
      'model': modelo,
      'max_tokens': 2048,
      'system': promptSistema,
      'messages': <Map<String, Object?>>[
        <String, Object?>{
          'role': 'user',
          'content':
              'Hau da euskarazko testua. Sortu JSON erantzuna sistemaren '
                  'aginduen arabera.\n\nTESTUA:\n$texto',
        },
      ],
    };

    http.Response respuesta;
    try {
      respuesta = await _cliente.post(
        endpoint,
        headers: <String, String>{
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
          // Imprescindible para llamadas desde el navegador (PWA).
          // Sin esta cabecera la API rechaza el CORS preflight desde
          // origenes web. La API la admite explícitamente para uso
          // directo desde cliente.
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode(cuerpo),
      );
    } catch (e) {
      throw ErrorGeneradorLlm('Sareko errorea: ${e.toString()}');
    }

    if (respuesta.statusCode == 401) {
      throw const ErrorGeneradorLlm(
          'API key okerra edo iraungita. Egiaztatu ezarpenetan.');
    }
    if (respuesta.statusCode >= 400) {
      throw ErrorGeneradorLlm(
          'API errorea (${respuesta.statusCode}): ${_extraerErrorTexto(respuesta.body)}');
    }

    final Map<String, dynamic> respuestaJson =
        jsonDecode(respuesta.body) as Map<String, dynamic>;
    final List<dynamic> contenido =
        (respuestaJson['content'] as List<dynamic>?) ?? const <dynamic>[];
    if (contenido.isEmpty) {
      throw const ErrorGeneradorLlm('Modelo erantzun hutsa eman du.');
    }
    final Map<String, dynamic> primerBloque =
        contenido.first as Map<String, dynamic>;
    final String? textoBloque = primerBloque['text'] as String?;
    if (textoBloque == null) {
      throw const ErrorGeneradorLlm('Modeloak ez du testurik itzuli.');
    }

    final Map<String, dynamic> jsonGenerado = _parsearJsonDelLlm(textoBloque);
    return _convertirAResultado(jsonGenerado);
  }

  /// Cierra el cliente HTTP. Llamar al destruir la instancia para
  /// liberar conexiones persistentes.
  void cerrar() => _cliente.close();

  String _construirPromptSistema({
    required bool incluirHutsuneak,
    required bool incluirEsaldi,
    required bool incluirSopa,
    required bool incluirLotura,
    required bool incluirDiktatua,
    NivelEuskera? nivelObjetivo,
  }) {
    final List<String> tiposPedidos = <String>[
      if (incluirHutsuneak) 'hutsuneak',
      if (incluirEsaldi) 'esaldi_eraikitzailea',
      if (incluirSopa) 'hitz_zaparrada',
      if (incluirLotura) 'lotura',
      if (incluirDiktatua) 'diktatua',
    ];
    final String descripcionMaila = nivelObjetivo == null
        ? 'A2-B1'
        : '${nivelObjetivo.etiqueta} (${nivelObjetivo.descripcionEuskera})';
    final String guiaNivel = _guiaPedagogicaPorNivel(nivelObjetivo);
    return 'Zu euskararen irakaslea zara, $descripcionMaila mailako '
        'helduentzat ariketak prestatzen dituena. $guiaNivel '
        'Erabiltzaileak emandako testutik abiatuta, '
        'erantzun JSON soil bat ${tiposPedidos.join(", ")} eremuekin. Ez gehitu '
        'azalpenik JSONetik kanpo.\n\n'
        'JSON formatua:\n'
        '{\n'
        '  "hutsuneak": {\n'
        '    "tokensOrden": ["hitz1", "hitz2", ...],\n'
        '    "posicionesHueco": [3, 7, 12],\n'
        '    "bancoPalabras": ["hitz_okerra1", ...]\n'
        '  },\n'
        '  "esaldi_eraikitzailea": {\n'
        '    "oraciones": [["hitz1","hitz2","hitz3"], ...]\n'
        '  },\n'
        '  "hitz_zaparrada": {\n'
        '    "palabrasClave": ["hitz1", "hitz2", ...]\n'
        '  },\n'
        '  "lotura": {\n'
        '    "parejas": [\n'
        '      {"euskera": "hitza", "espanol": "palabra"}\n'
        '    ]\n'
        '  },\n'
        '  "diktatua": {\n'
        '    "frases": [\n'
        '      {"euskera": "Esaldi osoa euskaraz.", "espanol": "Traducción al castellano."}\n'
        '    ]\n'
        '  }\n'
        '}\n\n'
        'Arauak:\n'
        '- tokensOrden: testua hitzetan zatituta jatorrizko ordenan, puntuazio gabe.\n'
        '- posicionesHueco: 4-8 indize, hitz interesgarriak (ez stopwords, ez aditz laguntzaile motzak), banatuta testu osoan.\n'
        '- bancoPalabras: hutsuneetako hitz zuzenak + 3-4 distraktore plausible.\n'
        '- oraciones: testuko 3-6 esaldi, bakoitza 3-8 hitz, jatorrizko ordenan.\n'
        '- palabrasClave: 6 hitz garrantzitsu, 4-10 letra bitartean, deklinazio markak kenduta posible bada.\n'
        '- lotura.parejas: zehazki 8 hitz-bikote testuaren oinarrizko hiztegitik. Euskara aldea testuan azaltzen den moduan (deklinazio markarik gabe ahal denean), gaztelaniako aldea itzulpen ohikoarekin.\n'
        '- diktatua.frases: 5-6 esaldi testutik, bakoitza 4-12 hitz, puntuazio osoarekin eta gaztelaniako itzulpen naturalarekin. Aukeratu ortografikoki adierazgarriak diren esaldiak (hots berezia, deklinazio markak…).\n'
        '- Sortu zer eskatu zaizun bakarrik. Beste eremuak ez gehitu.';
  }

  /// Pista pedagógica al modelo en función del nivel del alumno. Lo
  /// devolvemos en castellano porque el prompt-sistema es mixto eus/es
  /// y el modelo lo asimila mejor así.
  String _guiaPedagogicaPorNivel(NivelEuskera? nivel) {
    switch (nivel) {
      case NivelEuskera.a1:
        return 'Erabili egunerokoaren oinarrizko hiztegia, esaldi laburrak eta orainaldi soila. Saihestu deklinabide markak izenburuko forman.';
      case NivelEuskera.a2:
        return 'Erabili egunerokoaren hiztegia eta iragana sinplea ere. Esaldi labur eta zuzenak.';
      case NivelEuskera.b1:
        return 'Hiztegia zabaldu lan- eta eskola-arlora. Sartu mendeko esaldi sinpleak eta partizipioak.';
      case NivelEuskera.b2:
        return 'Erabili mendekotasun anitzeko esaldiak, baldintzazkoak eta diskurtso markatzaileak. Hiztegia formala/instituzionala onartu.';
      case NivelEuskera.c1:
        return 'Erabili diskurtso abstraktua, terminologia espezializatua, esaldi luze eta erlatibodun konplexuak. Saihestu errepikapen lexikoa.';
      case NivelEuskera.c2:
        return 'Maila natiboa: idiomatika, hiztegi adierazgarria, esaldi-egitura sortzaileak.';
      case null:
        return 'Erabili A2-B1 mailako euskera estandarra.';
    }
  }

  String _extraerErrorTexto(String cuerpo) {
    try {
      final Map<String, dynamic> json = jsonDecode(cuerpo);
      final Map<String, dynamic>? error =
          json['error'] as Map<String, dynamic>?;
      if (error != null) {
        return (error['message'] as String?) ?? cuerpo;
      }
    } catch (_) {}
    return cuerpo.length > 200 ? '${cuerpo.substring(0, 200)}…' : cuerpo;
  }

  Map<String, dynamic> _parsearJsonDelLlm(String texto) {
    // Recorta a la primera "{" y a la última "}" — el modelo a veces
    // antepone comentarios o markdown aunque le pidamos sólo JSON.
    final int inicio = texto.indexOf('{');
    final int fin = texto.lastIndexOf('}');
    if (inicio == -1 || fin == -1 || fin <= inicio) {
      throw const ErrorGeneradorLlm(
          'Erantzunak ez du JSON baliogarririk.');
    }
    final String recortado = texto.substring(inicio, fin + 1);
    try {
      return jsonDecode(recortado) as Map<String, dynamic>;
    } catch (e) {
      throw ErrorGeneradorLlm(
          'Erantzun-JSON-a ezin izan da irakurri: ${e.toString()}');
    }
  }

  ResultadoGeneracion _convertirAResultado(Map<String, dynamic> mapa) {
    HutsuneakGeneratuta? hutsuneak;
    final Map<String, dynamic>? mapaHutsuneak =
        mapa['hutsuneak'] as Map<String, dynamic>?;
    if (mapaHutsuneak != null) {
      hutsuneak = HutsuneakGeneratuta(
        tokensOrden: List<String>.from(
            mapaHutsuneak['tokensOrden'] as List<dynamic>),
        posicionesHueco: List<int>.from(
            (mapaHutsuneak['posicionesHueco'] as List<dynamic>)
                .map((dynamic v) => (v as num).toInt())),
        bancoPalabras: List<String>.from(
            mapaHutsuneak['bancoPalabras'] as List<dynamic>),
      );
    }

    EsaldiEraikitzaileaGeneratuta? esaldi;
    final Map<String, dynamic>? mapaEsaldi =
        mapa['esaldi_eraikitzailea'] as Map<String, dynamic>?;
    if (mapaEsaldi != null) {
      final List<dynamic> bruto = mapaEsaldi['oraciones'] as List<dynamic>;
      esaldi = EsaldiEraikitzaileaGeneratuta(
        oraciones: bruto
            .map((dynamic linea) =>
                List<String>.from(linea as List<dynamic>))
            .toList(growable: false),
      );
    }

    HitzZaparradaGeneratuta? sopa;
    final Map<String, dynamic>? mapaSopa =
        mapa['hitz_zaparrada'] as Map<String, dynamic>?;
    if (mapaSopa != null) {
      sopa = HitzZaparradaGeneratuta(
        palabrasClave: List<String>.from(
            mapaSopa['palabrasClave'] as List<dynamic>),
      );
    }

    LoturaGeneratuta? lotura;
    final Map<String, dynamic>? mapaLotura =
        mapa['lotura'] as Map<String, dynamic>?;
    if (mapaLotura != null) {
      final List<dynamic> brutoParejas =
          (mapaLotura['parejas'] as List<dynamic>?) ?? const <dynamic>[];
      final List<ParejaGenerada> parejas = brutoParejas
          .map((dynamic entrada) {
            final Map<String, dynamic> mapa =
                entrada as Map<String, dynamic>;
            return ParejaGenerada(
              euskera: (mapa['euskera'] as String?)?.trim() ?? '',
              espanol: (mapa['espanol'] as String?)?.trim() ?? '',
            );
          })
          .where((ParejaGenerada p) => p.euskera.isNotEmpty && p.espanol.isNotEmpty)
          .toList(growable: false);
      if (parejas.isNotEmpty) {
        lotura = LoturaGeneratuta(parejas: parejas);
      }
    }

    DiktatuaGeneratuta? diktatua;
    final Map<String, dynamic>? mapaDictado =
        mapa['diktatua'] as Map<String, dynamic>?;
    if (mapaDictado != null) {
      final List<dynamic> brutoFrases =
          (mapaDictado['frases'] as List<dynamic>?) ?? const <dynamic>[];
      final List<FraseDictadoGenerada> frases = brutoFrases
          .map((dynamic entrada) {
            final Map<String, dynamic> p = entrada as Map<String, dynamic>;
            return FraseDictadoGenerada(
              euskera: (p['euskera'] as String?)?.trim() ?? '',
              traduccionEspanol: (p['espanol'] as String?)?.trim(),
            );
          })
          .where((FraseDictadoGenerada f) => f.euskera.isNotEmpty)
          .toList(growable: false);
      if (frases.isNotEmpty) {
        diktatua = DiktatuaGeneratuta(frases: frases);
      }
    }

    return ResultadoGeneracion(
      hutsuneak: hutsuneak,
      esaldiEraikitzailea: esaldi,
      hitzZaparrada: sopa,
      lotura: lotura,
      diktatua: diktatua,
    );
  }
}
