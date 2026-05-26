import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'generador_heuristikoa.dart';

/// Qué tipo de minijuego envuelve esta `AriketaSortua`. Sirve como
/// discriminador a la hora de leer los datos crudos guardados en JSON.
enum TipoMinijuegoSortua {
  hutsuneak,
  esaldiEraikitzailea,
  hitzZaparrada,
  lotura,
  diktatua,
}

extension TipoMinijuegoSortuaSerializacion on TipoMinijuegoSortua {
  String get clave {
    switch (this) {
      case TipoMinijuegoSortua.hutsuneak:
        return 'hutsuneak';
      case TipoMinijuegoSortua.esaldiEraikitzailea:
        return 'esaldi_eraikitzailea';
      case TipoMinijuegoSortua.hitzZaparrada:
        return 'hitz_zaparrada';
      case TipoMinijuegoSortua.lotura:
        return 'lotura';
      case TipoMinijuegoSortua.diktatua:
        return 'diktatua';
    }
  }

  static TipoMinijuegoSortua desdeClave(String clave) {
    for (final TipoMinijuegoSortua valor in TipoMinijuegoSortua.values) {
      if (valor.clave == clave) return valor;
    }
    throw ArgumentError('Tipo de minijuego desconocido: $clave');
  }
}

/// Origen de la generación: heurístico local o asistencia LLM. Solo lo
/// guardamos para mostrar una etiqueta en la UI; no cambia el formato
/// de datos que el minijuego consume.
enum OrigenGeneracion { heuristico, llm }

extension OrigenGeneracionSerializacion on OrigenGeneracion {
  String get clave =>
      this == OrigenGeneracion.heuristico ? 'heuristico' : 'llm';

  static OrigenGeneracion desdeClave(String clave) {
    return clave == 'llm' ? OrigenGeneracion.llm : OrigenGeneracion.heuristico;
  }
}

/// Una partida concreta de un minijuego, generada a partir de un texto
/// del profesor. Se almacena de forma independiente para cada tipo de
/// minijuego (un mismo texto puede producir 3 `AriketaSortua`).
///
/// `datosJson` contiene la estructura específica del minijuego en
/// formato serializado — las clases auxiliares debajo se encargan de
/// convertir entre objetos tipados y mapa.
class AriketaSortua {
  /// Identificador único.
  final String id;

  /// Título corto (puesto por el profesor o derivado del texto).
  final String izenburua;

  /// Texto original tal y como lo pegó el profesor, conservado por si
  /// queremos regenerar más adelante con otra semilla o motor.
  final String testuJatorria;

  /// Qué minijuego va a jugar el alumno con estos datos.
  final TipoMinijuegoSortua tipoMinijuegoa;

  /// Cómo se generó (heurístico vs LLM).
  final OrigenGeneracion jatorria;

  /// Datos específicos del minijuego, ya en formato mapa. La pantalla
  /// del minijuego los reconvierte a su clase tipada.
  final Map<String, dynamic> datuak;

  /// Fecha de creación (ISO).
  final DateTime sortzeData;

  const AriketaSortua({
    required this.id,
    required this.izenburua,
    required this.testuJatorria,
    required this.tipoMinijuegoa,
    required this.jatorria,
    required this.datuak,
    required this.sortzeData,
  });

  AriketaSortua copiaCon({String? izenburua}) {
    return AriketaSortua(
      id: id,
      izenburua: izenburua ?? this.izenburua,
      testuJatorria: testuJatorria,
      tipoMinijuegoa: tipoMinijuegoa,
      jatorria: jatorria,
      datuak: datuak,
      sortzeData: sortzeData,
    );
  }

  Map<String, dynamic> aMapa() => <String, dynamic>{
        'id': id,
        'izenburua': izenburua,
        'testuJatorria': testuJatorria,
        'tipoMinijuegoa': tipoMinijuegoa.clave,
        'jatorria': jatorria.clave,
        'datuak': datuak,
        'sortzeDataIso': sortzeData.toIso8601String(),
      };

  static AriketaSortua desdeMapa(Map<String, dynamic> mapa) {
    return AriketaSortua(
      id: mapa['id'] as String,
      izenburua: mapa['izenburua'] as String,
      testuJatorria: mapa['testuJatorria'] as String,
      tipoMinijuegoa: TipoMinijuegoSortuaSerializacion.desdeClave(
        mapa['tipoMinijuegoa'] as String,
      ),
      jatorria: OrigenGeneracionSerializacion.desdeClave(
        mapa['jatorria'] as String,
      ),
      datuak: Map<String, dynamic>.from(mapa['datuak'] as Map),
      sortzeData: DateTime.parse(mapa['sortzeDataIso'] as String),
    );
  }
}

/// Adaptadores entre los `*Generatuta` del generador heurístico y un
/// mapa serializable. Permiten ir y volver sin acoplar las pantallas
/// de minijuego al generador.
class SerializadorHutsuneak {
  static Map<String, dynamic> aMapa(HutsuneakGeneratuta datos) =>
      <String, dynamic>{
        'tokensOrden': datos.tokensOrden,
        'posicionesHueco': datos.posicionesHueco,
        'bancoPalabras': datos.bancoPalabras,
      };

  static HutsuneakGeneratuta desdeMapa(Map<String, dynamic> mapa) {
    return HutsuneakGeneratuta(
      tokensOrden:
          List<String>.from(mapa['tokensOrden'] as List<dynamic>),
      posicionesHueco:
          List<int>.from(mapa['posicionesHueco'] as List<dynamic>),
      bancoPalabras:
          List<String>.from(mapa['bancoPalabras'] as List<dynamic>),
    );
  }
}

class SerializadorEsaldiEraikitzailea {
  static Map<String, dynamic> aMapa(EsaldiEraikitzaileaGeneratuta datos) =>
      <String, dynamic>{
        'oraciones': datos.oraciones
            .map((List<String> palabras) => palabras)
            .toList(growable: false),
      };

  static EsaldiEraikitzaileaGeneratuta desdeMapa(Map<String, dynamic> mapa) {
    final List<dynamic> bruto = mapa['oraciones'] as List<dynamic>;
    final List<List<String>> oraciones = bruto
        .map((dynamic palabras) =>
            List<String>.from(palabras as List<dynamic>))
        .toList(growable: false);
    return EsaldiEraikitzaileaGeneratuta(oraciones: oraciones);
  }
}

class SerializadorHitzZaparrada {
  static Map<String, dynamic> aMapa(HitzZaparradaGeneratuta datos) =>
      <String, dynamic>{
        'palabrasClave': datos.palabrasClave,
      };

  static HitzZaparradaGeneratuta desdeMapa(Map<String, dynamic> mapa) {
    return HitzZaparradaGeneratuta(
      palabrasClave:
          List<String>.from(mapa['palabrasClave'] as List<dynamic>),
    );
  }
}

class SerializadorDiktatua {
  static Map<String, dynamic> aMapa(DiktatuaGeneratuta datos) =>
      <String, dynamic>{
        'frases': datos.frases
            .map((FraseDictadoGenerada f) => <String, dynamic>{
                  'euskera': f.euskera,
                  if (f.traduccionEspanol != null)
                    'espanol': f.traduccionEspanol,
                })
            .toList(growable: false),
      };

  static DiktatuaGeneratuta desdeMapa(Map<String, dynamic> mapa) {
    final List<dynamic> bruto = mapa['frases'] as List<dynamic>;
    return DiktatuaGeneratuta(
      frases: bruto
          .map((dynamic entrada) {
            final Map<String, dynamic> p = Map<String, dynamic>.from(
                entrada as Map<dynamic, dynamic>);
            return FraseDictadoGenerada(
              euskera: p['euskera'] as String,
              traduccionEspanol: p['espanol'] as String?,
            );
          })
          .toList(growable: false),
    );
  }
}

class SerializadorLotura {
  static Map<String, dynamic> aMapa(LoturaGeneratuta datos) =>
      <String, dynamic>{
        'parejas': datos.parejas
            .map((ParejaGenerada p) => <String, String>{
                  'euskera': p.euskera,
                  'espanol': p.espanol,
                })
            .toList(growable: false),
      };

  static LoturaGeneratuta desdeMapa(Map<String, dynamic> mapa) {
    final List<dynamic> bruto = mapa['parejas'] as List<dynamic>;
    return LoturaGeneratuta(
      parejas: bruto
          .map((dynamic entrada) {
            final Map<String, dynamic> p = Map<String, dynamic>.from(
                entrada as Map<dynamic, dynamic>);
            return ParejaGenerada(
              euskera: p['euskera'] as String,
              espanol: p['espanol'] as String,
            );
          })
          .toList(growable: false),
    );
  }
}

/// Servicio CRUD para ejercicios generados desde un texto. Mismo
/// patrón que `AlmacenAriketaPertsonala`: una lista de ids y una
/// entrada JSON por cada ejercicio.
class AlmacenAriketaSortua {
  AlmacenAriketaSortua._();

  static final AlmacenAriketaSortua instancia = AlmacenAriketaSortua._();

  static const String _claveListaIds = 'aek_app.ariketa_sortua.lista';
  static const String _prefijoEntrada = 'aek_app.ariketa_sortua.entrada.';

  Future<List<AriketaSortua>> cargarTodas() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    final List<AriketaSortua> resultado = <AriketaSortua>[];
    for (final String id in ids) {
      final String? json = prefs.getString('$_prefijoEntrada$id');
      if (json == null) continue;
      try {
        resultado.add(AriketaSortua.desdeMapa(
            jsonDecode(json) as Map<String, dynamic>));
      } catch (_) {
        // Entrada corrupta — la saltamos sin romper la UI.
      }
    }
    resultado.sort((a, b) => b.sortzeData.compareTo(a.sortzeData));
    return resultado;
  }

  Future<AriketaSortua?> cargarUna(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('$_prefijoEntrada$id');
    if (json == null) return null;
    try {
      return AriketaSortua.desdeMapa(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> gordeBerria(AriketaSortua ariketa) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    if (!ids.contains(ariketa.id)) {
      await prefs.setStringList(_claveListaIds, <String>[...ids, ariketa.id]);
    }
    await prefs.setString(
      '$_prefijoEntrada${ariketa.id}',
      jsonEncode(ariketa.aMapa()),
    );
  }

  Future<void> eguneratu(AriketaSortua ariketa) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefijoEntrada${ariketa.id}',
      jsonEncode(ariketa.aMapa()),
    );
  }

  Future<void> ezabatu(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_claveListaIds) ?? const <String>[];
    final List<String> nuevaLista =
        ids.where((String idEntrada) => idEntrada != id).toList();
    await prefs.setStringList(_claveListaIds, nuevaLista);
    await prefs.remove('$_prefijoEntrada$id');
  }
}

/// Identificador opaco para una `AriketaSortua`. Mismo formato que el
/// de los ejercicios personales pero con prefijo distinto.
String generarIdAriketaSortua() {
  final int ahora = DateTime.now().millisecondsSinceEpoch;
  final int aleatorio = DateTime.now().microsecondsSinceEpoch & 0xFFFF;
  return 'as-${ahora.toRadixString(36)}-${aleatorio.toRadixString(36)}';
}

/// Construye 1 a 3 `AriketaSortua` a partir del `ResultadoGeneracion`
/// (los `null` se omiten). Comparten `testuJatorria` y `jatorria`,
/// cada uno con su tipo y datos. El título se deriva añadiendo un
/// sufijo por tipo a `tituloBase`.
List<AriketaSortua> construirAriketakSortuakDesdeResultado({
  required String tituloBase,
  required String testuJatorria,
  required OrigenGeneracion jatorria,
  required ResultadoGeneracion resultado,
}) {
  final DateTime ahora = DateTime.now();
  final List<AriketaSortua> generadas = <AriketaSortua>[];

  if (resultado.hutsuneak != null) {
    generadas.add(
      AriketaSortua(
        id: generarIdAriketaSortua(),
        izenburua: '$tituloBase — Hutsuneak',
        testuJatorria: testuJatorria,
        tipoMinijuegoa: TipoMinijuegoSortua.hutsuneak,
        jatorria: jatorria,
        datuak: SerializadorHutsuneak.aMapa(resultado.hutsuneak!),
        sortzeData: ahora,
      ),
    );
  }
  if (resultado.esaldiEraikitzailea != null) {
    generadas.add(
      AriketaSortua(
        id: generarIdAriketaSortua(),
        izenburua: '$tituloBase — Esaldi-Eraikitzailea',
        testuJatorria: testuJatorria,
        tipoMinijuegoa: TipoMinijuegoSortua.esaldiEraikitzailea,
        jatorria: jatorria,
        datuak: SerializadorEsaldiEraikitzailea.aMapa(
            resultado.esaldiEraikitzailea!),
        sortzeData: ahora,
      ),
    );
  }
  if (resultado.hitzZaparrada != null) {
    generadas.add(
      AriketaSortua(
        id: generarIdAriketaSortua(),
        izenburua: '$tituloBase — Hitz-Zaparrada',
        testuJatorria: testuJatorria,
        tipoMinijuegoa: TipoMinijuegoSortua.hitzZaparrada,
        jatorria: jatorria,
        datuak: SerializadorHitzZaparrada.aMapa(resultado.hitzZaparrada!),
        sortzeData: ahora,
      ),
    );
  }
  if (resultado.lotura != null) {
    generadas.add(
      AriketaSortua(
        id: generarIdAriketaSortua(),
        izenburua: '$tituloBase — Lotura',
        testuJatorria: testuJatorria,
        tipoMinijuegoa: TipoMinijuegoSortua.lotura,
        jatorria: jatorria,
        datuak: SerializadorLotura.aMapa(resultado.lotura!),
        sortzeData: ahora,
      ),
    );
  }
  if (resultado.diktatua != null) {
    generadas.add(
      AriketaSortua(
        id: generarIdAriketaSortua(),
        izenburua: '$tituloBase — Diktatua',
        testuJatorria: testuJatorria,
        tipoMinijuegoa: TipoMinijuegoSortua.diktatua,
        jatorria: jatorria,
        datuak: SerializadorDiktatua.aMapa(resultado.diktatua!),
        sortzeData: ahora,
      ),
    );
  }
  return generadas;
}
