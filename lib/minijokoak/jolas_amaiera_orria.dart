import 'package:flutter/material.dart';

import '../oinarriak/ariketa.dart';
import '../oinarriak/paleta.dart';
import '../oinarriak/pintor_rotulador.dart';

/// Pantalla que aparece al terminar un ejercicio. Muestra el resultado
/// del alumno con la estampilla roja correspondiente y dos acciones:
/// reintentar o volver al catálogo.
class JolasAmaieraOrria extends StatelessWidget {
  final ResultadoAriketa resultado;
  final VoidCallback alReintentar;

  const JolasAmaieraOrria({
    super.key,
    required this.resultado,
    required this.alReintentar,
  });

  String get _titulo {
    final double porcentaje = resultado.porcentajeAciertos;
    if (porcentaje >= 0.9) return 'BIKAINA!';
    if (porcentaje >= 0.7) return 'ONA!';
    if (porcentaje >= 0.5) return 'AURRERA!';
    return 'BERRIRO SAIATU';
  }

  String get _subtitulo {
    final double porcentaje = resultado.porcentajeAciertos;
    if (porcentaje >= 0.9) return 'Maila ezin hobea.';
    if (porcentaje >= 0.7) return 'Ondo egin duzu.';
    if (porcentaje >= 0.5) return 'Erdia baino gehiago asmatu duzu.';
    return 'Praktikatu eta itzuli.';
  }

  @override
  Widget build(BuildContext context) {
    final int segundos = resultado.tiempoEmpleado.inSeconds;
    final int porcentajeRedondeado =
        (resultado.porcentajeAciertos * 100).round();

    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: SafeArea(
        child: FondoPapelEnvejecido(
          semilla: 17,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: MarcoRotulador(
                  grosor: 3,
                  intensidadJitter: 1.4,
                  child: Container(
                    color: PaletaAek.papelViejo,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _titulo,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: PaletaAek.rojoRotulador,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitulo,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: PaletaAek.tintaDiluida(0.7),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _FilaEstadistica(
                          etiqueta: 'Asmatuak',
                          valor:
                              '${resultado.aciertos} / ${resultado.intentosTotales}',
                        ),
                        _FilaEstadistica(
                          etiqueta: 'Portzentajea',
                          valor: '$porcentajeRedondeado%',
                        ),
                        _FilaEstadistica(
                          etiqueta: 'Denbora',
                          valor: '${segundos}s',
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _BotonAccion(
                              etiqueta: 'BERRIRO',
                              esPrincipal: true,
                              alPulsar: alReintentar,
                            ),
                            _BotonAccion(
                              etiqueta: 'AUKERATU',
                              esPrincipal: false,
                              alPulsar: () => Navigator.of(context)
                                  .popUntil((Route ruta) => ruta.isFirst),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilaEstadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaEstadistica({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            etiqueta,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: PaletaAek.tintaDiluida(0.75),
              letterSpacing: 1.2,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: PaletaAek.tintaNegra,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final String etiqueta;
  final bool esPrincipal;
  final VoidCallback alPulsar;

  const _BotonAccion({
    required this.etiqueta,
    required this.esPrincipal,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        esPrincipal ? PaletaAek.rojoRotulador : PaletaAek.tintaNegra;
    return GestureDetector(
      onTap: alPulsar,
      child: MarcoRotulador(
        color: color,
        grosor: esPrincipal ? 3.2 : 2.4,
        intensidadJitter: 1.2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Text(
            etiqueta,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
