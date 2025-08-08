

import 'package:fconfigproxy/agreement/FConfigKeyValueHandle.dart';
import 'package:mmkv/mmkv.dart';

/// MMKV 配置存储实现类。
///
/// 使用 MMKV 高性能存储库实现配置的存储和管理。
class MMKVConfigStorageImpl implements FConfigKeyValueHandle {
  late MMKV _mmkv;

  @override
  Future<void> init(String configName) async {
    _mmkv = MMKV(configName);
  }

  @override
  bool hasValue(String key) {
    return _mmkv.containsKey(key);
  }

  @override
  T getValue<T>(String key, Type type) {
    if (type == String) {
      return _mmkv.decodeString(key) as T;
    } else if (type == int) {
      return _mmkv.decodeInt(key) as T;
    } else if (type == double) {
      return _mmkv.decodeDouble(key) as T;
    } else if (type == bool) {
      return _mmkv.decodeBool(key) as T;
    } else {
      throw Exception('Unsupported type: $type for key: $key');
    }
  }

  @override
  Future<void> setValue(String key, Type type, Object value) async {
    if (type == String) {
      _mmkv.encodeString(key, value as String);
    } else if (type == int) {
      _mmkv.encodeInt(key, value as int);
    } else if (type == double) {
      _mmkv.encodeDouble(key, value as double);
    } else if (type == bool) {
      _mmkv.encodeBool(key, value as bool);
    } else {
      throw Exception('Unsupported type: $type for key: $key');
    }
    // MMKV 的写入操作是同步的，但为了保持接口一致，返回 Future
    return Future.value();
  }

  @override
  Future<void> deleteValue(String key) async {
    _mmkv.removeValue(key);
    // 保持接口一致，返回 Future
    return Future.value();
  }

  @override
  Future<void> deleteAllValues() async {
    _mmkv.clearAll();
    // 保持接口一致，返回 Future
    return Future.value();
  }
}
