/**
 *  生成 dart 代码模板
 *
 *  该模板用于通过代码生成器自动生成配置代理类的实现代码。
 *  使用 Mustache 模板语法，支持动态插入类名、字段、方法等内容。
 *  主要功能包括：
 *    - 自动实现配置接口
 *    - 生成字段的 getter/setter 及变更通知
 *    - 生成方法拦截与代理逻辑
 *    - 支持 ValueNotifier、异步方法等扩展
 */
final String dartCodeTemplate = '''
class _{{className}}Impl implements {{className}} {

  /// 配置代理实例，静态成员保证全局唯一
  static final {{configProxy}} _ConfigProxy = {{configProxy}}();
  
  /// 构造函数，初始化配置并读取初始值
  _{{className}}Impl() {
    _ConfigProxy.init("{{configName}}");
    _read();
  }
  
  /// 拦截器生成的类级代码片段
  {{#interceptClassCodes}}
  {{{code}}}
  {{/interceptClassCodes}}
  
  /// 字段定义及其 getter/setter
  {{#fields}}
  late {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} _\${{keyName}};
  
  {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} get _{{keyName}} => _\${{keyName}};
  
  set _{{keyName}}({{{type}}}{{#typeIsNull}}?{{/typeIsNull}} value) {
    if(_\${{keyName}} == value) {
      return;
    }
    _\${{keyName}} = value;
    _updateValue("{{keyName}}",{{{type}}}, value);
  }
  {{/fields}}
  
  /// 读取所有配置项的值并通知变更
  void _read() {
    {{#fields}}
    _\${{keyName}} = _ConfigProxy.hasValue("{{keyName}}")
        ? _ConfigProxy.getValue("{{keyName}}", {{{type}}})
        : {{{defaultValue}}};
    _noticeValueUpdate("{{keyName}}", {{{type}}}, _\${{keyName}});
    {{/fields}}
  }
  
  /// 更新配置项的值，并通知监听
  void _updateValue(String key,Type type,Object? value){
    if (value == null) {
      if(_ConfigProxy.hasValue(key)) {
        _ConfigProxy.deleteValue(key);
      }
    } else {
      _ConfigProxy.setValue(key, type, value);
    }
    _noticeValueUpdate(key,type,value);
  }
  
  /// 通知配置项变更，触发监听器
  void _noticeValueUpdate(String key,Type type,Object? value) {
    {{#valueUpdates}}
    if(key == "{{keyName}}") {
      {{{valueUpdateListener}}}
    }
    {{/valueUpdates}}

    {{#otherMethodListeners}}
    {{{code}}}
    {{/otherMethodListeners}}
  }
  
  /// 生成的方法拦截器实现
  {{#interceptMethods}}
  {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} _{{name}}_intercept(
    {{#methodParams}}
    {{type}}{{#typeIsNull}}?{{/typeIsNull}} {{name}},
    {{/methodParams}}
  ) {
    {{methodBody}}
  }
  {{/interceptMethods}}
  
  /// 生成的 set 方法实现
  {{#setMethods}}
  @override
  set {{name}}({{{type}}}{{#typeIsNull}}?{{/typeIsNull}} value) {
    {{#isIntercept}}
    _{{keyName}} = _{{interceptName}}_intercept(value);
    {{/isIntercept}}
    {{^isIntercept}}
    _{{keyName}} = value;
    {{/isIntercept}}
  }
  {{/setMethods}}
  
  /// 生成的 get 方法实现
  {{#getMethods}}
  @override
  {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} get {{name}} {
    {{#isIntercept}}
    return _{{interceptName}}_intercept(_{{keyName}});
    {{/isIntercept}}
    {{^isIntercept}}
    return _{{keyName}};
    {{/isIntercept}}
  }
  {{/getMethods}}
  
  /// 生成的其他方法实现
  {{#otherMethods}}
  @override
  {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} {{name}}(
    {{#methodParams}}
    {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} {{name}},
    {{/methodParams}}
  ) {{#isAsync}}async{{/isAsync}} {
    {{methodBody}}
  }
  {{/otherMethods}}

  /// 单例实例
  static final {{className}} _instance = _{{className}}Impl();

}

/// 获取单例实例的方法
{{className}} _\$Get{{className}}() =>  _{{className}}Impl._instance;
''';
