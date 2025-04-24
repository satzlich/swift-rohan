// Copyright 2024-2025 Lie Yan

import Foundation

extension Expr {
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
    ["\(cVariable.type) #\(cVariable.argumentIndex)"]
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

  override func visit(strong: StrongExpr, _ context: Void) -> Array<String> {
    _visitElement(strong, context)
  }

  // MARK: - Math

  override func visit(accent: AccentExpr, _ context: Void) -> Array<String> {
    let description = "\(accent.type)"
    var children: [Array<String>] = []

    children.append(["accent: \(accent.accent)"])

    let nucleus = _visitElement(accent.nucleus, context, ["\(MathIndex.nuc)"])
    children.append(nucleus)

    return PrintUtils.compose([description], children)
  }

  override func visit(attach: AttachExpr, _ context: Void) -> Array<String> {
    let description = "\(attach.type)"
    var children: [Array<String>] = []

    if let lsub = attach.lsub {
      let lsub = _visitElement(lsub, context, ["\(MathIndex.lsub)"])
      children.append(lsub)
    }
    if let lsup = attach.lsup {
      let lsup = _visitElement(lsup, context, ["\(MathIndex.lsup)"])
      children.append(lsup)
    }
    do {
      let nucleus = _visitElement(attach.nucleus, context, ["\(MathIndex.nuc)"])
      children.append(nucleus)
    }
    if let sub = attach.sub {
      let sub = _visitElement(sub, context, ["\(MathIndex.sub)"])
      children.append(sub)
    }
    if let sup = attach.sup {
      let sup = _visitElement(sup, context, ["\(MathIndex.sup)"])
      children.append(sup)
    }
    return PrintUtils.compose([description], children)
  }

  override func visit(equation: EquationExpr, _ context: Void) -> Array<String> {
    let description = "\(equation.type) isBlock: \(equation.isBlock)"
    let nucleus = _visitElement(equation.nucleus, (), ["\(MathIndex.nuc)"])
    return PrintUtils.compose([description], [nucleus])
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> Array<String> {
    let description = "\(fraction.type) isBinomial: \(fraction.isBinomial)"
    let numerator = _visitElement(fraction.numerator, (), ["\(MathIndex.num)"])
    let denominator = _visitElement(fraction.denominator, (), ["\(MathIndex.denom)"])
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

  // MARK: - Text

  override func visit(text: TextExpr, _ context: Void) -> Array<String> {
    let description = "\(text.type) \"\(text.string)\""
    return [description]
  }

  override func visit(unknown: UnknownExpr, _ context: Void) -> Array<String> {
    let description = "\(unknown.type)"
    return [description]
  }
}
