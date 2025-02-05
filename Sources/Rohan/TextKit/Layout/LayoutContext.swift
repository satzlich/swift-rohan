// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
    var styleSheet: StyleSheet { get }

    // MARK: - State

    /** Cursor in the layout context */
    var cursor: Int { get }

    var isEditing: Bool { get }
    func beginEditing()
    func endEditing()

    // MARK: - Operations

    /** Move cursor back */
    func skipBackwards(_ n: Int)
    /** Remove `[cursor-n, cursor)` and move cursor back */
    func deleteBackwards(_ n: Int)
    /** Inform the layout context that the frames for `[cursor-n, cursor)` now
     become invalid, and move cursor back */
    func invalidateBackwards(_ n: Int)

    /** Insert text at cursor. Cursor isn't moved. */
    func insertText(_ text: TextNode)
    /** Insert newline at cursor. Cursor isn't moved. */
    func insertNewline(_ context: Node)
    /** Insert fragment at cursor. Cursor isn't moved. */
    func insertFragment(_ fragment: LayoutFragment, _ source: Node)
}
