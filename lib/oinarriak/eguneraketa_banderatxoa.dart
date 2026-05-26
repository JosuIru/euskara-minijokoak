import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'eguneraketak_zerbitzua.dart';
import 'paleta.dart';
import 'pintor_rotulador.dart';

/// Aviso discreto de "hay una versión nueva". Se comprueba solo al
/// montarse y permanece invisible (`SizedBox.shrink`) salvo que haya
/// actualización disponible — así no añade ruido cuando todo está al día
/// ni cuando la comprobación falla por red.
///
/// Pensado para colgarse en la pantalla de inicio bajo la cabecera.
class EguneraketaBanderatxoa extends StatefulWidget {
  const EguneraketaBanderatxoa({super.key});

  @override
  State<EguneraketaBanderatxoa> createState() => _EguneraketaBanderatxoaState();
}

class _EguneraketaBanderatxoaState extends State<EguneraketaBanderatxoa> {
  ManifestuEguneraketa? _eguneraketa;

  @override
  void initState() {
    super.initState();
    _comprobarEnSegundoPlano();
  }

  Future<void> _comprobarEnSegundoPlano() async {
    final EguneraketakZerbitzua zerbitzua = EguneraketakZerbitzua();
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final EmaitzaEguneraketa emaitza = await zerbitzua.egiaztatu(
        bertsioInstalatua: info.version,
        buildInstalatua: int.tryParse(info.buildNumber) ?? 0,
      );
      if (!mounted) return;
      if (emaitza.badagoEguneraketa) {
        setState(() => _eguneraketa = emaitza.manifestua);
      }
    } catch (_) {
      // Silencioso: el aviso es opcional, nunca debe romper el inicio.
    } finally {
      zerbitzua.cerrar();
    }
  }

  Future<void> _abrirDescarga() async {
    final ManifestuEguneraketa? eguneraketa = _eguneraketa;
    if (eguneraketa == null) return;
    final Uri? uri = Uri.tryParse(eguneraketa.deskargaUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final ManifestuEguneraketa? eguneraketa = _eguneraketa;
    if (eguneraketa == null) return const SizedBox.shrink();

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
            children: <Widget>[
              const Icon(Icons.system_update_alt,
                  color: PaletaAek.rojoRotulador, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      eguneraketa.derrigorrezkoa
                          ? 'Eguneraketa beharrezkoa: ${eguneraketa.bertsioa}'
                          : 'Bertsio berria eskuragarri: ${eguneraketa.bertsioa}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: PaletaAek.tintaNegra,
                      ),
                    ),
                    if (eguneraketa.oharrak != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        eguneraketa.oharrak!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: PaletaAek.tintaDiluida(0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _abrirDescarga,
                behavior: HitTestBehavior.opaque,
                child: MarcoRotulador(
                  color: PaletaAek.rojoRotulador,
                  grosor: 2,
                  intensidadJitter: 1.0,
                  child: Container(
                    color: PaletaAek.papelViejo,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    child: const Text(
                      'DESKARGATU',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: PaletaAek.rojoRotulador,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
