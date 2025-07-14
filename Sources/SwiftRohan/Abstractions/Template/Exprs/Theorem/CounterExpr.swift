// Copyright 2024-2025 Lie Yan

import Foundation

final class CounterExpr: Expr {
  override class var type: ExprType { .counter }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(counter: self, context)
  }

  // MARK: - State

  let counterName: CounterName

  init(_ counterName: CounterName) {
    self.counterName = counterName
    super.init()
  }

  private enum CodingKeys: CodingKey {
    case counterName
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    counterName = try container.decode(CounterName.self, forKey: .counterName)
    try super.init(from: decoder)
  }
}
