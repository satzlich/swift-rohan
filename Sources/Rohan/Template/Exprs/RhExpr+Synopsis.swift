// Copyright 2024-2025 Lie Yan

import Foundation

extension RhExpr {
  func prettyPrint() -> String {
    let visitor = PrettyPrintVisitor()
    let lines = accept(visitor, ())
    return lines.joined(separator: "\n")
  }
}

private final class PrettyPrintVisitor: ExpressionVisitor<Void, Array<String>> {
  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: Void) -> Array<String> {
    let description = "\(apply.type) \"\(apply.templateName)\""
    let chilren = apply.arguments.map { $0.accept(self, context) }
    return PrintUtils.compose([description], chilren)
  }

  override func visit(variable: VariableExpr, _ context: Void) -> Array<String> {
    let description = "\(variable.type) \"\(variable.name)\""
    return [description]
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: Void) -> Array<String> {
    ["\(cVariable.type) \(cVariable.argumentIndex)"]
  }

  // MARK: - Elements

  private func _visitElement(
    _ element: ElementExpr, _ context: Void, _ description: Array<String>? = nil
  ) -> Array<String> {
    let description = description ?? ["\(element.type)"]
    let children = element.children.map { $0.accept(self, context) }
    return PrintUtils.compose(description, children)
  }

  override func visit(content: ContentExpr, _ context: Void) -> Array<String> {
    _visitElement(content, context)
  }

  override func visit(emphasis: EmphasisExpr, _ context: Void) -> Array<String> {
    _visitElement(emphasis, context)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> Array<String> {
    let description = "\(heading.type) level: \(heading.level)"
    return _visitElement(heading, context, [description])
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> Array<String> {
    _visitElement(paragraph, context)
  }

  // MARK: - Math

  override func visit(equation: EquationExpr, _ context: Void) -> Array<String> {
    let description = "\(equation.type) isBlock: \(equation.isBlock)"
    let nucleus = _visitElement(equation.nucleus, (), ["nucleus"])
    return PrintUtils.compose([description], [nucleus])
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> Array<String> {
    let description = "\(fraction.type) isBinomial: \(fraction.isBinomial)"
    let numerator = _visitElement(fraction.numerator, (), ["numerator"])
    let denominator = _visitElement(fraction.denominator, (), ["denominator"])
    return PrintUtils.compose([description], [numerator, denominator])
  }

  private func _visitMatrixRow(
    _ row: MatrixRow, _ context: Void, _ description: Array<String>?
  ) -> Array<String> {
    let description = description ?? ["row"]
    let children: [Array<String>] = row.elements.map { $0.accept(self, context) }
    return PrintUtils.compose(description, children)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Array<String> {
    let description =
      "\(matrix.type) \(matrix.rows.count)x\(matrix.rows.first?.elements.count ?? 0)"
    let rows: [Array<String>] = matrix.rows.enumerated().map { (i, row) in
      let description = "row \(i)"
      return _visitMatrixRow(row, (), [description])
    }
    return PrintUtils.compose([description], rows)
  }

  override func visit(scripts: ScriptsExpr, _ context: Void) -> Array<String> {
    let description = "scripts"
    var children: [Array<String>] = []
    if let subScript = scripts.subScript {
      children.append(subScript.accept(self, context))
    }
    if let superScript = scripts.superScript {
      children.append(superScript.accept(self, context))
    }
    return PrintUtils.compose([description], children)
  }

  // MARK: - Text

  override func visit(text: TextExpr, _ context: Void) -> Array<String> {
    let description = "\(text.type) \"\(text.string)\""
    return [description]
  }
}
