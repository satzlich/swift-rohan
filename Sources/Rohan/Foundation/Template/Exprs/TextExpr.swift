// Copyright 2024-2025 Lie Yan

import _RopeModule

final class TextExpr: Expr {
  override class var type: ExprType { .text }

  let string: BigString

  init(_ string: BigString) {
    precondition(Self.validate(string: string))
    self.string = string
    super.init()
  }

  convenience init<S>(_ string: S) where S: StringProtocol {
    self.init(BigString(string))
  }

  static func + (lhs: TextExpr, rhs: TextExpr) -> TextExpr {
    TextExpr(lhs.string + rhs.string)
  }

  static func validate<S>(string: S) -> Bool where S: Sequence, S.Element == Character {
    // contains no new line character except "line separator"
    !string.contains { char in char.isNewline && char != Characters.lineSeparator }
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
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

extension TextExpr {
  static var placeholder: TextExpr { TextExpr(Strings.dottedSquare) }
}
