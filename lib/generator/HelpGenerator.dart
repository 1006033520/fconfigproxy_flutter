import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import '../annotation/FConfigKey.dart';
import 'FConfigGenerator.dart';

class FieldInfo {
  final String keyName;
  final String name;
  final String type;
  final bool typeIsNull;
  final String defaultValue;
  final bool isSet;

  const FieldInfo(
    this.name,
    this.keyName,
    this.type,
    this.typeIsNull,
    this.defaultValue,
    this.isSet,
  );

  factory FieldInfo.create(FieldElement field) {
    final fConfigKey = getAnnotation<FConfigKey>(field);

    return FieldInfo(
      field.name,
      fConfigKey?.read('keyName').stringValueOrNull ?? field.name,
      field.type.name!,
      (field.type.nullabilitySuffix == NullabilitySuffix.question),
      fConfigKey?.read('defaultValue').stringValueOrNull ?? 'null',
      field.setter != null,
    );
  }

  toMap() => {
    'type':type,
    'typeIsNull': typeIsNull,
    'keyName': keyName,
    'name': name,
    'defaultValue': defaultValue,
    'isSet': isSet,
    'isIntercept':false
  };

}
