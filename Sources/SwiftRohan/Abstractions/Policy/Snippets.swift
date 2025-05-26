// Copyright 2024-2025 Lie Yan

import Foundation

enum Snippets {
  // text
  static let emphasis = CommandBody(EmphasisExpr(), 1)
  static let strong = CommandBody(StrongExpr(), 1)
  static let equation = CommandBody(EquationExpr(.block), 1)
  static let inlineMath = CommandBody(EquationExpr(.inline), 1)

  static func header(level: Int) -> CommandBody {
    CommandBody(HeadingExpr(level: level), 1)
  }

  // math

  static func attachMathComponent(_ index: MathIndex) -> CommandBody {
    CommandBody(.addComponent(index))
  }

  static let overline = CommandBody(OverlineExpr(), 1, preview: .image("overline"))
  static let underline = CommandBody(UnderlineExpr(), 1, preview: .image("underline"))
  static let sqrt = CommandBody(RadicalExpr([]), 1, preview: .image("sqrt"))
  static let root = CommandBody(RadicalExpr([], []), 2, preview: .image("root"))
  static let textMode = CommandBody(TextModeExpr(), 1)

  static let rSup =
    CommandBody(AttachExpr(nuc: [], sup: []), 2, preview: .image("rsup"))
  static let rSub =
    CommandBody(AttachExpr(nuc: [], sub: []), 2, preview: .image("rsub"))
  static let rSupSub =
    CommandBody(AttachExpr(nuc: [], sub: [], sup: []), 3, preview: .image("rsupsub"))
  static let lrSub =
    CommandBody(AttachExpr(nuc: [], lsub: [], sub: []), 3, preview: .image("lrsub"))

  static func leftRight(_ left: String, _ right: String) -> CommandBody? {
    if left.count == 1, right.count == 1 {
      guard let delimiters = DelimiterPair(left.first!, right.first!)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left)⬚\(right)"
      return CommandBody(expr, 1, preview: .string(preview))
    }
    else {
      guard let left = NamedSymbol.lookup(left),
        let right = NamedSymbol.lookup(right),
        let delimiters = DelimiterPair(left, right)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left.string)⬚\(right.string)"
      return CommandBody(expr, 1, preview: .string(preview))
    }
  }

  static func mathTextStyle(_ style: MathTextStyle, _ string: String) -> CommandBody {
    let expr = MathVariantExpr(style, [TextExpr(string)])
    return CommandBody(expr, 0)
  }
}
