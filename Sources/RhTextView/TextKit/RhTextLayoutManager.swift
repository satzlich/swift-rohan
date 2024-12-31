// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class RhTextLayoutManager: NSTextLayoutManager {
    static let didChangeSelectionNotification = NSTextView.didChangeSelectionNotification

    override var textSelections: [NSTextSelection] {
        didSet {
            let notification = Notification(
                name: Self.didChangeSelectionNotification,
                object: self,
                userInfo: nil
            )
            NotificationCenter.default.post(notification)
        }
    }
}
