import 'package:meta/meta_meta.dart';

import 'FConfigAnnotationGenerator.dart';

/// 用于标记清除所有配置的注解。
/// 
/// 该注解只能用于方法上，配合代码生成器实现批量清除配置的功能。
@Target({TargetKind.method})
class FConfigClearAll implements FConfigFunInterceptGenerator {

  /// 构造函数，常量形式。
  const FConfigClearAll();

  /// 生成的类代码片段（此处无实现）。
  @override
  final String? classCode = null;

  /// 生成的目标方法代码片段，实现清除所有配置并刷新读取。
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
@Target({TargetKind.getter,TargetKind.field})
class FConfigValueNotifier implements FConfigFieldInterceptGenerator {

  /// 构造函数，常量形式。
  const FConfigValueNotifier();

  /// 生成的类代码片段，声明 ValueNotifier 并初始化。
  @override
  final String classCode = '''
  late final _{{name}}_ValueNotifier = ValueNotifier<{{keyType}}{{#keyTypeIsNull}}?{{/keyTypeIsNull}}>(_{{keyName}});
  ''';

  /// 生成的值变更监听方法代码片段，实现 ValueNotifier 的赋值。
  @override
  final String valueUpdateListenerFunCode = '''
  _{{name}}_ValueNotifier.value = (value as {{keyType}}{{#keyTypeIsNull}}?{{/keyTypeIsNull}});
  ''';

  /// 生成的设置字段代码片段（此处无实现）。
  @override
  final String? setFieldCode = null;

  /// 生成的获取字段代码片段，返回 ValueNotifier。
  @override
  final String? getFieldCode = '''
  return _{{name}}_ValueNotifier;
  ''';
}