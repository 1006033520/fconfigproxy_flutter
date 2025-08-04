/**
 *  生成 dart 代码模板
 */
final String dartCodeTemplate = '''
class _{{className}}Impl implements {{className}} {

  static final {{configProxy}} _ConfigProxy = {{configProxy}}();
  
  _{{className}}Impl() {
    _ConfigProxy.init("{{configName}}");
    _read();
  }
  
  {{#interceptClassCodes}}
  {{{code}}}
  {{/interceptClassCodes}}
  
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
  
  void _read() {
    {{#fields}}
    _\${{keyName}} = _ConfigProxy.hasValue("{{keyName}}")
        ? _ConfigProxy.getValue("{{keyName}}", {{{type}}})
        : {{{defaultValue}}};
    _noticeValueUpdate("{{keyName}}", {{{type}}}, _\${{keyName}});
    {{/fields}}
  }
  
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
  
  {{#interceptMethods}}
  {{{type}}}{{#typeIsNull}}?{{/typeIsNull}} _{{name}}_intercept(
    {{#methodParams}}
    {{type}}{{#typeIsNull}}?{{/typeIsNull}} {{name}},
    {{/methodParams}}
  ) {
    {{methodBody}}
  }
  {{/interceptMethods}}
  
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

  static final {{className}} _instance = _{{className}}Impl();

}

{{className}} _\$Get{{className}}() =>  _{{className}}Impl._instance;
''';
