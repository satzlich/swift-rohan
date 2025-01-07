// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView: NSUserInterfaceValidations {
    public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        // TODO: customise
        return true
    }
}

extension RhTextView: NSMenuItemValidation {
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        validateUserInterfaceItem(menuItem)
    }
}
