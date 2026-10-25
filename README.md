# Golfy

Aplicación Flutter de seguimiento de entrenamiento, bienestar e hidratación para golfistas.

## Probar en Windows

Con Flutter instalado, abrir PowerShell en la raíz de `golfy_app`:

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
flutter run -d web-server --web-port 8080
```

Abrir [localhost:8080](http://localhost:8080) en Brave, Edge o Chrome. Mantener la terminal abierta; `q` detiene la ejecución. `PUB_CACHE` guarda las dependencias dentro del proyecto y se debe configurar de nuevo al abrir otra terminal. No se necesitan claves ni un servidor propio para el clima.

## Clima con el patrón de la clase 7

La primera versión consulta las condiciones de **hoy en Santiago, Chile**. No consulta el clima del sábado ni la ubicación del teléfono. La fecha y hora que muestra la API corresponden a Santiago, independientemente de la zona horaria del dispositivo.

1. `lib/models/clima.dart`: modelo `Clima` con `factory Clima.fromJson`.
2. `lib/services/clima_service.dart`: petición GET con `dio`, `Future`, `async` y `await`. Las coordenadas, unidades y zona horaria se definen aquí.
3. `lib/providers/clima_provider.dart`: `ChangeNotifier` que conserva el Future durante la sesión. Cambiar de pantalla no vuelve a consultar. Actualizar o reintentar crea un nuevo Future.
4. `lib/widgets/clima_card.dart`: `FutureBuilder` con cargando, error con reintento y datos. Incluye resumen para Inicio y detalle para Hidratación.
5. `lib/main.dart`: `ChangeNotifierProvider` encima de la app, compartido entre las pantallas y sus rutas.

El resumen aparece debajo de Próxima ronda en Inicio. Para ver temperatura, humedad, UV, viento y probabilidad de lluvia, abrir la tarjeta Próxima ronda o ir a Bienestar → Plan de hidratación. El botón de actualización refresca los datos compartidos.

Si falla la conexión, se muestra un error con Reintentar; no se reemplazan los datos por valores inventados. La información se conserva en memoria, sin almacenamiento permanente ni actualización automática. El plan de agua sigue siendo un ejemplo fijo, separado del clima.

Datos de [Open-Meteo](https://open-meteo.com/), bajo [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Consultar la [documentación de la API](https://open-meteo.com/en/docs) y sus [condiciones de uso no comercial](https://open-meteo.com/en/terms). Los valores meteorológicos son estimaciones del modelo.

## Verificación

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
flutter analyze
flutter test
flutter build web
```

Las pruebas usan respuestas controladas, sin depender de internet. Cubren JSON inválido, errores HTTP, reintento, una sola consulta compartida, navegación y ambos temas en varios tamaños de pantalla. Android tiene habilitado el permiso de internet y macOS el acceso de red saliente; esas plataformas requieren sus propias herramientas para compilarse.
