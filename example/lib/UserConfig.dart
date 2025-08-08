import 'package:fconfigproxy/annotation/FConfig.dart';
import 'package:fconfigproxy/annotation/FConfigKey.dart';
import 'package:fconfigproxy/annotation/FConfigOtherAnnotation.dart';
import 'package:flutter/foundation.dart';
import 'package:fconfigproxy_hive_storage/fconfigproxy_hive_storage_impl.dart';
import 'package:fconfigproxy_mmkv_storage/fconfigproxy_mmkv_storage_impl.dart';


part 'UserConfig.g.dart';

@FConfig('UserConfigHive', HiveConfigStorageImpl)
abstract interface class UserConfigHive {

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

  factory UserConfigHive.getUserConfig() => _$GetUserConfigHive();

  
}




@FConfig('UserConfigMMKV', MMKVConfigStorageImpl)
abstract interface class UserConfigMMKV {

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

  factory UserConfigMMKV.getUserConfig() => _$GetUserConfigMMKV();

  
}