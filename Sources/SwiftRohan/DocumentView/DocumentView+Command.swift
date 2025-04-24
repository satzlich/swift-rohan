// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  /// Execute the command at the given range.
  internal func executeCommand(_ command: CommandBody, at range: RhTextRange) {
    switch command.content {
    case .string(let string):
      let result = replaceCharactersForEdit(in: range, with: string)
      assert(result.isInternalError == false)

    case .expressions(let exprs):
      let content = NodeUtils.convertExprs(exprs)
      let result = replaceContentsForEdit(in: range, with: content)
      assert(result.isInternalError == false)

    case .mathComponent(let component):
      assert(component == .sub || component == .sup)
      assertionFailure("Not implemented yet")
    }

    for _ in 0..<command.backwardMoves {
      self.moveBackward(nil)
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

      if container.isCompatible(with: body.category) {
        executeCommand(body, at: newRange)
      }
    }
  }
}
