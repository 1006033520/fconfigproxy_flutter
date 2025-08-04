import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:fconfigproxy/annotation/FConfigAnnotationGenerator.dart';
import 'package:fconfigproxy/generator/HelpGenerator.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:mustache_template/mustache.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import '../annotation/FConfig.dart';
import 'DartCodeTemplate.dart';

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
        final List<Map<String, dynamic>> otherMethodListeners = [];
        final List<Map<String, dynamic>> otherMethods = [];

        final List<FieldInfo> fieldInfos = [];
        final List<FieldInterceptInfo> fieldInterceptInfos = [];
        final List<FieldElement> fieldElementIntercepts = [];
        final List<ConstantReader> fieldReaderIntercepts = [];

        for (var field in element.fields) {
          final fieldIntercept = findFirstAnnotation(field, FConfigFieldInterceptGenerator);
          if(fieldIntercept != null){
            fieldElementIntercepts.add(field);
            fieldReaderIntercepts.add(fieldIntercept);
            continue;
          }
          final fieldInfo = FieldInfo.create(field);
          if(fieldInfo.typeIsNull || fieldInfo.defaultValue != 'null') {
            fieldInfos.add(fieldInfo);
          }
        }

        element.methods.forEach((it){
          final funIntercept = findFirstAnnotation(it, FConfigFunInterceptGenerator);
          if(funIntercept != null){
            final otherMethodInfo = OtherMethodInfo.create(it, funIntercept);
            otherMethods.add({
              'name': otherMethodInfo.name,
              'type': otherMethodInfo.type,
              'typeIsNull': otherMethodInfo.typeIsNull,
              'methodParams': otherMethodInfo.methodParams,
              'methodBody': otherMethodInfo.methodBody,
              'isAsync': otherMethodInfo.isAsync,
            });

            if(otherMethodInfo.classCode != null) {
              interceptClassCodes.add({'code': otherMethodInfo.classCode!});
            }

            if(otherMethodInfo.valueUpdateListenerFunCode != null) {
              otherMethodListeners.add({
                'code': otherMethodInfo.valueUpdateListenerFunCode,
              });
            }

          }

        });

        for (var i = 0; i < fieldElementIntercepts.length; i++) {
          final fieldElement = fieldElementIntercepts[i];
          final fieldReader = fieldReaderIntercepts[i];
          final fieldInfo = FConfigKeyAnalysis.analysis(fieldElement)?.let((it){
            return fieldInfos.firstWhere((element) => element.keyName == it.keyName);
          });
          if(fieldInfo == null){
            continue;
          }
          final fieldInterceptInfo = FieldInterceptInfo.create(fieldInfo,fieldElement, fieldReader);
          fieldInterceptInfos.add(fieldInterceptInfo);
        }

        fields.addAll(fieldInfos.map((fieldInfo)=>fieldInfo.toMap));
        getMethods.addAll(fieldInfos.map((fieldInfo)=>fieldInfo.toMap));
        setMethods.addAll(fieldInfos.where((fieldInfo)=>fieldInfo.isSet).map((fieldInfo)=>fieldInfo.toMap));

        fieldInterceptInfos.forEach(((it) {
          if(it.classCode != null) {
            interceptClassCodes.add({'code': it.classCode!});
          }

          interceptMethods.addAll(it.toInterceptMethodMaps());

          if(it.getFieldCode != null) {
            getMethods.add(it.toGetCodeMaps());
          }

          if(it.setFieldCode != null) {
            setMethods.add(it.toSetCodeMaps());
          }

          if(it.valueUpdateListenerFunCode != null) {
            valueUpdates.add({
              'keyName': it.keyName,
              'valueUpdateListener': it.valueUpdateListenerFunCode,
            });
          }

        }));

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
          'otherMethodListeners': otherMethodListeners,
          'otherMethods': otherMethods,
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
      if (constantValue == null) continue;
      final annotationType = constantValue.type;
      if (annotationType != null &&
          interceptChecker.isAssignableFromType(annotationType)) {
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

