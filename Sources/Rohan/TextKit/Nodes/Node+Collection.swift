// Copyright 2024-2025 Lie Yan

import Foundation

extension Collection<Node> {
  /// Returns the only text node in the collection, if there is exactly one.
  func getOnlyTextNode() -> TextNode? {
    guard count == 1, let node = first as? TextNode else { return nil }
    return node
  }
}
