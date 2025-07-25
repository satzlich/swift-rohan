import _RopeModule

final class TextExpr: Expr {
  override class var type: ExprType { .text }

  let string: BigString

  init(_ string: BigString) {
    precondition(TextExpr.validate(string: string))
    self.string = string
    super.init()
  }
  
  init<S: Sequence<Character>>(_ string: S) {
    precondition(TextExpr.validate(string: string))
    self.string = BigString(string)
    super.init()
  }

  static func + (lhs: TextExpr, rhs: TextExpr) -> TextExpr {
    TextExpr(lhs.string + rhs.string)
  }

  static func validate<S: Sequence<Character>>(string: S) -> Bool {
    // contains no new line character except "line separator"
    !string.contains { char in char.isNewline && char != "\u{2028}" }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(text: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case string }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    string = try container.decode(BigString.self, forKey: .string)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(string, forKey: .string)
    try super.encode(to: encoder)
  }
}
