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
