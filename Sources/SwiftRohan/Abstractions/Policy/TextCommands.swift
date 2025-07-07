// Copyright 2024-2025 Lie Yan

import Foundation

/// Non-symbol text commands.
enum TextCommands {
  nonisolated(unsafe) static let allCases: Array<CommandRecord> = _allCases()

  private static func _allCases() -> Array<CommandRecord> {
    var result: Array<CommandRecord> = []

    result.append(CommandRecord("wordjoiner", Snippets.wordJoiner))
    result.append(CommandRecord("equation*", Snippets.equationAst))
    result.append(CommandRecord("equation", Snippets.equation))
    result.append(contentsOf: HeadingNode.commandRecords)
    result.append(contentsOf: ItemListNode.commandRecords)
    result.append(contentsOf: TextStylesNode.commandRecords)

    // multiline
    do {
      let multilines: Array<(MathArray, String)> = [
        (MathArray.align, "aligned"),  // recycle "aligned"
        (MathArray.alignAst, "aligned"),  // recycle "aligned"
        (MathArray.gather, "gathered"),  // recycle "gathered"
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
