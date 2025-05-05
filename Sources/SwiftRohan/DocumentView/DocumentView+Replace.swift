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

  /// Remove given range and add the given math component to the first object
  /// located to the left of the range if the math component can be added.
  /// If the given math component already exists, only remove the given range.
  /// In both cases, place selection within the math component.
  /// - Returns: On success, an insertion point within the target math component
  ///     and an indicator of whether the component is added.
  /// - Precondition: the given range encloses a piece of text.
  /// - Postcondition: On success, selection is placed at the insertion point.
  internal func attachOrGotoMathComponentForEdit(
    for range: RhTextRange, with component: MathIndex
  ) -> EditResult? {
    precondition(_isEditing == true)

    guard component == .sub || component == .sup
    else {
      assertionFailure("Invalid component: \(component)")
      return .internalError(SatzError(.InvalidMathComponent))
    }

    if let (object, location) = documentManager.upstreamObject(from: range.location) {
      switch object {
      case .text(let string):
        return doReplace(TextNode(string), location)

      case .nonText(let node):
        if let node = node as? AttachNode {
          if let content = node.getComponent(component) {
            // remove range
            do {
              let result = replaceContentsForEdit(in: range, with: nil)
              assert(result.isInternalError == false)
            }
            // goto component
            var indices = location.indices
            indices.append(.index(location.offset))
            indices.append(.mathIndex(component))
            let newLocation = TextLocation(indices, content.childCount)

            guard let newLocation = documentManager.normalizeLocation(newLocation)
            else {
              assertionFailure("Invalid location: \(newLocation)")
              return .internalError(SatzError(.InvalidTextLocation))
            }
            let result = SatzResult.success(RhTextRange(newLocation))
            return performPostEditProcessing(result)
          }
          else {
            // remove range
            do {
              let result = replaceContentsForEdit(in: range, with: nil)
              assert(result.isInternalError == false)
            }
            // add component and register undo
            let endLocation = location.with(offsetDelta: 1)
            let newRange = RhTextRange(location, endLocation)!
            let result = addMathComponentForEdit(for: newRange, with: component)
            return performPostEditProcessing(result)
          }
        }
        else {
          return doReplace(node, location)
        }
      }
    }
    else {
      // no-op
      return nil
    }

    // Helper

    func doReplace(_ node: Node, _ location: TextLocation) -> EditResult {
      guard let newRange = RhTextRange(location, range.endLocation)
      else {
        assertionFailure("Invalid range: \(range)")
        return .internalError(SatzError(.InvalidTextRange))
      }
      let content = composeContent(node, component)
      let result = replaceContentsForEdit(in: newRange, with: content)
      assert(result.isInternalError == false)
      self.moveBackward(nil)
      return result
    }

    func composeContent(_ node: Node, _ component: MathIndex) -> [Node] {
      precondition(component == .sub || component == .sup)
      let attachNode =
        component == .sub
        ? AttachNode(nuc: [node.deepCopy()], sub: [])
        : AttachNode(nuc: [node.deepCopy()], sup: [])
      return [attachNode]
    }
  }

  /// Add the given math component to the __AttachNode__ at the given range.
  /// - Returns: The new range of selection
  private func addMathComponentForEdit(
    for range: RhTextRange, with component: MathIndex
  ) -> SatzResult<RhTextRange> {
    precondition(_isEditing == true)

    let location = range.location

    let isAdded = documentManager.addMathComponent(location, component)
    assert(isAdded == true)
    if isAdded {
      registerUndoAddMathComponent(for: range, with: component, _undoManager)
      var indices = location.indices
      indices.append(.index(location.offset))
      indices.append(.mathIndex(component))
      let newLocation = TextLocation(indices, 0)
      let newRange = RhTextRange(newLocation)
      return .success(newRange)
    }
    else {
      assertionFailure("Failed to add math component")
      return .failure(SatzError(.InvalidTextRange))
    }
  }

  /// Remove the math component from the __AttachNode__ at the given range.
  /// - Returns: The new range of selection
  private func removeMathComponentForEdit(
    for range: RhTextRange, with component: MathIndex
  ) -> SatzResult<RhTextRange> {
    precondition(_isEditing == true)

    let location = range.location

    let isRemoved = documentManager.removeMathComponent(location, component)
    assert(isRemoved == true)
    if isRemoved {
      registerUndoRemoveMathComponent(for: range, with: component, _undoManager)
      let newRange = RhTextRange(range.endLocation)
      return .success(newRange)
    }
    else {
      assertionFailure("Failed to remove math component")
      return .failure(SatzError(.InvalidTextRange))
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
        precondition(target._isEditing == true)

        let string = textNode.string
        let result = target.replaceCharacters(in: range, with: string, registerUndo: true)
        target.updateSelectionOrAssertFailure(result)
      }
    }
    else {
      undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
        precondition(target._isEditing == true)

        let result = target.replaceContents(in: range, with: nodes, registerUndo: true)
        target.updateSelectionOrAssertFailure(result)
      }
    }
  }

  private func registerUndoAddMathComponent(
    for range: RhTextRange, with component: MathIndex, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)
    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target.removeMathComponentForEdit(for: range, with: component)
      target.updateSelectionOrAssertFailure(result)
    }
  }

  private func registerUndoRemoveMathComponent(
    for range: RhTextRange, with component: MathIndex, _ undoManager: UndoManager
  ) {
    precondition(undoManager.isUndoRegistrationEnabled)
    undoManager.registerUndo(withTarget: self) { (target: DocumentView) in
      let result = target.addMathComponentForEdit(for: range, with: component)
      target.updateSelectionOrAssertFailure(result)
    }
  }

  private func updateSelectionOrAssertFailure(_ result: SatzResult<RhTextRange>) {
    switch result {
    case let .success(range):
      self.documentManager.textSelection = RhTextSelection(range.endLocation)

    case let .failure(error):
      assertionFailure("Unexpected error: \(error)")
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
        self.notifyOperationRejected()
        return .userError(error)
      }
      else {
        assertionFailure("Unexpected error: \(error)")
        return .internalError(error)
      }
    }
  }
}
