## 0.0.2

* 升级了依赖库：将 analyzer 从 7.5.4 升级到 8.1.1
* 修复了 API 兼容性问题：
  - 将 `methodElement.isAsynchronous` 替换为 `methodElement.firstFragment.isAsynchronous`
  - 将 `methodElement.parameters` 替换为 `methodElement.formalParameters`
  - 更新了 TypeChecker 的使用方式
* 优化了代码生成逻辑和错误处理
* 改进了文档和示例代码

## 0.0.1

* 初始版本发布
* 实现了核心功能：
  - 注解式配置项声明
  - 自动代码生成
  - 配置持久化
  - 配置变更通知
* 支持多种数据类型：字符串、布尔值、数字等
* 设计了可扩展的存储后端接口
* 提供了示例代码和详细文档
