// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  /// Compute the layout offset of the given path within subtree.
  /// - Returns: The layout offset of the path within subtree. Or nil if the path
  ///     is invalid.
  /// - Warning: It is required that every node obtained along path be in
  ///     __the same layout context__ as subtree and further more be __non-pivotal__.
  ///     Otherwise, the result is undefined.
  static func computeLayoutOffset(
    for path: ArraySlice<RohanIndex>, _ subtree: Node
  ) -> Int? {
    precondition(!path.isEmpty)
    var s = 0
    var node: Node = subtree
    for index in path.dropLast() {
      guard let n = node.getLayoutOffset(index),
        let child = node.getChild(index),
        // ensure non-piovtal node
        !child.isPivotal
      else { return nil }
      s += n
      node = child
    }
    guard let n = node.getLayoutOffset(path.last!) else { return nil }
    s += n
    return s
  }
}
