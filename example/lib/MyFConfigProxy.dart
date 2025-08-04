import 'package:fconfigproxy/agreement/FConfigKeyValueHandle.dart';
import 'package:hive/hive.dart';


class MyFConfigProxy implements FConfigKeyValueHandle {
  Box? _box;

  // static Future<void> preInit(String configName) async {
  //   await Hive.openBox(configName);
  // }

  @override
  void init(String configName) {
    _box = Hive.box(configName);
  }

  @override
  Future<void> deleteAllValues() async {
    await _box!.clear();
  }

  @override
  Future<void> deleteValue(String key) async {
    await _box!.delete(key);
  }

  @override
  T getValue<T>(String key, Type type) {
    return _box!.get(key);
  }

  @override
  Future<void> setValue(String key, Type type, Object value) async {
    await _box!.put(key, value);
  }

  @override
  bool hasValue(String key) {
    return _box!.containsKey(key);
  }

}

