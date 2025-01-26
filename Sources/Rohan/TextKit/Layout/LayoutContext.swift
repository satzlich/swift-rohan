// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
    var cursor: Int { get }

    // MARK: - State

    var isEditing: Bool { get }
    func beginEditing()
    func endEditing()

    // MARK: - Operations

    func skipBackwards(_ n: Int)
    func deleteBackwards(_ n: Int)
    func insertText(_ text: TextNode)
    func insertNewline()
    func insertFragment(_ fragment: LayoutFragment)
}
