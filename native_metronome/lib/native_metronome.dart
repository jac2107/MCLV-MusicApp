import 'package:flutter/services.dart';

class NativeMetronome {
  static const MethodChannel _channel = MethodChannel('native_metronome');

  static Future<String?> ping() async {
    final String? result = await _channel.invokeMethod<String>('ping');
    return result;
  }

  static Future<void> start(int bpm) async {
    await _channel.invokeMethod('start', {'bpm': bpm});
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}