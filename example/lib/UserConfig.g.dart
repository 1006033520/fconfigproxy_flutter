// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FConfigGenerator
// **************************************************************************

part of 'UserConfig.dart';

class _UserConfigImpl implements UserConfig {
  /// 配置代理实例，静态成员保证全局唯一
  static final MyFConfigProxy _ConfigProxy = MyFConfigProxy();

  /// 构造函数，初始化配置并读取初始值
  _UserConfigImpl() {
    _ConfigProxy.init("UserConfig");
    _read();
  }

  /// 拦截器生成的类级代码片段
  late final _addValueUpdateListener_valueListenerManager =
      FConfigValueListenerManager([]);

  late final _getValueUpdateListenerManager_valueListenerManager =
      FConfigValueListenerManager([]);

  late final _addSpecificValueUpdateListener_valueListenerManager =
      FConfigValueListenerManager(['userName', 'age']);

  late final _isLoginNotifier_ValueNotifier = ValueNotifier<bool>(_isLogin);

  /// 字段定义及其 getter/setter
  late String? _$userName;

  String? get _userName => _$userName;

  set _userName(String? value) {
    if (_$userName == value) {
      return;
    }
    _$userName = value;
    _updateValue("userName", String, value);
  }

  late int? _$age;

  int? get _age => _$age;

  set _age(int? value) {
    if (_$age == value) {
      return;
    }
    _$age = value;
    _updateValue("age", int, value);
  }

  late bool _$isLogin;

  bool get _isLogin => _$isLogin;

  set _isLogin(bool value) {
    if (_$isLogin == value) {
      return;
    }
    _$isLogin = value;
    _updateValue("isLogin", bool, value);
  }

  /// 读取所有配置项的值并通知变更
  void _read() {
    _$userName = _ConfigProxy.hasValue("userName")
        ? _ConfigProxy.getValue("userName", String)
        : null;
    _noticeValueUpdate("userName", String, _$userName);
    _$age = _ConfigProxy.hasValue("age")
        ? _ConfigProxy.getValue("age", int)
        : null;
    _noticeValueUpdate("age", int, _$age);
    _$isLogin = _ConfigProxy.hasValue("isLogin")
        ? _ConfigProxy.getValue("isLogin", bool)
        : false;
    _noticeValueUpdate("isLogin", bool, _$isLogin);
  }

  /// 更新配置项的值，并通知监听
  void _updateValue(String key, Type type, Object? value) {
    if (value == null) {
      if (_ConfigProxy.hasValue(key)) {
        _ConfigProxy.deleteValue(key);
      }
    } else {
      _ConfigProxy.setValue(key, type, value);
    }
    _noticeValueUpdate(key, type, value);
  }

  /// 通知配置项变更，触发监听器
  void _noticeValueUpdate(String key, Type type, Object? value) {
    if (key == "isLogin") {
      _isLoginNotifier_ValueNotifier.value = (value as bool);
    }

    _addValueUpdateListener_valueListenerManager.notifyListeners(
      key,
      type,
      value,
    );

    _getValueUpdateListenerManager_valueListenerManager.notifyListeners(
      key,
      type,
      value,
    );

    _addSpecificValueUpdateListener_valueListenerManager.notifyListeners(
      key,
      type,
      value,
    );
  }

  /// 生成的方法拦截器实现
  ValueNotifier<bool> _get_isLoginNotifier_intercept(bool isLogin) {
    return _isLoginNotifier_ValueNotifier;
  }

  /// 生成的 set 方法实现
  @override
  set userName(String? value) {
    _userName = value;
  }

  @override
  set age(int? value) {
    _age = value;
  }

  @override
  set isLogin(bool value) {
    _isLogin = value;
  }

  /// 生成的 get 方法实现
  @override
  String? get userName {
    return _userName;
  }

  @override
  int? get age {
    return _age;
  }

  @override
  bool get isLogin {
    return _isLogin;
  }

  @override
  ValueNotifier<bool> get isLoginNotifier {
    return _get_isLoginNotifier_intercept(_isLogin);
  }

  /// 生成的其他方法实现
  @override
  void clearAll() async {
    await _ConfigProxy.deleteAllValues();
    _read();
  }

  @override
  void addValueUpdateListener(void Function(String, Type, Object?) listener) {
    _addValueUpdateListener_valueListenerManager.addListener(listener);
  }

  @override
  FConfigValueListenerManager getValueUpdateListenerManager() {
    return _getValueUpdateListenerManager_valueListenerManager;
  }

  @override
  void addSpecificValueUpdateListener(
    void Function(String, Type, Object?) listener,
  ) {
    _addSpecificValueUpdateListener_valueListenerManager.addListener(listener);
  }

  @override
  void removeSpecificValueUpdateListener(
    void Function(String, Type, Object?) listener,
  ) {
    _addSpecificValueUpdateListener_valueListenerManager.removeListener(
      listener,
    );
  }

  /// 单例实例
  static final UserConfig _instance = _UserConfigImpl();
}

/// 获取单例实例的方法
UserConfig _$GetUserConfig() => _UserConfigImpl._instance;
