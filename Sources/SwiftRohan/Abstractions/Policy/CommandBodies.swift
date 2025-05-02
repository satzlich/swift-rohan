// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  // text

  static let emphasis = CommandBody([EmphasisExpr([])], .inlineContent, 1)
  static let strong = CommandBody([StrongExpr([])], .inlineContent, 1)

  static let equation =
    CommandBody([EquationExpr(isBlock: true, nuc: [])], .containsBlock, 1)
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, nuc: [])], .inlineContent, 1)

  // math

  static let binom = CommandBody(
    [FractionExpr(num: [], denom: [], isBinomial: true)], .mathContent, 2, image: "binom")
  static let frac =
    CommandBody([FractionExpr(num: [], denom: [])], .mathContent, 2, image: "frac")

  static let overline =
    CommandBody([OverlineExpr([])], .mathContent, 1, image: "overline")
  static let underline =
    CommandBody([UnderlineExpr([])], .mathContent, 1, image: "underline")

  static let sqrt = CommandBody([RadicalExpr([])], .mathContent, 1, image: "sqrt")
  static let root = CommandBody([RadicalExpr([], [])], .mathContent, 2, image: "root")

  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3, image: "lrsub")

  static let textMode = CommandBody([TextModeExpr([])], .mathContent, 1)

  // MARK: - Methods

  // text

  static func header(level: Int) -> CommandBody {
    let exprs = [HeadingExpr(level: level, [])]
    return CommandBody(exprs, .topLevelNodes, 1)
  }

  // math

  static func attachOrGotoMathComponent(_ index: MathIndex) -> CommandBody {
    CommandBody(index)
  }

  static func accent(_ char: Character) -> CommandBody {
    let exprs = [AccentExpr(char, nucleus: [])]
    let preview = "\(Characters.dottedSquare)\(char)"
    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func cases(_ count: Int, image imageName: String) -> CommandBody {
    let rows: [CasesExpr.Element] = (0..<count).map { _ in CasesExpr.Element() }
    let exprs = [CasesExpr(rows)]
    return CommandBody(exprs, .mathContent, count, image: imageName)
  }

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    precondition(Delimiter.validate(left) && Delimiter.validate(right))
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let exprs = [LeftRightExpr(delimiters, [])]
    let preview = "\(left)\(Characters.dottedSquare)\(right)"

    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func mathOperator(_ name: String, _ limits: Bool = false) -> CommandBody {
    let exprs = [MathOperatorExpr([TextExpr(name)], limits)]
    let preview = "\(name)"
    return CommandBody(exprs, .mathContent, 0, preview)
  }

  static func mathVariant(
    _ mathVariant: MathVariant?, bold: Bool?, italic: Bool?, _ preview: String
  ) -> CommandBody {
    let exprs = [MathVariantExpr(mathVariant, bold: bold, italic: italic, [])]
    return CommandBody(exprs, .mathContent, 1, preview)
  }

  static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair,
    image imageName: String
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] = (0..<columnCount).map { _ in
        MatrixExpr.Element()
      }
      return MatrixExpr.Row(elements)
    }
    let exprs = [MatrixExpr(rows, delimiters)]
    let n = rowCount * columnCount

    return CommandBody(exprs, .mathContent, n, image: imageName)
  }

  static func overSpreader(_ char: Character, image imageName: String) -> CommandBody {
    let exprs = [OverspreaderExpr(char, [])]
    return CommandBody(exprs, .mathContent, 1, image: imageName)
  }

  static func underSpreader(_ char: Character, image imageName: String) -> CommandBody {
    let exprs = [UnderspreaderExpr(char, [])]
    return CommandBody(exprs, .mathContent, 1, image: imageName)
  }
}
