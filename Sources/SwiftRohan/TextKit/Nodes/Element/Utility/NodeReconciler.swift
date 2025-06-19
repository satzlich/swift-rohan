// Copyright 2024-2025 Lie Yan

enum NodeReconciler {
  @inline(__always)
  static func skip<C: LayoutContext>(current: Node, context: C) -> Int {
    let length = current.layoutLength()
    context.skipBackwards(length)
    return length
  }

  @inline(__always)
  static func skip<C: LayoutContext>(current: Int, context: C) -> Int {
    context.skipBackwards(current)
    return current
  }

  @inline(__always)
  static func insert<C: LayoutContext>(new: Node, context: C) -> Int {
    new.performLayout(context, fromScratch: true)
  }

  @inline(__always)
  static func reconcile<C: LayoutContext>(dirty: Node, context: C) -> Int {
    dirty.performLayout(context, fromScratch: false)
  }

  @inline(__always)
  static func delete<C: LayoutContext>(old: Int, context: C) {
    context.deleteBackwards(old)
  }
}
