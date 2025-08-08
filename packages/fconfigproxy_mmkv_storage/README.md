# fconfigproxy_mmkv_storage

fconfigproxy 的 MMKV 存储实现插件。提供基于 MMKV 高性能键值存储的配置持久化功能。

## 功能
- 使用 MMKV 存储配置项，性能优异
- 支持字符串、布尔值、数字等多种类型
- 自动创建和管理存储实例


## 集成
在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  fconfigproxy_mmkv_storage:
    path: ../packages/fconfigproxy_mmkv_storage/
  mmkv: ^2.2.2
```

## 注意事项
- 相关配置参考MMKV文档
- 支持 Android、iOS

