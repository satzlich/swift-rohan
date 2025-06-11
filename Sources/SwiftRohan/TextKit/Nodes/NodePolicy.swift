// Copyright 2024-2025 Lie Yan

import Foundation

enum NodePolicy {
  // MARK: - Properties

  /// True if reflow for inline math is enabled.
  static let isInlineMathReflowEnabled: Bool = true

  /// Returns true if the node is transparent.
  /// - Note: A characterising property of **transparent node** is: insertion any
  ///     content into the interior of a transparent node can split the node into
  ///     two nodes, with the inserted content in between.
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
    [
      .apply,
      // Array
      .matrix,
      // Math
      .accent,
      .attach,
      .equation,
      .fraction,
      .leftRight,
      .mathAttributes,
      .mathStyles,
      .radical,
      .textMode,
      .underOver,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind is a block element.
  @inline(__always)
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  @inline(__always)
  static func isPlaceholderEnabled(_ nodeType: NodeType) -> Bool {
    // must be element node
    [
      NodeType.content,
      .emphasis,
      .heading,
      .strong,
      .variable,
    ]
    .contains(nodeType)
  }

  /// Returns true if the node is inline-math.
  static func isInlineMath(_ node: Node) -> Bool {
    isEquationNode(node) && node.isBlock == false
  }

  /// Returns true if the node is inline but not inline-math.
  static func isInlineOther(_ node: Node) -> Bool {
    [.emphasis, .linebreak, .strong, .unknown].contains(node.type)
  }

  /// Returns true if a node of given kind can be used as paragraph container.
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
    // NOTE: update `shouldIncreaseLevel(_:)` if this is changed.

    // must be element node or argument node
    [
      .argument,
      .content,  // this covers most math node
      .emphasis,
      .heading,
      .strong,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind should increase the nested level.
  @inline(__always)
  static func shouldIncreaseLevel(_ nodeType: NodeType) -> Bool {
    // NOTE: update `needsVisualDelimiter(_:)` if this is changed.
    [
      .apply,  // proxy for `.argument`
      .content,  // this covers most math node
      .emphasis,
      .heading,
      .strong,
    ].contains(nodeType)
  }

  // MARK: - Relations

  /// Returns true if a node of given kind can be a top-level node in a document.
  @inline(__always)
  static func canBeTopLevel(_ node: Node) -> Bool {
    [.heading, .paragraph].contains(node.type)
      || isEquationNode(node) && node.isBlock
  }

  /// Returns true if two nodes of given kinds are elements that can be merged.
  @inline(__always)
  static func isMergeableElements(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    switch lhs {
    case .paragraph: return rhs == .paragraph
    default: return false
    }
  }

  // MARK: - Content Categories

  /// Returns true if it can be determined from the type of a node that the node
  /// can be inserted into math list.
  @inline(__always)
  static func isMathListContent(_ nodeType: NodeType) -> Bool {
    [
      // Math
      .accent,
      .attach,
      .fraction,
      .leftRight,
      .mathAttributes,
      .mathExpression,
      .mathOperator,
      .namedSymbol,
      .mathStyles,
      .matrix,
      .radical,
      .textMode,
      .underOver,
      // Misc
      .text,
      .unknown,
    ].contains(nodeType)
  }

  static func isMathOnlyContent(_ node: Node) -> Bool {
    return isMathOnlyContent(node.type) || isMathSymbol(node)

    func isMathSymbol(_ node: Node) -> Bool {
      (node as? NamedSymbolNode)?.namedSymbol.subtype == .math
    }
  }

  /// Returns true if a node of given kind can appear in math list only.
  @inline(__always)
  private static func isMathOnlyContent(_ nodeType: NodeType) -> Bool {
    [
      .accent,
      .attach,
      .fraction,
      .leftRight,
      .mathAttributes,
      .mathExpression,
      .mathOperator,
      .mathStyles,
      .matrix,
      .radical,
      .textMode,
      .underOver,
    ].contains(nodeType)
  }

  /// Content container cateogry of given node type, or nil if the value should
  /// be determined from contextual nodes.
  static func containerCategory(of nodeType: NodeType) -> ContainerCategory? {
    switch nodeType {
    // Misc
    case .linebreak: return nil
    case .text: return nil
    case .unknown: return nil

    // Element
    case .content: return nil
    case .emphasis: return .extendedTextContainer
    case .heading: return .inlineContentContainer
    case .paragraph: return nil
    case .root: return .topLevelContainer
    case .strong: return .extendedTextContainer

    // Math
    case .accent: return .mathContainer
    case .attach: return .mathContainer
    case .equation: return .mathContainer
    case .fraction: return .mathContainer
    case .leftRight: return .mathContainer
    case .mathAttributes: return .mathContainer
    case .mathExpression: return nil
    case .mathOperator: return nil
    case .mathStyles: return .mathContainer
    case .matrix: return .mathContainer
    case .namedSymbol: return nil
    case .radical: return .mathContainer
    case .textMode: return .textTextContainer
    case .underOver: return .mathContainer

    // Template
    case .apply: return nil
    case .argument: return nil
    case .cVariable: return nil
    case .variable: return nil
    }
  }
}
