// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  // text
  static let emphasis = CommandBody(EmphasisExpr(), .inlineContent, 1)
  static let strong = CommandBody(StrongExpr(), .inlineContent, 1)
  static let equation = CommandBody(EquationExpr(isBlock: true), .containsBlock, 1)
  static let inlineEquation = CommandBody(EquationExpr(isBlock: false), .inlineContent, 1)

  static func header(level: Int) -> CommandBody {
    CommandBody(HeadingExpr(level: level), .topLevelNodes, 1)
  }

  // math

  static func attachMathComponent(_ index: MathIndex) -> CommandBody {
    CommandBody(.addComponent(index))
  }

  static let overline = CommandBody(OverlineExpr(), .mathContent, 1, image: "overline")
  static let underline = CommandBody(UnderlineExpr(), .mathContent, 1, image: "underline")
  static let sqrt = CommandBody(RadicalExpr([]), .mathContent, 1, image: "sqrt")
  static let root = CommandBody(RadicalExpr([], []), .mathContent, 2, image: "root")
  static let textMode = CommandBody(TextModeExpr(), .mathContent, 1)

  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3, image: "lrsub")

  static func aligned(_ rowCount: Int, _ columnCount: Int, image: String) -> CommandBody {
    let rows: [AlignedExpr.Row] = (0..<rowCount).map { _ in
      let elements: [AlignedExpr.Element] = (0..<columnCount).map { _ in
        AlignedExpr.Element()
      }
      return AlignedExpr.Row(elements)
    }
    let count = rowCount * columnCount
    return CommandBody(AlignedExpr(rows), .mathContent, count, image: image)
  }

  static func cases(_ count: Int, image: String) -> CommandBody {
    let rows: [CasesExpr.Row] =
      (0..<count).map { _ in CasesExpr.Row([CasesExpr.Element()]) }
    return CommandBody(CasesExpr(rows), .mathContent, count, image: image)
  }

  static func leftRight(_ left: String, _ right: String) -> CommandBody? {
    if left.count == 1, right.count == 1 {
      guard let delimiters = DelimiterPair(left.first!, right.first!)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left)⬚\(right)"
      return CommandBody(expr, .mathContent, 1, preview)
    }
    else {
      guard let left = MathSymbol.lookup(left),
        let right = MathSymbol.lookup(right),
        let delimiters = DelimiterPair(left, right)
      else { return nil }
      let expr = LeftRightExpr(delimiters, [])
      let preview = "\(left.symbol)⬚\(right.symbol)"
      return CommandBody(expr, .mathContent, 1, preview)
    }
  }
}
