import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fconfigproxy_method_channel.dart';

abstract class FconfigproxyPlatform extends PlatformInterface {
  /// Constructs a FconfigproxyPlatform.
  FconfigproxyPlatform() : super(token: _token);

  static final Object _token = Object();

  static FconfigproxyPlatform _instance = MethodChannelFconfigproxy();

  /// The default instance of [FconfigproxyPlatform] to use.
  ///
  /// Defaults to [MethodChannelFconfigproxy].
  static FconfigproxyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FconfigproxyPlatform] when
  /// they register themselves.
  static set instance(FconfigproxyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
