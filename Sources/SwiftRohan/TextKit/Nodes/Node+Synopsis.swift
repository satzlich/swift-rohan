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
      let snapshotRecords = elementNode.snapshotRecords.map { $0.map(\.description) }
      let description = snapshotRecords.map { $0.joined(separator: ", ") } ?? "nil"
      result.append("snapshot: \(description)")
    }

    return result
  }

  override func visitNode(_ node: Node, _ context: Void) -> Array<String> {
    if let element = node as? ElementNode {
      // compute children
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      return PrintUtils.compose(description(of: node), children)
    }
    else {
      return description(of: node)
    }
  }

  // MARK: - Math

  override func visit(accent: AccentNode, _ context: Void) -> Array<String> {
    _visitMathNode(accent, context)
  }

  override func visit(attach: AttachNode, _ context: Void) -> Array<String> {
    _visitMathNode(attach, context)
  }

  override func visit(cases: CasesNode, _ context: Void) -> Array<String> {
    let rows = (0..<cases.rowCount).map { i in
      _visitComponent(cases.getElement(i), context, "#\(i)")
    }
    let description = description(of: cases)
    return PrintUtils.compose(description, rows)
  }

  override func visit(equation: EquationNode, _ context: Void) -> Array<String> {
    _visitMathNode(equation, context)
  }

  override func visit(fraction: FractionNode, _ context: Void) -> Array<String> {
    _visitMathNode(fraction, context)
  }

  override func visit(leftRight: LeftRightNode, _ context: Void) -> Array<String> {
    _visitMathNode(leftRight, context)
  }

  override func visit(matrix: MatrixNode, _ context: Void) -> Array<String> {
    let rows = (0..<matrix.rowCount).map { i in visitRow(matrix.getRow(at: i), i) }
    let description = description(of: matrix)
    return PrintUtils.compose(description, rows)

    // Helper

    func visitRow(_ row: MatrixNode.Row, _ i: Int) -> Array<String> {
      let elements = row.enumerated().map { _visitComponent($1, context, "#\($0)") }
      return PrintUtils.compose(["row \(i)"], elements)
    }
  }

  override func visit(overline: OverlineNode, _ context: Void) -> Array<String> {
    _visitMathNode(overline, context)
  }

  override func visit(overspreader: OverspreaderNode, _ context: Void) -> Array<String> {
    _visitMathNode(overspreader, context)
  }

  override func visit(underline: UnderlineNode, _ context: Void) -> Array<String> {
    _visitMathNode(underline, context)
  }

  override func visit(underspreader: UnderspreaderNode, _ context: Void) -> Array<String>
  {
    _visitMathNode(underspreader, context)
  }

  private func _visitComponent(
    _ content: ContentNode, _ context: Void, _ name: String
  ) -> Array<String> {
    let contentSynopsis = content.accept(self, context)
    let description = description(of: content, name)
    return description + contentSynopsis.dropFirst()
  }

  private func _visitMathNode(_ node: MathNode, _ context: Void) -> Array<String> {
    let components = node.enumerateComponents().map { index, component in
      self._visitComponent(component, context, "\(index)")
    }
    let description = description(of: node)
    return PrintUtils.compose(description, components)
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
