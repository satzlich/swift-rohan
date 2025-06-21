// Copyright 2024-2025 Lie Yan

final class HeadingExpr: ElementExpr {
  class override var type: ExprType { .heading }

  enum Subtype: String, Codable, CaseIterable {
    case sectionAst
    case subsectionAst
    case subsubsectionAst

    var level: Int {
      switch self {
      case .sectionAst: return 1
      case .subsectionAst: return 2
      case .subsubsectionAst: return 3
      }
    }

    var command: String {
      switch self {
      case .sectionAst: return "section*"
      case .subsectionAst: return "subsection*"
      case .subsubsectionAst: return "subsubsection*"
      }
    }

    static func fromCommand(_ command: String) -> Subtype? {
      switch command {
      case "section*": return .sectionAst
      case "subsection*": return .subsectionAst
      case "subsubsection*": return .subsubsectionAst
      default: return nil
      }
    }
  }

  var level: Int { subtype.level }
  var subtype: Subtype

  init(_ subtype: Subtype, _ expressions: Array<Expr> = []) {
    self.subtype = subtype
    super.init(expressions)
  }

  override func with(children: Array<Expr>) -> Self {
    Self(subtype, children)
  }

  static func validate(level: Int) -> Bool {
    1...5 ~= level
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(heading: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case subtype }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }
}
