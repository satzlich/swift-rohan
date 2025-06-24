// Copyright 2024-2025 Lie Yan

enum StringReconciler {
  @inline(__always)
  static func skip<C: LayoutContext>(current: String, context: C) -> Int {
    context.skipForward(current.length)
    return current.length
  }

  /// Insert newline according to the state of `new`.
  /// - Parameters:
  ///   - container: the node containing the `new` variable.
  @inline(__always)
  static func insert<C: LayoutContext>(new: String, context: C, _ container: Node) -> Int
  {
    context.insertTextForward(new, container)
    return new.length
  }

  /// Reconcile newline according to the state change described by `dirty`.
  /// - Parameters:
  ///   - container: the node containing the `old` and `new` variables.
  @inline(__always)
  static func reconcile<C: LayoutContext>(
    dirty: (old: String, new: String), context: C, _ container: Node
  ) -> Int {
    let (old, new) = dirty

    if old == new {
      context.skipForward(old.length)
    }
    else {
      context.deleteForward(old.length)
      context.insertTextForward(new, container)
    }
    return new.length
  }

  @inline(__always)
  static func delete<C: LayoutContext>(old: String, context: C) {
    context.deleteForward(old.length)
  }
}
