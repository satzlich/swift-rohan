// Copyright 2024-2025 Lie Yan

import Foundation

enum NodePolicy {
  // MARK: - Properties

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
  static func isPivotal(_ nodeType: NodeType) -> Bool {
    [.apply, .equation, .fraction].contains(nodeType)
  }

  /// Returns true if a node of given kind is a block element.
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  /// Returns true if a node of given kind can be used as paragraph container.
  static func isParagraphContainer(_ nodeType: NodeType) -> Bool {
    [.root].contains(nodeType)
  }

  /// Returns true if a node of given kind can be empty.
  static func isVoidableElement(_ nodeType: NodeType) -> Bool { true }

  /// Returns true if cursor is allowed (immediately) in the given node.
  @inline(__always)
  static func isCursorAllowed(in node: Node) -> Bool {
    isElementNode(node) || isTextNode(node) || isArgumentNode(node)
  }

  /// Returns true if a node of given kind needs visual delimiter to indicate
  /// its boundary.
  static func needsVisualDelimiter(_ nodeType: NodeType) -> Bool {
    [.argument, .content, .emphasis, .heading].contains(nodeType)
  }

  // MARK: - Relations

  /// Returns true if a node of given kind can be a top-level node in a document.
  static func canBeTopLevel(_ node: Node) -> Bool {
    [.heading, .paragraph].contains(node.type)
  }

  /// Returns true if two nodes of given kinds are elements that can be merged.
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
  static func isMathListContent(_ nodeType: NodeType) -> Bool {
    [
      // Math
      .fraction, .matrix, .scripts, .textMode,
      // Misc
      .text, .unknown,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind can appear in math list only.
  static func isMathOnlyContent(_ nodeType: NodeType) -> Bool {
    [.fraction, .matrix, .scripts, .textMode].contains(nodeType)
  }

  /// Content container cateogry of given node type, or nil if the value should
  /// be determined from contextual nodes.
  static func containerCategory(of nodeType: NodeType) -> ContainerCategory? {
    switch nodeType {
    // Misc
    case .linebreak, .text, .unknown: return nil
    // Element
    case .content: return nil
    case .emphasis: return .plainTextContainer
    case .heading: return .inlineTextContainer
    case .paragraph: return nil
    case .root: return .topLevelContainer
    // Math
    case .equation, .fraction: return .mathList
    case .matrix: return nil
    case .scripts: return .mathList
    case .textMode: return .inlineTextContainer
    // Template
    case .apply, .argument, .cVariable, .variable: return nil
    }
  }
}
