/// 配置注解类，用于标记配置名称和代理类型。
class FConfig {
  /// 配置名称
  final String configName;
  /// 代理类型
  final Type proxyType;

  /// 创建一个 [FConfig] 实例，需指定 [configName] 和 [proxyType]。
  const FConfig(this.configName, this.proxyType);
}