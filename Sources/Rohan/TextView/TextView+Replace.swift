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
    var contentsCopy: [Node]? = nil
    // if undo registration is enabled, we need to deep copy the nodes to be deleted
    if self.undoManager?.isUndoRegistrationEnabled == true {
      contentsCopy = documentManager.mapContents(in: range, { $0.deepCopy() })
    }

    // perform action
    let result = replacementHandler(range)

    // ensure action is successful and undoManager is available
    guard let insertedRange = result.success(),
      registerUndo == true,
      let undoManager = self.undoManager,
      undoManager.isUndoRegistrationEnabled
    else {
      assertionFailure("UndoManager should not be nil")
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
