// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import UniformTypeIdentifiers

extension RhTextView: NSServicesMenuRequestor {
    // MARK: - Pasteboard

    public func readSelection(from pboard: NSPasteboard) -> Bool {
        if readRTF(from: pboard) { return true }
        if readPlainText(from: pboard) { return true }
        return false // unsupported
    }

    public func readSelection(
        from pboard: NSPasteboard,
        type: NSPasteboard.PasteboardType
    ) -> Bool {
        switch type {
        case .rtf:
            return readRTF(from: pboard)
        case .string:
            return readPlainText(from: pboard)
        default:
            return false
        }
    }

    private func readRTF(from pboard: NSPasteboard) -> Bool {
        guard pboard.types?.contains(.rtf) == true,
              pboard.canReadItem(withDataConformingToTypes: [UTType.rtf.identifier]),
              let attrString = pboard
                  .readObjects(forClasses: [NSAttributedString.self])
                  .flatMap({ $0.first as? NSAttributedString })
        else { return false }

        _textContentStorage.performEditingTransaction {
            _textContentStorage.replaceContents(
                in: textLayoutManager.textSelections.flatMap(\.textRanges),
                with: [NSTextParagraph(attributedString: attrString)]
            )
        }
        return true
    }

    private func readPlainText(from pboard: NSPasteboard) -> Bool {
        guard pboard.types?.contains(.string) == true,
              pboard.canReadItem(withDataConformingToTypes: [UTType.plainText.identifier]),
              let string = pboard.string(forType: .string)
        else { return false }

        _textContentStorage.performEditingTransaction {
            _textContentStorage.replaceContents(
                in: textLayoutManager.textSelections.flatMap(\.textRanges),
                with: [NSTextParagraph(attributedString: NSAttributedString(string: string))]
            )
        }
        return true
    }

    public func writeSelection(to pboard: NSPasteboard,
                               types: [NSPasteboard.PasteboardType]) -> Bool
    {
        // form attributed string
        guard !types.isEmpty,
              let textSelection = textLayoutManager.textSelections.last,
              let attributedString = _textContentStorage.attributedString(for: textSelection)
        else { return false }

        // actions

        func writeRTF() -> Bool {
            let rtf = attributedString.rtf(
                from: NSRange(location: 0, length: attributedString.length)
            )
            return pboard.setData(rtf, forType: .rtf)
        }

        func writePlainText() -> Bool {
            return pboard.setString(attributedString.string, forType: .string)
        }

        func writeNoop() -> Bool {
            return false
        }

        // form actions
        let actions = types.map { type -> () -> Bool in
            switch type {
            case .rtf:
                return writeRTF
            case .string:
                return writePlainText
            default:
                return writeNoop
            }
        }

        // clear previous contents
        if !actions.isEmpty {
            pboard.clearContents()
        }

        // execute
        return actions.reduce(false) { acc, action in acc || action() }
    }
}
