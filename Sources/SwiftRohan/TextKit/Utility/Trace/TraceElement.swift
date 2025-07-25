struct TraceElement {
  let node: Node
  let index: RohanIndex

  init(_ node: Node, _ index: RohanIndex) {
    self.node = node
    self.index = index
  }

  /// Replace the index of the element with the given index.
  ///
  /// - Precondition: `index` is of the same type as `self.index`
  func with(index: RohanIndex) -> TraceElement {
    precondition(index.isSameType(as: self.index))
    return TraceElement(node, index)
  }

  @inline(__always) func getChild() -> Node? { node.getChild(index) }

  @inline(__always) var asTuple: (Node, RohanIndex) { (node, index) }
}
