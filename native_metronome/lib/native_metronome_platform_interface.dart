import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_metronome_method_channel.dart';

abstract class NativeMetronomePlatform extends PlatformInterface {
  /// Constructs a NativeMetronomePlatform.
  NativeMetronomePlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeMetronomePlatform _instance = MethodChannelNativeMetronome();

  /// The default instance of [NativeMetronomePlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeMetronome].
  static NativeMetronomePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeMetronomePlatform] when
  /// they register themselves.
  static set instance(NativeMetronomePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
