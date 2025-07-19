import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:fconfigproxy/annotation/FConfigKey.dart';
import 'package:fconfigproxy/generator/HelpGenerator.dart';
import 'package:mustache_template/mustache.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import '../annotation/FConfig.dart';
import '../annotation/FConfigAnnotationGenerator.dart';
import 'DartCodeTemplate.dart';
import 'package:build/build.dart';

Builder fConfigBuilder(BuilderOptions options) =>
    LibraryBuilder(FConfigGenerator());

TypeChecker get typeChecker => TypeChecker.fromRuntime(FConfig);

class FConfigGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();

    List<String> parts = [];

    for (var annotatedElement in library.annotatedWith(typeChecker)) {
      final libraryName = buildStep.inputId.uri.pathSegments.last;
      if (!parts.contains(libraryName)) {
        buffer.writeln("part of '$libraryName';\n");
        parts.add(libraryName);
      }

      final element = annotatedElement.element;

      if (element is ClassElement) {
        final fConfigAnnotation = getAnnotation<FConfig>(element);
        if (fConfigAnnotation == null) continue;

        if (!element.isAbstract && !element.isInterface) {
          throw InvalidGenerationSourceError(
            '`@FConfig` 只能用于抽象类或接口。',
            element: element,
          );
        }

        final proxyType = fConfigAnnotation.read('fConfigProxyType').typeValue;

        final List<Map<String, dynamic>> fields = [];
        final List<Map<String, dynamic>> getMethods = [];
        final List<Map<String, dynamic>> setMethods = [];
        final List<Map<String, dynamic>> interceptMethods = [];
        final List<Map<String, dynamic>> interceptClassCodes = [];
        final List<Map<String, dynamic>> valueUpdates = [];

        for (var field in element.fields) {
          final fieldInfo = FieldInfo.create(field);

          var interceptAnnotation = findFirstAnnotation(
            field,
            FConfigFieldInterceptGenerator,
          );

          if (!fieldInfo.typeIsNull && fieldInfo.defaultValue == 'null') {
            continue;
          }
          fields.add(fieldInfo.toMap());
          getMethods.add(fieldInfo.toMap());
          if (fieldInfo.isSet) {
            setMethods.add(fieldInfo.toMap());
          }
          // {
          //   final keyName = fConfigKey?.read('keyName').stringValueOrNull;
          //   if (keyName != null) {
          //     final getFieldCode = interceptAnnotation
          //         .read('getFieldCode')
          //         .stringValueOrNull;
          //     final classCode = interceptAnnotation
          //         .read('classCode')
          //         .stringValueOrNull;
          //     final valueUpdateListenerFunCode = interceptAnnotation
          //         .read('valueUpdateListenerFunCode')
          //         .stringValueOrNull;
          //
          //     final genericType = element.fields.firstWhere((field) {
          //       final fConfigKey = getAnnotation<FConfigKey>(field);
          //       final _keyName =
          //           fConfigKey?.read('keyName').stringValueOrNull ?? field.name;
          //       return _keyName == keyName;
          //     }).type;
          //
          //     if (classCode != null) {
          //       interceptClassCodes.add({
          //         'code': Template(classCode).renderString({
          //           'name': field.name,
          //           'keyName': keyName,
          //           'type': genericType.getDisplayString(
          //             withNullability: false,
          //           ),
          //           'typeIsNull':
          //               genericType.nullabilitySuffix ==
          //               NullabilitySuffix.question,
          //         }),
          //       });
          //     }
          //
          //     if (valueUpdateListenerFunCode != null) {
          //       valueUpdates.add({
          //         'keyName': keyName,
          //         'valueUpdateListener': Template(valueUpdateListenerFunCode)
          //             .renderString({
          //               'name': field.name,
          //               'type': genericType.getDisplayString(
          //                 withNullability: false,
          //               ),
          //               'typeIsNull':
          //                   genericType.nullabilitySuffix ==
          //                   NullabilitySuffix.question,
          //             }),
          //       });
          //     }
          //
          //     if (getFieldCode != null) {
          //       interceptMethods.add({
          //         'type': field.type,
          //         'typeIsNull':
          //             field.type.nullabilitySuffix ==
          //             NullabilitySuffix.question,
          //         'name': '_get_${field.name}',
          //         'methodParams': [
          //           {
          //             'type': genericType.getDisplayString(
          //               withNullability: false,
          //             ),
          //             'typeIsNull':
          //                 genericType.nullabilitySuffix ==
          //                 NullabilitySuffix.question,
          //             'name': 'value',
          //           },
          //         ],
          //         'methodBody': Template(getFieldCode).renderString({
          //           'keyName': keyName,
          //           'type': field.type.getDisplayString(withNullability: false),
          //           'typeIsNull':
          //               field.type.nullabilitySuffix ==
          //               NullabilitySuffix.question,
          //           'name': field.name,
          //         }),
          //       });
          //
          //       getMethods.add({
          //         'type': field.type,
          //         'typeIsNull':
          //             field.type.nullabilitySuffix ==
          //             NullabilitySuffix.question,
          //         'name': field.name,
          //         'isIntercept': true,
          //         'interceptName': '_get_${field.name}_intercept',
          //         'keyName':
          //             fConfigKey?.read('keyName').stringValueOrNull ??
          //             field.name,
          //       });
          //     }
          //
          //     if (!field.isFinal) {
          //       final setFieldCode = interceptAnnotation
          //           .read('setFieldCode')
          //           .stringValueOrNull;
          //       if (setFieldCode != null) {
          //         interceptMethods.add({
          //           'type': field.type.getDisplayString(withNullability: false),
          //           'typeIsNull':
          //               field.type.nullabilitySuffix ==
          //               NullabilitySuffix.question,
          //           'name': field.name,
          //           'methodParams': [
          //             {
          //               'type': field.type.getDisplayString(
          //                 withNullability: false,
          //               ),
          //               'typeIsNull':
          //                   field.type.nullabilitySuffix ==
          //                   NullabilitySuffix.question,
          //             },
          //           ],
          //           'methodBody': Template(setFieldCode).renderString({
          //             'keyName': keyName,
          //             'type': field.type.getDisplayString(
          //               withNullability: false,
          //             ),
          //             'typeIsNull':
          //                 field.type.nullabilitySuffix ==
          //                 NullabilitySuffix.question,
          //             'name': field.name,
          //           }),
          //         });
          //
          //         setMethods.add({
          //           'type': field.type.getDisplayString(withNullability: false),
          //           'typeIsNull':
          //               field.type.nullabilitySuffix ==
          //               NullabilitySuffix.question,
          //           'name': field.name,
          //           'isIntercept': true,
          //           'interceptName': '_${field.name}_intercept',
          //           'keyName':
          //               fConfigKey?.read('keyName').stringValueOrNull ??
          //               field.name,
          //         });
          //       }
          //     }
          //   }
          // }
        }

        final generatorCode = Template(dartCodeTemplate).renderString({
          'className': element.name,
          'configProxy': proxyType.getDisplayString(),
          'configName': fConfigAnnotation.read('configName').stringValue,
          'interceptClassCodes': interceptClassCodes,
          'fields': fields,
          'valueUpdates': valueUpdates,
          'interceptMethods': interceptMethods,
          'setMethods': setMethods,
          'getMethods': getMethods,
          'otherMethods': [],
        });

        buffer.writeln(generatorCode);
      }
    }

    return buffer.toString();
  }

  ConstantReader? findFirstAnnotation(Element element, Type type) {
    final interceptChecker = TypeChecker.fromRuntime(type);
    for (final annotation in element.metadata) {
      final constantValue = annotation.computeConstantValue();
      print('findFirstAnnotation 1 $element $constantValue');
      if (constantValue == null) continue;
      final annotationType = constantValue.type;
      print('findFirstAnnotation 2 $element $annotationType');
      if (annotationType != null &&
          interceptChecker.isAssignableFromType(annotationType)) {
        print('findFirstAnnotation 3 $element $constantValue');
        return ConstantReader(constantValue);
      }
    }
    return null;
  }
}

ConstantReader? getAnnotation<T>(Element element) {
  final typeChecker = TypeChecker.fromRuntime(T);
  final annotations = typeChecker.annotationsOf(element);
  return annotations.isNotEmpty ? ConstantReader(annotations.first) : null;
}

extension ConstantReaderExtension on ConstantReader {
  get stringValueOrNull {
    return isNull ? null : stringValue;
  }

  get typeValueOrNull {
    return isNull ? null : typeValue;
  }
}
