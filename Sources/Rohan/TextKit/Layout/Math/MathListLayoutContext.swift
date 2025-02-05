// Copyright 2024-2025 Lie Yan

import Foundation

final class MathListLayoutContext: LayoutContext {
    let styleSheet: StyleSheet
    let mathContext: MathContext
    let layoutFragment: MathListLayoutFragment

    init(_ styleSheet: StyleSheet,
         _ mathContext: MathContext,
         _ layoutFragment: MathListLayoutFragment)
    {
        self.styleSheet = styleSheet
        self.mathContext = mathContext

        self.layoutFragment = layoutFragment
        self._cursor = layoutFragment.contentLayoutLength
        self._index = layoutFragment.count
    }

    // MARK: - State

    /** cursor in the math list, measured in layout length */
    private var _cursor: Int = 0
    var cursor: Int { _cursor }

    /** index in the math list, measured in number of fragments */
    private var _index: Int = 0

    var isEditing: Bool { @inline(__always) get { layoutFragment.isEditing }}

    @inline(__always)
    func beginEditing() {
        layoutFragment.beginEditing()
    }

    @inline(__always)
    func endEditing() {
        layoutFragment.endEditing()
        layoutFragment.fixLayout(mathContext)
    }

    // MARK: - Operations

    func skipBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = layoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // update location
        _cursor -= n
        _index = index
    }

    func deleteBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = layoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // remove
        layoutFragment.removeSubrange(index ..< _index)

        // update location
        _cursor -= n
        _index = index
    }

    func invalidateBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        guard let index = layoutFragment.index(_index, llOffsetBy: -n)
        else { preconditionFailure("index not found; there may be a bug") }

        // invalidate
        layoutFragment.invalidateSubrange(index ..< _index)

        // update location
        _cursor -= n
        _index = index
    }

    func insertText(_ text: TextNode) {
        let mathProperty = text.resolveProperties(styleSheet) as MathProperty
        let font = mathContext.getFont()

        let string = text.string

        // TODO: handle characters beyond the font's support
        let fragments: [any MathLayoutFragment] = string.unicodeScalars
            .map { Self.substTable[$0] ?? $0 }
            .map { char in
                MathUtils.styledChar(for: char,
                                     variant: mathProperty.variant,
                                     bold: mathProperty.bold,
                                     italic: mathProperty.italic,
                                     autoItalic: true)
            }
            .compactMap { char in
                MathGlyphLayoutFragment(char, font, mathContext.table, 1)
            }
        assert(fragments.count == text.layoutLength)
        layoutFragment.insert(contentsOf: fragments, at: _index)
    }

    private static let substTable: [UnicodeScalar: UnicodeScalar] = [
        "-": "\u{2212}",
    ]

    func insertNewline(_ context: Node) {
        preconditionFailure("newline is not allowed in math list")
    }

    func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
        precondition(isEditing && cursor >= 0 && fragment is MathLayoutFragment)
        layoutFragment.insert(fragment as! MathLayoutFragment, at: _index)
    }
}
