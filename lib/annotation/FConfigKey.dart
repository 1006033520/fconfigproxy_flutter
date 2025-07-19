import 'package:meta/meta_meta.dart';

@Target({
  TargetKind.field,
  TargetKind.getter,
  TargetKind.setter,
  TargetKind.method,
})
class FConfigKey {
  final String? keyName;
  final String? defaultValue;

  const FConfigKey({this.keyName, this.defaultValue});
}
