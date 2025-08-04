import 'package:fconfigproxy/annotation/FConfig.dart';
import 'package:fconfigproxy/annotation/FConfigIntercept.dart';
import 'package:fconfigproxy/annotation/FConfigKey.dart';
import 'package:fconfigproxy_example/MyFConfigProxy.dart';
import 'package:flutter/foundation.dart';

part 'UserConfig.g.dart';

@FConfig('UserConfig', MyFConfigProxy)
abstract interface class UserConfig {

  String? userName;

  int? age;

  @FConfigKey(keyName: 'isLogin', defaultValue: 'false')
  abstract bool isLogin;

  @FConfigValueNotifier()
  @FConfigKey(keyName: "isLogin")
  abstract final ValueNotifier<bool> isLoginNotifier;

  @FConfigClearAll()
  void clearAll();

  factory UserConfig.getUserConfig() => _$GetUserConfig();
  
}