import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fconfigproxy_platform_interface.dart';

/// An implementation of [FconfigproxyPlatform] that uses method channels.
class MethodChannelFconfigproxy extends FconfigproxyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fconfigproxy');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
