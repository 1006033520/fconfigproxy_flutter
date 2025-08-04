/// 提供类似 Kotlin 的作用域函数扩展，便于链式调用和简化对象操作。

/// let 扩展：将当前对象作为参数传递给 block，并返回 block 的结果。
extension Let<T> on T {
  R let<R>(R Function(T) block) {
    return block(this);
  }
}

/// also 扩展：将当前对象作为参数传递给 block，block 返回 void，最后返回自身。
extension Also<T> on T {
  T also(void Function(T) block) {
    block(this);
    return this;
  }
}

/// apply 扩展：将当前对象作为 this 传递给 block，block 返回 void，最后返回自身。
extension Apply<T> on T {
  T apply(void Function(T) block) {
    block(this);
    return this;
  }
}

/// run 扩展：将当前对象作为 this 传递给 block，并返回 block 的结果。
extension Run<T> on T {
  R run<R>(R Function(T) block) {
    return block(this);
  }
}
