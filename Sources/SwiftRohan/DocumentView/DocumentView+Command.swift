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
        moveBackward(nil)
      }

    case let .insertExpressions(insertExpressions):
      let content = NodeUtils.convertExprs(insertExpressions.expressions)
      let result = replaceContentsForEdit(in: range, with: content)
      assert(result.isInternalError == false)
      for _ in 0..<insertExpressions.backwardMoves {
        moveBackward(nil)
      }

    case let .editAttach(editAttach):
      switch editAttach {
      case let .attachComponent(mathIndex):
        guard
          let (object, location) = documentManager.upstreamObject(from: range.location)
        else {
          return
        }

        let result = replaceContentsForEdit(in: range, with: nil)
        guard let range1 = result.success()
        else {
          assertionFailure("Failed to replace contents for edit attach")
          return
        }

        let range2: RhTextRange
        switch object {
        case let .text(string):
          let end = location.with(offsetDelta: string.length)
          range2 = RhTextRange(location, end)!
        case let .nonText(node):
          let end = location.with(offsetDelta: 1)
          range2 = RhTextRange(location, end)!
        }
        _ = addMathComponentForEdit(range2, mathIndex, [])

      case .removeComponent(_):
        preconditionFailure("not implemented")
      }

    case .editMatrix(_):
      preconditionFailure("not implemented")
    }
  }

  /// Execute replacement rule at the given range for the given string.
  /// - Parameters:
  ///   - string: The string just typed.
  ///   - range: The range of string.
  /// - Precondition: the content in `range` equals `string` (un-checked in code).
  internal func executeReplacementIfNeeded(for string: String, at range: RhTextRange) {

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
