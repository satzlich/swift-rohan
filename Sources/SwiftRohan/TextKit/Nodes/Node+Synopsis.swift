// Copyright 2024-2025 Lie Yan

import Foundation

private func extractText(_ node: Node) -> String? {
  guard let textNode = node as? TextNode else { return nil }
  return "\"\(textNode.string)\""
}

extension Node {
  final func prettyPrint() -> String {
    let visitor = PrettyPrintVisitor(extractText)
    return accept(visitor, ()).joined(separator: "\n")
  }

  final func debugPrint() -> String {
    let visitor = PrettyPrintVisitor(extractText, showId: true, showSnapshot: true)
    return accept(visitor, ()).joined(separator: "\n")
  }

  final func layoutLengthSynopsis() -> String {
    let visitor = PrettyPrintVisitor({ node in "\(node.layoutLength())" })
    return accept(visitor, ()).joined(separator: "\n")
  }
}

private final class PrettyPrintVisitor: NodeVisitor<Array<String>, Void> {
  private let eval: (Node) -> String?
  private let showId: Bool
  private let showSnapshot: Bool

  init(
    _ eval: @escaping (Node) -> String?,
    showId: Bool = false,
    showSnapshot: Bool = false
  ) {
    self.eval = eval
    self.showId = showId
    self.showSnapshot = showSnapshot
  }

  private func description(of node: Node, _ name: String? = nil) -> Array<String> {
    var result = [String]()

    let first: String = {
      var fields = [String]()
      // add node id
      if showId && !isRootNode(node) { fields.append("(\(node.id))") }
      // add node name
      let name = name ?? "\(node.type)"
      fields.append(name)
      // add node value
      if let value = eval(node) { fields.append(value) }
      return fields.joined(separator: " ")
    }()
    result.append(first)

    if showSnapshot, let elementNode = node as? ElementNode {
      let snapshotRecords = elementNode.snapshotDescription()
      let description = snapshotRecords.map { $0.joined(separator: ", ") } ?? "nil"
      result.append("snapshot: \(description)")
    }

    return result
  }

  override func visitNode(_ node: Node, _ context: Void) -> Array<String> {
    switch node {
    case let element as ElementNode:
      // compute children
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      return PrintUtils.compose(description(of: node), children)

    case let mathNode as MathNode:
      return _visitMathNode(mathNode, context)

    case let node as ArrayNode:
      return _visitGridNode(node, context)

    default:
      return description(of: node)
    }
  }

  // MARK: - Math

  override func visit(
    mathExpression: MathExpressionNode, _ context: Void
  ) -> Array<String> {
    let name = "\(mathExpression.type) \(mathExpression.mathExpression.command)"
    let description = description(of: mathExpression, name)
    return PrintUtils.compose(description, [])
  }

  override func visit(mathOperator: MathOperatorNode, _ context: Void) -> Array<String> {
    let name = "\(mathOperator.type) \(mathOperator.mathOperator.command)"
    let description = description(of: mathOperator, name)
    return PrintUtils.compose(description, [])
  }

  override func visit(namedSymbol: NamedSymbolNode, _ context: Void) -> Array<String> {
    let name = "\(namedSymbol.type) \(namedSymbol.namedSymbol.command)"
    let description = description(of: namedSymbol, name)
    return PrintUtils.compose(description, [])
  }

  private func _visitMathNode(_ node: MathNode, _ context: Void) -> Array<String> {
    let components = node.enumerateComponents().map { index, component in
      self._visitComponent(component, context, "\(index)")
    }
    let description = description(of: node)
    return PrintUtils.compose(description, components)
  }

  private func _visitComponent(
    _ content: ContentNode, _ context: Void, _ name: String
  ) -> Array<String> {
    let contentSynopsis = content.accept(self, context)
    let description = description(of: content, name)
    return description + contentSynopsis.dropFirst()
  }

  private func _visitGridNode(_ node: ArrayNode, _ context: Void) -> Array<String> {
    let rows = (0..<node.rowCount).map { i in
      _visitRow(node.getRow(at: i), i, context)
    }
    let description = description(of: node)
    return PrintUtils.compose(description, rows)
  }

  private final func _visitRow(
    _ row: MatrixNode.Row, _ i: Int, _ context: Void
  ) -> Array<String> {
    let elements = row.enumerated().map { _visitComponent($1, context, "#\($0)") }
    return PrintUtils.compose(["row \(i)"], elements)
  }

  // MARK: - Template

  override func visit(apply: ApplyNode, _ context: Void) -> Array<String> {
    // description for the node
    let name = "template(\(apply.template.name))"
    let description = description(of: apply, name)
    // arguments
    let arguments = (0..<apply.argumentCount)
      .map { i in apply.getArgument(i).accept(self, context) }
    // content
    let content = apply.getContent().accept(self, context)
    return PrintUtils.compose(description, arguments + [content])
  }

  override func visit(argument: ArgumentNode, _ context: Void) -> Array<String> {
    let n = argument.variableNodes.count
    let name = "argument #\(argument.argumentIndex) (x\(n))"
    return description(of: argument, name)
  }

  override func visit(variable: VariableNode, _ context: Void) -> Array<String> {
    var result = visitNode(variable, context)

    let name = "variable #\(variable.argumentIndex)"

    let desc = description(of: variable, name)
    result.replaceSubrange(0..<desc.count, with: desc)

    return result
  }
}
