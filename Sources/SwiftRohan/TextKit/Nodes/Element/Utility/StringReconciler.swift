// Copyright 2024-2025 Lie Yan

enum StringReconciler {

  @inline(__always)
  static func skipForward<C: LayoutContext>(current: String, context: C) -> Int {
    context.skipForward(current.length)
    return current.length
  }

  @inline(__always)
  static func insertForward<C: LayoutContext>(
    new: String, context: C, _ container: Node
  ) -> Int {
    context.insertText(new, container)
    return new.length
  }

  @inline(__always)
  static func reconcileForward<C: LayoutContext>(
    dirty: (old: String, new: String), context: C, _ container: Node
  ) -> Int {
    let (old, new) = dirty

    if old == new {
      context.skipForward(old.length)
    }
    else {
      context.deleteForward(old.length)
      context.insertText(new, container)
    }
    return new.length
  }

  @inline(__always)
  static func deleteForward<C: LayoutContext>(old: String, context: C) {
    context.deleteForward(old.length)
  }
}
