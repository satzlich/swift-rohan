// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  /// Execute the command at the given range.
  internal func executeCommand(_ command: CommandBody, at range: RhTextRange) {

    switch command {
    case let .insertString(insertString):
      let result = replaceCharactersForEdit(in: range, with: insertString.string)
      assert(result.isSuccess)
      for _ in 0..<insertString.backwardMoves {
        moveBackward(nil)
      }

    case let .insertExprs(insertExprs):
      let content: Array<Node> = NodeUtils.convertExprs(insertExprs.exprs)
      let result = replaceContentsForEdit(in: range, with: content)

      switch result {
      case .success, .extraParagraph, .blockInserted:
        for _ in 0..<insertExprs.backwardMoves {
          moveBackward(nil)
        }

      case .failure(let error):
        assert(error.code.type == .UserError)
      }

    case let .editMath(editMath):
      switch editMath {
      case let .attachOrGotoComponent(mathIndex):
        _executeAttachOrGotoComponent(mathIndex, at: range)

      case .removeComponent(_):
        preconditionFailure("not implemented")
      }
    }
  }

  /// Execute "EditMath.attachOrGotoComponent" command at the given range.
  /// - Precondition: Currently we support only `sub` and `sup` components.
  private func _executeAttachOrGotoComponent(
    _ mathIndex: MathIndex, at range: RhTextRange
  ) {
    switch mathIndex {
    case .sub, .sup:
      // obtain the object to apply the command
      guard
        let object = documentManager.crossedObjectAt(range.location, direction: .backward)
      else { return }

      // obtain the target range
      let range2: RhTextRange
      switch object {
      case let .text(string, location):
        // remove range if non-empty
        if range.isEmpty == false {
          let result = replaceContentsForEdit(in: range, with: nil as Array<Node>?)
          assert(result.isSuccess)
        }

        let end = location.with(offsetDelta: string.length)
        range2 = RhTextRange(location, end)!

      case .nonTextNode(_, let location):
        // remove range if non-empty
        if range.isEmpty == false {
          let result = replaceContentsForEdit(in: range, with: nil as Array<Node>?)
          assert(result.isSuccess)
        }

        let end = location.with(offsetDelta: 1)
        range2 = RhTextRange(location, end)!

      case .blockBoundary:
        return
      }

      // add the math component
      _ = addMathComponentForEdit(range2, mathIndex, [])

    default:
      assertionFailure("Invalid math index: \(mathIndex)")
      return
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

    guard let container = documentManager.containerCategory(for: range.location) else {
      assertionFailure("Invalid range: \(range)")
      return
    }

    let mode = container.layoutMode()
    let char = string.first!
    let location = range.location

    // match replacement rule
    if let n = engine.prefixSize(for: char, in: mode),
      let prefix = documentManager.prefixString(from: location, count: n),
      let (body, matched) = engine.replacement(for: char, prefix: prefix, in: mode),
      let beginning = documentManager.traceBackward(from: location, matched),
      let newRange = RhTextRange(beginning, range.endLocation),
      body.isCompatible(with: container)
    {
      executeCommand(body, at: newRange)
    }
  }
}
