import Foundation

class MathExpr: Expr {
  typealias MathComponent = (index: MathIndex, content: ContentExpr)

  internal func enumerateComponents() -> Array<MathComponent> {
    preconditionFailure("This method should be overridden")
  }
}
