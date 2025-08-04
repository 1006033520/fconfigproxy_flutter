/// 方法拦截代码生成器接口，用于生成与配置相关的方法代码片段。
abstract class FConfigFunInterceptGenerator {
  /// 生成的类代码片段
  abstract final String? classCode;

  /// 生成的值变更监听方法代码片段
  abstract final String? valueUpdateListenerFunCode;

  /// 生成的目标方法代码片段
  abstract final String funCode;

  /// 是否为异步方法
  abstract final bool isAsync;
}

/// 字段拦截代码生成器接口，用于生成与配置相关的字段代码片段。
abstract class FConfigFieldInterceptGenerator {
  /// 生成的类代码片段
  abstract final String? classCode;

  /// 生成的值变更监听方法代码片段
  abstract final String? valueUpdateListenerFunCode;

  /// 生成的设置字段代码片段
  abstract final String? setFieldCode;

  /// 生成的获取字段代码片段
  abstract final String? getFieldCode;
}
