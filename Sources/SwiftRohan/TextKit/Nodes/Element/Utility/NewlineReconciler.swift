// Copyright 2024-2025 Lie Yan

enum NewlineReconciler {
  @inline(__always)
  static func skip<C: LayoutContext>(currrent: Bool, context: C) -> Int {
    if currrent {
      context.skipBackwards(1)
      return 1
    }
    else {
      return 0
    }
  }

  @inline(__always)
  static func insert<C: LayoutContext>(new: Bool, context: (layout: C, node: Node)) -> Int
  {
    let (layoutContext, contextNode) = context

    if new {
      layoutContext.insertNewline(contextNode)
      return 1
    }
    else {
      return 0
    }
  }

  @inline(__always)
  static func reconcile<C: LayoutContext>(
    dirty: (old: Bool, new: Bool), context: (layout: C, node: Node)
  ) -> Int {
    let (layoutContext, contextNode) = context
    switch dirty {
    case (false, false):
      return 0
    case (false, true):
      layoutContext.insertNewline(contextNode)
      return 1
    case (true, false):
      layoutContext.deleteBackwards(1)
      return 0
    case (true, true):
      layoutContext.skipBackwards(1)
      return 1
    }
  }

  @inline(__always)
  static func delete<C: LayoutContext>(old: Bool, context: C) {
    if old { context.deleteBackwards(1) }
  }
}
