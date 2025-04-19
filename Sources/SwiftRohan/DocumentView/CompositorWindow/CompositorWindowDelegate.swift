// Copyright 2024-2025 Lie Yan

import Foundation

protocol CompositorWindowDelegate: AnyObject {
  /// Called when the command is changed.
  func commandDidChange(_ text: String, _ controller: CompositorWindowController)

  /// Called when the user selects a completion item.
  func commitSelection(
    _ item: CompletionItem, _ controller: CompositorWindowController)
}
