import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:fconfigproxy/utils/buildRunnerFun.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mustache_template/mustache.dart';

import '../annotation/FConfigAnnotationGenerator.dart';
import '../annotation/FConfigKey.dart';
import 'FConfigGenerator.dart';

class FConfigKeyAnalysis {
  final String? keyName;
  final String? defaultValue;
  FConfigKeyAnalysis._(this.keyName, this.defaultValue);

  static FConfigKeyAnalysis? analysis(FieldElement field) {
    final fConfigKey = getAnnotation<FConfigKey>(field);
    if (fConfigKey == null) {
      return null;
    }
    return FConfigKeyAnalysis._(
      fConfigKey.read('keyName').stringValueOrNull,
      fConfigKey.read('defaultValue').stringValueOrNull,
    );
  }
}

class FieldInfo {
  final String keyName;
  final String name;
  final String type;
  final bool typeIsNull;
  final String defaultValue;
  final bool isSet;

  late Map<String, dynamic> toMap;

  FieldInfo(
    this.name,
    this.keyName,
    this.type,
    this.typeIsNull,
    this.defaultValue,
    this.isSet,
  ) {
    toMap = {
      'type': type,
      'typeIsNull': typeIsNull,
      'keyName': keyName,
      'name': name,
      'defaultValue': defaultValue,
      'isSet': isSet,
      'isIntercept': false,
    };
  }

  factory FieldInfo.create(FieldElement field) {
    final fConfigKey = FConfigKeyAnalysis.analysis(field);

    return FieldInfo(
      field.name,
      fConfigKey?.keyName ?? field.name,
      field.type.genericsName,
      (field.type.nullabilitySuffix == NullabilitySuffix.question),
      fConfigKey?.defaultValue ?? 'null',
      field.setter != null,
    );
  }
}

class FieldInterceptInfo implements FConfigFieldInterceptGenerator {
  final String name;

  final String type;

  final bool typeIsNull;

  final String keyName;

  final String keyType;

  final bool keyTypeIsNull;

  @override
  final String? classCode;

  @override
  final String? getFieldCode;

  @override
  final String? setFieldCode;

  @override
  final String? valueUpdateListenerFunCode;

  const FieldInterceptInfo(
    this.name,
    this.type,
    this.typeIsNull,
    this.keyName,
    this.keyType,
    this.keyTypeIsNull,
    this.classCode,
    this.getFieldCode,
    this.setFieldCode,
    this.valueUpdateListenerFunCode,
  );

  factory FieldInterceptInfo.create(
    FieldInfo fieldInfo,
    FieldElement field,
    ConstantReader reader,
  ) {
    final map = {
      "name": field.name,
      "type": field.type.genericsName,
      'typeIsNull':
          (field.type.nullabilitySuffix == NullabilitySuffix.question),
      "keyName": fieldInfo.keyName,
      "keyType": fieldInfo.type,
      "keyTypeIsNull": fieldInfo.typeIsNull,
    };

    return FieldInterceptInfo(
      field.name,
      field.type.genericsName,
      (field.type.nullabilitySuffix == NullabilitySuffix.question),
      fieldInfo.keyName,
      fieldInfo.type,
      fieldInfo.typeIsNull,
      reader
          .read('classCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(map)),
      reader
          .read('getFieldCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(map)),
      reader
          .read('setFieldCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(map)),
      reader
          .read('valueUpdateListenerFunCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(map)),
    );
  }

  toInterceptMethodMaps() {
    final List<Map<String, dynamic>> interceptMethodMaps = [];

    if (setFieldCode != null) {
      interceptMethodMaps.add({
        'type': keyType,
        'typeIsNull': keyTypeIsNull,
        'name': 'set_$name',
        'methodParams': [
          {'type': type, 'typeIsNull': typeIsNull, 'name': name},
        ],
        'methodBody': setFieldCode,
      });
    }

    if (getFieldCode != null) {
      interceptMethodMaps.add({
        'type': type,
        'typeIsNull': typeIsNull,
        'name': 'get_$name',
        'methodParams': [
          {'type': keyType, 'typeIsNull': keyTypeIsNull, 'name': keyName},
        ],
        'methodBody': getFieldCode,
      });
    }

    return interceptMethodMaps;
  }

  toSetCodeMaps() {
    if (setFieldCode != null) {
      return {
        'type': type,
        'typeIsNull': typeIsNull,
        'name': name,
        'keyName': keyName,
        'isIntercept': true,
        'interceptName': 'set_$name',
      };
    }
    return null;
  }

  toGetCodeMaps() {
    if (getFieldCode != null) {
      return {
        'type': type,
        'typeIsNull': typeIsNull,
        'name': name,
        'keyName': keyName,
        'isIntercept': true,
        'interceptName': 'get_$name',
      };
    }
    return null;
  }
}

class OtherMethodInfo {

  final String name;
  final String type;
  final bool typeIsNull;
  final List<Map<String, dynamic>> methodParams;
  final String? classCode;
  final String methodBody;
  final String? valueUpdateListenerFunCode;

  const OtherMethodInfo(
    this.name,
    this.type,
    this.typeIsNull,
    this.methodParams,
    this.classCode,
    this.methodBody,
    this.valueUpdateListenerFunCode,
  );  

  factory OtherMethodInfo.create(
    MethodElement methodElement,
    ConstantReader reader,
  ) {
    final returnType = methodElement.returnType.genericsName;
    final typeIsNull = (methodElement.returnType.nullabilitySuffix == NullabilitySuffix.question);
    final methodParams = methodElement.parameters.map((param) {
      return {
        'type': param.type.genericsName,
        'typeIsNull': (param.type.nullabilitySuffix == NullabilitySuffix.question),
        'name': param.name,
      };
    }).toList();

    return OtherMethodInfo(
      methodElement.name,
      returnType,
      typeIsNull,
      methodParams,
      reader.read('classCode').stringValueOrNull,
      reader.read('funCode').stringValue,
      reader.read('valueUpdateListenerFunCode').stringValueOrNull,
      );
  }

}
