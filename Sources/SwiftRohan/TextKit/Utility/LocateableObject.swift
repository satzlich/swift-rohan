// Copyright 2024-2025 Lie Yan

import Foundation

enum LocateableObject {
  /// String is expected to have length "1".
  case text(String)
  /// Node is expected to be not "TextNode".
  case nonText(Node)

  func nonText() -> Node? {
    switch self {
    case .text:
      return nil
    case .nonText(let node):
      return node
    }
  }
}
