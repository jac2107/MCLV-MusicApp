// firebase_messaging (versión pineada en pubspec.yaml) trae por debajo
// firebase_messaging_web, que NO compila con el SDK de Dart actual (usa una
// API de JS interop vieja — PromiseJsImpl/handleThenable/dartify — que ya
// no existe). Si dejamos `import 'package:firebase_messaging/...'` suelto
// en main.dart, `flutter build web` falla al compilar, aunque el código
// esté detrás de un `if (!kIsWeb)` — porque ese chequeo es en RUNTIME y el
// error de firebase_messaging_web es en COMPILACIÓN.
//
// Por eso todo el bootstrap de notificaciones vive en un archivo aparte,
// seleccionado en tiempo de compilación: en Android/iOS usa la
// implementación real (notification_bootstrap_io.dart); en web usa un
// no-op (notification_bootstrap_web.dart) que ni siquiera importa
// firebase_messaging, así que ese paquete nunca se compila para web.
export 'notification_bootstrap_io.dart'
    if (dart.library.html) 'notification_bootstrap_web.dart';