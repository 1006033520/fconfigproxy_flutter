
/// 配置键值存储操作接口。
///
/// 该接口定义了通用的配置存取、删除、初始化等操作，便于不同存储实现（如本地、云端等）统一调用。
abstract class FConfigKeyValueHandle {

  /// 初始化存储实例。
  ///
  /// [configName] 用于指定存储空间或命名空间。
  Future<void> init(String configName);

  /// 判断指定 key 是否存在。
  ///
  /// [key] 要判断的键名。
  /// 返回 true 表示存在。
  bool hasValue(String key);

  /// 获取指定 key 的值。
  ///
  /// [key] 要获取的键名。
  /// [type] 期望的类型（如 int、String 等）。
  /// 返回对应类型的值。
  T getValue<T>(String key, Type type);

  /// 设置指定 key 的值。
  ///
  /// [key] 要设置的键名。
  /// [type] 值的类型。
  /// [value] 要存储的值。
  Future<void> setValue(String key, Type type, Object value);

  /// 删除指定 key 的值。
  ///
  /// [key] 要删除的键名。
  Future<void> deleteValue(String key);

  /// 清空所有存储的键值。
  Future<void> deleteAllValues();
}
