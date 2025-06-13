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

  static func mathTextStyle(_ style: MathTextStyle, _ string: String) -> CommandBody {
    let expr = MathStylesExpr(MathStyles.mathTextStyle(style), [TextExpr(string)])
    return CommandBody(expr, 0)
  }

  /// Create a command body for left-right delimiters.
  static func leftRight(_ left: ExtendedChar, _ right: ExtendedChar) -> CommandBody? {
    leftRight(.pair(left, right))
  }

  static func leftRight(_ delimiters: OneOrPair<String, String>) -> CommandBody? {
    switch delimiters {
    case let .left(left):
      guard let leftDelimiter = NamedSymbol.lookup(left).map({ ExtendedChar.symbol($0) })
      else { return nil }
      return leftRight(.left(leftDelimiter))

    case let .right(right):
      guard
        let rightDelimiter = NamedSymbol.lookup(right).map({ ExtendedChar.symbol($0) })
      else { return nil }
      return leftRight(.right(rightDelimiter))

    case let .pair(left, right):
      guard let leftDelimiter = NamedSymbol.lookup(left).map({ ExtendedChar.symbol($0) }),
        let rightDelimiter = NamedSymbol.lookup(right).map({ ExtendedChar.symbol($0) })
      else { return nil }
      return leftRight(.pair(leftDelimiter, rightDelimiter))
    }
  }

  static func leftRight(
    _ delimiters: OneOrPair<ExtendedChar, ExtendedChar>
  ) -> CommandBody? {
    switch delimiters {
    case let .left(left):
      guard let leftDelimiter = left.toDelimiter() else { return nil }
      let delimiters = DelimiterPair(leftDelimiter, Delimiter.null)
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left.preview())⬚"
      return CommandBody(expr, 1, preview: .string(preview))

    case let .right(right):
      guard let rightDelimiter = right.toDelimiter() else { return nil }
      let delimiters = DelimiterPair(Delimiter.null, rightDelimiter)
      let expr = LeftRightExpr(delimiters, [])
      let preview = "⬚\(right.preview())"
      return CommandBody(expr, 1, preview: .string(preview))

    case let .pair(left, right):
      guard let leftDelimiter = left.toDelimiter(),
        let rightDelimiter = right.toDelimiter()
      else { return nil }
      let delimiters = DelimiterPair(leftDelimiter, rightDelimiter)
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left.preview())⬚\(right.preview())"
      return CommandBody(expr, 1, preview: .string(preview))
    }
  }
}
