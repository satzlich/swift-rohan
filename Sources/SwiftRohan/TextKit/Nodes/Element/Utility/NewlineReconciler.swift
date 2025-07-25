enum NewlineReconciler {

  @inline(__always)
  static func skipForward<C: LayoutContext>(current: Bool, context: C) -> Int {
    if current {
      context.skipForward(1)
      return 1
    }
    else {
      return 0
    }
  }

  @inline(__always)
  static func insertForward<C: LayoutContext>(
    new: Bool, context: C, _ container: Node
  ) -> Int {
    if new {
      context.insertNewline(container)
      return 1
    }
    else {
      return 0
    }
  }

  @inline(__always)
  static func reconcileForward<C: LayoutContext>(
    dirty: (old: Bool, new: Bool), context: C, _ container: Node
  ) -> Int {
    switch dirty {
    case (false, false):
      return 0
    case (false, true):
      context.insertNewline(container)
      return 1
    case (true, false):
      context.deleteForward(1)
      return 0
    case (true, true):
      context.skipForward(1)
      return 1
    }
  }

  @inline(__always)
  static func deleteForward<C: LayoutContext>(old: Bool, context: C) {
    if old { context.deleteForward(1) }
  }
}
