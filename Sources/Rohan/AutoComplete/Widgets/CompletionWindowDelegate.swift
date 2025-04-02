// Copyright 2024-2025 Lie Yan

import AppKit

protocol CompletionWindowDelegate: AnyObject {
  // Implement this method to respond to item selection.
  func completionWindowController(
    _ windowController: CompletionWindowController, item: any CompletionItem,
    movement: NSTextMovement)
}
