// Copyright 2024-2025 Lie Yan

import Foundation

final class MathListLayoutContext: LayoutContext {
    private(set) var cursor: Int = 0
    let styleSheet: StyleSheet

    private(set) var isEditing: Bool = false

    /** index in the math list fragment */
    private var _index: Int = 0
    /** index where the latest modification is made */
    var _dirtyIndex: Int = 0
    private(set) var mathListLayoutFragment: MathListLayoutFragment

    // MARK: - Context

    /** Math context (intended for reuse in descendants) */
    public private(set) var mathContext: MathContext

    init(_ styleSheet: StyleSheet,
         _ mathContext: MathContext,
         _ mathListLayoutFragment: MathListLayoutFragment)
    {
        self.cursor = mathListLayoutFragment.layoutLength
        self.styleSheet = styleSheet

        self.mathContext = mathContext

        self._index = mathListLayoutFragment.count
        self._dirtyIndex = _index
        self.mathListLayoutFragment = mathListLayoutFragment
    }

    func beginEditing() {
        precondition(isEditing == false)
        isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        isEditing = false
        mathListLayoutFragment.fragmentsDidChange(mathContext, _dirtyIndex)
    }

    func skipBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // update location
        cursor -= n
        _index = index
    }

    func deleteBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // remove
        mathListLayoutFragment.removeSubrange(index ..< _index)

        // update location
        cursor -= n
        _index = index
        _dirtyIndex = _index
    }

    func invalidateBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = mathListLayoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // update location
        cursor -= n
        _index = index
        _dirtyIndex = _index
    }

    func insertText(_ text: TextNode) {
        let mathProperty = text.resolveProperties(styleSheet) as MathProperty
        let font = mathContext.getFont()

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

        // index doesn't change, but we need to update _dirtyIndex
        _dirtyIndex = _index
    }

    func insertNewline() {
        preconditionFailure("newline is not allowed in math list")
    }

    func insertFragment(_ fragment: any LayoutFragment) {
        precondition(isEditing && cursor >= 0 && fragment is MathLayoutFragment)

        // insert
        mathListLayoutFragment.insert(fragment as! MathLayoutFragment, at: _index)

        // index doesn't change, but we need to update _dirtyIndex
        _dirtyIndex = _index
    }
}
