// Copyright 2024-2025 Lie Yan

import Foundation

enum NodePolicy {
  // MARK: - Node Type

  static func isTransparent(_ nodeType: NodeType) -> Bool {
    [.paragraph, .text].contains(nodeType)
  }

  static func isPivotal(_ nodeType: NodeType) -> Bool {
    [.apply, .equation, .fraction].contains(nodeType)
  }

  /** Returns true if a node of given kind can be a top-level node in a document. */
  static func isTopLevel(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  /// Returns true if every kind of contents that can be inserted into ParagraphNode
  /// can also be inserted into given node kind.
  static func isParagraphLike(_ nodeType: NodeType) -> Bool {
    [.paragraph].contains(nodeType)
  }

  /// Returns true if a node of given kind can be used as paragraph container,
  /// either a paragraph container or a top-level container.
  static func isParagraphContainerLike(_ nodeType: NodeType) -> Bool {
    [.root].contains(nodeType)
  }

  static func isVoidableElement(_ nodeType: NodeType) -> Bool {
    // so far every element node is voidable
    true
  }

  /// Returns true if two top-level nodes can be merged.
  static func isMergeable(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    precondition(isTopLevel(lhs) && isTopLevel(rhs))
    switch lhs {
    case .paragraph:
      return rhs == .paragraph
    default:
      return false
    }
  }

  // MARK: - MathList Content

  /** Returns true if it can be determined from the type of a node that the node
   can be inserted into inline math. */
  static func isMathListContent(_ nodeType: NodeType) -> Bool {
    [
      // Math
      .fraction, .matrix, .scripts, .textMode,
      // Misc
      .text, .unknown,
    ].contains(nodeType)
  }

  /** Returns true if a node of given kind can appear in math list only. */
  static func isMathListOnlyContent(_ nodeType: NodeType) -> Bool {
    [
      // Math
      .fraction, .matrix, .scripts, .textMode,
    ].contains(nodeType)
  }

  /// Content container cateogry of node type, or nil if determined by contextual nodes.
  static func contentContainerCategory(of nodeType: NodeType) -> ContentContainerCategory?
  {
    CONTENT_CONTAINER_CATEGORY[nodeType]
  }
}

/// Map from node type to content container category, or nil if determined by
/// contextual nodes.
private let CONTENT_CONTAINER_CATEGORY: [NodeType: ContentContainerCategory] = [
  // Template
  // .apply: .none,
  // .argument: .none,
  // .variable: .none,

  // Element
  // .content: .none,
  .emphasis: .plainTextContainer,
  .heading: .inlineTextContainer,
  // .paragraph: .none,
  .root: .topLevelContainer,
  .textMode: .inlineTextContainer,

  // Math
  .equation: .mathList,
  .fraction: .mathList,
  // .matrix: ??
  .scripts: .mathList,

  // Misc
  .linebreak: .plainTextContainer,  // inapplicable actually
  // .text: .none,
  .unknown: .plainTextContainer,  // inapplicable actually
]
