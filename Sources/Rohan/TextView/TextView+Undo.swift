// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public final override var undoManager: UndoManager? { self._undoManager }

  @objc public func redo(_ sender: Any?) {
    guard let undoManager = self.undoManager else { return }

    documentManager.beginEditing()
    undoManager.redo()
    documentManager.endEditing()
  }

  @objc public func undo(_ sender: Any?) {
    guard let undoManager = self.undoManager else { return }

    documentManager.beginEditing()
    undoManager.undo()
    documentManager.endEditing()
  }
}
