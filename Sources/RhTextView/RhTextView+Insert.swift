// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    override public func insertLineBreak(_ sender: Any?) {
        let lineSeparator = String(UnicodeScalar(NSLineSeparatorCharacter)!)
        insertText(lineSeparator)
    }

    override public func insertNewline(_ sender: Any?) {
        insertText("\n")
    }

    override public func insertTab(_ sender: Any?) {
        let tab = String(UnicodeScalar(NSTabCharacter)!)
        insertText(tab)
    }

    override public func insertText(_ insertString: Any) {
        insertText(insertString,
                   replacementRange: NSRange(location: NSNotFound, length: 0))
    }
}
