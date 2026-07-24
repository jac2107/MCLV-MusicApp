// Selecciona en tiempo de COMPILACIÓN qué implementación usar:
// - metronome_service_io.dart   → Android/iOS/desktop, usa native_metronome real.
// - metronome_service_web.dart  → Web, implementación vacía (no-op).
//
// Esto es distinto a un simple "if (kIsWeb)" en runtime: si dejáramos el
// import de native_metronome suelto en Vcanciones.dart, `flutter build web`
// fallaría al compilar porque ese plugin no tiene implementación web. Con
// el import condicional de abajo, el código de native_metronome ni siquiera
// se incluye en el build web.
export 'metronome_service_io.dart'
    if (dart.library.html) 'metronome_service_web.dart';