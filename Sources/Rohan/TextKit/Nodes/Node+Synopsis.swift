// Copyright 2024-2025 Lie Yan

import Foundation

extension Node {
  final func prettyPrint() -> String {
    accept(PrettyPrintVisitor(), ()).joined(separator: "\n")
  }

  final func debugPrint() -> String {
    accept(DebugPrintVisitor(), ()).joined(separator: "\n")
  }

  final func layoutLengthSynopsis() -> String {
    accept(NodeTreeVisitor(\.layoutLength), ()).description
  }
}

private enum _Rope<T>: CustomStringConvertible {
  case Leaf(T)
  case Node([_Rope<T>])

  var description: String {
    switch self {
    case let .Leaf(value):
      return "\(value)"
    case let .Node(children):
      let children = children.map(\.description).joined(separator: ", ")
      return "[\(children)]"
    }
  }
}

private final class NodeTreeVisitor<T>: NodeVisitor<Tree<T>, Void> {
  private let eval: (Node) -> T

  init(_ eval: @escaping (Node) -> T) {
    self.eval = eval
  }

  override func visitNode(_ node: Node, _ context: Void) -> Tree<T> {
    if let element = node as? ElementNode {
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      return .Node(eval(element), children)
    }
    else if let math = node as? MathNode {
      let children = math.enumerateComponents()
        .map { $0.content.accept(self, context) }
      return .Node(eval(math), children)
    }
    fatalError("overriding required for \(type(of: node))")
  }

  override func visit(text: TextNode, _ context: Void) -> Tree<T> {
    .Leaf(eval(text))
  }
}

private struct PrettyPrinter {
  private var children: Array<Array<String>>

  var isEmpty: Bool { children.isEmpty }
  var count: Int { children.count }

  init(_ children: Array<Array<String>>) {
    self.children = children
  }

  subscript(index: Int) -> Array<String> {
    children[index]
  }

  func compose(_ root: String) -> Array<String> {
    guard !children.isEmpty else { return [root] }

    let middle = children.dropLast().flatMap(compose(_:))
    let last = composeLast(children.last!)
    return [root] + middle + last
  }

  private func compose(_ printout: Array<String>) -> Array<String> {
    guard !printout.isEmpty else { return [] }
    let first = [" ├ " + printout[0]]
    let rest = printout.dropFirst().map {
      " │ " + $0
    }
    return first + rest
  }

  private func composeLast(_ printout: Array<String>) -> Array<String> {
    guard !printout.isEmpty else { return [] }
    let first = [" └ " + printout[0]]
    let rest = printout.dropFirst().map {
      "   " + $0
    }
    return first + rest
  }
}

private final class PrettyPrintVisitor: NodeVisitor<Array<String>, Void> {
  override func visitNode(_ node: Node, _ context: Void) -> Array<String> {
    if let element = node as? ElementNode {
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      let prettyOutput = PrettyPrinter(children)
      return prettyOutput.compose("\(node.nodeType)")
    }

    fatalError("overriding required for \(type(of: node))")
  }

  override func visit(text: TextNode, _ context: Void) -> Array<String> {
    [
      """
      text "\(text.getString())"
      """
    ]
  }

  override func visit(equation: EquationNode, _ context: Void) -> Array<String> {
    let nucleus = {
      let nucleus = equation.nucleus.accept(self, context)
      return ["nucleus"] + nucleus.dropFirst()
    }()

    let pretty = PrettyPrinter([nucleus])
    return pretty.compose("\(equation.nodeType)")
  }

  override func visit(fraction: FractionNode, _ context: Void) -> Array<String> {
    let numerator = {
      let numerator = fraction.numerator.accept(self, context)
      return ["numerator"] + numerator.dropFirst()
    }()
    let denominator = {
      let denominator = fraction.denominator.accept(self, context)
      return ["denominator"] + denominator.dropFirst()
    }()
    let pretty = PrettyPrinter([numerator, denominator])
    return pretty.compose("\(fraction.nodeType)")
  }
}

private final class DebugPrintVisitor: NodeVisitor<Array<String>, Void> {
  private func header(_ node: Node, _ customName: String? = nil) -> String {
    let name = customName ?? "\(node.nodeType)"
    return "\(name) \(node.layoutLength)"
  }

  override func visitNode(_ node: Node, _ context: Void) -> Array<String> {
    if let element = node as? ElementNode {
      let children = (0..<element.childCount)
        .map { element.getChild($0).accept(self, context) }
      let prettyOutput = PrettyPrinter(children)

      return prettyOutput.compose(header(node))
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

    let pretty = PrettyPrinter([nucleus])
    return pretty.compose(header(equation))
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
    let pretty = PrettyPrinter([numerator, denominator])
    return pretty.compose(header(fraction))
  }
}
