import 'package:fconfigproxy/annotation/FConfig.dart';
import 'package:fconfigproxy/annotation/FConfigKey.dart';
import 'package:fconfigproxy/annotation/FConfigOtherAnnotation.dart';
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

 
  /// 监听所有字段的变更
  /// 
  /// [listener] 变更时的回调函数，接收字段名、类型和新值
  @FConfigValueUpdateListener()
  void addValueUpdateListener(void Function(String key, Type type, Object? value) listener);


  /// 监听所有字段的变更
  /// 
  /// [listener] 变更时的回调函数，接收字段名、类型和新值
  @FConfigValueUpdateListener()
  FConfigValueListenerManager getValueUpdateListenerManager();

  /// 只监听特定字段的变更
  /// 
  /// [listener] 变更时的回调函数
  @FConfigValueUpdateListener(keyNames:['userName', 'age'])
  void addSpecificValueUpdateListener(void Function(String key, Type type, Object? value) listener);

  /// 移除特定字段的监听
  ///
  /// [listener] 变更时的回调函数
  @FConfigValueUpdateListenerRemove('addSpecificValueUpdateListener')
  void removeSpecificValueUpdateListener(void Function(String key, Type type, Object? value) listener);

  factory UserConfig.getUserConfig() => _$GetUserConfig();
  
}