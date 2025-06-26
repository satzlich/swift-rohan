// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

extension DocumentView {

  // MARK: - Replace Contents

  /// Replace the contents in the given range with nodes.
  /// Undo registration is always enabled.
  /// - Note: For internal error, assertion failure is triggered.
  @discardableResult
  internal func replaceContentsForEdit(
    in range: RhTextRange, with nodes: Array<Node>?
  ) -> EditResult<RhTextRange> {
    precondition(_isEditing)
    let result = replaceContents(in: range, with: nodes, registerUndo: true)
    return performPostEditProcessing(result)
  }

  internal func replaceCharacters(
    in range: RhTextRange, with string: String, registerUndo: Bool
  ) -> EditResult<RhTextRange> {
    replaceCharacters(in: range, with: BigString(string), registerUndo: registerUndo)
  }

  /// Replace the contents in the given range with string.
  /// - Note: For internal error, assertion failure is triggered.
  internal func replaceCharactersForEdit(
    in range: RhTextRange, with string: String
  ) -> EditResult<RhTextRange> {
    precondition(_isEditing == true)
    let result = replaceCharacters(in: range, with: BigString(string), registerUndo: true)
    return performPostEditProcessing(result)
  }

  private func replaceCharacters(
    in range: RhTextRange, with string: BigString, registerUndo: Bool
  ) -> EditResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceCharacters(in: range, with: string)
    }
  }

  private func replaceContents(
    in range: RhTextRange, with nodes: Array<Node>?, registerUndo: Bool
  ) -> EditResult<RhTextRange> {
    _replaceContents(in: range, registerUndo: registerUndo) { range in
      documentManager.replaceContents(in: range, with: nodes)
    }
  }

  /// Replace the contents in the given range with replacementHandler.
  /// If the operation succeeds, register an undo action.
  private func _replaceContents(
    in range: RhTextRange, registerUndo: Bool,
    _ replacementHandler: (RhTextRange) -> EditResult<RhTextRange>
  ) -> EditResult<RhTextRange> {
    guard let undoManager = self.undoManager,
      registerUndo && undoManager.isUndoRegistrationEnabled
    else {
      return replacementHandler(range)
    }

    // register undo action is required below

    // copy contents to be replaced
    let contentsCopy: Array<Node>? =
      documentManager.mapContents(in: range, { $0.deepCopy() })
    guard let contentsCopy else {
      assertionFailure("contentsCopy should not be nil")
      return .failure(SatzError(.ReplaceContentsFailure))
    }

    // perform replacement
    let result = replacementHandler(range)
    switch result {
    case let .success(range),
      let .extraParagraph(range),
      let .blockInserted(range):

      // register undo action
      registerUndoReplaceContents(for: range, with: contentsCopy, undoManager)

    case .failure(let error):
      assert(error.code.type == .UserError)  // user error is okay
    }
    return result

  }

  private func registerUndoReplaceContents(
    for range: RhTextRange, with nodes: Array<Node>?, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    if let textNode = nodes?.getOnlyElement() as? TextNode {
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

  // MARK: - Edit Math

  /// Add the math component to the node/nodes at the given range.
  /// - Returns: The new range of selection
  internal func addMathComponentForEdit(
    _ range: RhTextRange, _ mathIndex: MathIndex, _ component: ElementStore
  ) -> EditResult<RhTextRange> {
    let result = _attachOrGotoMathComponent(for: range, with: mathIndex, component)
    return performPostEditProcessing(result)
  }

  /// Remove the math component from the math node at the given range.
  /// - Returns: The new range of selection
  internal func removeMathComponentForEdit(
    _ range: RhTextRange, _ mathIndex: MathIndex
  ) -> EditResult<RhTextRange> {
    let result = _removeMathComponent(for: range, with: mathIndex)
    return performPostEditProcessing(result)
  }

  /// Add the math component to the node/nodes at the given range. Undo action is
  /// registered.
  /// - Returns: The new range of selection
  private func _attachOrGotoMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex, _ component: ElementStore
  ) -> EditResult<RhTextRange> {
    precondition(_isEditing == true)
    precondition(range.isEmpty == false)

    let result = documentManager.attachOrGotoMathComponent(range, mathIndex, component)

    switch result {
    case .success(let (newRange, isAdded)):
      if isAdded && _undoManager.isUndoRegistrationEnabled {
        registerUndoAddMathComponent(for: newRange, with: mathIndex, _undoManager)
      }

      if let newLocation =
        documentManager.descendTo(newRange.location, Either.Left(mathIndex))
      {
        return .success(RhTextRange(newLocation))
      }
      else {
        return .failure(SatzError(.ModifyMathFailure))
      }

    case .failure(let error):
      return .failure(error)
    }
  }

  /// Remove the math component from the math node at the given range. Undo action
  /// is registered.
  /// - Returns: The new range of selection
  private func _removeMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex
  ) -> EditResult<RhTextRange> {
    precondition(_isEditing == true)
    precondition(range.isEmpty == false)

    let componentCopy: ElementStore
    do {
      let path = range.location.asArray + [.mathIndex(mathIndex)]
      guard let node = documentManager.getNode(at: path),
        let node = node as? ContentNode
      else {
        return .failure(SatzError(.ModifyMathFailure))
      }
      componentCopy = ElementStore(node.childrenReadonly().lazy.map { $0.deepCopy() })
    }

    let result = documentManager.removeMathComponent(range, mathIndex)

    return result.map { range in
      if _undoManager.isUndoRegistrationEnabled {
        registerUndoRemoveMathComponent(
          for: range, with: mathIndex, componentCopy, _undoManager)
      }
      let newRange = RhTextRange(range.endLocation)
      return newRange
    }
  }

  private func registerUndoAddMathComponent(
    for range: RhTextRange, with component: MathIndex, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target._removeMathComponent(for: range, with: component)
      _ = target.performPostEditProcessing(result)
    }
  }

  private func registerUndoRemoveMathComponent(
    for range: RhTextRange, with mathIndex: MathIndex, _ component: ElementStore,
    _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result =
        target._attachOrGotoMathComponent(for: range, with: mathIndex, component)
      _ = target.performPostEditProcessing(result)
    }
  }

  // MARK: - Edit Grid

  /// Modify grid for edit.
  /// - Returns: The new range of selection.
  internal func modifyGridForEdit(
    _ range: RhTextRange, _ instruction: GridOperation
  ) -> EditResult<RhTextRange> {
    let result = _modifyGrid(range, instruction)
    return performPostEditProcessing(result)
  }

  /// Modify grid as specified by the instruction. Undo action is registered.
  private func _modifyGrid(
    _ range: RhTextRange, _ instruction: GridOperation
  ) -> EditResult<RhTextRange> {
    precondition(_isEditing == true)
    precondition(range.isEmpty == false)

    let undoAction: GridOperation
    switch instruction {
    case let .insertRow(_, at: row):
      undoAction = GridOperation.removeRow(at: row)

    case let .insertColumn(_, at: column):
      undoAction = GridOperation.removeColumn(at: column)

    case let .removeRow(row):
      guard let rowCopy: Array<Array<Node>> = makeRowCopy(row)
      else {
        assertionFailure("failed to copy row")
        return .failure(SatzError(.ModifyGridFailure))
      }
      undoAction = GridOperation.insertRow(rowCopy, at: row)

    case let .removeColumn(column):
      guard let columnCopy: Array<Array<Node>> = makeColumnCopy(column)
      else {
        assertionFailure("failed to copy column")
        return .failure(SatzError(.ModifyGridFailure))
      }
      undoAction = GridOperation.insertColumn(columnCopy, at: column)
    }

    let result = documentManager.modifyGrid(range, instruction)

    switch result {
    case .success(let range):
      if _undoManager.isUndoRegistrationEnabled {
        registerUndoModifyGrid(for: range, with: undoAction, _undoManager)
      }
      switch instruction {
      case .insertRow(_, at: let row):
        let gridIndex = GridIndex(row, 0)
        guard
          let location =
            documentManager.descendTo(range.location, Either.Right(gridIndex))
        else {
          assertionFailure("failed to compose location")
          return .failure(SatzError(.ModifyGridFailure))
        }
        let newRange = RhTextRange(location)
        return .success(newRange)

      case .insertColumn(_, at: let column):
        let gridIndex = GridIndex(0, column)
        guard
          let location =
            documentManager.descendTo(range.location, Either.Right(gridIndex))
        else {
          assertionFailure("failed to compose location")
          return .failure(SatzError(.ModifyGridFailure))
        }
        let newRange = RhTextRange(location)
        return .success(newRange)

      case .removeRow, .removeColumn:
        let newRange = RhTextRange(range.endLocation)
        return .success(newRange)
      }

    case .failure(let error):
      return .failure(error)
    }

    // Helper

    func makeRowCopy(_ row: Int) -> Array<Array<Node>>? {
      guard let node = documentManager.getNode(at: range.location),
        let node = node as? ArrayNode
      else {
        return nil
      }
      let ncols = node.columnCount
      return (0..<ncols).map { col in
        node.getElement(row, col).childrenReadonly().map { $0.deepCopy() }
      }
    }

    func makeColumnCopy(_ column: Int) -> Array<Array<Node>>? {
      guard let node = documentManager.getNode(at: range.location),
        let node = node as? ArrayNode
      else {
        return nil
      }
      let nrows = node.rowCount
      return (0..<nrows).map { row in
        node.getElement(row, column).childrenReadonly().map { $0.deepCopy() }
      }
    }
  }

  private func registerUndoModifyGrid(
    for range: RhTextRange, with instruction: GridOperation, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)

    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target._modifyGrid(range, instruction)
      _ = target.performPostEditProcessing(result)
    }
  }

  // MARK: - Post Edit Processing

  private func performPostEditProcessing(
    _ result: EditResult<RhTextRange>
  ) -> EditResult<RhTextRange> {
    switch result {
    // for editing operation, affinity is always upstream.
    case let .success(range):
      let target = range.endLocation
      let affinity = documentManager.resolveAffinityForMove(in: .forward, target: target)
      documentManager.textSelection = RhTextSelection(target, affinity: affinity)

    case let .extraParagraph(range):
      documentManager.textSelection =
        RhTextSelection(range.endLocation, affinity: .upstream)
      moveBackward(nil)  // move backward to the end of the new paragraph

    case let .blockInserted(range):
      documentManager.textSelection =
        RhTextSelection(range.endLocation, affinity: .downstream)

    case let .failure(error):
      if error.code.type == .UserError {
        if error.code == .InsertOperationRejected {
          notifyOperationIsRejected()
        }
      }
      else {
        assertionFailure("Unexpected error: \(error)")
      }
    }

    return result
  }
}
