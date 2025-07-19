import 'package:meta/meta_meta.dart';

import '../agreement/FConfigKeyValueHandle.dart';

/**
 * FConfig.dart
 * 配置注解类
 */
@Target({TargetKind.classType})
class FConfig{
  final String configName;
  final Type fConfigProxyType;
  const FConfig(this.configName,this.fConfigProxyType);
}