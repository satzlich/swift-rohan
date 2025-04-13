// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol CompletionViewControllerDelegate: AnyObject {
  /// Callback when the completion item is selected.
  func completionItemSelected(
    _ viewController: CompletionViewController, item: any CompletionItem,
    movement: NSTextMovement)

  /// Callback when layout is completed.
  func viewDidLayout(_ viewController: CompletionViewController)
}
