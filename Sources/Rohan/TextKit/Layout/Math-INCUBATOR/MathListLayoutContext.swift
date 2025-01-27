// Copyright 2024-2025 Lie Yan

import Foundation

final class MathListLayoutContext: LayoutContext {
    private(set) var cursor: Int = 0
    let styleSheet: StyleSheet

    private(set) var isEditing: Bool = false

    /* index in the math list fragment*/
    private var _index: Int = 0
    private(set) var mathListLayoutFragment: MathListLayoutFragment

    // MARK: - Context

    public let mathStyle: MathStyle
    public let cramped: Bool
    /** Math context (intended for reuse in descendants) */
    public private(set) var mathContext: MathContext

    init(_ styleSheet: StyleSheet,
         _ mathStyle: MathStyle,
         _ cramped: Bool,
         _ mathContext: MathContext,
         _ mathListLayoutFragment: MathListLayoutFragment)
    {
        self.cursor = mathListLayoutFragment.layoutLength
        self.styleSheet = styleSheet

        self.mathStyle = mathStyle
        self.cramped = cramped
        self.mathContext = mathContext

        self._index = mathListLayoutFragment.count
        self.mathListLayoutFragment = mathListLayoutFragment
    }

    func beginEditing() {
        precondition(isEditing == false)
        isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        isEditing = false
        mathListLayoutFragment.fragmentsDidChange(mathContext, mathStyle)
    }

    func skipBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, nsOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // update location
        _index = index
        cursor -= n
    }

    func deleteBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, nsOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // remove
        mathListLayoutFragment.removeSubrange(index ..< _index)

        // update location
        _index = index
        cursor -= n
    }

    func invalidateBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, nsOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // update location
        _index = index
        cursor -= n
    }

    func insertText(_ text: TextNode) {
        let mathProperty = text.resolveProperties(styleSheet) as MathProperty
        let font = mathContext.getFont(for: mathProperty.style)

        let string = text.string

        // TODO: handle characters beyond the font's support
        let fragments: [any MathLayoutFragment] = string.unicodeScalars
            .map { char in
                MathUtils.styledChar(char, mathProperty.variant,
                                     bold: mathProperty.bold,
                                     italic: mathProperty.italic,
                                     autoItalic: true)
            }
            .compactMap { MathGlyphLayoutFragment($0, font, mathContext.table, 1) }
        assert(fragments.count == text.layoutLength)
        mathListLayoutFragment.insert(contentsOf: fragments, at: _index)
    }

    func insertNewline() {
        preconditionFailure("newline is not allowed in math list")
    }

    func insertFragment(_ fragment: any LayoutFragment) {
        precondition(isEditing && cursor >= 0 && fragment is MathLayoutFragment)

        // insert
        mathListLayoutFragment.insert(fragment as! MathLayoutFragment, at: _index)
    }
}
