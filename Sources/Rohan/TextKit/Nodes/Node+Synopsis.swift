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
      return Self.compose(header(node), children)
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
    return Self.compose(header(equation), [nucleus])
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
    return Self.compose(header(fraction), [numerator, denominator])
  }

  /**

     ## Example
     Code:
     ```swift
     let root = "root"
     let children = [
       ["child1"],
       ["child2",
        " └ grandchild1"],
     ]
     compose(root, children).joined(separator: "\n")
     ```
     Output:
     ```
     root
      ├ child1
      └ child2
         └ grandchild1
     ```
     */
  private static func compose(_ root: String, _ children: [Array<String>]) -> Array<String> {
    func convert(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = [" ├ " + printout[0]]
      let rest = printout.dropFirst().map {
        " │ " + $0
      }
      return first + rest
    }
    func convertLast(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = [" └ " + printout[0]]
      let rest = printout.dropFirst().map {
        "   " + $0
      }
      return first + rest
    }
    guard !children.isEmpty else { return [root] }
    let middle = children.dropLast().flatMap(convert(_:))
    let last = convertLast(children.last!)
    return [root] + middle + last
  }
}
