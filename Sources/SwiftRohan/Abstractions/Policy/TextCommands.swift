// Copyright 2024-2025 Lie Yan

import Foundation

/// Non-symbol text commands.
enum TextCommands {
  static let allCases: Array<CommandRecord> = _allCases()

  private static func _allCases() -> Array<CommandRecord> {
    var result: Array<CommandRecord> = []

    result.append(CommandRecord("wordjoiner", Snippets.wordJoiner))
    result.append(CommandRecord("equation*", Snippets.equation))
    result.append(contentsOf: HeadingNode.commandRecords)
    result.append(contentsOf: ItemListNode.commandRecords)

    // textStyles
    do {
      let records = TextStyles.allCases.map { textStyle in
        let expr = TextStylesExpr(textStyle)
        return CommandRecord(textStyle.command, CommandBody(expr, 1))
      }
      result.append(contentsOf: records)
    }

    // multiline
    do {
      let multilines: Array<(MathArray, String)> = [
        (MathArray.alignAst, "aligned"),  // recycle "aligned"
        (MathArray.gatherAst, "gathered"),  // recycle "gathered"
        (MathArray.multlineAst, "multline"),
      ]
      assert(multilines.count == MathArray.blockMathCommands.count)

      let records = multilines.map { multiline, image in
        let expr = CommandBody.arrayExpr(multiline, image: image, MultilineExpr.self)
        return CommandRecord(multiline.command, expr)
      }
      result.append(contentsOf: records)
    }

    return result
  }
}
