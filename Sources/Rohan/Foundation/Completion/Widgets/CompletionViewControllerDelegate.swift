// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol CompletionViewControllerDelegate: AnyObject {
  /// Implement this method to respond to item selection.
  func completionViewController(
    _ viewController: CompletionViewController, item: any CompletionItem,
    movement: NSTextMovement)

  /// Implement this method to respond to view frame changes.
  func viewFrameDidChange(_ viewController: CompletionViewController, frame: CGRect)
}
