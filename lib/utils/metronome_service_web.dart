// En web el metrónomo no está disponible (native_metronome es un plugin
// nativo sin implementación web). El botón correspondiente se oculta en la
// UI con kIsWeb, así que estos métodos no deberían llamarse nunca en la
// práctica — quedan como no-op por seguridad.
class MetronomeService {
  static void start(int bpm) {}
  static void stop() {}
}