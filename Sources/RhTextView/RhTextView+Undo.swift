// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    override public var undoManager: UndoManager? {
        _undoManager
    }

    @objc func undo(_ sender: Any?) {
        print("undo")
    }

    @objc func redo(_ sender: Any?) {
        print("redo")
    }
}
