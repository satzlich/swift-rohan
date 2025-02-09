// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
    var styleSheet: StyleSheet { get }

    // MARK: - State

    /** Cursor in the layout context */
    var layoutCursor: Int { get }

    var isEditing: Bool { get }
    func beginEditing()
    func endEditing()

    // MARK: - Operations

    /** Move cursor backwards */
    func skipBackwards(_ n: Int)
    /** Remove `[layoutCursor-n, layoutCursor)` and move cursor backwards */
    func deleteBackwards(_ n: Int)
    /** Inform the layout context that the frames for `[layoutCursor-n, layoutCursor)`
     now become invalid, and move cursor backwards */
    func invalidateBackwards(_ n: Int)

    /** Insert text at cursor. Cursor remains at the same location. */
    func insertText(_ text: TextNode)
    /** Insert newline at cursor. Cursor remains at the same location. */
    func insertNewline(_ context: Node)
    /** Insert fragment at cursor. Cursor remains at the same location. */
    func insertFragment(_ fragment: LayoutFragment, _ source: Node)
}
