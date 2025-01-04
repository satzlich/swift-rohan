// Copyright 2024-2025 Lie Yan

import Foundation

struct RhMarkedText: CustomDebugStringConvertible {
    var markedText: NSAttributedString
    var markedRange: NSRange
    var selectedRange: NSRange

    init(_ markedText: NSAttributedString,
         markedRange: NSRange,
         selectedRange: NSRange)
    {
        self.markedText = markedText
        self.markedRange = markedRange
        self.selectedRange = selectedRange
    }

    var debugDescription: String {
        """
        \(markedText.string), \
        markedRange: \(markedRange), \
        selectedRange: \(selectedRange)
        """
    }
}
