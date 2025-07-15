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
  @inlinable @inline(__always)
  static func isTransparent(_ nodeType: NodeType) -> Bool {
    [.paragraph, .text].contains(nodeType)
  }

  /// Returns true if a node of given kind is a block element.
  @inlinable @inline(__always)
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [
      .heading,
      .itemList,
      .paragraph,
      .parList,
      .root,
    ].contains(nodeType)
  }

  /// Returns the type of the layout produced by a node of given kind.
  @inlinable @inline(__always)
  static func layoutType(_ nodeType: NodeType) -> LayoutType {
    switch nodeType {
    case .heading, .itemList, .paragraph, .parList, .root:
      return .block
    case _:
      return .inline
    }
  }

  /// Returns true if a node of given kind can be a top-level node in a document.
  @inlinable @inline(__always)
  static func isTopLevelNode(_ node: Node) -> Bool {
    if [NodeType.heading, .paragraph, .parList].contains(node.type) {
      return true
    }
    else if let applyNode = node as? ApplyNode,
      applyNode.getContent().childrenReadonly().allSatisfy({ isTopLevelNode($0) })
    {
      return true
    }
    else {
      return false
    }
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
  @inlinable @inline(__always)
  static func isPivotal(_ nodeType: NodeType) -> Bool {
    [
      .apply,
      // Array
      .matrix,
      .multiline,
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

  @inlinable @inline(__always)
  static func isPlaceholderEnabled(_ nodeType: NodeType) -> Bool {
    // must be element node
    [
      NodeType.content,
      .heading,
      .paragraph,
      .textStyles,
      .variable,
    ]
    .contains(nodeType)
  }

  @inlinable @inline(__always)
  static func placeholder(for nodeType: NodeType) -> Character {
    // ZWSP or dotted square
    nodeType == .paragraph ? "\u{200B}" : "⬚"
  }

  /// Returns true if the node is inline-math.
  @inlinable @inline(__always)
  static func isInlineMath(_ node: Node) -> Bool {
    isEquationNode(node) && node.isBlock == false
  }

  /// Returns true if the node is paragraph content other than inline math compatible.
  @inlinable @inline(__always)
  static func isOtherArbitraryParagraphContent(_ node: Node) -> Bool {
    [
      .linebreak,
      .multiline,  // block, but inline content.
      .textStyles,
      .unknown,
    ].contains(node.type)
      || (isEquationNode(node) && node.isBlock)  // block math
  }

  @inlinable @inline(__always)
  static func isStrictToplevelParagraphContent(_ node: Node) -> Bool {
    .itemList == node.type
  }

  /// Returns true if a node of given kind can be used as a container for
  /// block elements such as heading and paragraph.
  @inlinable @inline(__always)
  static func isBlockContainer(_ nodeType: NodeType) -> Bool {
    [
      .itemList,
      .parList,
      .root,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind can be empty.
  @inlinable @inline(__always)
  static func isVoidableElement(_ nodeType: NodeType) -> Bool { true }

  // MARK: - Cursor and Selection

  /// Returns true if cursor is allowed (immediately) in the given node.
  @inlinable @inline(__always)
  static func isCursorAllowed(in node: Node) -> Bool {
    isElementNode(node) || isTextNode(node) || isArgumentNode(node)
  }

  /// Returns true if a node of given kind needs visual delimiter to indicate
  /// its boundary.
  @inlinable @inline(__always)
  static func needsVisualDelimiter(_ nodeType: NodeType) -> Bool {
    // NOTE: update `shouldIncreaseLevel(_:)` if this is changed.

    // must be element node or argument node
    [
      .argument,
      .content,  // this covers most math node
      .heading,
      .textStyles,
    ].contains(nodeType)
  }

  /// Returns true if a node of given kind should increase the nested level.
  @inlinable @inline(__always)
  static func shouldIncreaseLevel(_ nodeType: NodeType) -> Bool {
    // NOTE: update `needsVisualDelimiter(_:)` if this is changed.
    [
      .apply,  // proxy for `.argument`
      .content,  // this covers most math node
      .heading,
      .textStyles,
    ].contains(nodeType)
  }

  // MARK: - Relations

  /// Returns true if two nodes of given kinds are elements that can be merged.
  @inlinable @inline(__always)
  static func isMergeableElements(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    switch lhs {
    case .paragraph: return rhs == .paragraph
    default: return false
    }
  }

  // MARK: - Content Categories

  /// Returns true if it can be determined from the type of a node that the node
  /// can be inserted into math list.
  @inlinable @inline(__always)
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
      .mathStyles,
      .matrix,
      .namedSymbol,
      .radical,
      .textMode,
      .underOver,
      // Misc
      .text,
      .unknown,
    ].contains(nodeType)
  }

  @inlinable @inline(__always)
  static func isMathOnlyContent(_ node: Node) -> Bool {
    return isMathOnlyContent(node.type) || isMathSymbol(node)

    @inline(__always)
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

  /// True if a counter segment should be computed from child nodes and be updated
  /// when the node content changes.
  @inlinable @inline(__always)
  static func shouldSynthesiseCounterSegment(_ type: NodeType) -> Bool {
    [
      .content,
      .itemList,
      .paragraph,
      .parList,
      .root,
      .textStyles,
      .variable,
    ].contains(type)
  }

  /// Content container cateogry of given node type, or nil if the value should
  /// be determined from contextual nodes.
  static func containerCategory(of nodeType: NodeType) -> ContainerCategory? {
    switch nodeType {
    // Misc
    case .counter: return nil
    case .linebreak: return nil
    case .text: return nil
    case .unknown: return nil

    // Element
    case .content: return nil
    case .heading: return .inlineContentContainer
    case .itemList: return .paragraphContainer
    case .paragraph: return nil
    case .parList: return .paragraphContainer
    case .root: return .topLevelContainer
    case .textStyles: return .extendedTextContainer

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
    case .multiline: return .mathContainer
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
