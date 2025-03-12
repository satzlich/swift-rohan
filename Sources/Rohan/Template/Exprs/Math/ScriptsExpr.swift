// Copyright 2024-2025 Lie Yan

final class ScriptsExpr: Expr {
  class override var type: ExprType { .scripts }

  let subScript: ContentExpr?
  let superScript: ContentExpr?

  convenience init(subScript: [Expr]? = nil, superScript: [Expr]? = nil) {
    self.init(
      subScript: subScript.map(ContentExpr.init),
      superScript: superScript.map(ContentExpr.init))
  }

  init(subScript: ContentExpr? = nil, superScript: ContentExpr? = nil) {
    precondition(subScript != nil || superScript != nil)
    self.subScript = subScript
    self.superScript = superScript
    super.init()
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

  // MARK: - Codable

  private enum CodingKeys:  CodingKey {
    case subScript
    case superScript
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subScript = try container.decodeIfPresent(ContentExpr.self, forKey: .subScript)
    superScript = try container.decodeIfPresent(ContentExpr.self, forKey: .superScript)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(subScript, forKey: .subScript)
    try container.encodeIfPresent(superScript, forKey: .superScript)
    try super.encode(to: encoder)
  }
}
