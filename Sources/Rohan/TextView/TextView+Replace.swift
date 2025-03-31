// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension TextView {

  private func replaceContents(
    in range: RhTextRange, with nodes: [Node]?, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceContents(in: range, with: nodes)
    }
  }

  /// Replace the contents in the given range with nodes.
  /// Undo registration is always enabled.
  /// - Note: For internal error, assertion failure is triggered.
  func replaceContentsForEdit(
    in range: RhTextRange, with nodes: [Node]?,
    message: String? = nil
  ) -> EditResult {
    let result = replaceContents(in: range, with: nodes, registerUndo: true)
    return didReplaceContentsForEdit(result, message: message)
  }

  func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  /// Replace the contents in the given range with string.
  /// - Note: For internal error, assertion failure is triggered.
  func replaceCharactersForEdit(
    in range: RhTextRange, with string: BigString
  ) -> EditResult {
    let result = replaceCharacters(in: range, with: string, registerUndo: true)
    return didReplaceContentsForEdit(result)
  }

  /// Replace the contents in the given range with replacementHandler.
  /// If the operation succeeds, register an undo action.
  private func _replaceContents(
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

    if let textNode = nodes?.getOnlyTextNode() {
      undoManager.registerUndo(withTarget: self) { (target: TextView) in
        let result =
          target.replaceCharacters(in: range, with: textNode.string, registerUndo: true)
        self.didReplaceContents(result).map { error in
          assertionFailure("Failed to undo with replaceCharacters: \(error)")
        }
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { target in
        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        self.didReplaceContents(result).map { error in
          assertionFailure("Failed to undo with replaceContents: \(error)")
        }
      }
    }
  }

  private func didReplaceContents(
    _ result: SatzResult<RhTextRange>, _ message: String? = nil
  ) -> SatzError? {
    // check result and update selection
    switch result {
    case .success(let range):
      // update layout
      self.needsLayoutAndScroll = true
      // update selection
      self.documentManager.textSelection = RhTextSelection(range.endLocation)
      return nil

    case .failure(let error):
      return error
    }
  }

  /// - Note: For internal error, assertion failure is triggered.
  private func didReplaceContentsForEdit(
    _ result: SatzResult<RhTextRange>, message: String? = nil
  ) -> EditResult {
    guard let error = didReplaceContents(result, message)
    else { return .success }

    if error.code == .InsertOperationRejected {
      self.notifyOperationRejected()
      return .rejected(error)
    }
    else {
      // update layout
      self.needsLayoutAndScroll = true
      // it is a programming error if this is reached
      let message = message ?? "Failed to replace contents"
      assertionFailure("\(message): \(error)")
      Rohan.logger.error("\(message): \(error)")
      return .internalError(error)
    }
  }
}
