import 'package:fconfigproxy/agreement/FConfigKeyValueHandle.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

/// Hive 配置存储实现类。
///
/// 使用 Hive 数据库实现配置的存储和管理。
class HiveConfigStorageImpl implements FConfigKeyValueHandle {
  late Box _box;

  @override
  Future<void> init(String configName) async {
    _box = await Hive.openBox(configName);
  }

  @override
  bool hasValue(String key) {
    return _box.containsKey(key);
  }

  @override
  T getValue<T>(String key, Type type) {
    final value = _box.get(key);
    if (value == null) {
      throw Exception('Key $key not found in Hive storage');
    }
    return value as T;
  }

  @override
  Future<void> setValue(String key, Type type, Object value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> deleteValue(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> deleteAllValues() async {
    await _box.clear();
  }
}
