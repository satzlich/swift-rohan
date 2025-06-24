// Copyright 2024-2025 Lie Yan

enum NewlineReconciler {
  @inline(__always)
  static func skip<C: LayoutContext>(current: Bool, context: C) -> Int {
    if current {
      context.skipForward(1)
      return 1
    }
    else {
      return 0
    }
  }

  /// Insert newline according to the state of `new`.
  /// - Parameters:
  ///   - container: the node containing the `new` variable.
  @inline(__always)
  static func insert<C: LayoutContext>(new: Bool, context: C, _ container: Node) -> Int {
    if new {
      context.insertNewlineForward(container)
      return 1
    }
    else {
      return 0
    }
  }

  /// Reconcile newline according to the state change described by `dirty`.
  /// - Parameters:
  ///   - container: the node containing the `old` and `new` variables.
  @inline(__always)
  static func reconcile<C: LayoutContext>(
    dirty: (old: Bool, new: Bool), context: C, _ container: Node
  ) -> Int {
    switch dirty {
    case (false, false):
      return 0
    case (false, true):
      context.insertNewlineForward(container)
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
  static func delete<C: LayoutContext>(old: Bool, context: C) {
    if old { context.deleteForward(1) }
  }
}
