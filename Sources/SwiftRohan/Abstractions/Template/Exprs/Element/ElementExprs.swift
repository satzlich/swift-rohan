// Copyright 2024-2025 Lie Yan

final class RootExpr: ElementExpr {
  override class var type: ExprType { .root }

  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(root: self, context)
  }
}

final class ContentExpr: ElementExpr {
  class override var type: ExprType { .content }

  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(content: self, context)
  }
}

final class EmphasisExpr: ElementExpr {
  class override var type: ExprType { .emphasis }

  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(emphasis: self, context)
  }
}

final class HeadingExpr: ElementExpr {
  class override var type: ExprType { .heading }

  enum Subtype: String, Codable {
    case h1, h2, h3, h4, h5

    init(level: Int) {
      precondition(HeadingExpr.validate(level: level))
      switch level {
      case 1: self = .h1
      case 2: self = .h2
      case 3: self = .h3
      case 4: self = .h4
      case 5: self = .h5
      default: preconditionFailure("Invalid heading level")
      }
    }
  }

  let level: Int
  var subtype: Subtype { Subtype(level: level) }

  init(level: Int, _ expressions: [Expr] = []) {
    precondition(HeadingExpr.validate(level: level))
    self.level = level
    super.init(expressions)
  }

  override func with(children: [Expr]) -> Self {
    Self(level: level, children)
  }

  static func validate(level: Int) -> Bool {
    1...5 ~= level
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(heading: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case level }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    level = try container.decode(Int.self, forKey: .level)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(level, forKey: .level)
    try super.encode(to: encoder)
  }
}

final class ParagraphExpr: ElementExpr {
  class override var type: ExprType { .paragraph }

  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(paragraph: self, context)
  }
}

final class StrongExpr: ElementExpr {
  class override var type: ExprType { .strong }

  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(strong: self, context)
  }
}
