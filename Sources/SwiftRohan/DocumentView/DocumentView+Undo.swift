// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  public final override var undoManager: UndoManager? { self._undoManager }

  @objc public func redo(_ sender: Any?) {
    guard let undoManager = self.undoManager else { return }

    undoManager.redo()
    self.needsLayout = true
    self.setNeedsUpdate(selection: true, scroll: true)
  }

  @objc public func undo(_ sender: Any?) {
    guard let undoManager = self.undoManager else { return }

    undoManager.undo()
    self.needsLayout = true
    self.setNeedsUpdate(selection: true, scroll: true)
  }
}
