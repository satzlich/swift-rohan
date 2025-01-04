// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import UniformTypeIdentifiers

extension RhTextView {
    @objc public func copy(_ sender: Any?) {
        _ = writeSelection(to: NSPasteboard.general, types: [.rtf, .string])
    }

    @objc public func paste(_ sender: Any?) {
        let pasteboard = NSPasteboard.general

        if pasteboard.canReadItem(withDataConformingToTypes: [UTType.rtf.identifier]) {
            pasteAsRichText(sender)
        }
        else if pasteboard.canReadItem(
            withDataConformingToTypes: [UTType.plainText.identifier]
        ) {
            pasteAsPlainText(sender)
        }
    }

    @objc public func pasteAsPlainText(_ sender: Any?) {
        _ = readSelection(from: NSPasteboard.general, type: .string)
    }

    @objc public func pasteAsRichText(_ sender: Any?) {
        _ = readSelection(from: NSPasteboard.general, type: .rtf)
    }

    @objc public func cut(_ sender: Any?) {
        copy(sender)
        delete(sender)
    }

    @objc public func delete(_ sender: Any?) {
        precondition(textLayoutManager.textSelections.count <= 1)

        guard let textSelection = textLayoutManager.textSelections.last
        else { return }

        for textRange in textSelection.textRanges {
            let characterRange = textContentManager.characterRange(for: textRange)
            insertText("", replacementRange: characterRange)
        }
    }
}
