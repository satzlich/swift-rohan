// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView: NSServicesMenuRequestor {
    public func readSelection(from pboard: NSPasteboard) -> Bool {
        false
    }

    public func writeSelection(to pboard: NSPasteboard,
                               types: [NSPasteboard.PasteboardType]) -> Bool
    {
        false
    }
}
