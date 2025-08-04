
abstract class FConfigFunInterceptGenerator {

  abstract final String? classCode;

  abstract final String? valueUpdateListenerFunCode;

  abstract final String funCode;

  abstract final bool isAsync;
}

abstract class FConfigFieldInterceptGenerator {

  abstract final String? classCode;

  abstract final String? valueUpdateListenerFunCode;

  abstract final String? setFieldCode;

  abstract final String? getFieldCode;
}
