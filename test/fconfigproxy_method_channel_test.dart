import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fconfigproxy/fconfigproxy_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFconfigproxy platform = MethodChannelFconfigproxy();
  const MethodChannel channel = MethodChannel('fconfigproxy');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
