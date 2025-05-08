// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentView {
  // MARK: - Math Component

  @objc func removeSuperscript(_ sender: Any?) {
    _removeMathComponent(.sup)
  }

  @objc func removeSubscript(_ sender: Any?) {
    _removeMathComponent(.sub)
  }

  /// Remove math component from the math node determined by the current selection.
  private func _removeMathComponent(_ mathIndex: MathIndex) {
    guard let range = documentManager.textSelection?.textRange,
      range.isEmpty,
      let (node, location) = documentManager.contextualNode(for: range.location),
      isAttachNode(node)
    else {
      return
    }
    let end = location.with(offsetDelta: 1)
    let target = RhTextRange(location, end)!

    beginEditing()
    defer { endEditing() }
    _ = removeMathComponentForEdit(target, mathIndex)
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
}
