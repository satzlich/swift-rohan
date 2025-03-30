// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  // MARK: - Content-Container Compatibility

  /// Returns true if content is compatible with container.
  static func isCompatible(
    content: ContentCategory, _ container: ContentContainerCategory
  ) -> Bool {
    switch content {
    case .plaintext:
      return true
    case .inlineContent:
      return [
        .inlineTextContainer, .paragraphContainer, .topLevelContainer,
      ].contains(container)
    case .containsBlock, .paragraphNodes:
      return [.paragraphContainer, .topLevelContainer].contains(container)
    case .topLevelNodes:
      return container == .topLevelContainer
    case .mathListContent:
      return container == .mathList
    }
  }

  // MARK: - Text

  /// Returns the (most restricting) content category of the node list. Or nil
  /// if the nodes are inconsistent so cannot be used as content.
  static func contentCategory(of nodes: [Node]) -> ContentCategory? {
    // check plain text
    if nodes.count == 1 && isTextNode(nodes[0]) {
      return .plaintext
    }

    // collect counts
    let countSummary = nodes.reduce(into: CountSummary.zero) { summary, node in
      if node.isBlock {
        summary.blockNodes += 1
      }
      if isParagraphNode(node) {
        summary.paragraphNodes += 1
      }
      if isTopLevelNode(node) {
        summary.topLevelNodes += 1
      }
      if isMathListOnlyContent(node) {
        summary.mathListOnlyNodes += 1
      }
    }

    if countSummary.mathListOnlyNodes != 0 {
      return .mathListContent
    }
    else if countSummary.blockNodes == 0 {
      return .inlineContent
    }
    else if countSummary.topLevelNodes == 0 {
      return .containsBlock
    }
    else if countSummary.paragraphNodes == nodes.count {
      return .paragraphNodes
    }
    else if countSummary.topLevelNodes == nodes.count {
      return .topLevelNodes
    }

    return nil

    // Helper Structure

    struct CountSummary {
      var blockNodes: Int
      var paragraphNodes: Int
      var topLevelNodes: Int
      var mathListOnlyNodes: Int

      static var zero: CountSummary {
        CountSummary(
          blockNodes: 0, paragraphNodes: 0, topLevelNodes: 0, mathListOnlyNodes: 0)
      }
    }
  }

  /// Returns true if the list of nodes contains math-list-only content.
  private static func containsMathListOnlyContent<S>(_ nodes: S) -> Bool
  where S: Sequence, S.Element == Node {
    nodes.contains {
      isMathListOnlyContent($0)
    }
  }

  /// Returns true if the node can be inserted into math list only.
  private static func isMathListOnlyContent(_ node: Node) -> Bool {
    if NodePolicy.isMathListOnlyContent(node.type) {
      return true
    }
    if let applyNode = node as? ApplyNode {
      return containsMathListOnlyContent(applyNode.getContent().getChildren_readonly())
    }
    return false
  }

  // MARK: - Container Category

  /// Returns category of content container where location is in.
  static func contentContainerCategory(
    for location: TextLocation, _ tree: RootNode
  ) -> ContentContainerCategory? {
    Trace.from(location, tree).flatMap { trace in
      contentContainerCategory(of: trace.last!.node)
    }
  }

  /// Returns the category of content container that the node __is__ or __is in__.
  /// Returns nil if no consistent category can be found.
  static func contentContainerCategory(of node: Node) -> ContentContainerCategory? {
    var node = node
    repeat {
      switch node {
      case let argumentNode as ArgumentNode:
        return argumentNode.getContentContainerCategory()
      case let variableNode as VariableNode:
        if let argumentNode = variableNode.argumentNode {
          return argumentNode.getContentContainerCategory()
        }
      default:
        break
      // FALL THROUGH
      }

      // check by node type
      if let category = NodePolicy.contentContainerCategory(of: node.type) {
        return category
      }
      // if there is parent, go to it
      if let parent = node.parent {
        node = parent
      }
      // otherwise, return nil
      else {
        return nil
      }
    } while true
    assertionFailure("Unreachable")
    return nil
  }
}
