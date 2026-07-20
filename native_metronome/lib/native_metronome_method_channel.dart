import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_metronome_platform_interface.dart';

/// An implementation of [NativeMetronomePlatform] that uses method channels.
class MethodChannelNativeMetronome extends NativeMetronomePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_metronome');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
