// Copyright 2024-2025 Lie Yan

struct TraceElement {
  let node: Node
  let index: RohanIndex

  init(_ node: Node, _ index: RohanIndex) {
    self.node = node
    self.index = index
  }

  func with(index: RohanIndex) -> TraceElement {
    TraceElement(node, index)
  }

  func getChild() -> Node? {
    node.getChild(index)
  }
}
