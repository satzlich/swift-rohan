// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension TextView {

  func replaceContents(
    in range: RhTextRange, with nodes: [Node]?, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceContents(in: range, with: nodes)
    }
  }

  func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  /// Replace the contents in the given range with replacementHandler.
  /// If the operation succeeds, register an undo action.
  func _replaceContents(
    in range: RhTextRange, registerUndo: Bool,
    _ replacementHandler: (RhTextRange) -> SatzResult<RhTextRange>
  ) -> SatzResult<RhTextRange> {
    guard let undoManager = self.undoManager,
      registerUndo && undoManager.isUndoRegistrationEnabled
    else {
      return replacementHandler(range)
    }

    // register undo action is required below

    // copy contents to be replaced
    let contentsCopy: [Node]? = documentManager.mapContents(in: range, { $0.deepCopy() })
    guard let contentsCopy else {
      assertionFailure("contentsCopy should not be nil")
      return .failure(SatzError(.InvalidTextRange))
    }

    // perform replacement
    let result = replacementHandler(range)

    // ensure the replacement succeeded
    guard let insertedRange = result.success() else {
      // it's okay if the insertion operation is invalid due to user input;
      // but it's a programming error otherwise.
      guard result.failure()?.code == .InsertOperationRejected
      else {
        assertionFailure("failed to replace contents")
        return result
      }
      return result
    }

    // register undo action
    self.registerUndo(for: insertedRange, with: contentsCopy, undoManager)

    return result
  }

  private func registerUndo(
    for range: RhTextRange, with nodes: [Node]?, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    if let nodes = nodes,
      let textNode = getSingleTextNode(nodes)
    {
      undoManager.registerUndo(withTarget: self) { (target: TextView) in
        let result =
          target.replaceCharacters(in: range, with: textNode.string, registerUndo: true)
        assert(result.isSuccess)
        guard let insertedRange = result.success() else { return }
        target.documentManager.textSelection = RhTextSelection(insertedRange.endLocation)
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { target in
        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        assert(result.isSuccess)
        guard let insertedRange = result.success() else { return }
        target.documentManager.textSelection = RhTextSelection(insertedRange.endLocation)
      }
    }
  }
}
