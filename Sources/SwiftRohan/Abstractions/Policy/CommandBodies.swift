// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, nuc: [])], .inlineContent, 1)

  static let superScript = CommandBody([AttachExpr(nuc: [], sup: [])], .mathContent, 2)
  static let subScript = CommandBody([AttachExpr(nuc: [], sub: [])], .mathContent, 2)
  static let supSubScript =
    CommandBody([AttachExpr(nuc: [], sub: [], sup: [])], .mathContent, 3)
  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3)

  static func accent(from char: Character) -> CommandBody {
    let preview = "\(Characters.dottedSquare)\(char)"
    return CommandBody([AccentExpr(char, nucleus: [])], .mathContent, 1, preview)
  }

  static func cases(_ count: Int) -> CommandBody {
    let rows: [CasesExpr.Element] = (0..<count).map { _ in CasesExpr.Element() }
    let cases = CasesExpr(rows)
    let n = count
    return CommandBody([cases], .mathContent, n)
  }

  static func mathVariant(
    _ mathVariant: MathVariant?, bold: Bool?, italic: Bool?
  ) -> CommandBody {
    let expr = MathVariantExpr(mathVariant, bold: bold, italic: italic, [])
    return CommandBody([expr], .mathContent, 1)
  }

  static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] = (0..<columnCount).map { _ in
        MatrixExpr.Element()
      }
      return MatrixExpr.Row(elements)
    }
    let matrix = MatrixExpr(rows, delimiters)
    let n = rowCount * columnCount

    return CommandBody([matrix], .mathContent, n)
  }

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let expr = LeftRightExpr(delimiters, [])
    let preview = "\(left)\(Characters.dottedSquare)\(right)"
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func overSpreader(_ char: Character) -> CommandBody {
    let expr = OverspreaderExpr(char, [])
    let preview = "\(char)"
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func underSpreader(_ char: Character) -> CommandBody {
    let expr = UnderspreaderExpr(char, [])
    let preview = "\(char)"
    return CommandBody([expr], .mathContent, 1, preview)
  }
}
