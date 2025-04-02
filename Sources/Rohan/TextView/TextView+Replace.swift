// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension TextView {

  /// Replace the contents in the given range with nodes.
  /// Undo registration is always enabled.
  /// - Note: For internal error, assertion failure is triggered.
  internal func replaceContentsForEdit(
    in range: RhTextRange, with nodes: [Node]?,
    message: @autoclosure () -> String? = { nil }()
  ) -> EditResult {
    let result = replaceContents(in: range, with: nodes, registerUndo: true)
    return didReplaceContentsForEdit(result, message: message())
  }

  internal func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  /// Replace the contents in the given range with string.
  /// - Note: For internal error, assertion failure is triggered.
  internal func replaceCharactersForEdit(
    in range: RhTextRange, with string: BigString
  ) -> EditResult {
    let result = replaceCharacters(in: range, with: string, registerUndo: true)
    return didReplaceContentsForEdit(result)
  }

  internal func replaceCharactersForEdit(
    in range: RhTextRange, with string: String
  ) -> EditResult {
    self.replaceCharactersForEdit(in: range, with: BigString(string))
  }

  // MARK: - private

  private func replaceContents(
    in range: RhTextRange, with nodes: [Node]?, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceContents(in: range, with: nodes)
    }
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
    switch result {
    case .success(let insertedRange):
      // register undo action
      self.registerUndo(for: insertedRange, with: contentsCopy, undoManager)
      return result

    case .failure(let error) where error.code.type == .UserError:
      // user error is okay
      return result

    default:
      assertionFailure("failed to replace contents")
      return result
    }
  }

  private func registerUndo(
    for range: RhTextRange, with nodes: [Node]?, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    if let textNode = nodes?.getOnlyTextNode() {
      undoManager.registerUndo(withTarget: self) { (target: TextView) in
        let string = textNode.string
        let result = target.replaceCharacters(in: range, with: string, registerUndo: true)
        self.didReplaceContents(result).map { error in
          assertionFailure("Failed to undo with replaceCharacters: \(error)")
        }
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { (target: TextView) in
        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        self.didReplaceContents(result).map { error in
          assertionFailure("Failed to undo with replaceContents: \(error)")
        }
      }
    }
  }

  /// Deal with the result of replacing contents/characters.
  /// If the operation succeeds, update the selection.
  /// - Returns: nil if the operation succeeds, otherwise the error.
  private func didReplaceContents(
    _ result: SatzResult<RhTextRange>, _ message: @autoclosure () -> String? = { nil }()
  ) -> SatzError? {
    // check result and update selection
    switch result {
    case .success(let range):
      // update selection
      self.documentManager.textSelection = RhTextSelection(range.endLocation)
      // request updates
      self.needsLayout = true
      self.setNeedsUpdate(selection: true, scroll: true)
      return nil

    case .failure(let error):
      return error
    }
  }

  /// Deal with the result of replacing contents/characters for edit.
  ///
  /// ## Behavior
  /// If the operation succeeds, update the selection. Otherwise, it's an error.
  /// For user error, notify about the operation rejection.
  /// For internal error, assertion failure is triggered.
  private func didReplaceContentsForEdit(
    _ result: SatzResult<RhTextRange>, message: @autoclosure () -> String? = { nil }()
  ) -> EditResult {
    guard let error = didReplaceContents(result, message())
    else { return .success }

    if error.code == .InsertOperationRejected {
      self.notifyOperationRejected()
      return .operationRejected(error)
    }
    else {
      // request updates
      self.needsLayout = true
      self.setNeedsUpdate(selection: true, scroll: true)

      // it is a programming error if this is reached
      let message = message() ?? "Failed to replace contents"
      assertionFailure("\(message): \(error)")
      Rohan.logger.error("\(message): \(error)")
      return .internalError(error)
    }
  }
}
