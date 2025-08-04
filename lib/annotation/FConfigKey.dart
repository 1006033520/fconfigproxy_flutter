import 'package:meta/meta_meta.dart';

/// 用于标记配置项的注解。
///
/// 可用于字段、getter、setter、方法，支持自定义 key 名和默认值。
@Target({
  TargetKind.field,
  TargetKind.getter,
  TargetKind.setter,
  TargetKind.method,
})
class FConfigKey {
  /// 配置项的 key 名，若为空则使用成员名。
  final String? keyName;

  /// 配置项的默认值，若为空则无默认值。
  final String? defaultValue;

  /// 构造函数，支持可选 keyName 和 defaultValue。
  const FConfigKey({this.keyName, this.defaultValue});
}
