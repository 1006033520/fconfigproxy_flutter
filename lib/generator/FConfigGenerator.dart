import 'package:analyzer/dart/element/element.dart';
import 'package:fconfigproxy/annotation/FConfigAnnotationGenerator.dart';
import 'package:fconfigproxy/generator/HelpGenerator.dart';
import 'package:fconfigproxy/utils/fun.dart';
import 'package:mustache_template/mustache.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import '../annotation/FConfig.dart';
import 'DartCodeTemplate.dart';

/// 构建器入口，供 build_runner 调用，生成配置代理相关代码。
Builder fConfigBuilder(BuilderOptions options) =>
    LibraryBuilder(FConfigGenerator());

/// 获取 FConfig 注解的 TypeChecker，用于查找被注解的类。
TypeChecker get typeChecker => TypeChecker.fromRuntime(FConfig);

/// FConfig 注解代码生成器，实现 source_gen 的 Generator。
class FConfigGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();

    // 记录已处理的 part 文件，避免重复生成 part of 语句
    List<String> parts = [];

    // 遍历所有带有 FConfig 注解的元素
    for (var annotatedElement in library.annotatedWith(typeChecker)) {
      final libraryName = buildStep.inputId.uri.pathSegments.last;
      if (!parts.contains(libraryName)) {
        buffer.writeln("part of '$libraryName';\n");
        parts.add(libraryName);
      }

      final element = annotatedElement.element;

      // 只处理类元素
      if (element is ClassElement) {
        // 读取 FConfig 注解内容
        final fConfigAnnotation = getAnnotation<FConfig>(element);
        if (fConfigAnnotation == null) continue;

        // 只允许抽象类或接口使用 FConfig 注解
        if (!element.isAbstract && !element.isInterface) {
          throw InvalidGenerationSourceError(
            '`@FConfig` 只能用于抽象类或接口。',
            element: element,
          );
        }

        // 获取代理类型
        final proxyType = fConfigAnnotation.read('proxyType').typeValue;

        // 代码生成所需的各类信息收集
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

        // 遍历类字段，收集拦截器注解和普通字段信息
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

        // 遍历类方法，收集方法拦截器注解
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

        // 处理字段拦截器相关信息
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

        // 整理字段、getter、setter、拦截器等信息，供模板渲染
        fields.addAll(fieldInfos.map((fieldInfo)=>fieldInfo.toMap));
        getMethods.addAll(fieldInfos.map((fieldInfo)=>fieldInfo.toMap));
        setMethods.addAll(fieldInfos.where((fieldInfo)=>fieldInfo.isSet).map((fieldInfo)=>fieldInfo.toMap));

        fieldInterceptInfos.forEach(((it) {
          if(it.classCode != null) {
            interceptClassCodes.add({'code': it.classCode!});
          }

          interceptMethods.addAll(it.toInterceptMethodMaps());

          if(it.getFieldCode != null) {
            getMethods.add(it.toGetCodeMap());
          }

          if(it.setFieldCode != null) {
            setMethods.add(it.toSetCodeMap());
          }

          if(it.valueUpdateListenerFunCode != null) {
            valueUpdates.add({
              'keyName': it.keyName,
              'valueUpdateListener': it.valueUpdateListenerFunCode,
            });
          }

        }));

        // 使用 Mustache 模板渲染最终代码
        // 模板参数说明：
        // className: 被代理的类名
        // configProxy: 代理实现类（具体进行key、value操作的实现类）
        // configName: 配置名称（注解参数）
        // interceptClassCodes: 字段/方法拦截器生成的类代码
        // fields: 普通字段信息列表
        // valueUpdates: 字段变更监听方法
        // interceptMethods: 拦截器方法集合
        // setMethods: setter 方法集合
        // getMethods: getter 方法集合
        // otherMethodListeners: 其他方法监听器
        // otherMethods: 其他方法集合
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

  /// 查找元素上的第一个指定类型的注解，返回 ConstantReader
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

/// 获取元素上的指定类型注解（泛型），返回 ConstantReader
ConstantReader? getAnnotation<T>(Element element) {
  final typeChecker = TypeChecker.fromRuntime(T);
  final annotations = typeChecker.annotationsOf(element);
  return annotations.isNotEmpty ? ConstantReader(annotations.first) : null;
}

