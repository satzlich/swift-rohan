// Copyright 2024-2025 Lie Yan

import Foundation

class RhExpr {  // "Rh" for "Rohan", to avoid name confilict with Foundation.Expression
  class var type: ExprType { preconditionFailure("overriding required") }
  final var type: ExprType { Self.type }

  func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> { preconditionFailure("overriding required") }
}

// MARK: - Template

/** Template calls, for which `Apply` is a shorthand */
final class ApplyExpr: RhExpr {
  override class var type: ExprType { .apply }

  let templateName: TemplateName
  let arguments: [ContentExpr]

  init(_ templateName: TemplateName, arguments: [ContentExpr]) {
    self.templateName = templateName
    self.arguments = arguments
  }

  init(_ templateName: TemplateName, arguments: [Array<RhExpr>] = []) {
    self.templateName = templateName
    self.arguments = arguments.map(ContentExpr.init)
  }

  func with(templateName: TemplateName) -> ApplyExpr {
    ApplyExpr(templateName, arguments: arguments)
  }

  func with(arguments: [ContentExpr]) -> ApplyExpr {
    ApplyExpr(templateName, arguments: arguments)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(apply: self, context)
  }
}

/** Named variable */
final class VariableExpr: RhExpr {
  class override var type: ExprType { .variable }

  let name: Identifier

  init(_ name: Identifier) {
    self.name = name
  }

  init(_ name: String) {
    self.name = Identifier(name)
  }

  func with(name: Identifier) -> VariableExpr {
    VariableExpr(name)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(variable: self, context)
  }
}

final class UnnamedVariableExpr: RhExpr {
  class override var type: ExprType { .unnamedVariable }

  /** index to the referenced __template parameter__ */
  let index: Int

  init(_ index: Int) {
    precondition(Self.validate(index: index))
    self.index = index
  }

  static func validate(index: Int) -> Bool {
    index >= 0
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(unnamedVariable: self, context)
  }
}

// MARK: - Basics

final class TextExpr: RhExpr {
  override class var type: ExprType { .text }

  let string: String

  init(_ string: String) {
    precondition(Self.validate(string: string))
    self.string = string
  }

  static func + (lhs: TextExpr, rhs: TextExpr) -> TextExpr {
    TextExpr(lhs.string + rhs.string)
  }

  static func validate<S>(string: S) -> Bool
  where S: Sequence, S.Element == Character {
    // contains no new line character except "line separator"
    !string.contains(where: { $0.isNewline && $0 != "\u{2028}" })
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(text: self, context)
  }
}

class ElementExpr: RhExpr {
  let expressions: [RhExpr]

  var isEmpty: Bool { expressions.isEmpty }

  init(_ expressions: [RhExpr] = []) {
    self.expressions = expressions
  }

  func with(expressions: [RhExpr]) -> Self {
    preconditionFailure("overriding required")
  }
}

final class ContentExpr: ElementExpr {
  class override var type: ExprType { .content }
  override func with(expressions: [RhExpr]) -> Self {
    Self(expressions)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(content: self, context)
  }
}

final class EmphasisExpr: ElementExpr {
  class override var type: ExprType { .emphasis }
  override func with(expressions: [RhExpr]) -> Self {
    Self(expressions)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(emphasis: self, context)
  }
}

final class HeadingExpr: ElementExpr {
  class override var type: ExprType { .heading }
  let level: Int

  init(level: Int, _ expressions: [RhExpr] = []) {
    precondition(Self.validate(level: level))
    self.level = level
    super.init(expressions)
  }

  func with(level: Int) -> HeadingExpr {
    HeadingExpr(level: level, expressions)
  }

  override func with(expressions: [RhExpr]) -> Self {
    Self(level: level, expressions)
  }

  static func validate(level: Int) -> Bool {
    1...5 ~= level
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(heading: self, context)
  }
}

final class ParagraphExpr: ElementExpr {
  class override var type: ExprType { .paragraph }

  override func with(expressions: [RhExpr]) -> Self {
    Self(expressions)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(paragraph: self, context)
  }
}

// MARK: - Math

final class EquationExpr: RhExpr {
  class override var type: ExprType { .equation }
  let isBlock: Bool
  let nucleus: ContentExpr

  init(isBlock: Bool, nucleus: ContentExpr) {
    self.isBlock = isBlock
    self.nucleus = nucleus
  }

  init(isBlock: Bool, nucleus: [RhExpr] = []) {
    self.isBlock = isBlock
    self.nucleus = ContentExpr(nucleus)
  }

  func with(isBlock: Bool) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nucleus: nucleus)
  }

  func with(nucleus: ContentExpr) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nucleus: nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(equation: self, context)
  }
}

final class FractionExpr: RhExpr {
  class override var type: ExprType { .fraction }
  let numerator: ContentExpr
  let denominator: ContentExpr
  let isBinomial: Bool

  init(numerator: [RhExpr], denominator: [RhExpr], isBinomial: Bool = false) {
    self.numerator = ContentExpr(numerator)
    self.denominator = ContentExpr(denominator)
    self.isBinomial = isBinomial
  }

  init(numerator: ContentExpr, denominator: ContentExpr, isBinomial: Bool) {
    self.numerator = numerator
    self.denominator = denominator
    self.isBinomial = isBinomial
  }

  func with(numerator: ContentExpr) -> FractionExpr {
    FractionExpr(numerator: numerator, denominator: denominator, isBinomial: isBinomial)
  }

  func with(denominator: ContentExpr) -> FractionExpr {
    FractionExpr(numerator: numerator, denominator: denominator, isBinomial: isBinomial)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(fraction: self, context)
  }
}

struct MatrixRow: Sequence {
  let elements: [ContentExpr]

  var isEmpty: Bool { elements.isEmpty }
  var count: Int { elements.count }

  init(_ elements: [[RhExpr]]) {
    self.elements = elements.map(ContentExpr.init)
  }

  init(_ elements: [ContentExpr]) {
    self.elements = elements
  }

  func with(elements: [ContentExpr]) -> MatrixRow {
    MatrixRow(elements)
  }

  func makeIterator() -> IndexingIterator<[ContentExpr]> {
    elements.makeIterator()
  }
}

final class MatrixExpr: RhExpr {
  override class var type: ExprType { .matrix }

  let rows: [MatrixRow]

  init(_ rows: [MatrixRow]) {
    precondition(Self.validate(rows: rows))
    self.rows = rows
  }

  func with(rows: [MatrixRow]) -> MatrixExpr {
    MatrixExpr(rows)
  }

  static func validate(rows: [MatrixRow]) -> Bool {
    // non empty and has the size of the first row
    !rows.isEmpty && !rows[0].isEmpty
      && rows.dropFirst().allSatisfy { row in
        row.count == rows[0].count
      }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }
}

final class ScriptsExpr: RhExpr {
  class override var type: ExprType { .scripts }

  let subScript: ContentExpr?
  let superScript: ContentExpr?

  init(subScript: [RhExpr]? = nil, superScript: [RhExpr]? = nil) {
    precondition(subScript != nil || superScript != nil)
    self.subScript = subScript.map(ContentExpr.init)
    self.superScript = superScript.map(ContentExpr.init)
  }

  init(subScript: ContentExpr? = nil, superScript: ContentExpr? = nil) {
    precondition(subScript != nil || superScript != nil)
    self.subScript = subScript
    self.superScript = superScript
  }

  func with(subScript: ContentExpr?) -> ScriptsExpr {
    ScriptsExpr(subScript: subScript, superScript: superScript)
  }

  func with(superScript: ContentExpr?) -> ScriptsExpr {
    ScriptsExpr(subScript: subScript, superScript: superScript)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(scripts: self, context)
  }
}
