// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension DocumentView {

  /// Replace the contents in the given range with nodes.
  /// Undo registration is always enabled.
  /// - Note: For internal error, assertion failure is triggered.
  @discardableResult
  internal func replaceContentsForEdit(
    in range: RhTextRange, with nodes: [Node]?,
    message: @autoclosure () -> String? = { nil }()
  ) -> EditResult {
    precondition(_isEditing == true)
    let result = replaceContents(in: range, with: nodes, registerUndo: true)
    return performPostEditProcessing(result)
  }

  internal func replaceCharacters(
    in range: RhTextRange, with string: String, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    replaceCharacters(in: range, with: BigString(string), registerUndo: registerUndo)
  }

  /// Replace the contents in the given range with string.
  /// - Note: For internal error, assertion failure is triggered.
  internal func replaceCharactersForEdit(
    in range: RhTextRange, with string: String
  ) -> EditResult {
    precondition(_isEditing == true)
    let result = replaceCharacters(in: range, with: BigString(string), registerUndo: true)
    return performPostEditProcessing(result)
  }

  /// Add the math component to the node/nodes at the given range.
  /// - Returns: The new range of selection
  internal func addMathComponentForEdit(
    _ range: RhTextRange, _ mathIndex: MathIndex, _ component: [Node]
  ) -> EditResult {
    let result = addMathComponent(for: range, with: mathIndex, component)
    return performPostEditProcessing(result)
  }

  /// Add the math component to the node/nodes at the given range. Undo action is
  /// registered.
  /// - Returns: The new range of selection
  private func addMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex, _ component: [Node]
  ) -> SatzResult<RhTextRange> {
    precondition(_isEditing == true)
    precondition(range.isEmpty == false)

    let result = documentManager.addMathComponent(range, mathIndex, component)

    switch result {
    case .success(let (newRange, isAdded)):
      if isAdded && _undoManager.isUndoRegistrationEnabled {
        registerUndoAddMathComponent(for: newRange, with: mathIndex, _undoManager)
      }

      if let newLocation = composeLocation(newRange.location, mathIndex) {
        return .success(RhTextRange(newLocation))
      }
      else {
        return .failure(SatzError(.InvalidTextLocation))
      }

    case .failure(let error):
      return .failure(error)
    }

    // Helper
    func composeLocation(
      _ location: TextLocation, _ mathIndex: MathIndex
    ) -> TextLocation? {
      var indices = location.indices
      indices.append(.index(location.offset))
      indices.append(.mathIndex(mathIndex))
      guard let node = documentManager.getNode(at: indices),
        let node = node as? ContentNode
      else {
        return nil
      }
      let newLocation = TextLocation(indices, node.childCount)
      return documentManager.normalizeLocation(newLocation)
    }
  }

  /// Remove the math component from the math node at the given range. Undo action
  /// is registered.
  /// - Returns: The new range of selection
  private func removeMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex
  ) -> SatzResult<RhTextRange> {
    precondition(_isEditing == true)
    precondition(range.isEmpty == false)

    let componentCopy: [Node]
    do {
      let path = range.location.asPath + [.mathIndex(mathIndex)]
      guard let node = documentManager.getNode(at: path),
        let node = node as? ContentNode
      else {
        return .failure(SatzError(.InvalidTextLocation))
      }
      componentCopy = node.getChildren_readonly().map { $0.deepCopy() }
    }

    let result = documentManager.removeMathComponent(range, mathIndex)
    switch result {
    case .success(let range):
      if _undoManager.isUndoRegistrationEnabled {
        registerUndoRemoveMathComponent(
          for: range, with: mathIndex, componentCopy, _undoManager)
      }
      let newRange = RhTextRange(range.endLocation)
      return .success(newRange)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: - private

  private func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> SatzResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
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
    guard let contentsCopy
    else {
      assertionFailure("contentsCopy should not be nil")
      return .failure(SatzError(.InvalidTextRange))
    }

    // perform replacement
    let result = replacementHandler(range)
    switch result {
    case .success(let insertedRange):
      // register undo action
      registerUndoReplaceContents(for: insertedRange, with: contentsCopy, undoManager)
      return result

    case .failure(let error):
      if error.code.type == .UserError {
        // user error is okay
        return result
      }
      else {
        assertionFailure("failed to replace contents")
        return result
      }
    }
  }

  private func registerUndoReplaceContents(
    for range: RhTextRange, with nodes: [Node]?, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    if let textNode = nodes?.getOnlyTextNode() {
      undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
        let string = textNode.string
        let result = target.replaceCharacters(in: range, with: string, registerUndo: true)
        _ = target.performPostEditProcessing(result)
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        _ = target.performPostEditProcessing(result)
      }
    }
  }

  private func registerUndoAddMathComponent(
    for range: RhTextRange, with component: MathIndex, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target.removeMathComponent(for: range, with: component)
      _ = target.performPostEditProcessing(result)
    }
  }

  private func registerUndoRemoveMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex, _ component: [Node],
    _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target.addMathComponent(for: range, with: mathIndex, component)
      _ = target.performPostEditProcessing(result)
    }
  }

  private func performPostEditProcessing(_ result: SatzResult<RhTextRange>) -> EditResult
  {
    switch result {
    case .success(let range):
      documentManager.textSelection = RhTextSelection(range.endLocation)
      return .success(range)

    case let .failure(error):
      if error.code == .InsertOperationRejected {
        notifyOperationRejected()
        return .userError(error)
      }
      else {
        assertionFailure("Unexpected error: \(error)")
        return .internalError(error)
      }
    }
  }
}
