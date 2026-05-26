# Euskaraz — AEK

AEK euskaltegietarako web aplikazioa: kantutegia eta gramatika minijokoak.

Aplicación para los euskaltegis de AEK: cancionero y minijuegos de gramática
para practicar euskera. Incluye un generador de ejercicios a partir de texto
(motor heurístico + asistencia opcional con la API de Anthropic) y un sistema
de aviso de nuevas versiones.

Plataformas objetivo: **Android** (APK) y **Web**.

## Requisitos

- Flutter 3.41+ (canal stable). Dart SDK ^3.11.5.

## Desarrollo

```bash
flutter pub get
flutter run            # dispositivo/emulador o navegador
flutter analyze        # análisis estático (debe salir limpio)
flutter test           # suite de tests
```

## Configuración

- **API key de Anthropic**: no va en el código. El profesor la introduce en los
  ajustes de la app y se guarda con `SharedPreferences`. El modelo por defecto
  es `claude-haiku-4-5-20251001`.
- **Manifiesto de actualizaciones**: la app consulta por defecto
  `https://aek-app.eus/eguneraketak.json` (ver
  `lib/oinarriak/eguneraketak_zerbitzua.dart`). Ajusta esa URL si publicas el
  manifiesto en otra ubicación.

## Build de producción

### Web

```bash
flutter build web --release
# Salida en build/web/ — servir como sitio estático.
```

### Android (APK / App Bundle)

1. Genera un keystore de release (una sola vez, guárdalo fuera del repo):

   ```bash
   keytool -genkey -v -keystore ~/euskaraz-release.jks \
       -keyalg RSA -keysize 2048 -validity 10000 -alias euskaraz
   ```

2. Copia `android/key.properties.example` a `android/key.properties` y rellena
   las contraseñas, el alias y la ruta absoluta del `.jks`. Este archivo y el
   keystore están ignorados por git: **nunca los subas ni los pierdas**.

3. Compila:

   ```bash
   flutter build apk --release        # APK (distribución directa / actualizaciones)
   flutter build appbundle --release  # AAB (Google Play)
   ```

Si `android/key.properties` no existe, el build de release usa las claves de
debug (útil para probar `flutter run --release`, pero **no publicable**).

- `applicationId`: `eus.eus.euskaraz`
- Minificación y `shrinkResources` activados; reglas en
  `android/app/proguard-rules.pro`.
