// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public final override var undoManager: UndoManager? { self._undoManager }

  /// - Note: add `@objc` to make this method available
  @objc public func redo(_ sender: Any?) {
    print("redo")
  }

  /// - Note: add `@objc` to make this method available
  @objc public func undo(_ sender: Any?) {
    print("undo")
  }
}
