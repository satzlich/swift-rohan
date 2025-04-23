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

  override func visit(equation: EquationNode, _ context: Void) -> Array<String> {
    let nucleus = {
      let nucleus = equation.nucleus.accept(self, context)
      return description(of: equation.nucleus, "nucleus") + nucleus.dropFirst()
    }()
    return PrintUtils.compose(description(of: equation), [nucleus])
  }

  override func visit(fraction: FractionNode, _ context: Void) -> Array<String> {
    let numerator = {
      let numerator = fraction.numerator.accept(self, context)
      return description(of: fraction.numerator, "\(MathIndex.num)")
        + numerator.dropFirst()
    }()
    let denominator = {
      let denominator = fraction.denominator.accept(self, context)
      return description(of: fraction.denominator, "\(MathIndex.denominator)")
        + denominator.dropFirst()
    }()
    return PrintUtils.compose(description(of: fraction), [numerator, denominator])
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
