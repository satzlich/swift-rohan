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
     Convert text ranges to attributed string
     */
    func attributedString(for textRanges: [NSTextRange]) -> NSAttributedString {
        // form character ranges
        let characterRanges = textRanges.map(characterRange(for:))

        assert(textStorage != nil)

        // form attributed string
        let attrString = NSMutableAttributedString()
        attrString.performEditing {
            characterRanges.forEach {
                attrString.append(textStorage!.attributedSubstring(from: $0))
            }
        }
        return attrString
    }
}
