import 'package:native_metronome/native_metronome.dart';

class MetronomeService {
  static void start(int bpm) => NativeMetronome.start(bpm);
  static void stop() => NativeMetronome.stop();
}