internal struct NodeIdSet: ExpressibleByArrayLiteral {
  typealias ArrayLiteralElement = NodeIdentifier

  private var _components: Array<NodeIdentifier> = []

  init(arrayLiteral elements: ArrayLiteralElement...) {
    _components = elements
  }

  mutating func insert(_ component: NodeIdentifier) {
    _components.append(component)
  }

  func contains(_ component: NodeIdentifier) -> Bool {
    _components.contains(component)
  }

  mutating func removeAll() {
    _components.removeAll()
  }
}
