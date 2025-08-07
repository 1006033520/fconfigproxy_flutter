
import 'package:meta/meta_meta.dart';

import 'FConfigAnnotationGenerator.dart';
import 'FConfigAnnotationField.dart';

/// 本文件包含了额外的FConfig注解定义，用于实现高级配置功能
/// 如配置清除、值监听、变更通知等。
/// 这些注解与代码生成器配合使用，可自动生成相关功能代码。

/// 用于标记清除所有配置的注解。
///
/// 该注解只能用于方法上，配合代码生成器实现批量清除配置的功能。
/// 使用示例：
/// ```dart
/// @FConfigClearAll()
/// Future<void> clearAllConfig() async {} // 方法体将被代码生成器替换
/// ```
@Target({TargetKind.method})
class FConfigClearAll implements FConfigFunInterceptGenerator {
  /// 构造函数，常量形式。
  const FConfigClearAll();

  /// 生成的类代码片段（此处无实现）。
  @override
  final String? classCode = null;

  /// 生成的目标方法代码片段，实现清除所有配置并刷新读取。
  ///
  /// 代码片段会被插入到被注解的方法体中，实现：
  /// 1. 调用配置代理删除所有值
  /// 2. 重新读取配置
  @override
  final String funCode = '''
  await _ConfigProxy.deleteAllValues();
  _read();
  ''';

  /// 生成的值变更监听方法代码片段（此处无实现）。
  @override
  final String? valueUpdateListenerFunCode = null;

  /// 是否为异步方法，这里为 true。
  @override
  final bool isAsync = true;
}

/// 用于标记字段或 getter 的注解，实现 ValueNotifier 功能。
///
/// 该注解可用于 getter 或字段，配合代码生成器实现配置变更通知。
/// 使用后，字段或getter会被包装为ValueNotifier，当配置值变化时自动通知监听者。
/// 使用示例：
/// ```dart
/// @FConfigValueNotifier()
/// String get appName => _appName;
/// ```
@Target({TargetKind.getter, TargetKind.field})
class FConfigValueNotifier implements FConfigFieldInterceptGenerator {
  /// 构造函数，常量形式。
  const FConfigValueNotifier();

  /// 生成的类代码片段，声明 ValueNotifier 并初始化。
  ///
  /// 代码片段会被插入到生成的代理类中，创建一个与字段关联的ValueNotifier实例。
  /// - {{ name }}: 字段名称
  /// - {{ keyType }}: 字段类型
  /// - {{ keyTypeIsNull }}: 字段类型是否可空
  /// - {{ keyName }}: 内部存储字段名
  @override
  final String classCode = '''
  late final _{{ name }}_ValueNotifier = ValueNotifier<{{ keyType }}{% if keyTypeIsNull %}?{% endif %}>(_{{ keyName }});
  ''';

  /// 生成的值变更监听方法代码片段，实现 ValueNotifier 的赋值。
  ///
  /// 当配置值变化时，此代码会更新ValueNotifier的值，触发监听者回调。
  @override
  final String valueUpdateListenerFunCode = '''
  _{{ name }}_ValueNotifier.value = (value as {{ keyType }}{% if keyTypeIsNull %}?{% endif %});
  ''';

  /// 生成的设置字段代码片段（此处无实现）。
  @override
  final String? setFieldCode = null;

  /// 生成的获取字段代码片段，返回 ValueNotifier。
  @override
  final String? getFieldCode = '''
  return _{{ name }}_ValueNotifier;
  ''';
}

/// 配置值变更监听器的函数类型定义。
///
/// 当配置值发生变化时，会调用此类型的函数。
/// [key] - 发生变化的配置键名
/// [type] - 配置值的类型
/// [value] - 新的配置值
typedef FConfigValueListener =
    void Function(String key, Type type, Object? value);

/// 配置值变更监听器管理器。
///
/// 负责管理一组配置键的监听器，支持添加、移除和通知监听器。
class FConfigValueListenerManager {
  /// 监听的配置键名列表。
  ///
  /// 如果为空，则监听所有配置键的变化。
  final List<String> keyNames;
  /// 存储监听器的内部列表。
  final List<FConfigValueListener> _listeners = [];

  /// 构造函数。
  ///
  /// [keyNames] - 要监听的配置键名列表
  FConfigValueListenerManager(this.keyNames);

  /// 添加一个配置值变更监听器。
  ///
  /// [listener] - 要添加的监听器函数
  void addListener(FConfigValueListener listener) {
    _listeners.add(listener);
  }

  /// 移除一个配置值变更监听器。
  ///
  /// [listener] - 要移除的监听器函数
  void removeListener(FConfigValueListener listener) {
    _listeners.remove(listener);
  }

  /// 通知所有监听器配置值发生了变化。
  ///
  /// [keyName] - 发生变化的配置键名
  /// [type] - 配置值的类型
  /// [value] - 新的配置值
  void notifyListeners(String keyName, Type type, Object? value) {
    if (keyNames.isEmpty || keyNames.contains(keyName)) {
      for (var listener in _listeners) {
        listener(keyName, type, value);
      }
    }
  }
}

/// 用于添加配置值变更监听器的注解。
///
/// 该注解用于方法上，配合代码生成器实现配置值变更监听功能。
/// 使用示例：
/// ```dart
/// @FConfigValueUpdateListener(keyNames: ['appName', 'version'])
/// void addConfigListener(FConfigValueListener listener);  // 方法体将被代码生成器替换
/// ```
class FConfigValueUpdateListener implements FConfigFunInterceptGenerator{

  /// 要监听的配置键名列表。
  ///
  /// 如果为null或空，则监听所有配置键的变化。
  /// 被@FconfigAnnotationField标记，表示这是一个需要在代码生成时处理的字段。
  @FconfigAnnotationField()
  final List<String>? keyNames;

  /// 构造函数。
  ///
  /// [keyNames] - 要监听的配置键名列表
  const FConfigValueUpdateListener({this.keyNames});

  /// 生成的类代码片段，创建FConfigValueListenerManager实例。
  ///
  /// 代码片段会被插入到生成的代理类中，初始化监听器管理器。
  /// - {{ methodName }}: 被注解的方法名
  /// - {% for keyName in keyNames %}: 循环生成keyNames列表
  @override
  final String? classCode = '''
  late final _{{ methodName }}_valueListenerManager = FConfigValueListenerManager([
    {% for keyName in keyNames %}
    '{{ keyName }}',
    {% endfor %}
  ]);
  ''';
  
  /// 生成的方法体代码片段，添加监听器。
  ///
  /// 代码片段会替换被注解的方法体，实现：
  /// 1. 遍历方法参数，将每个参数作为监听器添加到管理器
  /// 2. 如果方法有返回类型，则返回监听器管理器
  /// - {{ methodParams }}: 方法参数列表
  /// - {{ methodName }}: 方法名
  /// - {{ returnType }}: 返回类型
  @override
  final String funCode = '''
  {% for param in methodParams %}
  _{{ methodName }}_valueListenerManager.addListener({{ param.name }});
  {% endfor %}
  {% if returnType %}
  return _{{ methodName }}_valueListenerManager;
  {% endif %}
  ''';
  
  /// 是否为异步方法，这里为 false。
  @override
  final bool isAsync = false;
  
  /// 生成的值变更监听方法代码片段，通知监听器。
  ///
  /// 当配置值变化时，此代码会调用监听器管理器的notifyListeners方法。
  @override
  final String valueUpdateListenerFunCode = '''
  _{{ methodName }}_valueListenerManager.notifyListeners(key, type, value);
  ''';
}

/// 用于移除配置值变更监听器的注解。
///
/// 该注解用于方法上，配合代码生成器实现移除配置值变更监听器功能。
/// 使用示例：
/// ```dart
/// @FConfigValueUpdateListenerRemove('addConfigListener')
/// void removeConfigListener(FConfigValueListener listener) {} // 方法体将被代码生成器替换
/// ```
class FConfigValueUpdateListenerRemove implements FConfigFunInterceptGenerator{

  /// 对应的添加监听器方法名。
  ///
  /// 指定要移除的监听器所属的添加监听器方法。
  /// 被@FconfigAnnotationField标记，表示这是一个需要在代码生成时处理的字段。
  @FconfigAnnotationField()
  final String listenerMethodName;

  /// 构造函数。
  ///
  /// [listenerMethodName] - 对应的添加监听器方法名
  const FConfigValueUpdateListenerRemove(this.listenerMethodName);

  @override
  final String? classCode = null;

  /// 是否为异步方法，这里为 false。
  @override
  final bool isAsync = false;

  /// 生成的方法体代码片段，移除监听器。
  ///
  /// 代码片段会替换被注解的方法体，实现从指定的监听器管理器中移除监听器。
  /// - {{ methodParams }}: 方法参数列表
  /// - {{ listenerMethodName }}: 对应的添加监听器方法名
  @override
  final String funCode = '''
  {% for param in methodParams %}
  _{{ listenerMethodName }}_valueListenerManager.removeListener({{ param.name }});
  {% endfor %}
  ''';

  /// 生成的值变更监听方法代码片段（此处无实现）。
  @override
  final String? valueUpdateListenerFunCode = null;

}



