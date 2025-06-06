// Copyright 2024-2025 Lie Yan

/// Common interface for Node and PartialNode.
protocol NodeLike {
  var type: NodeType { get }
  func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R
}

extension Node: NodeLike {}

extension PartialNode: NodeLike {
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

  func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
    switch self {
    case .original(let node):
      return node.accept(visitor, context)
    case .slicedText(let slicedText):
      return slicedText.accept(visitor, context)
    case .slicedElement(let slicedElement):
      return slicedElement.accept(visitor, context)
    }
  }
}

func isParagraphNode<T: NodeLike>(_ node: T) -> Bool {
  node.type == .paragraph
}
