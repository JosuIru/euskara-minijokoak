import 'package:flutter/material.dart';

/// Paleta cromática única para toda la aplicación AEK.
///
/// Regla: blanco/negro + un único rojo de acento. Nada más. Cualquier
/// minijuego, cualquier pantalla del kantutegia y cualquier panel del
/// profesor deben atenerse a esta paleta — la coherencia visual es
/// parte del lenguaje pedagógico de la app.
class PaletaAek {
  /// Fondo principal: papel envejecido, no blanco puro (cansa menos la vista).
  static const Color papelViejo = Color(0xFFF3E9CE);

  /// Variante más sucia/gris para fondos secundarios o paneles superpuestos.
  static const Color papelSucio = Color(0xFFE0D6BD);

  /// Tinta negra de rotulador: no negro absoluto, ligeramente cálido.
  static const Color tintaNegra = Color(0xFF1A1814);

  /// Rojo único permitido: tono de boli rojo / sello. Reservado para
  /// aciertos críticos, marcas de profesor, estampillas y elementos que
  /// deben gritar "atención".
  static const Color rojoRotulador = Color(0xFFD42620);

  /// Tinta diluida para sombras tenues, manchas, arrugas.
  static Color tintaDiluida(double alfa) =>
      tintaNegra.withValues(alpha: alfa.clamp(0.0, 1.0));

  /// Rojo diluido para acentos suaves (estampillas semi-desvanecidas).
  static Color rojoDiluido(double alfa) =>
      rojoRotulador.withValues(alpha: alfa.clamp(0.0, 1.0));
}

/// Tema global Material configurado para que cualquier widget estándar
/// (botones, textos, scaffolds) caiga automáticamente en el lenguaje
/// visual rotulador sin tener que sobrescribirlo en cada pantalla.
ThemeData temaAek() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: PaletaAek.papelViejo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PaletaAek.rojoRotulador,
      brightness: Brightness.light,
      surface: PaletaAek.papelViejo,
      primary: PaletaAek.tintaNegra,
      secondary: PaletaAek.rojoRotulador,
    ).copyWith(
      onSurface: PaletaAek.tintaNegra,
      onPrimary: PaletaAek.papelViejo,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w900,
        color: PaletaAek.tintaNegra,
        letterSpacing: 2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w800,
        color: PaletaAek.tintaNegra,
        letterSpacing: 1.5,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        color: PaletaAek.tintaNegra,
      ),
      titleLarge: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        color: PaletaAek.tintaNegra,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'monospace',
        color: PaletaAek.tintaNegra,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'monospace',
        color: PaletaAek.tintaNegra,
      ),
      labelLarge: TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        color: PaletaAek.tintaNegra,
        letterSpacing: 1.2,
      ),
    ),
  );
}
