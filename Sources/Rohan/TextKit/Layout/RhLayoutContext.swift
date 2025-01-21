// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class RhLayoutContext {
    final var cursor: Int { @inline(__always) get { _cursor } }

    @usableFromInline var _cursor: Int

    init(cursor: Int) {
        self._cursor = cursor
    }

    func skipBackwards(_ n: Int) {
        preconditionFailure("overriding required")
    }

    func deleteBackwards(_ n: Int) {
        preconditionFailure("overriding required")
    }

    // MARK: - Insert Building Blocks

    func insert(text: TextNode) {
        preconditionFailure("overriding required")
    }

    func insertNewline() {
        preconditionFailure("overriding required")
    }
}

final class RhTextKitLayoutContext: RhLayoutContext {
    let textContentStorage: NSTextContentStorage_fix
    let styleSheet: StyleSheet

    init(_ textContentStorage: NSTextContentStorage_fix, _ styleSheet: StyleSheet) {
        self.textContentStorage = textContentStorage
        self.styleSheet = styleSheet
        super.init(cursor: textContentStorage.textStorage!.length)
    }

    override func skipBackwards(_ n: Int) {
        precondition(n >= 0 && _cursor >= n)
        _cursor -= n
    }

    override func deleteBackwards(_ n: Int) {
        precondition(n >= 0 && _cursor >= n)

        // find text range
        let location = _cursor - n
        let characterRange = NSRange(location: location, length: n)
        guard let textRange = textContentStorage.textRange(for: characterRange)
        else { preconditionFailure("text range not found") }

        // update state
        textContentStorage.replaceContents(in: textRange, with: nil)
        _cursor = location
    }

    override func insert(text: TextNode) {
        // find text location
        guard let location = textContentStorage.textLocation(for: _cursor)
        else { preconditionFailure("text location not found") }
        // styles
        let properties = text.resolve(with: styleSheet) as TextProperty
        // create text element
        let attrString = NSAttributedString(string: text.string,
                                            attributes: properties.attributes())
        let textElement = NSTextParagraph(attributedString: attrString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    override func insertNewline() {
        // find text location
        guard let location = textContentStorage.textLocation(for: _cursor)
        else { preconditionFailure("text location not found") }

        // create text element
        let attributedString = NSAttributedString(string: "\n")
        assert(attributedString.length == 1)

        let textElement = NSTextParagraph(attributedString: attributedString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }
}
