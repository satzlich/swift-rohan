// Copyright 2024-2025 Lie Yan

/// Common interface for Node and PartialNode.
protocol GenNode {
  var type: NodeType { get }
  func accept<V, R, C>(_ visitor: V, _ context: C) -> R where V: NodeVisitor<R, C>
  var isBlock: Bool { get }
  var layoutType: LayoutType { get }
}

extension Node: GenNode {}

extension PartialNode: GenNode {
  var type: NodeType {
    switch self {
    case .original(let node):
      return node.type
    case .slicedText(let slicedText):
      return slicedText.type
    case .slicedElement(let slicedElement):
      return slicedElement.type
    }
  }

  func accept<V, R, C>(_ visitor: V, _ context: C) -> R where V: NodeVisitor<R, C> {
    switch self {
    case .original(let node):
      return node.accept(visitor, context)
    case .slicedText(let slicedText):
      return slicedText.accept(visitor, context)
    case .slicedElement(let slicedElement):
      return slicedElement.accept(visitor, context)
    }
  }

  var isBlock: Bool {
    switch self {
    case .original(let node):
      return node.isBlock
    case .slicedText(let slicedText):
      return slicedText.isBlock
    case .slicedElement(let slicedElement):
      return slicedElement.isBlock
    }
  }

  var layoutType: LayoutType {
    switch self {
    case .original(let node):
      return node.layoutType
    case .slicedText(let slicedText):
      return slicedText.layoutType
    case .slicedElement(let slicedElement):
      return slicedElement.layoutType
    }
  }
}

func isParagraphNode<T: GenNode>(_ node: T) -> Bool {
  node.type == .paragraph
}
