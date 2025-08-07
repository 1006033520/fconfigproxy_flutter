import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:source_gen/source_gen.dart';

/// ConstantReader 的扩展方法，便于安全获取注解参数值。
extension ConstantReaderExtension on ConstantReader {
  /// 获取字符串值，如果为 null 则返回 null。
  String? get stringValueOrNull {
    return isNull ? null : stringValue;
  }

  /// 获取类型值，如果为 null 则返回 null。
  DartType? get typeValueOrNull {
    return isNull ? null : typeValue;
  }
}

/// DartType 的扩展方法，便于获取泛型类型名（带或不带可空后缀）。
extension DartTypeExtension on DartType {
  /// 获取类型的显示名称（带泛型），并去除可空后缀 '?'
  String get genericsName {
    return getDisplayString(withNullability: true).let((it) {
      // 如果类型为可空（如 String?），去掉最后的 '?'
      if (nullabilitySuffix == NullabilitySuffix.question) {
        return it.substring(0, it.length - 1);
      }
      return it;
    });
  }
}

// ------------------------------
// 核心类型检查器
// ------------------------------
const _boolChecker = TypeChecker.fromRuntime(bool);
const _intChecker = TypeChecker.fromRuntime(int);
const _doubleChecker = TypeChecker.fromRuntime(double);
const _stringChecker = TypeChecker.fromRuntime(String);
const _symbolChecker = TypeChecker.fromRuntime(Symbol);
const _listChecker = TypeChecker.fromRuntime(List);
const _mapChecker = TypeChecker.fromRuntime(Map);
const _typeChecker = TypeChecker.fromRuntime(Type);

// ------------------------------
// DartObject扩展方法
// ------------------------------
extension DartObjectExtension on DartObject {
  /// 将DartObject转换为对应的Dart基础类型或Map（自定义类型）
  dynamic get parsedValue {
    if (isNull) return null;
    final type = this.type;
    if (type == null) return _unknownValue(this);

    // 基本类型处理
    if (_boolChecker.isExactlyType(type)) {
      return toBoolValue();
    } else if (_intChecker.isExactlyType(type)) {
      return toIntValue();
    } else if (_doubleChecker.isExactlyType(type)) {
      return toDoubleValue();
    } else if (_stringChecker.isExactlyType(type)) {
      return toStringValue();
    } else if (_symbolChecker.isExactlyType(type)) {
      return toSymbolValue();
    }

    // 列表类型处理
    else if (_listChecker.isAssignableFromType(type)) {
      return toListValue()?.map((item) => item.parsedValue).toList();
    }

    // Map类型处理
    else if (_mapChecker.isAssignableFromType(type)) {
      final map = toMapValue() ?? {};
      return {
        for (final entry in map.entries)
          entry.key?.parsedValue: entry.value?.parsedValue
      };
    }

    // // 枚举类型处理（修正部分）
    // else if (type.element is EnumElement) {
    //   return _parseEnum(this, type.element as EnumElement);
    // }

    // 类型字面量处理
    else if (_typeChecker.isExactlyType(type)) {
      return {
        '__type': 'type',
        'name': type.genericsName,
        'isNull': type.nullabilitySuffix == NullabilitySuffix.question,
      };
    }

    // 自定义对象处理
    else if (type is InterfaceType) {
      return _parseInterfaceType(this, type);
    }

    // 未知类型处理
    return _unknownValue(this);
  }

  // /// 解析枚举类型（正确实现）
  // static Map<String, dynamic> _parseEnum(DartObject object, EnumElement enumElement) {
  //   // 枚举值的名称存储在"name"字段中
  //   final nameSymbol = Symbol('name');
  //   final nameValue = object.getField(nameSymbol);
  //   final enumName = nameValue?.toStringValue();

  //   return {
  //     '__type': 'enum',
  //     'enumClass': enumElement.name,
  //     'value': enumName,
  //     'library': enumElement.library.source.uri.toString(),
  //   };
  // }

  /// 解析接口类型（自定义类）
  static Map<String, dynamic> _parseInterfaceType(DartObject object, InterfaceType type) {
    final classElement = type.element as ClassElement;
    return {
      '__type': 'instance',
      'class': classElement.name,
      'library': classElement.library.source.uri.toString(),
      'fields': {
        for (final field in classElement.fields)
          if (!field.isStatic)
            field.name: object.getField(field.name)?.parsedValue
      },
    };
  }

  /// 处理未知类型
  static Map<String, dynamic> _unknownValue(DartObject object) {
    return {
      '__type': 'unknown',
      'type': object.type?.getDisplayString(withNullability: false),
      'value': object.toString(),
    };
  }
}