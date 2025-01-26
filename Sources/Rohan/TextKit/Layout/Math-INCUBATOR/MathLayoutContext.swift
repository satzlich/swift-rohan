// Copyright 2024-2025 Lie Yan

final class MathLayoutContext: LayoutContext {
    private(set) var cursor: Int = 0
    private(set) var isEditing: Bool = false

    func beginEditing() {
        precondition(isEditing == false)
        isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        isEditing = false
    }

    func skipBackwards(_ n: Int) {
        preconditionFailure()
    }

    func deleteBackwards(_ n: Int) {
        preconditionFailure()
    }

    func insertText(_ text: TextNode) {
        preconditionFailure()
    }

    func insertNewline() {
        preconditionFailure()
    }

    func insertFragment(_ fragment: any LayoutFragment) {
        preconditionFailure()
    }
}
