import AppKit
import Foundation

extension DocumentView {
  public final override var undoManager: UndoManager? { self._undoManager }

  @objc public func redo(_ sender: Any?) {
    guard let undoManager = self.undoManager,
      undoManager.canRedo
    else { return }

    beginEditing()
    defer { endEditing() }
    undoManager.redo()
  }

  @objc public func undo(_ sender: Any?) {
    guard let undoManager = self.undoManager,
      undoManager.canUndo
    else { return }

    beginEditing()
    defer { endEditing() }
    undoManager.undo()
  }
}
