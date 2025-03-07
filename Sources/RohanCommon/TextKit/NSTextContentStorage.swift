// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentStorage {
    /**
     Convert text elements to attributed string
     */
    public func attributedString(for textElements: [NSTextElement]) -> NSAttributedString {
        let attrString = NSMutableAttributedString()

        attrString.beginEditing()
        textElements
            .compactMap(attributedString(for:))
            .forEach(attrString.append(_:))
        attrString.endEditing()
        return attrString
    }

    /**
     Convert text ranges to attributed string
     */
    public func attributedString(for textRanges: [NSTextRange]) -> NSAttributedString {
        // form character ranges
        let characterRanges = textRanges.map(characterRange(for:))

        assert(textStorage != nil)

        // form attributed string
        let attrString = NSMutableAttributedString()
        attrString.beginEditing()
        characterRanges.forEach {
            attrString.append(textStorage!.attributedSubstring(from: $0))
        }
        attrString.endEditing()
        return attrString
    }
}
