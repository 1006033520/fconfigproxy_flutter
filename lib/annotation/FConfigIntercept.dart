import 'package:meta/meta_meta.dart';

import 'FConfigAnnotationGenerator.dart';

@Target({TargetKind.method})
class FConfigClearAll implements FConfigFunInterceptGenerator {

  const FConfigClearAll();

  @override
  final String? classCode = null;

  @override
  final String funCode = '''
  await _ConfigProxy.deleteAllValues();
  _read();
  ''';

  @override
  final String? valueUpdateListenerFunCode = null;
  
  @override
  final bool isAsync = true;
}


@Target({TargetKind.getter,TargetKind.field})
class FConfigValueNotifier implements FConfigFieldInterceptGenerator {

  const FConfigValueNotifier();

  @override
  final String classCode = '''
  late final _{{name}}_ValueNotifier = ValueNotifier<{{keyType}}{{#keyTypeIsNull}}?{{/keyTypeIsNull}}>(_{{keyName}});
  ''';

  @override
  final String valueUpdateListenerFunCode = '''
  _{{name}}_ValueNotifier.value = (value as {{keyType}}{{#keyTypeIsNull}}?{{/keyTypeIsNull}});
  ''';

  @override
  final String? setFieldCode = null;

  @override
  final String? getFieldCode = '''
  return _{{name}}_ValueNotifier;
  ''';
}