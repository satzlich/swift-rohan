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

  static let fraction =
    CommandBody(FractionExpr(num: [], denom: []), 2, preview: .image("frac"))
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
    guard let leftDelimiter = NamedSymbol.lookup(left).map({ ExtendedChar.symbol($0) }),
      let rightDelimiter = NamedSymbol.lookup(right).map({ ExtendedChar.symbol($0) })
    else { return nil }
    return leftRight(leftDelimiter, rightDelimiter)
  }

  static func leftRight(_ left: ExtendedChar, _ right: ExtendedChar) -> CommandBody? {
    guard let leftDelimiter = delimiter(from: left),
      let rightDelimiter = delimiter(from: right)
    else { return nil }

    let delimiters = DelimiterPair(leftDelimiter, rightDelimiter)
    let expr = LeftRightExpr(delimiters, [])
    let preview = "\(left.preview())⬚\(right.preview())"

    return CommandBody(expr, 1, preview: .string(preview))

    // Helper
    func delimiter(from char: ExtendedChar) -> Delimiter? {
      switch char {
      case let .char(c): return Delimiter(c)
      case let .symbol(symbol): return Delimiter(symbol)
      }
    }
  }

  static func mathTextStyle(_ style: MathTextStyle, _ string: String) -> CommandBody {
    let expr = MathStylesExpr(MathStyles.mathTextStyle(style), [TextExpr(string)])
    return CommandBody(expr, 0)
  }
}
