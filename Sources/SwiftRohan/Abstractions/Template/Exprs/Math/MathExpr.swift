// Copyright 2024-2025 Lie Yan

import Foundation

class MathExpr: Expr {
  typealias MathComponent = (index: MathIndex, content: ContentExpr)

  func enumerateComponents() -> [MathComponent] {
    preconditionFailure("This method should be overridden")
  }
}
