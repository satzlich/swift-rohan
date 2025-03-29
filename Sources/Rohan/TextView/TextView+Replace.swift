// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension TextView {

  func replaceContents(
    in range: RhTextRange, with nodes: [Node]?
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range) { range in
      documentManager.replaceContents(in: range, with: nodes)
    }
  }

  func replaceCharacters(
    in range: RhTextRange, with string: BigString
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  /// Replace the contents in the given range with replacementHandler.
  private func _replaceContents(
    in range: RhTextRange,
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
      let undoManager = self.undoManager,
      undoManager.isUndoRegistrationEnabled
    else {
      assertionFailure("UndoManager should not be nil")
      return result
    }

    // register undo action
    registerUndo(for: insertedRange, with: contentsCopy, undoManager)
    return result
  }

  private func registerUndo(
    for range: RhTextRange, with nodes: [Node]?, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    if let nodes = nodes,
      let textNode = getSingleTextNode(nodes)
    {
      undoManager.registerUndo(withTarget: self) { target in
        let result = target.replaceCharacters(in: range, with: textNode.string)
        assert(result.isSuccess)
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { target in
        let result = target.replaceContents(in: range, with: nodes)
        assert(result.isSuccess)
      }
    }
  }
}
