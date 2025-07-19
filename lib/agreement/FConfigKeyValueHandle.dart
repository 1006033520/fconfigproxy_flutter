
abstract class FConfigKeyValueHandle {

  void init(String configName);

  bool hasValue(String key);

  T getValue<T>(String key,Type type);

  void setValue(String key,Type type, Object value);

  void deleteValue(String key);

  void deleteAllValues();
}
