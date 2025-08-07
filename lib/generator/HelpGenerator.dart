import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:fconfigproxy/utils/buildRunnerFun.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mustache_template/mustache.dart';

import '../annotation/FConfigAnnotationField.dart';
import '../annotation/FConfigAnnotationGenerator.dart';
import '../annotation/FConfigKey.dart';
import 'FConfigGenerator.dart';

/// FConfigKey 注解分析工具类，提取 keyName 和 defaultValue。
class FConfigKeyAnalysis {
  final String? keyName;
  final String? defaultValue;
  FConfigKeyAnalysis._(this.keyName, this.defaultValue);

  /// 分析字段上的 FConfigKey 注解，返回 keyName 和 defaultValue。
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

/// 字段信息结构体，便于模板渲染和代码生成。
class FieldInfo {
  /// 配置项 key 名
  final String keyName;
  /// 字段名
  final String name;
  /// 字段类型
  final String type;
  /// 字段是否可空
  final bool typeIsNull;
  /// 默认值
  final String defaultValue;
  /// 是否有 setter
  final bool isSet;

  /// 用于 Mustache 模板渲染的 Map
  late Map<String, dynamic> toMap;

  /// 构造函数
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

  /// 工厂方法：从 FieldElement 创建 FieldInfo
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

class FConfigAnnotationFieldInfo{
  final List<String> fields;

  const FConfigAnnotationFieldInfo(this.fields);

  factory FConfigAnnotationFieldInfo.create(ConstantReader reader){
    final typeChecker = TypeChecker.fromRuntime(FconfigAnnotationField);
    return reader.objectValue.type?.element?.let((it){
      if(it is ClassElement){
        return it.fields.where((field) => typeChecker.hasAnnotationOf(field)).map((field) {
          return field.name;
        }).toList();
      }
      return null;
    })?.let((it) => FConfigAnnotationFieldInfo(it)) ?? const FConfigAnnotationFieldInfo([]);
  }
}

/// 字段拦截信息结构体，实现 FConfigFieldInterceptGenerator，用于生成字段相关的拦截代码和模板数据。
///
/// 该结构体用于描述带有字段拦截注解的字段，便于代码生成器根据注解内容生成自定义的 getter/setter、监听器等代码片段。
class FieldInterceptInfo implements FConfigFieldInterceptGenerator {
  /// 字段名
  final String name;
  /// 字段类型
  final String type;
  /// 字段是否可空
  final bool typeIsNull;
  /// 配置项 key 名
  final String keyName;
  /// key 对应的类型（通常与字段类型一致）
  final String keyType;
  /// key 类型是否可空
  final bool keyTypeIsNull;

  /// 生成的类级代码片段（如 ValueNotifier 声明等）
  @override
  final String? classCode;

  /// 生成的 getter 代码片段（如返回 ValueNotifier）
  @override
  final String? getFieldCode;

  /// 生成的 setter 代码片段（如赋值并通知变更）
  @override
  final String? setFieldCode;

  /// 生成的值变更监听方法代码片段
  @override
  final String? valueUpdateListenerFunCode;

  /// 构造函数，初始化所有字段
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

  /// 工厂方法：从字段和注解 ConstantReader 创建 FieldInterceptInfo
  ///
  /// 通过 Mustache 模板渲染注解中的代码片段，动态生成对应的代码字符串。
  factory FieldInterceptInfo.create(
    FieldInfo fieldInfo,
    FieldElement field,
    ConstantReader reader,
  ) {
    final templateData = {
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
          ?.let((it) => Template(it).renderString(templateData)),
      reader
          .read('getFieldCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(templateData)),
      reader
          .read('setFieldCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(templateData)),
      reader
          .read('valueUpdateListenerFunCode')
          .stringValueOrNull
          ?.let((it) => Template(it).renderString(templateData)),
    );
  }

  /// 转换为拦截方法的 Map，供模板渲染
  ///
  /// 用于生成自定义 getter/setter 拦截方法的模板数据。
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

  /// 转换为 set 方法的 Map，供模板渲染
  ///
  /// 用于生成自定义 setter 的模板数据。
  toSetCodeMap() {
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

  /// 转换为 get 方法的 Map，供模板渲染
  ///
  /// 用于生成自定义 getter 的模板数据。
  toGetCodeMap() {
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

/// 其他方法信息结构体，用于方法拦截器生成
class OtherMethodInfo {
  /// 方法名
  final String name;
  /// 返回类型
  final String type;
  /// 是否可空
  final bool typeIsNull;
  /// 参数列表（类型、可空、名称）
  final List<Map<String, dynamic>> methodParams;
  /// 生成的类级代码片段
  final String? classCode;
  /// 是否为异步方法
  final bool isAsync;
  /// 生成的方法体代码
  final String methodBody;
  /// 生成的值变更监听方法代码片段
  final String? valueUpdateListenerFunCode;

  /// 构造函数
  const OtherMethodInfo(
    this.name,
    this.type,
    this.typeIsNull,
    this.methodParams,
    this.classCode,
    this.isAsync,
    this.methodBody,
    this.valueUpdateListenerFunCode,
  );  

  /// 工厂方法：从方法元素和注解 ConstantReader 创建 OtherMethodInfo
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

    final Map<String,dynamic> templateData = {
      'methodName': methodElement.name,
      'returnType': returnType == 'void' ? null : returnType,
      'returnTypeIsNull': typeIsNull,
      'isAsync': methodElement.isAsynchronous,
    };

    methodElement.parameters.forEach((param) {
      templateData[param.name] = {
        
      };
    });

    FConfigAnnotationFieldInfo.create(reader).let((it){
      for (var field in it.fields) {
        final fieldElement = reader.read(field);

        if(fieldElement.isNull) {
          return;
        }
        templateData[field] = fieldElement.objectValue.parsedValue;

      }
    });

    return OtherMethodInfo(
      methodElement.name,
      returnType,
      typeIsNull,
      methodParams,
      reader.read('classCode').stringValueOrNull?.let((it) => Template(it,lenient: true).renderString(templateData)),
      reader.read('isAsync').boolValue,
      reader.read('funCode').stringValue.let((it) => Template(it,lenient: true).renderString(templateData)),
      reader.read('valueUpdateListenerFunCode').stringValueOrNull?.let((it) => Template(it,lenient: true).renderString(templateData)),
      );
  }

}