// Copyright 2024-2025 Lie Yan

import Foundation

public struct CommandBody {
  enum Content {
    case plaintext(String)
    case other([Expr])
  }

  /// Content produced by this command.
  let content: Content

  /// Category of the content produced by this command.
  let category: ContentCategory

  /// Backward moves needed to relocate the cursor.
  let backwardMoves: Int

  private init(_ content: Content, _ category: ContentCategory, _ backwardMoves: Int) {
    precondition(backwardMoves >= 0)
    self.content = content
    self.category = category
    self.backwardMoves = backwardMoves
  }

  init(_ exprs: [Expr], _ category: ContentCategory, _ backwardMoves: Int) {
    self.init(.other(exprs), category, backwardMoves)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    self.init(.plaintext(symbol.string), category, symbol.backwardMoves)
  }
}
