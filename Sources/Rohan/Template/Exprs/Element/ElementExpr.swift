// Copyright 2024-2025 Lie Yan
import Foundation

class ElementExpr: Expr {
  let children: [Expr]

  var isEmpty: Bool { children.isEmpty }

  init(_ children: [Expr] = []) {
    self.children = children
    super.init()
  }

  func with(expressions: [Expr]) -> Self {
    preconditionFailure("overriding required")
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case children
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
    self.children = try ExprSerdeUtils.decodeListOfExprs(from: &childrenContainer)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(children, forKey: .children)
    try super.encode(to: encoder)
  }
}
