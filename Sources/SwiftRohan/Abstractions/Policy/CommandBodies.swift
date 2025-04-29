// Copyright 2024-2025 Lie Yan

import Foundation

/// Shared command bodies
enum CommandBodies {
  static let inlineEquation =
    CommandBody([EquationExpr(isBlock: false, nuc: [])], .inlineContent, 1)

  static let superScript =
    CommandBody([AttachExpr(nuc: [], sup: [])], .mathContent, 2, image: "sup")
  static let subScript =
    CommandBody([AttachExpr(nuc: [], sub: [])], .mathContent, 2, image: "sub")
  static let supSubScript =
    CommandBody([AttachExpr(nuc: [], sub: [], sup: [])], .mathContent, 3, image: "supsub")
  static let lrSubScript =
    CommandBody([AttachExpr(nuc: [], lsub: [], sub: [])], .mathContent, 3, image: "lrsub")

  static func accent(from char: Character) -> CommandBody {
    let preview = "\(Characters.dottedSquare)\(char)"
    return CommandBody([AccentExpr(char, nucleus: [])], .mathContent, 1, preview)
  }

  static func cases(_ count: Int, image imageName: String? = nil) -> CommandBody {
    let rows: [CasesExpr.Element] = (0..<count).map { _ in CasesExpr.Element() }
    let cases = CasesExpr(rows)
    let n = count

    if let imageName {
      return CommandBody([cases], .mathContent, n, image: imageName)
    }
    else {
      return CommandBody([cases], .mathContent, n)
    }
  }

  static func mathOperator(_ name: String, _ limits: Bool = false) -> CommandBody {
    let expr = MathOperatorExpr([TextExpr(name)], limits)
    let preview = "\(name)"
    return CommandBody([expr], .mathContent, 0, preview)
  }

  static func mathVariant(
    _ mathVariant: MathVariant?, bold: Bool?, italic: Bool?,
    _ preview: String? = nil
  ) -> CommandBody {
    let expr = MathVariantExpr(mathVariant, bold: bold, italic: italic, [])
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair,
    image imageName: String? = nil
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] = (0..<columnCount).map { _ in
        MatrixExpr.Element()
      }
      return MatrixExpr.Row(elements)
    }
    let matrix = MatrixExpr(rows, delimiters)
    let n = rowCount * columnCount

    if let imageName {
      return CommandBody([matrix], .mathContent, n, image: imageName)
    }
    else {
      return CommandBody([matrix], .mathContent, n)
    }
  }

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let expr = LeftRightExpr(delimiters, [])
    let preview = "\(left)\(Characters.dottedSquare)\(right)"
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func overSpreader(
    _ char: Character, image fileName: String? = nil
  ) -> CommandBody {
    let expr = OverspreaderExpr(char, [])
    if let fileName {
      return CommandBody([expr], .mathContent, 1, image: fileName)
    }
    else {
      return CommandBody([expr], .mathContent, 1)
    }
  }

  static func underSpreader(
    _ char: Character, image fileName: String? = nil
  ) -> CommandBody {
    let expr = UnderspreaderExpr(char, [])
    if let fileName {
      return CommandBody([expr], .mathContent, 1, image: fileName)
    }
    else {
      return CommandBody([expr], .mathContent, 1)
    }
  }
}
