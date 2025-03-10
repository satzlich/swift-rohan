// Copyright 2024-2025 Lie Yan

import Foundation

enum NodePolicy {
  @inline(__always)
  static func isTransparent(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph, .text].contains(nodeType)
  }

  @inline(__always)
  static func isPivotal(_ nodeType: NodeType) -> Bool {
    [.apply, .equation, .fraction].contains(nodeType)
  }

  @inline(__always)
  static func isBlockElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  @inline(__always)
  static func isParagraphLikeElement(_ nodeType: NodeType) -> Bool {
    [.heading, .paragraph].contains(nodeType)
  }

  @inline(__always)
  static func isVoidableElement(_ nodeType: NodeType) -> Bool {
    // so far every element node is voidable
    true
  }
}
