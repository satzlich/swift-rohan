import Foundation

final class MathStylesExpr: MathExpr {
  class override var type: ExprType { .mathStyles }

  let styles: MathStyles
  let nucleus: ContentExpr

  init(_ styles: MathStyles, _ nucleus: Array<Expr>) {
    self.styles = styles
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  init(_ styles: MathStyles, _ nucleus: ContentExpr) {
    self.styles = styles
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathStylesExpr {
    MathStylesExpr(styles, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathStyles: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let styles = MathStyles.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid styles command: \(command)")
    }
    self.styles = styles
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(styles.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
