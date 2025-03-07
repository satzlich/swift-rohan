// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
  final func prettyPrint() -> String {
    func eval(_ node: Node) -> String? {
      guard let textNode = node as? TextNode else { return nil }
      return "\"\(textNode.bigString)\""
    }
    return accept(PrettyPrintVisitor(eval), ()).joined(separator: "\n")
  }

  final func debugPrint() -> String {
    func eval(_ node: Node) -> String? {
      guard let textNode = node as? TextNode else { return nil }
      return "\"\(textNode.bigString)\""
    }
    return accept(PrettyPrintVisitor(eval, showId: true), ()).joined(separator: "\n")
  }

  final func layoutLengthSynopsis() -> String {
    accept(PrettyPrintVisitor(\.layoutLength.description), ()).joined(separator: "\n")
  }
}

private final class PrettyPrintVisitor: NodeVisitor<Array<String>, Void> {
  private let eval: (Node) -> String?
  private let showId: Bool

  init(_ eval: @escaping (Node) -> String?, showId: Bool = false) {
    self.eval = eval
    self.showId = showId
  }

  private func header(_ node: Node, _ name: String? = nil) -> String {
    var fields = [String]()
    // add node id
    if showId { fields.append("#\(node.id)") }
    // add node name (default to node type)
    let name = name ?? "\(node.nodeType)"
    fields.append(name)
    // add node value
    if let value = eval(node) { fields.append(value) }
    return fields.joined(separator: " ")
  }

  override func visitNode(_ node: Node, _ context: Void) -> Array<String> {
    if let element = node as? ElementNode {
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      return PrintUtils.compose(header(node), children)
    }
    fatalError("overriding required for \(type(of: node))")
  }

  override func visit(text: TextNode, _ context: Void) -> Array<String> {
    [header(text)]
  }

  // MARK: - Math

  override func visit(equation: EquationNode, _ context: Void) -> Array<String> {
    let nucleus = {
      let nucleus = equation.nucleus.accept(self, context)
      return [header(equation.nucleus, "nucleus")] + nucleus.dropFirst()
    }()
    return PrintUtils.compose(header(equation), [nucleus])
  }

  override func visit(fraction: FractionNode, _ context: Void) -> Array<String> {
    let numerator = {
      let numerator = fraction.numerator.accept(self, context)
      return [header(fraction.numerator, "numerator")] + numerator.dropFirst()
    }()
    let denominator = {
      let denominator = fraction.denominator.accept(self, context)
      return [header(fraction.denominator, "denominator")] + denominator.dropFirst()
    }()
    return PrintUtils.compose(header(fraction), [numerator, denominator])
  }

  // MARK: - Template

  override func visit(apply: ApplyNode, _ context: Void) -> Array<String> {
    // create header
    let name = "template(\(apply.template.name))"
    let header = header(apply, name)
    // arguments
    let arguments = (0..<apply.argumentCount).map {
      apply.getArgument($0).accept(self, context)
    }
    // content
    let content = apply.getContent().accept(self, context)
    return PrintUtils.compose(header, arguments + [content])
  }

  override func visit(argument: ArgumentNode, _ context: Void) -> Array<String> {
    let n = argument.variableNodes.count
    let name = "argument #\(argument.argumentIndex) (x\(n))"
    let header = header(argument, name)
    return [header]
  }

  override func visit(variable: VariableNode, _ context: Void) -> Array<String> {
    var result = visitNode(variable, context)

    let name = "variable #\(variable.getArgumentIndex() ?? -1)"
    result[0] = header(variable, name)
    return result
  }
}
