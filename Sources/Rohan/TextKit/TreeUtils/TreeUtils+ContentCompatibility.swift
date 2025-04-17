// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  // MARK: - Content Category

  /// Returns the (most restricting) content category of the node list. Or nil
  /// if the nodes are inconsistent so cannot be used as content.
  static func contentCategory(of nodes: [Node]) -> ContentCategory? {
    var counts = CountSummary.zero
    performCount(&counts, nodes)

    if counts.total == 0 {
      return nil
    }
    else if counts.total == counts.text {
      return .plaintext
    }
    else if counts.strictInline > 0,
      counts.total == counts.strictInline + counts.text
    {
      assert(counts.topLevel == 0)
      return .inlineContent
    }
    else if counts.block > 0,
      counts.total == counts.block + counts.strictInline + counts.text,
      counts.topLevel == 0
    {
      return .containsBlock
    }
    else if counts.total == counts.paragraph {
      return .paragraphNodes
    }
    else if counts.total == counts.topLevel {
      return .topLevelNodes
    }
    else if counts.total == counts.text + counts.mathOnly {
      return .mathListContent
    }
    return nil
  }

  private struct CountSummary {
    var total: Int
    /// text node
    var text: Int
    /// inline but not plain text
    var strictInline: Int
    /// isBlock = true
    var block: Int
    /// paragraph node
    var paragraph: Int
    /// top level node
    var topLevel: Int
    /// math-list only node
    var mathOnly: Int

    static let zero: CountSummary = .init(
      total: 0, text: 0, strictInline: 0, block: 0, paragraph: 0, topLevel: 0,
      mathOnly: 0)
  }

  private static func performCount<C: Collection<Node>>(
    _ summary: inout CountSummary, _ nodes: C
  ) {
    nodes.forEach { node in performCount(&summary, node) }
  }

  /// Count the number of different kinds of nodes in the tree. For ApplyNode, it
  /// counts the children of its content node.
  private static func performCount(_ summary: inout CountSummary, _ node: Node) {
    switch node {
    case let applyNode as ApplyNode:
      performCount(&summary, applyNode.getContent().getChildren_readonly())

    case let variableNode as VariableNode:
      performCount(&summary, variableNode.getChildren_readonly())

    default:
      summary.total += 1

      if isTextNode(node) {
        summary.text += 1
        return
      }

      if NodePolicy.isInlineElement(node.type)
        || isLinebreakNode(node)
        || (isEquationNode(node) && !node.isBlock)
      {
        summary.strictInline += 1
      }
      if node.isBlock { summary.block += 1 }
      if isParagraphNode(node) { summary.paragraph += 1 }
      if NodePolicy.canBeTopLevel(node) { summary.topLevel += 1 }
      if NodePolicy.isMathOnlyContent(node.type) { summary.mathOnly += 1 }
    }
  }

  /// Returns the (most restricting) content category of the expression list.
  /// Or nil if the nodes are inconsistent so cannot be used as content.
  static func contentCategory(of exprs: [Expr]) -> ContentCategory? {
    preconditionFailure("TODO: implement")
  }

  // MARK: - Container Category

  /// Returns category of content container where location is in.
  static func containerCategory(
    for location: TextLocation, _ tree: RootNode
  ) -> ContainerCategory? {
    Trace.from(location, tree).flatMap { trace in
      containerCategory(of: trace.last!.node)
    }
  }

  /// Returns the category of content container that the node __is__ or __is in__.
  /// Returns nil if no consistent category can be found.
  static func containerCategory(of node: Node) -> ContainerCategory? {
    var node = node
    repeat {
      switch node {
      case let argumentNode as ArgumentNode:
        return argumentNode.getContainerCategory()
      case let variableNode as VariableNode:
        if let argumentNode = variableNode.argumentNode {
          return argumentNode.getContainerCategory()
        }
      default:
        break
      // FALL THROUGH
      }

      // check by node type
      if let category = NodePolicy.containerCategory(of: node.type) {
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
