import 'package:meta/meta_meta.dart';

import 'FConfigAnnotationGenerator.dart';

@Target({TargetKind.method})
class FConfigClearAll implements FConfigFunInterceptGenerator {
  @override
  final String? classCode = null;

  @override
  final String funCode = '''
  _ConfigProxy.deleteAllValues();
  _read();
  ''';

  @override
  final String? valueUpdateListenerFunCode = null;
}


@Target({TargetKind.getter,TargetKind.field})
class FConfigValueNotifier implements FConfigFieldInterceptGenerator {

  const FConfigValueNotifier();

  @override
  final String classCode = '''
  late final _{{name}}_ValueNotifier = ValueNotifier<{{type}}{{#typeIsNull}}?{{/typeIsNull}}>(_{{keyName}});
  ''';

  @override
  final String valueUpdateListenerFunCode = '''
  _{{name}}_ValueNotifier.value = (value as {{type}}{{#typeIsNull}}?{{/typeIsNull}});
  ''';

  @override
  final String? setFieldCode = null;

  @override
  final String? getFieldCode = '''
  return _{{name}}_ValueNotifier;
  ''';
}