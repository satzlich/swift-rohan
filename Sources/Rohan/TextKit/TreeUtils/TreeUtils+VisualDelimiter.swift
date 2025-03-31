// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  /// Compute the visual delimiter range for a location in the tree.
  static func visualDelimiterRange(
    for location: TextLocation, _ tree: RootNode
  ) -> RhTextRange? {
    guard let trace = Trace.from(location, tree) else { return nil }

    // find the last non-transparent node
    let i = trace.lastIndex(where: { $0.node.isTransparent == false })
    guard let i else { return nil }

    // check if the node needs visual delimiter
    let node = trace[i].node
    guard NodePolicy.needsVisualDelimiter(node.type) else { return nil }

    // take prefix
    let prefix = trace[0..<i].map(\.index)

    switch node {
    case let element as ElementNode:
      let end = element.childCount
      guard end > 0 else { return nil }
      return RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end))
    case let argument as ArgumentNode:
      let end = argument.childCount
      guard end > 0 else { return nil }
      return RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end))
    default:
      return nil
    }
  }
}
