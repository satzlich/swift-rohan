// Copyright 2024-2025 Lie Yan

import Foundation

/// Non-symbol text commands.
enum TextCommands {
  static let allCases: Array<CommandRecord> = _allCases()

  private static func _allCases() -> Array<CommandRecord> {
    var result: Array<CommandRecord> =
      [
        // style
        .init("emph", Snippets.emphasis),
        .init("strong", Snippets.strong),
        // math
        .init("equation*", Snippets.equation),
      ]

    result.append(contentsOf: HeadingNode.commandRecords)

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
