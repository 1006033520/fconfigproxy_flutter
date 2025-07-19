// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FConfigGenerator
// **************************************************************************

part of 'Test.dart';

class _TestImpl implements Test {
  static final MyFConfigProxy _ConfigProxy = MyFConfigProxy();

  _TestImpl() {
    _ConfigProxy.init("TestConfig");
    _read();
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

  late int _$w12;

  int get _w12 => _$w12;

  set _w12(int value) {
    if (_$w12 == value) {
      return;
    }
    _$w12 = value;
    _updateValue("w12", int, value);
  }

  late String _$name;

  String get _name => _$name;

  set _name(String value) {
    if (_$name == value) {
      return;
    }
    _$name = value;
    _updateValue("name", String, value);
  }

  void _read() {
    _$age = _ConfigProxy.hasValue("age")
        ? _ConfigProxy.getValue("age", int)
        : null;
    _noticeValueUpdate("age", int, _$age);
    _$w12 = _ConfigProxy.hasValue("w12")
        ? _ConfigProxy.getValue("w12", int)
        : 0;
    _noticeValueUpdate("w12", int, _$w12);
    _$name = _ConfigProxy.hasValue("name")
        ? _ConfigProxy.getValue("name", String)
        : 'Default Name';
    _noticeValueUpdate("name", String, _$name);
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

  void _noticeValueUpdate(String key, Type type, Object? value) {}

  @override
  set age(int? value) {
    _age = value;
  }

  @override
  set w(int value) {
    _w12 = value;
  }

  @override
  int? get age {
    return _age;
  }

  @override
  int get w {
    return _w12;
  }

  @override
  String get name {
    return _name;
  }
}

enum _enum_Test {
  instance;

  getTest() => _TestImpl();
}

Test _$GetTest() => _enum_Test.instance.getTest();
