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
}
