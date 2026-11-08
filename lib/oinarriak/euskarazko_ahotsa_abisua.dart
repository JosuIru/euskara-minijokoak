import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'paleta.dart';
import 'pintor_rotulador.dart';

/// Comprueba si el motor de voz tiene euskera. Si no lo tiene, flutter_tts
/// lee con la voz por defecto del sistema (normalmente castellano) sin
/// avisar, y un ejercicio de escucha pierde su sentido.
///
/// En web el navegador carga la lista de voces de forma asíncrona y la
/// primera consulta puede llegar vacía: por eso, si la respuesta es "no",
/// se repite una vez tras una breve espera antes de darla por buena.
/// Si la consulta falla, se asume que sí hay voz para no alarmar sin motivo.
Future<bool> badagoEuskarazkoAhotsa(FlutterTts tts) async {
  Future<bool> consultarUnaVez() async {
    for (final String codigoIdioma in const <String>['eu-ES', 'eu']) {
      if (await tts.isLanguageAvailable(codigoIdioma) == true) return true;
    }
    return false;
  }

  try {
    if (await consultarUnaVez()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return await consultarUnaVez();
  } catch (_) {
    return true;
  }
}

/// Aviso para los juegos de escucha cuando el dispositivo no tiene voz en
/// euskera. Permanece invisible (`SizedBox.shrink`) si la voz existe.
class EuskarazkoAhotsaAbisua extends StatefulWidget {
  final FlutterTts tts;

  const EuskarazkoAhotsaAbisua({super.key, required this.tts});

  @override
  State<EuskarazkoAhotsaAbisua> createState() => _EuskarazkoAhotsaAbisuaState();
}

class _EuskarazkoAhotsaAbisuaState extends State<EuskarazkoAhotsaAbisua> {
  bool _faltaVozEuskera = false;

  @override
  void initState() {
    super.initState();
    _comprobarVoz();
  }

  Future<void> _comprobarVoz() async {
    final bool hayVozEuskera = await badagoEuskarazkoAhotsa(widget.tts);
    if (!mounted || hayVozEuskera) return;
    setState(() => _faltaVozEuskera = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_faltaVozEuskera) return const SizedBox.shrink();

    final String instrucciones = kIsWeb
        ? 'Nabigatzaile honek ez du euskarazko ahotsik. Probatu Chrome edo '
              'Edge-rekin, edo erabili aplikazioa mugikorrean.'
        : 'Instalatu euskarazko ahotsa: Ezarpenak › Testua ahots bihurtzea › '
              'Google-ren ahots-motorra › Instalatu ahots-datuak › Euskara.';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: MarcoRotulador(
        color: PaletaAek.rojoRotulador,
        grosor: 3,
        intensidadJitter: 1.3,
        child: Container(
          color: PaletaAek.papelViejo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.record_voice_over_outlined,
                color: PaletaAek.rojoRotulador,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Ez dago euskarazko ahotsik',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: PaletaAek.tintaNegra,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Esaldiak beste hizkuntza bateko ahoskerarekin '
                      'entzungo dira. $instrucciones',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: PaletaAek.tintaDiluida(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
