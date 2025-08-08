# fconfigproxy_hive_storage

fconfigproxy 的 Hive 存储实现插件。提供基于 Hive 数据库的配置持久化功能。

## 功能
- 使用 Hive 数据库存储配置项
- 支持字符串、布尔值、数字等多种类型
- 自动创建和管理数据库

## 集成
在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  fconfigproxy_hive_storage:
    path: ../packages/fconfigproxy_hive_storage/
  hive: ^2.2.3
```

## 注意事项
- 相关配置参考Hive文档

