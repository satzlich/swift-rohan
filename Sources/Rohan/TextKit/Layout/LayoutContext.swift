// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
    var cursor: Int { get }
    var styleSheet: StyleSheet { get }

    // MARK: - State

    var isEditing: Bool { get }
    func beginEditing()
    func endEditing()

    // MARK: - Operations

    /** Move cursor */
    func skipBackwards(_ n: Int)
    /** Remove `[cursor-n, cursor)` and move cursor */
    func deleteBackwards(_ n: Int)
    /** Inform the layout context that the frames for `[cursor-n, cursor)` now
     become invalid, and move cursor */
    func invalidateBackwards(_ n: Int)

    func insertText(_ text: TextNode)
    func insertNewline()
    func insertFragment(_ fragment: LayoutFragment)
}
