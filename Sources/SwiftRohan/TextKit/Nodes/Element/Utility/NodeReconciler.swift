// Copyright 2024-2025 Lie Yan

enum NodeReconciler {
  @inline(__always)
  static func skipForward(current: Node, context: some LayoutContext) -> Int {
    let length = current.layoutLength()
    context.skipForward(length)
    return length
  }

  @inline(__always)
  static func skipForward(current: Int, context: some LayoutContext) -> Int {
    context.skipForward(current)
    return current
  }

  /// Inserts a new node into the layout context.
  /// - Parameters:
  ///   - new: The new node to be inserted.
  ///   - context: The layout context where the node should be inserted.
  ///   - atBlockStart: True if the context cursor is at the start of the block.
  @inline(__always)
  static func insertForward(
    new: Node, context: some LayoutContext, atBlockStart: Bool = false
  ) -> Int {
    new.performLayout(context, fromScratch: true, atBlockStart: atBlockStart)
  }

  /// Reconciles a dirty node in the layout context.
  /// - Parameters:
  ///   - dirty: The dirty node to be reconciled.
  ///   - context: The layout context where the node should be reconciled.
  ///   - atBlockStart: True if the context cursor is at the start of the block.
  @inline(__always)
  static func reconcileForward(
    dirty: Node, context: some LayoutContext, atBlockStart: Bool = false
  ) -> Int {
    dirty.performLayout(context, fromScratch: false, atBlockStart: atBlockStart)
  }

  @inline(__always)
  static func deleteForward(old: Int, context: some LayoutContext) {
    context.deleteForward(old)
  }
}
