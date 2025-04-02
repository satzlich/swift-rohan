// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class CompletionWindowController: NSWindowController {
  public weak var delegate: CompletionWindowDelegate?

  private var completionViewController: CompletionViewController {
    window!.contentViewController as! CompletionViewController
  }

  var isVisible: Bool { window?.isVisible ?? false }

  init(_ viewController: CompletionViewController) {
    let window = CompletionWindow(contentViewController: viewController)
    window.applyDefaultSetting()
    super.init(window: window)

    viewController.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @available(*, unavailable)
  override func showWindow(_ sender: Any?) {
    super.showWindow(sender)
  }

  public func show() {
    super.showWindow(nil)
  }

  /// Show window with given completion items.
  /// - Parameters:
  ///   - origin: top-left corner of the frame of completion window.
  ///   - items: the list of completion items.
  ///   - parent: the parent window
  public func showWindow(
    at origin: CGPoint, items: Array<any CompletionItem>, parent: NSWindow
  ) {
    guard let window = window else { return }
    if !isVisible { parent.addChildWindow(window, ordered: .above) }

    // set items
    completionViewController.items = items
    // set position
    window.setFrameTopLeftPoint(origin)

    // add observer: when window is closed, clean up
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification, object: window, queue: .main
    ) { [weak self] notification in
      self?.cleanupOnClose()
    }

    // add observer: when parent window loses focus, close current window
    NotificationCenter.default.addObserver(
      forName: NSWindow.didResignKeyNotification, object: parent, queue: .main
    ) { [weak self] notification in
      self?.close()
    }
  }

  /// Perform clean-up on window close.
  private func cleanupOnClose() {
    completionViewController.items.removeAll(keepingCapacity: true)
  }

  public override func close() {
    guard isVisible else { return }
    super.close()
  }
}

extension CompletionWindowController: CompletionViewControllerDelegate {
  /*
   Workflow:
     viewController.insertCompletionItem() -->
     viewControllerDelegate.completionViewController() -->
     windowControllerDelegate.completionWindowController() -->
     application logic
   */

  func completionViewController(
    _ viewController: CompletionViewController, item: any CompletionItem,
    movement: NSTextMovement
  ) {
    delegate?.completionWindowController(self, item: item, movement: movement)
  }
}
