import 'package:shared_preferences/shared_preferences.dart';

/// Configuración global del usuario que persiste entre sesiones. De
/// momento sólo guarda credenciales y preferencias del generador
/// asistido por LLM, pero el módulo está pensado para crecer con otros
/// ajustes (idioma de UI, tamaño de fuente, etc).
///
/// Importante: la API key se guarda en `shared_preferences` (localStorage
/// en web). Para una app educativa local esto es razonable, pero si en
/// el futuro hay despliegue público hay que evaluar `flutter_secure_storage`
/// como alternativa.
class AlmacenEzarpenak {
  AlmacenEzarpenak._();

  static final AlmacenEzarpenak instancia = AlmacenEzarpenak._();

  static const String _claveApiKeyAnthropic =
      'aek_app.ezarpenak.anthropic_api_key';
  static const String _claveModeloAnthropic =
      'aek_app.ezarpenak.anthropic_modelo';

  /// Modelo por defecto si el profesor no toca nada. Haiku es barato y
  /// suficiente para reformular un texto en ejercicios.
  static const String modeloAnthropicPorDefecto = 'claude-haiku-4-5-20251001';

  Future<String?> leerApiKeyAnthropic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? valor = prefs.getString(_claveApiKeyAnthropic);
    if (valor == null || valor.trim().isEmpty) return null;
    return valor.trim();
  }

  Future<void> gordeApiKeyAnthropic(String apiKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveApiKeyAnthropic, apiKey.trim());
  }

  Future<void> ezabatuApiKeyAnthropic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveApiKeyAnthropic);
  }

  Future<String> leerModeloAnthropic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveModeloAnthropic) ?? modeloAnthropicPorDefecto;
  }

  Future<void> gordeModeloAnthropic(String modelo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveModeloAnthropic, modelo);
  }
}
