# fconfigproxy

fconfigproxy 是一个用于 Flutter 的配置代理插件，支持通过注解和代码生成自动实现配置项的本地持久化、变更通知等功能。适用于需要统一管理配置、支持多端同步和扩展存储方式的场景。

## 功能特性

- 支持注解式声明配置项，自动生成配置代理代码
- 支持多种存储实现（如 Hive、MMKV 等），可自定义扩展
- 支持 ValueNotifier 变更通知，便于 UI 自动刷新
- 支持方法/字段拦截，灵活扩展配置行为
- 兼容 Android、iOS、Web、桌面等多平台

## 快速开始

### 1. 添加依赖

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  fconfigproxy:
    path: ../ # 或使用 pub.dev 上的版本

dev_dependencies:
  build_runner: ^2.4.7
  source_gen: ^2.0.0
```

### 2. 声明配置接口

```dart
import 'package:fconfigproxy/annotation/FConfig.dart';

@FConfig('app_config', MyFConfigProxy)
abstract class AppConfig {
  @FConfigKey(keyName: 'user_token')
  String? get userToken;
  set userToken(String? value);

  @FConfigKey(defaultValue: 'false')
  bool get isFirstOpen;
}
```

### 3. 实现存储代理（如 Hive/MMKV）

```dart
class MyFConfigProxy implements FConfigKeyValueHandle {
  // 具体实现见 example/lib/MyFConfigProxy.dart
}
```

### 4. 运行代码生成

在项目根目录执行：

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. 使用配置代理

```dart
final config = _$GetAppConfig();
config.userToken = 'abc123';
print(config.isFirstOpen);
```

## 进阶用法

- 支持 ValueNotifier 监听配置变更
- 支持自定义方法拦截、批量清除等扩展
- 可扩展更多存储后端

## 示例

请参考 `example/` 目录下的完整用法。

## 贡献与反馈

欢迎 issue、PR 及建议！

---

如需详细 API 说明和高级用法，请查阅源码注释或联系作者。

