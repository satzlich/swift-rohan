import DequeModule
import Foundation
import _RopeModule

/// A sliced element is an element with its children replaced with a slice.
struct SlicedElement: Encodable {
  typealias BackStore = Deque<PartialNode>

  /// the source node
  private var _sourceNode: ElementNode
  /// children of the element slice
  private var _children: Deque<PartialNode> = []

  init(for elementNode: ElementNode) {
    _sourceNode = elementNode
  }

  mutating func appendChild(_ child: PartialNode) {
    _children.append(child)
  }

  mutating func prependChild(_ child: PartialNode) {
    _children.prepend(child)
  }

  // MARK: - Clone

  func deepCopy() -> ElementNode {
    let copy = _sourceNode.cloneEmpty()
    let children = _children.map { $0.deepCopy() }
    // insert children with `inStorage: false`
    copy.insertChildren(contentsOf: children, at: 0, inStorage: false)
    return copy
  }

  // MARK: - Encodable

  func encode(to encoder: any Encoder) throws {
    try _sourceNode.encode(to: encoder, withChildren: _children)
  }
}

extension SlicedElement: GenNode {
  var type: NodeType { _sourceNode.type }

  func accept<V, R, C>(_ visitor: V, _ context: C) -> R where V: NodeVisitor<R, C> {
    visitor.visit(slicedElement: self, context)
  }

  /// Visit in the manner of source node with children.
  func visitSourceWithChildren<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    _sourceNode.accept(visitor, context, withChildren: _children)
  }

  var layoutType: LayoutType { _sourceNode.layoutType }
}
