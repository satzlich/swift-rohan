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

  /// Returns the type of the layout produced by a node of given kind.
  @inlinable @inline(__always)
  static func layoutType(_ nodeType: NodeType) -> LayoutType {
    switch nodeType {
    case .heading, .itemList, .parList, .root:
      return .hardBlock
    case .paragraph:
      return .softBlock
    case _:
      return .inline
    }
  }

  /// Returns true if a node of given kind can be a top-level node in a document.
  @inlinable @inline(__always)
  static func canBeToplevelNode(_ node: Node) -> Bool {
    if [NodeType.heading, .paragraph, .parList].contains(node.type) {
      return true
    }
    else if let applyNode = node as? ApplyNode,
      applyNode.getExpansion().childrenReadonly().allSatisfy({ canBeToplevelNode($0) })
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
    ].contains(nodeType)
  }

  @inlinable @inline(__always)
  static func placeholder(for nodeType: NodeType) -> PlaceholderRecord {
    if [.paragraph, .heading].contains(nodeType) {
      PlaceholderRecord("\u{2009}", false)  // use thin space.
    }
    else {
      PlaceholderRecord("⬚", true)
    }
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
  static func needsVisualDelimiter(_ node: Node) -> Bool {
    // NOTE: update `shouldIncreaseLevel(_:)` if this is changed.
    // must be element node or argument node

    if [.content, .heading, .textStyles].contains(node.type) {
      return true
    }
    else if let argumentNode = node as? ArgumentNode,
      !(argumentNode.containerType == .block)
    {
      return true
    }
    else {
      return false
    }
  }

  /// Returns true if a node of given kind should increase the nested level.
  @inlinable @inline(__always)
  static func shouldIncreaseLevel(_ nodeType: NodeType) -> Bool {
    // NOTE: update `needsVisualDelimiter(_:)` if this is changed.
    [
      .apply,  // proxy for `.argument`
      .content,  // this covers most math node
      .expansion,
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

  /// True if a counter segment should be computed from child nodes and be updated
  /// when the node content changes.
  @inlinable @inline(__always)
  static func shouldSynthesiseCounterSegment(_ type: NodeType) -> Bool {
    [
      .content,
      .expansion,
      .itemList,
      .paragraph,
      .parList,
      .root,
      .textStyles,
      .variable,
    ].contains(type)
  }
}
