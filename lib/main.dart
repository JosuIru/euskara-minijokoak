import 'package:flutter/material.dart';

import 'ikaslea/hasiera_orria.dart';
import 'ikaslea/ikaslearen_orria.dart';
import 'ikaslea/klasea_orria.dart';
import 'ikaslea/nire_jarraipena_orria.dart';
import 'irakaslea/ariketa_pertsonala_orriak.dart';
import 'irakaslea/ezarpenak_orria.dart';
import 'irakaslea/irakaslearen_orria.dart';
import 'irakaslea/testutik_sortu_orriak.dart';
import 'minijokoak/anfitrioi_ariketa.dart';
import 'oinarriak/paleta.dart';

void main() {
  runApp(const AplikazioaAek());
}

class AplikazioaAek extends StatelessWidget {
  const AplikazioaAek({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euskaraz — AEK',
      theme: temaAek(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: _generarRuta,
    );
  }

  /// Router manual. Ruta `/minijokoa/<identificadorAriketa>` carga
  /// dinámicamente cualquier ejercicio registrado en el catálogo.
  Route<dynamic>? _generarRuta(RouteSettings ezarpenak) {
    final Uri uriRuta = Uri.parse(ezarpenak.name ?? '/');
    final List<String> segmentos = uriRuta.pathSegments;

    if (segmentos.isEmpty) {
      return MaterialPageRoute<void>(
        builder: (BuildContext context) => const HasieraOrria(),
        settings: ezarpenak,
      );
    }

    switch (segmentos.first) {
      case 'ikaslea':
        if (segmentos.length >= 2 && segmentos[1] == 'jarraipena') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => const NireJarraipenaOrria(),
            settings: ezarpenak,
          );
        }
        if (segmentos.length >= 2 && segmentos[1] == 'klasea') {
          final String? codigoPrecargado =
              uriRuta.queryParameters['kodea'];
          return MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                KlaseaOrria(codigoPrecargado: codigoPrecargado),
            settings: ezarpenak,
          );
        }
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => const IkaslearenOrria(),
          settings: ezarpenak,
        );
      case 'irakaslea':
        if (segmentos.length >= 2 && segmentos[1] == 'pertsonalak') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                const AriketaPertsonalakZerrenda(),
            settings: ezarpenak,
          );
        }
        if (segmentos.length >= 2 && segmentos[1] == 'testutik') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => const TestutikSortuZerrenda(),
            settings: ezarpenak,
          );
        }
        if (segmentos.length >= 2 && segmentos[1] == 'ezarpenak') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => const EzarpenakOrria(),
            settings: ezarpenak,
          );
        }
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => const IrakaslearenOrria(),
          settings: ezarpenak,
        );
      case 'minijokoa':
        if (segmentos.length >= 2) {
          final String identificador = segmentos[1];
          final String? idSortua = uriRuta.queryParameters['sortua'];
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => AnfitrioiAriketaOrria(
              identificadorAriketa: identificador,
              idSortua: idSortua,
            ),
            settings: ezarpenak,
          );
        }
        break;
    }

    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const _PaginaRutaNoEncontrada(),
      settings: ezarpenak,
    );
  }
}

class _PaginaRutaNoEncontrada extends StatelessWidget {
  const _PaginaRutaNoEncontrada();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaAek.papelViejo,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '404',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: PaletaAek.rojoRotulador,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Orri hau ez dago.',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                color: PaletaAek.tintaNegra,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (_) => false),
              child: const Text(
                'HASIERARA ITZULI',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: PaletaAek.tintaNegra,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
