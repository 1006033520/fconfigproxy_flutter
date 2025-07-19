
import 'agreement/FConfigKeyValueHandle.dart';

class MyFConfigProxy implements FConfigKeyValueHandle{

  @override
  void deleteAllValues() {
    // TODO: implement deleteAllValues
  }

  @override
  void deleteValue(String key) {
    // TODO: implement deleteValue
  }

  @override
  T getValue<T>(String key,Type type) {
    // TODO: implement getValue
    throw UnimplementedError();
  }

  @override
  void init(String configName) {
    // TODO: implement init
  }

  @override
  void setValue(String key,Type type, Object value) {
    // TODO: implement setValue
  }

  @override
  bool hasValue(String key) {
    // TODO: implement hasValue
    throw UnimplementedError();
  }

}

