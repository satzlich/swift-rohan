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

  /// Returns true if a node of given kind can be a top-level node in a document.
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

  /// Returns true if a node of given kind can be used as paragraph container.
  static func isParagraphContainerLike(_ nodeType: NodeType) -> Bool {
    [.root].contains(nodeType)
  }

  /// Returns true if a node of given kind can be empty.
  static func isVoidableElement(_ nodeType: NodeType) -> Bool { true }

  /// Returns true if a node of given kind needs visual delimiter to indicate
  /// its boundary.
  static func needsVisualDelimiter(_ nodeType: NodeType) -> Bool {
    [.argument, .content, .emphasis, .heading].contains(nodeType)
  }

  /// Returns true if two element nodes can be merged.
  static func isMergeableElements(_ lhs: NodeType, _ rhs: NodeType) -> Bool {
    switch lhs {
    case .paragraph:
      return rhs == .paragraph
    default:
      return false
    }
  }

  // MARK: - MathList Content

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
  static func isMathListOnlyContent(_ nodeType: NodeType) -> Bool {
    [.fraction, .matrix, .scripts, .textMode].contains(nodeType)
  }

  /// Content container cateogry of given node type, or nil if the value should
  /// be determined from contextual nodes.
  static func contentContainerCategory(of nodeType: NodeType) -> ContentContainerCategory?
  {
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
