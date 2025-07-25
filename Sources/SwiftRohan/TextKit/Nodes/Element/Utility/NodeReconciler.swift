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
  ///   - atBlockEdge: True if the context cursor is at the start of the block.
  @inline(__always)
  static func insertForward(
    new: Node, context: some LayoutContext, atBlockEdge: Bool
  ) -> Int {
    new.performLayout(context, fromScratch: true, atBlockEdge: atBlockEdge)
  }

  /// Reconciles a dirty node in the layout context.
  /// - Parameters:
  ///   - dirty: The dirty node to be reconciled.
  ///   - context: The layout context where the node should be reconciled.
  ///   - atBlockEdge: True if the context cursor is at the start of the block.
  @inline(__always)
  static func reconcileForward(
    dirty: Node, context: some LayoutContext, atBlockEdge: Bool
  ) -> Int {
    dirty.performLayout(context, fromScratch: false, atBlockEdge: atBlockEdge)
  }

  @inline(__always)
  static func deleteForward(old: Int, context: some LayoutContext) {
    context.deleteForward(old)
  }
}
