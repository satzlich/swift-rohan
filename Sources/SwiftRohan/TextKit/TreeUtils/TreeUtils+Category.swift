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
    else if counts.total == counts.textNodes {
      return .plaintext
    }
    else if counts.total == counts.universalTextCompatible {
      return .universalText
    }
    else if counts.total == counts.textTextCompatible {
      return .textText
    }
    else if counts.total == counts.extendedTextCompatible {
      return .extendedText
    }
    else if counts.total == counts.inlineContentCompatible {
      return .inlineContent
    }
    else if counts.total == counts.containsBlockCompatible,
      counts.topLevelNodes == 0
    {
      return .containsBlock
    }
    else if counts.total == counts.paragraphNodes {
      return .paragraphNodes
    }
    else if counts.total == counts.topLevelNodes {
      return .topLevelNodes
    }
    else if counts.total == counts.mathContentCompatible {
      return .mathContent
    }
    return nil
  }

  private struct CountSummary {
    var total: Int
    /// plaintext
    var textNodes: Int
    /// plaintext + universal symbols
    var universalSymbols: Int
    /// plaintext + universal symbols + text symbols
    var textText: Int
    /// EquationNode where subtype=inline.
    var inlineMath: Int
    /// inline conetnt other than inline-math.
    var inlineOther: Int
    /// isBlock = true
    var blockNodes: Int
    /// paragraph node
    var paragraphNodes: Int
    /// top level node
    var topLevelNodes: Int
    /// math-list only node
    var mathOnlyNodes: Int

    static let zero: CountSummary = .init(
      total: 0, textNodes: 0, universalSymbols: 0, textText: 0, inlineMath: 0,
      inlineOther: 0, blockNodes: 0, paragraphNodes: 0, topLevelNodes: 0,
      mathOnlyNodes: 0)

    var universalTextCompatible: Int { textNodes + universalSymbols }
    var textTextCompatible: Int { universalTextCompatible + textText }
    var extendedTextCompatible: Int { textTextCompatible + inlineMath }
    var inlineContentCompatible: Int { extendedTextCompatible + inlineOther }
    var containsBlockCompatible: Int { inlineContentCompatible + blockNodes }
    var mathContentCompatible: Int { universalTextCompatible + mathOnlyNodes }
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

    case let contentNode as ContentNode:
      performCount(&summary, contentNode.getChildren_readonly())

    default:
      summary.total += 1

      if isTextNode(node) {
        summary.textNodes += 1
        return
      }
      else if isUniversalSymbol(node) {
        summary.universalSymbols += 1
        return
      }
      else if isTextSymbol(node) {
        summary.textText += 1
        return
      }

      if NodePolicy.isInlineMath(node) {
        summary.inlineMath += 1
      }
      else if NodePolicy.isInlineOther(node) {
        summary.inlineOther += 1
      }

      if node.isBlock { summary.blockNodes += 1 }
      if isParagraphNode(node) { summary.paragraphNodes += 1 }
      if NodePolicy.canBeTopLevel(node) { summary.topLevelNodes += 1 }
      if NodePolicy.isMathOnlyContent(node) { summary.mathOnlyNodes += 1 }
    }

    func isUniversalSymbol(_ node: Node) -> Bool {
      (node as? NamedSymbolNode)?.namedSymbol.subtype == .universal
    }
    func isTextSymbol(_ node: Node) -> Bool {
      (node as? NamedSymbolNode)?.namedSymbol.subtype == .text
    }
  }

  /// Returns the (most restricting) content category of the expression list.
  /// Or nil if the nodes are inconsistent so cannot be used as content.
  static func contentCategory(of exprs: [Expr]) -> ContentCategory? {
    let nodes = NodeUtils.convertExprs(exprs)
    return contentCategory(of: nodes)
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
