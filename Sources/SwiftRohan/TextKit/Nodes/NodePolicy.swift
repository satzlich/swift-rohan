// Copyright 2024-2025 Lie Yan

import Foundation

enum NodePolicy {
  // MARK: - Properties

  @inline(__always)
  static func isTransparent(_ nodeType: NodeType) -> Bool {
    [.paragraph, .text].contains(nodeType)
  }

  /// Returns true if tracing nodes from ancestor should stop at a node of given kind.
  ///
  /// - Note: The function returns true when the layout offset used by its parent
  ///     is inapplicable to a node of this kind. There are two cases:
  ///     1) the node introduces a new layout context. Since two layout contexts
  ///       don't share layout offsets, the original layout offset is inapplicable.
  ///     2) the node is ApplyNode. In this case, the layout context remains the
  ///       same, but the layout offset behaviours is peculiar due to the nature
  ///       of ApplyNode, and requires special handling.
  @inline(__always)
  static func isPivotal(_ nodeType: NodeType) -> Bool {
    [.apply, .attach, .equation, .fraction].contains(nodeType)
  }

  /// Returns true if a node of given kind is a block element.
  @inline(__always)
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  /// Returns true if a node of given kind needs a leading ZWSP.
  @inline(__always)
  static func needsLeadingZWSP(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph, .root].contains(nodeType)
  }

  @inline(__always)
  static func isPlaceholderEnabled(_ nodeType: NodeType) -> Bool {
    // must be element node
    [NodeType.content, .emphasis, .heading, .strong, .variable].contains(nodeType)
  }

  /// Returns true if a node is inline.
  @inline(__always)
  static func isInline(_ node: Node) -> Bool {
    [.emphasis, .linebreak, .strong, .unknown].contains(node.type)
      || isEquationNode(node) && !node.isBlock
  }

  /// Returns true if a node of given kind can be used as paragraph container.
  @inline(__always)
  static func isParagraphContainer(_ nodeType: NodeType) -> Bool {
    [.root].contains(nodeType)
  }

  /// Returns true if a node of given kind can be empty.
  @inline(__always)
  static func isVoidableElement(_ nodeType: NodeType) -> Bool { true }

  /// Returns true if cursor is allowed (immediately) in the given node.
  @inline(__always)
  static func isCursorAllowed(in node: Node) -> Bool {
    isElementNode(node) || isTextNode(node) || isArgumentNode(node)
  }

  /// Returns true if a node of given kind needs visual delimiter to indicate
  /// its boundary.
  @inline(__always)
  static func needsVisualDelimiter(_ nodeType: NodeType) -> Bool {
    [.argument, .content, .emphasis, .heading, .strong].contains(nodeType)
  }

  // MARK: - Relations

  /// Returns true if a node of given kind can be a top-level node in a document.
  @inline(__always)
  static func canBeTopLevel(_ node: Node) -> Bool {
    [.heading, .paragraph].contains(node.type)
  }

  /// Returns true if two nodes of given kinds are elements that can be merged.
  @inline(__always)
  static func isMergeableElements(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    switch lhs {
    case .paragraph:
      return rhs == .paragraph
    default:
      return false
    }
  }

  // MARK: - Content Categories

  /// Returns true if it can be determined from the type of a node that the node
  /// can be inserted into math list.
  @inline(__always)
  static func isMathListContent(_ nodeType: NodeType) -> Bool {
    [
      // Math
      .fraction, .matrix, .attach, .textMode,
      // Misc
      .text, .unknown,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind can appear in math list only.
  @inline(__always)
  static func isMathOnlyContent(_ nodeType: NodeType) -> Bool {
    [.fraction, .matrix, .attach, .textMode].contains(nodeType)
  }

  /// Content container cateogry of given node type, or nil if the value should
  /// be determined from contextual nodes.
  static func containerCategory(of nodeType: NodeType) -> ContainerCategory? {
    switch nodeType {
    // Misc
    case .linebreak, .text, .unknown: return nil
    // Element
    case .content: return nil
    case .emphasis: return .textContainer
    case .heading: return .inlineTextContainer
    case .paragraph: return nil
    case .root: return .topLevelContainer
    case .strong: return .textContainer
    // Math
    case .equation, .fraction: return .mathContainer
    case .matrix: return nil
    case .attach: return .mathContainer
    case .textMode: return .inlineTextContainer
    // Template
    case .apply, .argument, .cVariable, .variable: return nil
    }
  }
}
