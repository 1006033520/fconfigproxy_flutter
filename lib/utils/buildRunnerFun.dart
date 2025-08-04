import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:source_gen/source_gen.dart';

extension ConstantReaderExtension on ConstantReader {
  String? get stringValueOrNull {
    return isNull ? null : stringValue;
  }

  DartType? get typeValueOrNull {
    return isNull ? null : typeValue;
  }
}

extension DartTypeExtension on DartType {
  String get genericsName {
    return getDisplayString(withNullability: true).let((it) {
      if (nullabilitySuffix == NullabilitySuffix.question) {
        return it.substring(0, it.length - 1);
      }
      return it;
    });
  }
}
