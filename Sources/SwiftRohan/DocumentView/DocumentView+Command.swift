// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  /// Execute the command at the given range.
  internal func executeCommand(_ command: CommandBody, at range: RhTextRange) {
    switch command.content {
    case .plaintext(let string):
      let result = replaceCharactersForEdit(in: range, with: string)
      assert(result.isInternalError == false)

    case .expressions(let exprs):
      let content = NodeUtils.convertExprs(exprs)
      let result = replaceContentsForEdit(in: range, with: content)
      assert(result.isInternalError == false)
    }

    for _ in 0..<command.backwardMoves {
      self.moveBackward(nil)
    }
  }

  /// Execute
  internal func executeReplacement() {

  }
}
