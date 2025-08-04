
abstract class FConfigKeyValueHandle {

  // Future<void> preInit(String configName);

  void init(String configName);

  bool hasValue(String key);

  T getValue<T>(String key,Type type);

  Future<void> setValue(String key,Type type, Object value);

  Future<void> deleteValue(String key);

  Future<void> deleteAllValues();
}
