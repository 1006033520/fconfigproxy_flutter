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
  
  /// 构造函数
  _{{className}}Impl();

  /// 初始化配置
  Future<void> init() async {
    await _ConfigProxy.init("{{configName}}");
    _read();
  }
  
  /// 拦截器生成的类级代码片段
  {% for codeBlock in interceptClassCodes %}
  {{ codeBlock.code }}
  {% endfor %}
  
  /// 字段定义及其 getter/setter
  {% for field in fields %}
  late {{ field.type }}{% if field.typeIsNull %}?{% endif %} _\${{ field.keyName }};
  
  {{ field.type }}{% if field.typeIsNull %}?{% endif %} get _{{ field.keyName }} => _\${{ field.keyName }};
  
  set _{{ field.keyName }}({{ field.type }}{% if field.typeIsNull %}?{% endif %} value) {
    if(_\${{ field.keyName }} == value) {
      return;
    }
    _\${{ field.keyName }} = value;
    _updateValue("{{ field.keyName }}",{{ field.type }}, value);
  }
  {% endfor %}
  
  /// 读取所有配置项的值并通知变更
  void _read() {
    {% for field in fields %}
    _\${{ field.keyName }} = _ConfigProxy.hasValue("{{ field.keyName }}")
        ? _ConfigProxy.getValue("{{ field.keyName }}", {{ field.type }})
        : {{ field.defaultValue }};
    _noticeValueUpdate("{{ field.keyName }}", {{ field.type }}, _\${{ field.keyName }});
    {% endfor %}
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
    {% for update in valueUpdates %}
    if(key == "{{ update.keyName }}") {
      {{ update.valueUpdateListener }}
    }
    {% endfor %}

    {% for listener in otherMethodListeners %}
    {{ listener.code }}
    {% endfor %}
  }
  
  /// 生成的方法拦截器实现
  {% for method in interceptMethods %}
  {{ method.type }}{% if method.typeIsNull %}?{% endif %} _{{ method.name }}_intercept(
    {% for param in method.methodParams %}
    {{ param.type }}{% if param.typeIsNull %}?{% endif %} {{ param.name }}{% if not loop.last %},{% endif %}
    {% endfor %}
  ) {
    {{ method.methodBody }}
  }
  {% endfor %}
  
  /// 生成的 set 方法实现
  {% for method in setMethods %}
  @override
  set {{ method.name }}({{ method.type }}{% if method.typeIsNull %}?{% endif %} value) {
    {% if method.isIntercept %}
    _{{ method.keyName }} = _{{ method.interceptName }}_intercept(value);
    {% else %}
    _{{ method.keyName }} = value;
    {% endif %}
  }
  {% endfor %}
  
  /// 生成的 get 方法实现
  {% for method in getMethods %}
  @override
  {{ method.type }}{% if method.typeIsNull %}?{% endif %} get {{ method.name }} {
    {% if method.isIntercept %}
    return _{{ method.interceptName }}_intercept(_{{ method.keyName }});
    {% else %}
    return _{{ method.keyName }};
    {% endif %}
  }
  {% endfor %}
  
  /// 生成的其他方法实现
  {% for method in otherMethods %}
  @override
  {{ method.type }}{% if method.typeIsNull %}?{% endif %} {{ method.name }}(
    {% for param in method.methodParams %}
    {{ param.type }}{% if param.typeIsNull %}?{% endif %} {{ param.name }}{% if not loop.last %},{% endif %}
    {% endfor %}
  ) {% if method.isAsync %}async{% endif %} {
    {{ method.methodBody }}
  }
  {% endfor %}

  /// 单例实例
  static final {{className}} _instance = _{{className}}Impl();

}

/// 获取单例实例的方法
{{className}} _\$Get{{className}}() =>  _{{className}}Impl._instance;

/// 扩展方法，用于初始化配置
extension {{className}}Extension on {{className}} {
  Future<void> init{{className}}() async {
    await (this as _{{className}}Impl).init();
  }
}

''';
