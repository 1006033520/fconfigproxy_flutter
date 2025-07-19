
import 'fconfigproxy_platform_interface.dart';

class Fconfigproxy {
  Future<String?> getPlatformVersion() {
    return FconfigproxyPlatform.instance.getPlatformVersion();
  }
}
