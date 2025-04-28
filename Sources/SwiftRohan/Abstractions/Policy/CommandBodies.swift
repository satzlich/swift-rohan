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

  static func leftRight(_ left: Character, _ right: Character) -> CommandBody {
    let delimiters = DelimiterPair(Delimiter(left)!, Delimiter(right)!)
    let expr = LeftRightExpr(delimiters, [])
    let preview = "\(left)\(Characters.dottedSquare)\(right)"
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func overSpreader(_ char: Character) -> CommandBody {
    let expr = OverspreaderExpr(char, [])
    let preview = "\(Characters.dottedSquare)\(char)"
    return CommandBody([expr], .mathContent, 1, preview)
  }

  static func underSpreader(_ char: Character) -> CommandBody {
    let expr = UnderspreaderExpr(char, [])
    let preview = "\(char)\(Characters.dottedSquare)"
    return CommandBody([expr], .mathContent, 1, preview)
  }
}
