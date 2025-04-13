// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class CompletionWindowController: NSWindowController {
  public weak var delegate: CompletionWindowDelegate?
  private var eventMonitor: Any?

  private var completionViewController: CompletionViewController {
    window!.contentViewController as! CompletionViewController
  }

  var isVisible: Bool { window?.isVisible ?? false }

  // recommended top-left point of the window
  private var topLeftPoint: CGPoint? = nil
  // recommended bottom-left point of the window when topLeftPoint is resulting
  // in the window being off-screen partially or fully.
  private var bottomLeftPoint: CGPoint? = nil

  // the frame observer for the window
  private var frameObserver: NSKeyValueObservation?

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
  ///   - topLeftPoint: the top left point of the window.
  ///   - bottomLeftPoint: the bottom left point of the window when topLeftPoint
  ///       is resulting in the window being off-screen partially or fully.
  ///   - items: the list of completion items.
  ///   - parent: the parent window
  public func showWindow(
    at topLeftPoint: CGPoint, _ bottomLeftPoint: CGPoint,
    items: Array<any CompletionItem>, parent: NSWindow
  ) {
    guard let window = window else { return }

    if !isVisible { parent.addChildWindow(window, ordered: .above) }

    // set items
    completionViewController.items = items

    // set window position
    self.topLeftPoint = topLeftPoint
    self.bottomLeftPoint = bottomLeftPoint

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

  func updateWindowPosition() {
    guard let window = window,
      let topLeftPoint = topLeftPoint,
      let bottomLeftPoint = bottomLeftPoint
    else { return }

    let size = window.frame.size
    let screenFrame = NSScreen.main?.frame ?? .zero

    if topLeftPoint.y - size.height < screenFrame.minY {
      let point = bottomLeftPoint.with(yDelta: size.height)
      window.setFrameTopLeftPoint(point)
    }
    else {
      window.setFrameTopLeftPoint(topLeftPoint)
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

  func completionViewController(
    _ viewController: CompletionViewController, item: any CompletionItem,
    movement: NSTextMovement
  ) {
    delegate?.completionWindowController(self, item: item, movement: movement)
  }

  func viewFrameDidChange(_ viewController: CompletionViewController, frame: CGRect) {
    guard let window = window else { return }
    self.updateWindowPosition()
  }
}
