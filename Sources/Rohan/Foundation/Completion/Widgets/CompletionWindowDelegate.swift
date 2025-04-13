// Copyright 2024-2025 Lie Yan

import AppKit

public protocol CompletionWindowDelegate: AnyObject {
  /// Callback when completion item is selected.
  func completionItemSelected(
    _ windowController: CompletionWindowController, item: any CompletionItem,
    movement: NSTextMovement)
}
