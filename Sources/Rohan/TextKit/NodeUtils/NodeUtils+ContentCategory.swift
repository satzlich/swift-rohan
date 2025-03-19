// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  // MARK: - Text

  /** Returns the (most restricting) text content category of the node list.
   Or nil if the nodes cannot be used as text content. */
  static func getTextContentCategory(of nodes: [Node]) -> TextContentCategory? {
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
      if NodePolicy.isTopLevel(node.type) {
        summary.topLevelNodes += 1
      }
      if isMathListOnlyContent(node) {
        summary.mathListOnlyNodes += 1
      }
    }

    // ensure nodes can be used as text content
    guard countSummary.mathListOnlyNodes == 0 else { return nil }

    if countSummary.blockNodes == 0 {
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

  // MARK: - Math

  /** Returns the (most restricting) math content category of the node list.
   Or nil if the nodes cannot be used as math content. */
  static func getMathContentCategory(of nodes: [Node]) -> MathContentCategory? {
    if nodes.count == 1 && isTextNode(nodes[0]) {
      return .plaintext
    }
    else if isMathListCompatible(nodes) {
      return .mathListContent
    }
    else {
      return nil
    }
  }

  /** Returns true if the node list can be content of inline math. */
  private static func isMathListCompatible<S>(_ nodes: S) -> Bool
  where S: Sequence, S.Element == Node {
    nodes.allSatisfy {
      isMathListCompatible($0)
    }
  }

  /** Returns true if the node can be inserted into inline math. */
  private static func isMathListCompatible(_ node: Node) -> Bool {
    if NodePolicy.isMathListContent(node.type) {
      return true
    }
    if let applyNode = node as? ApplyNode {
      return isMathListCompatible(applyNode.getContent().getChildren_readonly())
    }
    return false
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

  /** Returns category of content container where location is in. */
  static func contentContainerCategory(
    for location: TextLocation, _ tree: RootNode
  ) -> ContentContainerCategory? {
    guard let trace = buildTrace(for: location, tree) else { return nil }
    return contentContainerCategory(of: trace.last!.node)
  }

  /** Returns the category of content container that the node is. */
  static func contentContainerCategory(of node: Node) -> ContentContainerCategory? {
    var node = node
    repeat {
      // For ArgumentNode, delegate to the instance.
      if let argumentNode = node as? ArgumentNode {
        return argumentNode.getContentContainerCategory()
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

  // MARK: - Content-Container Compatibility

  /// Returns true if math content is compatible with container.
  static func isCompatible(
    mathContent: MathContentCategory, container: ContentContainerCategory
  ) -> Bool {
    switch (mathContent, container) {
    case (.plaintext, .plainTextContainer), (.plaintext, .mathList):
      return true
    case (.mathListContent, .mathList):
      return true
    default:
      return false
    }
  }

  /// Returns true if text content is compatible with container.
  static func isCompatible(
    textContent: TextContentCategory, container: ContentContainerCategory
  ) -> Bool {
    if container == .mathList { return false }

    switch textContent {
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
    }
  }
}
