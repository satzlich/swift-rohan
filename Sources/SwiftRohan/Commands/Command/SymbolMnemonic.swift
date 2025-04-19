// Copyright 2024-2025 Lie Yan

struct SymbolMnemonic {
  /// Mnemonic command
  let command: String
  /// Symbol string
  let string: String
  /// Backward moves needed to relocate the cursor.
  let backwardMoves: Int

  init(_ command: String, _ string: String, _ backwardMoves: Int = 0) {
    precondition(backwardMoves >= 0)
    self.command = command
    self.string = string
    self.backwardMoves = backwardMoves
  }
}
