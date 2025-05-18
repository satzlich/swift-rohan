// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
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

  static let overline = CommandBody(OverlineExpr(), 1, image: "overline")
  static let underline = CommandBody(UnderlineExpr(), 1, image: "underline")
  static let sqrt = CommandBody(RadicalExpr([]), 1, image: "sqrt")
  static let root = CommandBody(RadicalExpr([], []), 2, image: "root")
  static let textMode = CommandBody(TextModeExpr(), 1)

  static let lrSubScript =
    CommandBody(AttachExpr(nuc: [], lsub: [], sub: []), 3, image: "lrsub")

  static func aligned(_ rowCount: Int, _ columnCount: Int, image: String) -> CommandBody {
    let rows = (0..<rowCount).map { _ in
      let elements = (0..<columnCount).map { _ in AlignedExpr.Element() }
      return AlignedExpr.Row(elements)
    }
    let count = rowCount * columnCount
    return CommandBody(AlignedExpr(rows), count, image: image)
  }

  static func cases(_ count: Int, image: String) -> CommandBody {
    let rows = (0..<count).map { _ in CasesExpr.Row([CasesExpr.Element()]) }
    return CommandBody(CasesExpr(rows), count, image: image)
  }

  static func leftRight(_ left: String, _ right: String) -> CommandBody? {
    if left.count == 1, right.count == 1 {
      guard let delimiters = DelimiterPair(left.first!, right.first!)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left)⬚\(right)"
      return CommandBody(expr, 1, text: preview)
    }
    else {
      guard let left = MathSymbol.lookup(left),
        let right = MathSymbol.lookup(right),
        let delimiters = DelimiterPair(left, right)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left.symbol)⬚\(right.symbol)"
      return CommandBody(expr, 1, text: preview)
    }
  }

  static func mathbb(_ string: String) -> CommandBody {
    let mathbb = MathTextStyle.lookup("mathbb")!
    let expr = MathVariantExpr(mathbb, [TextExpr(string)])
    return CommandBody(expr, 0)
  }

  static func mathcal(_ string: String) -> CommandBody {
    let mathcal = MathTextStyle.lookup("mathcal")!
    let expr = MathVariantExpr(mathcal, [TextExpr(string)])
    return CommandBody(expr, 0)
  }

  static func mathsf(_ string: String) -> CommandBody {
    let mathsf = MathTextStyle.lookup("mathsf")!
    let expr = MathVariantExpr(mathsf, [TextExpr(string)])
    return CommandBody(expr, 0)
  }
}
