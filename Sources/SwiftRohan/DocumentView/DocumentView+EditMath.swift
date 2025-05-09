// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  // MARK: - Math Component

  @objc func removeSuperscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.sup))
  }

  @objc func removeSubscript(_ sender: Any?) {
    _performMathOperation(.removeComponent(.sub))
  }

  @objc func addDegree(_ sender: Any?) {
    _performMathOperation(.addComponent(.index))
  }

  @objc func removeDegree(_ sender: Any?) {
    _performMathOperation(.removeComponent(.index))
  }

  /// Perform operation on math node.
  private func _performMathOperation(_ instruction: CommandBody.EditMath) {
    guard let range = documentManager.textSelection?.textRange,
      range.isEmpty,
      let (node, location) = documentManager.contextualNode(for: range.location)
    else {
      return
    }
    let end = location.with(offsetDelta: 1)
    let target = RhTextRange(location, end)!

    beginEditing()
    defer { endEditing() }

    switch instruction {
    case let .addComponent(mathIndex):
      _ = addMathComponentForEdit(target, mathIndex, [])

    case let .removeComponent(mathIndex):
      guard isAttachNode(node) || isRadicalNode(node)
      else { return }
      _ = removeMathComponentForEdit(target, mathIndex)
    }
  }

  // MARK: - Grid

  @objc func insertRowBefore(_ sender: Any?) {

  }

  @objc func insertRowAfter(_ sender: Any?) {
  }

  @objc func insertColumnBefore(_ sender: Any?) {
  }

  @objc func insertColumnAfter(_ sender: Any?) {
  }

  @objc func deleteRow(_ sender: Any?) {
  }

  @objc func deleteColumn(_ sender: Any?) {
  }

  private func _performGridOperation(_ instruction: CommandBody.EditGrid) {
  }
}
