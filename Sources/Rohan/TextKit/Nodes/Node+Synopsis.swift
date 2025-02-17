// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
  final func prettyPrint() -> String {
    func eval(_ node: Node) -> String? {
      guard let textNode = node as? TextNode else { return nil }
      return "\"\(textNode.getString())\""
    }
    return accept(PrettyPrintVisitor(eval), ()).joined(separator: "\n")
  }

  final func layoutLengthSynopsis() -> String {
    accept(PrettyPrintVisitor(\.layoutLength.description), ()).joined(separator: "\n")
  }
}

private final class PrettyPrintVisitor: NodeVisitor<Array<String>, Void> {
  private let eval: (Node) -> String?

  init(_ eval: @escaping (Node) -> String?) {
    self.eval = eval
  }

  private func header(_ node: Node, _ customName: String? = nil) -> String {
    let name = customName ?? "\(node.nodeType)"
    let value = eval(node)
    return value != nil ? "\(name) \(value!)" : name
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
}
