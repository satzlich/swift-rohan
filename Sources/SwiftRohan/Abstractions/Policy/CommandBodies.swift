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
  static let overline = CommandBody(OverlineExpr(), .mathContent, 1, image: "overline")
  static let underline = CommandBody(UnderlineExpr(), .mathContent, 1, image: "underline")
  static let sqrt = CommandBody(RadicalExpr([]), .mathContent, 1, image: "sqrt")
  static let root = CommandBody(RadicalExpr([], []), .mathContent, 2, image: "root")
  static let textMode = CommandBody(TextModeExpr(), .mathContent, 1)

  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3, image: "lrsub")

  static func accent(_ char: Character) -> CommandBody {
    let preview = "\(Chars.dottedSquare)\(char)"
    return CommandBody(AccentExpr(char, []), .mathContent, 1, preview)
  }

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

  static func attachMathComponent(_ index: MathIndex) -> CommandBody {
    CommandBody(.addComponent(index))
  }

  static func cases(_ count: Int, image: String) -> CommandBody {
    let rows: [CasesExpr.Row] =
      (0..<count).map { _ in CasesExpr.Row([CasesExpr.Element()]) }
    return CommandBody(CasesExpr(rows), .mathContent, count, image: image)
  }

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    precondition(Delimiter.validate(left) && Delimiter.validate(right))
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let expr = LeftRightExpr(delimiters, [])
    let preview = "\(left)\(Chars.dottedSquare)\(right)"

    return CommandBody(expr, .mathContent, 1, preview)
  }

  static func mathVariant(
    _ mathVariant: MathVariant?, bold: Bool?, italic: Bool?, _ preview: String
  ) -> CommandBody {
    let expr = MathVariantExpr(mathVariant, bold: bold, italic: italic, [])
    return CommandBody(expr, .mathContent, 1, preview)
  }

  static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair,
    image: String
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] =
        (0..<columnCount).map { _ in MatrixExpr.Element() }
      return MatrixExpr.Row(elements)
    }
    let expr = MatrixExpr(delimiters, rows)
    let count = rowCount * columnCount

    return CommandBody(expr, .mathContent, count, image: image)
  }

  static func overSpreader(_ char: Character, image: String) -> CommandBody {
    let expr = OverspreaderExpr(char, [])
    return CommandBody(expr, .mathContent, 1, image: image)
  }

  static func underSpreader(_ char: Character, image: String) -> CommandBody {
    let expr = UnderspreaderExpr(char, [])
    return CommandBody(expr, .mathContent, 1, image: image)
  }
}
