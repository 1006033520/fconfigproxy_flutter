import 'dart:core';

import 'package:fconfigproxy/annotation/FConfig.dart';
import 'package:fconfigproxy/annotation/FConfigKey.dart';
import 'package:flutter/cupertino.dart';

import 'MyFConfigProxy.dart';
import 'annotation/FConfigIntercept.dart';

part 'Test.g.dart';

@FConfig("TestConfig", MyFConfigProxy)
abstract interface class Test {
  int? age;
  @FConfigKey(keyName: "w12", defaultValue: "0")
  abstract int w;
  @FConfigKey(keyName: "name",defaultValue: "'Default Name'")
  abstract final String name;

  @FConfigValueNotifier()
  @FConfigKey(keyName: "age")
  abstract final ValueNotifier<int?> aa;


  factory Test.getTest() => _$GetTest();
}


void test(){
  final List<String> list = ['a', 'b', 'c'];
  final data = {
    'aa':'bb',
    'cc': list
  };

}