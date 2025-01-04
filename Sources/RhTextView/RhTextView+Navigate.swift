// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    // MARK: - MoveAndModifySelection

    override open func moveLeft(_ sender: Any?) {
        updateTextSelections(
            direction: .backward,
            destination: .character,
            extending: false,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveLeftAndModifySelection(_ sender: Any?) {
        updateTextSelections(
            direction: .backward,
            destination: .character,
            extending: true,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveRight(_ sender: Any?) {
        updateTextSelections(
            direction: .forward,
            destination: .character,
            extending: false,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveRightAndModifySelection(_ sender: Any?) {
        updateTextSelections(
            direction: .forward,
            destination: .character,
            extending: true,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveUp(_ sender: Any?) {
        updateTextSelections(
            direction: .up,
            destination: .character,
            extending: false,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveUpAndModifySelection(_ sender: Any?) {
        updateTextSelections(
            direction: .up,
            destination: .character,
            extending: true,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveDown(_ sender: Any?) {
        updateTextSelections(
            direction: .down,
            destination: .character,
            extending: false,
            confined: false
        )
        reconcileSelection()
    }

    override open func moveDownAndModifySelection(_ sender: Any?) {
        updateTextSelections(
            direction: .down,
            destination: .character,
            extending: true,
            confined: false
        )
        reconcileSelection()
    }
}
