// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FConfigGenerator
// **************************************************************************

part of 'UserConfig.dart';

class _UserConfigImpl implements UserConfig {
  static final MyFConfigProxy _ConfigProxy = MyFConfigProxy();

  _UserConfigImpl() {
    _ConfigProxy.init("UserConfig");
    _read();
  }

  late final _isLoginNotifier_ValueNotifier = ValueNotifier<bool>(_isLogin);

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

  void _noticeValueUpdate(String key, Type type, Object? value) {
    if (key == "isLogin") {
      _isLoginNotifier_ValueNotifier.value = (value as bool);
    }
  }

  ValueNotifier<bool> _get_isLoginNotifier_intercept(bool isLogin) {
    return _isLoginNotifier_ValueNotifier;
  }

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

  @override
  void clearAll() async {
    await _ConfigProxy.deleteAllValues();
    _read();
  }

  static final UserConfig _instance = _UserConfigImpl();
}

UserConfig _$GetUserConfig() => _UserConfigImpl._instance;
