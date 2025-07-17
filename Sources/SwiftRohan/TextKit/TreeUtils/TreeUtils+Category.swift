// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {
  // MARK: - Content Category

  /// Returns the (most restricting) content category of the node list. Or nil
  /// if the nodes are inconsistent so cannot be used as content.
  static func contentCategory<S: Collection<Node>>(of nodes: S) -> ContentCategory? {
    var counts = CountSummary.zero
    _performCount(&counts, nodes)

    if counts.total == 0 {
      return nil
    }
    // universal
    else if counts.total == counts.textNodes {
      return .plaintext
    }
    else if counts.total == counts.universalTextCompatible {
      return .universalText
    }
    // text layout
    else if counts.total == counts.textTextCompatible {
      return .textText
    }
    else if counts.total == counts.extendedTextCompatible {
      return .extendedText
    }
    else if counts.total == counts.arbitraryParagraphContentCompatible {
      return .arbitraryParagraphContent
    }
    else if counts.total == counts.toplevelParagraphContentCompatible {
      return .toplevelParagraphContent
    }
    else if counts.total == counts.paragraphNodes {
      return .paragraphNodes
    }
    else if counts.total == counts.topLevelNodes {
      return .toplevelNodes
    }
    // math layout
    else if counts.total == counts.mathTextCompatible {
      return .mathText
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
    /// universal symbols
    var universalSymbols: Int

    /// text symbols
    var textSymbols: Int
    /// EquationNode where subtype=inline.
    var inlineMath: Int
    /// paragraph content other than extend-text compatible nodes.
    var otherArbitraryParagraphContent: Int
    /// paragraph content other than arbitrary paragraph content.
    var strictToplevelParagraphContent: Int
    /// paragraph node
    var paragraphNodes: Int
    /// top-level node
    var topLevelNodes: Int

    /// math symbols
    var mathSymbols: Int
    /// math-list only node other than math symbols.
    var otherMathOnly: Int

    static let zero = CountSummary(
      total: 0, textNodes: 0, universalSymbols: 0,
      textSymbols: 0, inlineMath: 0,
      otherArbitraryParagraphContent: 0,
      strictToplevelParagraphContent: 0,
      paragraphNodes: 0, topLevelNodes: 0,
      mathSymbols: 0, otherMathOnly: 0)

    var universalTextCompatible: Int { textNodes + universalSymbols }
    // text layout
    var textTextCompatible: Int { universalTextCompatible + textSymbols }
    var extendedTextCompatible: Int { textTextCompatible + inlineMath }
    var arbitraryParagraphContentCompatible: Int {
      extendedTextCompatible + otherArbitraryParagraphContent
    }
    var toplevelParagraphContentCompatible: Int {
      arbitraryParagraphContentCompatible + strictToplevelParagraphContent
    }
    var topLevelCompatible: Int { toplevelParagraphContentCompatible + topLevelNodes }
    // math layout
    var mathTextCompatible: Int { universalTextCompatible + mathSymbols }
    var mathContentCompatible: Int { mathTextCompatible + otherMathOnly }
  }

  private static func _performCount<C: Collection<Node>>(
    _ summary: inout CountSummary, _ nodes: C
  ) {
    nodes.forEach { node in _performCount(&summary, node) }
  }

  /// Count the number of different kinds of nodes in the tree. For ApplyNode, it
  /// counts the children of its content node.
  private static func _performCount(_ summary: inout CountSummary, _ node: Node) {
    switch node {
    case let applyNode as ApplyNode:
      _performCount(&summary, applyNode.getExpansion().childrenReadonly())

    case let variableNode as VariableNode:
      _performCount(&summary, variableNode.childrenReadonly())

    case let contentNode as ContentNode:
      _performCount(&summary, contentNode.childrenReadonly())

    case let expansionNode as ExpansionNode:
      _performCount(&summary, expansionNode.childrenReadonly())

    default:
      summary.total += 1

      // count those that are close to text material.
      if isTextNode(node) {
        summary.textNodes += 1
        return
      }
      else if let namedSymbolNode = node as? NamedSymbolNode {
        switch namedSymbolNode.namedSymbol.contentMode {
        case .universal:
          summary.universalSymbols += 1
          return
        case .text:
          summary.textSymbols += 1
          return
        case .math:
          summary.mathSymbols += 1
          return
        }
      }
      else if node is CounterNode {
        summary.textSymbols += 1
        return
      }

      if NodePolicy.isInlineMath(node) {
        summary.inlineMath += 1
      }
      else if NodePolicy.isOtherArbitraryParagraphContent(node) {
        summary.otherArbitraryParagraphContent += 1
      }
      else if NodePolicy.isStrictToplevelParagraphContent(node) {
        summary.strictToplevelParagraphContent += 1
      }

      if isParagraphNode(node) { summary.paragraphNodes += 1 }
      if NodePolicy.isTopLevelNode(node) { summary.topLevelNodes += 1 }
      if NodePolicy.isMathOnlyContent(node) { summary.otherMathOnly += 1 }
    }
  }

  /// Returns the (most restricting) content category of the expression list.
  /// Or nil if the nodes are inconsistent so cannot be used as content.
  static func contentCategory(of exprs: Array<Expr>) -> ContentCategory? {
    let nodes: Array<Node> = NodeUtils.convertExprs(exprs)
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
