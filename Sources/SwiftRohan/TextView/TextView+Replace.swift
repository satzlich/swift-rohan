// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension TextView {

  /// Replace the contents in the given range with nodes.
  /// Undo registration is always enabled.
  /// - Note: For internal error, assertion failure is triggered.
  @discardableResult
  internal func replaceContentsForEdit(
    in range: RhTextRange, with nodes: [Node]?,
    message: @autoclosure () -> String? = { nil }()
  ) -> EditResult {
    let result = replaceContents(in: range, with: nodes, registerUndo: true)
    return performPostEditProcessing(result)
  }

  internal func replaceCharacters(
    in range: RhTextRange, with string: String, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    self.replaceCharacters(in: range, with: BigString(string), registerUndo: registerUndo)
  }

  /// Replace the contents in the given range with string.
  /// - Note: For internal error, assertion failure is triggered.
  internal func replaceCharactersForEdit(
    in range: RhTextRange, with string: String
  ) -> EditResult {
    self.replaceCharactersForEdit(in: range, with: BigString(string))
  }

  // MARK: - private

  private func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  private func replaceCharactersForEdit(
    in range: RhTextRange, with string: BigString
  ) -> EditResult {
    let result = replaceCharacters(in: range, with: string, registerUndo: true)
    return performPostEditProcessing(result)
  }

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
        target.updateSelectionOrAssertFailure(result)
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { (target: TextView) in
        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        target.updateSelectionOrAssertFailure(result)
      }
    }
  }

  private func updateSelectionOrAssertFailure(_ result: SatzResult<RhTextRange>) {
    switch result {
    case let .success(range):
      self.documentManager.textSelection = RhTextSelection(range.endLocation)
      self.needsLayout = true
      self.setNeedsUpdate(selection: true, scroll: true)

    case let .failure(error):
      assertionFailure("Unexpected error: \(error)")
    }
  }

  private func performPostEditProcessing(_ result: SatzResult<RhTextRange>) -> EditResult
  {
    switch result {
    case .success(let range):
      self.documentManager.textSelection = RhTextSelection(range.endLocation)
      self.needsLayout = true
      self.setNeedsUpdate(selection: true, scroll: true)
      return .success(range)

    case let .failure(error):
      if error.code == .InsertOperationRejected {
        self.notifyOperationRejected()
        return .operationRejected(error)
      }
      else {
        assertionFailure("Unexpected error: \(error)")
        self.needsLayout = true
        self.setNeedsUpdate(selection: true, scroll: true)
        return .internalError(error)
      }
    }
  }

}
