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

    init(_ textContentStorage: NSTextContentStorage_fix) {
        self.textContentStorage = textContentStorage
        super.init(cursor: textContentStorage.textStorage!.length)
    }

    override func skipBackwards(_ n: Int) {
        precondition(n >= 0)
        _cursor -= n
        assert(_cursor >= 0)
    }

    override func deleteBackwards(_ n: Int) {
        precondition(n >= 0)

        // find text range
        let location = _cursor - n
        let characterRange = NSRange(location: location, length: n)
        guard let textRange = textContentStorage.textRange(for: characterRange)
        else { preconditionFailure("text range not found") }

        // update state
        textContentStorage.replaceContents(in: textRange, with: nil)
        _cursor = location

        assert(_cursor >= 0)
    }

    override func insert(text: TextNode) {
        // find text location
        guard let location = textContentStorage.textLocation(for: _cursor)
        else { preconditionFailure("text location not found") }
        // create text element
        let attrString = NSAttributedString(string: text.string)
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
        let attrString = NSAttributedString(string: "\n")
        let textElement = NSTextParagraph(attributedString: attrString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }
}
