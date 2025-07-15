// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  /// Compute the visual delimiter range for a location in the tree and also
  /// the nested level of the node that needs visual delimiter.
  static func visualDelimiterRange(
    for location: TextLocation, _ tree: RootNode, _ styleSheet: StyleSheet
  ) -> (RhTextRange, level: Int)? {
    guard let trace = Trace.from(location, tree) else { return nil }

    // find the last non-transparent node
    let i = trace.lastIndex(where: { $0.node.isTransparent == false })
    guard let i else { return nil }

    // check if the node needs visual delimiter
    let node = trace[i].node
    guard NodePolicy.needsVisualDelimiter(node) else { return nil }

    // take prefix
    let prefix = trace[0..<i].map(\.index)

    switch node {
    case let element as ElementNode:
      let end = element.childCount
      guard end > 0,
        let range = RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end)),
        let level = element.resolveValue(InternalProperty.nestedLevel, styleSheet)
          .integer()
      else { return nil }
      return (range, level)

    case let argument as ArgumentNode:
      let end = argument.childCount
      let key = InternalProperty.nestedLevel
      guard end > 0,
        let range = RhTextRange(TextLocation(prefix, 0), TextLocation(prefix, end)),
        let variableNode = argument.variableNodes.first,
        let level = variableNode.resolveValue(key, styleSheet).integer()
      else { return nil }
      return (range, level)

    default:
      return nil
    }
  }
}
