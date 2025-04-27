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
    let accentChar = ["accent: \(accent.accent)"]
    let nucleus = _visitComponent(accent.nucleus, context, "\(MathIndex.nuc)")
    return PrintUtils.compose(description(of: accent), [accentChar, nucleus])
  }

  override func visit(attach: AttachNode, _ context: Void) -> Array<String> {
    var children: [Array<String>] = []

    attach.lsub.map { lsub in
      children.append(_visitComponent(lsub, context, "\(MathIndex.lsub)"))
    }
    attach.lsup.map { lsup in
      children.append(_visitComponent(lsup, context, "\(MathIndex.lsup)"))
    }

    children.append(_visitComponent(attach.nucleus, context, "\(MathIndex.nuc)"))

    attach.sub.map { sub in
      children.append(_visitComponent(sub, context, "\(MathIndex.sub)"))
    }
    attach.sup.map { sup in
      children.append(_visitComponent(sup, context, "\(MathIndex.sup)"))
    }

    return PrintUtils.compose(description(of: attach), children)
  }
  
  

  override func visit(equation: EquationNode, _ context: Void) -> Array<String> {
    let nucleus = _visitComponent(equation.nucleus, context, "\(MathIndex.nuc)")
    return PrintUtils.compose(description(of: equation), [nucleus])
  }

  override func visit(fraction: FractionNode, _ context: Void) -> Array<String> {
    let numerator = _visitComponent(fraction.numerator, context, "\(MathIndex.num)")
    let denominator = _visitComponent(fraction.denominator, context, "\(MathIndex.denom)")
    return PrintUtils.compose(description(of: fraction), [numerator, denominator])
  }

  override func visit(matrix: TrueMatrixNode, _ context: Void) -> Array<String> {
    let rows = (0..<matrix.rowCount).map { i in visitRow(matrix.getRow(at: i), i) }
    let description = description(of: matrix)
    return PrintUtils.compose(description, rows)

    // Helper

    func visitRow(_ row: TrueMatrixNode.Row, _ i: Int) -> Array<String> {
      let elements = row.enumerated().map { _visitComponent($1, context, "#\($0)") }
      return PrintUtils.compose(["row \(i)"], elements)
    }
  }

  private func _visitComponent(
    _ conent: ContentNode, _ context: Void, _ name: String
  ) -> Array<String> {
    let content = conent.accept(self, context)
    let description = description(of: conent, name)
    return description + content.dropFirst()
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
