import 'package:flutter_test/flutter_test.dart';
import 'package:fconfigproxy/fconfigproxy.dart';
import 'package:fconfigproxy/fconfigproxy_platform_interface.dart';
import 'package:fconfigproxy/fconfigproxy_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFconfigproxyPlatform
    with MockPlatformInterfaceMixin
    implements FconfigproxyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FconfigproxyPlatform initialPlatform = FconfigproxyPlatform.instance;

  test('$MethodChannelFconfigproxy is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFconfigproxy>());
  });

  test('getPlatformVersion', () async {
    Fconfigproxy fconfigproxyPlugin = Fconfigproxy();
    MockFconfigproxyPlatform fakePlatform = MockFconfigproxyPlatform();
    FconfigproxyPlatform.instance = fakePlatform;

    expect(await fconfigproxyPlugin.getPlatformVersion(), '42');
  });
}
