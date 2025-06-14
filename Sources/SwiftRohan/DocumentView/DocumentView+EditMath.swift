// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  // MARK: - Math Component

  @objc func removeLeftSuperscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.lsup))
  }

  @objc func addLeftSuperscript(_ sender: Any?) {
    _performMathOperation(.attachOrGotoComponent(.lsup))
  }

  @objc func removeLeftSubscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.lsub))
  }

  @objc func addLeftSubscript(_ sender: Any?) {
    _performMathOperation(.attachOrGotoComponent(.lsub))
  }

  @objc func removeSuperscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.sup))
  }

  @objc func addSuperscript(_ sender: Any?) {
    _performMathOperation(.attachOrGotoComponent(.sup))
  }

  @objc func removeSubscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.sub))
  }

  @objc func addSubscript(_ sender: Any?) {
    _performMathOperation(.attachOrGotoComponent(.sub))
  }

  @objc func addDegree(_ sender: Any?) {
    _performMathOperation(.attachOrGotoComponent(.index))
  }

  @objc func removeDegree(_ sender: Any?) {
    _performMathOperation(.removeComponent(.index))
  }

  /// Perform operation on math node.
  private func _performMathOperation(_ instruction: CommandBody.EditMath) {
    guard let range = documentManager.textSelection?.textRange,
      range.isEmpty,
      let (node, location, _) = documentManager.contextualNode(for: range.location)
    else {
      return
    }
    let end = location.with(offsetDelta: 1)
    let target = RhTextRange(location, end)!

    beginEditing()
    defer { endEditing() }

    switch instruction {
    case let .attachOrGotoComponent(mathIndex):
      _ = addMathComponentForEdit(target, mathIndex, [])

    case let .removeComponent(mathIndex):
      guard isAttachNode(node) || isRadicalNode(node)
      else { return }
      _ = removeMathComponentForEdit(target, mathIndex)
    }
  }

  // MARK: - Grid

  @objc func insertRowBefore(_ sender: Any?) {
    _performGridOperation(.insertRowBefore)
  }

  @objc func insertRowAfter(_ sender: Any?) {
    _performGridOperation(.insertRowAfter)
  }

  @objc func insertColumnBefore(_ sender: Any?) {
    _performGridOperation(.insertColumnBefore)
  }

  @objc func insertColumnAfter(_ sender: Any?) {
    _performGridOperation(.insertColumnAfter)
  }

  @objc func deleteRow(_ sender: Any?) {
    _performGridOperation(.deleteRow)
  }

  @objc func deleteColumn(_ sender: Any?) {
    _performGridOperation(.deleteColumn)
  }

  private func _performGridOperation(_ instruction: CommandBody.EditArray) {
    guard let range = documentManager.textSelection?.textRange,
      range.isEmpty,
      let (node, location, childIndex) =
        documentManager.contextualNode(for: range.location),
      let node = node as? ArrayNode,
      case let .gridIndex(gridIndex) = childIndex
    else {
      return
    }
    let nrows = node.rowCount
    let ncols = node.columnCount
    let i = gridIndex.row
    let j = gridIndex.column

    let end = location.with(offsetDelta: 1)
    let target = RhTextRange(location, end)!

    beginEditing()
    defer { endEditing() }

    func elements(_ n: Int) -> Array<Array<Node>> {
      (0..<n).map { _ in Array() }
    }

    switch instruction {
    case .insertRowBefore:
      let operation: GridOperation = .insertRow(elements(ncols), at: i)
      _ = modifyGridForEdit(target, operation)

    case .insertRowAfter:
      let operation: GridOperation = .insertRow(elements(ncols), at: i + 1)
      _ = modifyGridForEdit(target, operation)

    case .insertColumnBefore:
      let operation: GridOperation = .insertColumn(elements(nrows), at: j)
      _ = modifyGridForEdit(target, operation)

    case .insertColumnAfter:
      let operation: GridOperation = .insertColumn(elements(nrows), at: j + 1)
      _ = modifyGridForEdit(target, operation)

    case .deleteRow:
      _ = modifyGridForEdit(target, .removeRow(at: i))

    case .deleteColumn:
      _ = modifyGridForEdit(target, .removeColumn(at: j))
    }
  }
}
