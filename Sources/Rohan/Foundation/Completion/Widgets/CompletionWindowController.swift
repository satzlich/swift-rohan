// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class CompletionWindowController: NSWindowController {
  public weak var delegate: CompletionWindowDelegate?
  private var eventMonitor: Any?

  private var completionViewController: CompletionViewController {
    window!.contentViewController as! CompletionViewController
  }

  /// True if the window is visible.
  var isVisible: Bool { window?.isVisible ?? false }

  /// recommended position of top-left point of the window
  /// When this point is used, window height grows downwards.
  private var topAnchorPosition: CGPoint? = nil
  /// recommended position of bottom-left point of the window
  /// When this point is used, window height grows upwards.
  private var bottomAnchorPosition: CGPoint? = nil

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
  public override func showWindow(_ sender: Any?) {
    super.showWindow(sender)
  }

  /// Show window with given completion items.
  /// - Parameters:
  ///   - topAnchorPosition: the recommended position of the top-left point of the window.
  ///   - bottomAnchorPosition: the recommended position of the bottom-left point of
  ///       the window.
  ///   - items: the list of completion items.
  ///   - parent: the parent window
  public func showWindow(
    at topAnchorPosition: CGPoint, _ bottomAnchorPosition: CGPoint,
    items: Array<any CompletionItem>, parent: NSWindow
  ) {
    guard let window = window else { return }

    if !isVisible { parent.addChildWindow(window, ordered: .above) }

    // set items
    completionViewController.items = items

    // set window position
    self.topAnchorPosition = topAnchorPosition
    self.bottomAnchorPosition = bottomAnchorPosition

    updateWindowPosition()

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

    // add event monitor
    eventMonitor =
      NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) {
        [weak self] event in self?.handleEvent(event)
      }
  }

  /// Show window with given completion items.
  /// - Returns: true if the window is positioned at topLeftPoint, false if it is
  ///     positioned at bottomLeftPoint. Otherwise nil.
  @discardableResult
  func updateWindowPosition() -> Bool? {
    guard let window = window,
      let topAnchorPosition,
      let bottomAnchorPosition
    else { return nil }

    let size = window.frame.size
    let screenFrame = NSScreen.main?.frame ?? .zero

    if topAnchorPosition.y - size.height < screenFrame.minY {
      window.setFrameOrigin(bottomAnchorPosition)
      return false
    }
    else {
      window.setFrameTopLeftPoint(topAnchorPosition)
      return true
    }
  }

  private func handleEvent(_ event: NSEvent) -> NSEvent? {
    // close window if mouse is clicked outside the window
    if let window = self.window, window.isVisible {
      let locationInWindow = event.locationInWindow
      let locationInView = window.contentView?.convert(locationInWindow, from: nil)

      if !(window.contentView?.bounds.contains(locationInView ?? NSPoint.zero) ?? false) {
        self.close()
      }
    }
    return event
  }

  /// Perform clean-up on window close.
  private func cleanupOnClose() {
    completionViewController.items.removeAll(keepingCapacity: true)
  }

  public override func close() {
    guard isVisible else { return }
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
      eventMonitor = nil
    }
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

  func completionItemSelected(
    _ viewController: CompletionViewController, item: any CompletionItem,
    movement: NSTextMovement
  ) {
    delegate?.completionItemSelected(self, item: item, movement: movement)
  }

  func viewDidLayout(_ viewController: CompletionViewController) {
    guard let window = window else { return }
    let useTopAnchor = self.updateWindowPosition()
    guard let useTopAnchor else { return }
    viewController.tablePosition = useTopAnchor ? .below : .above
  }
}
