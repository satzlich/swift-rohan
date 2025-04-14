// Copyright 2024-2025 Lie Yan

import Foundation

protocol CompositorViewDelegate: AnyObject {
  /// Called when the command is changed.
  func commandDidChange(_ text: String, _ controller: CompositorViewController)

  /// Called when the user selects a completion item.
  func commitSelection(_ item: CompletionItem, _ controller: CompositorViewController)

  func viewDidLayout(_ controller: CompositorViewController)
}
