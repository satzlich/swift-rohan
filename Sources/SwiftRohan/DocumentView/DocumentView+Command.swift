// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  /// Execute the command at the given range.
  internal func executeCommand(_ command: CommandBody, at range: RhTextRange) {

    switch command {
    case let .insertString(insertString):
      let result = replaceCharactersForEdit(in: range, with: insertString.string)
      assert(result.isInternalError == false)
      for _ in 0..<insertString.backwardMoves {
        self.moveBackward(nil)
      }

    case let .insertExpressions(insertExpressions):
      let content = NodeUtils.convertExprs(insertExpressions.expressions)
      let result = replaceContentsForEdit(in: range, with: content)
      assert(result.isInternalError == false)
      for _ in 0..<insertExpressions.backwardMoves {
        self.moveBackward(nil)
      }

    case let .attachOrGotoMathComponent(mathIndex):
      _ = attachOrGotoMathComponentForEdit(for: range, with: mathIndex)
    }
  }

  /// Execute replacement rule at the given range for the given string.
  /// - Parameters:
  ///   - string: The string just typed.
  ///   - range: The range of string.
  /// - Precondition: the content in `range` equals `string` (un-checked in code).
  internal func executeReplacementIfNeeded(for string: String, at range: RhTextRange) {
    precondition(range.location.offset + string.length == range.endLocation.offset)

    guard let engine = replacementProvider,
      string.count == 1
    else { return }

    guard let container = documentManager.containerCategory(for: range.location)
    else {
      assertionFailure("Invalid range: \(range)")
      return
    }

    let mode = container.layoutMode()
    let char = string.first!
    let location = range.location

    if let n = engine.prefixSize(for: char, in: mode),
      let prefix = documentManager.prefixString(from: location, charCount: n),
      let (body, m) = engine.replacement(for: char, prefix: prefix, in: mode),
      m <= location.offset,
      let newRange = RhTextRange(location.with(offsetDelta: -m), range.endLocation)
    {
      if body.isCompatible(with: container) {
        executeCommand(body, at: newRange)
      }
    }
  }
}
