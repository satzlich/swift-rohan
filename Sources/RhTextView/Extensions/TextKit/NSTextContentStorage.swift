// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentStorage {
    /**
     Convert text elements to attributed string
     */
    func attributedString(for textElements: [NSTextElement]) -> NSAttributedString {
        let attrString = NSMutableAttributedString()
        attrString.performEditing {
            textElements
                .compactMap(attributedString(for:))
                .forEach(attrString.append(_:))
        }
        return attrString
    }

    /**
     Attributed string for last text selection

     - Returns: nil if no text selection
     */
    func attributedString(for textSelection: NSTextSelection) -> NSAttributedString? {
        let textRanges = textSelection.textRanges
        guard !textRanges.isEmpty else { return nil }

        // form character ranges
        let characterRanges = textRanges.map(characterRange(for:))
        guard !characterRanges.isEmpty else { return nil }

        assert(textStorage != nil)

        // form attributed string
        var attrString = NSMutableAttributedString()
        attrString.performEditing {
            characterRanges.forEach {
                attrString.append(textStorage!.attributedSubstring(from: $0))
            }
        }
        return attrString
    }
}
