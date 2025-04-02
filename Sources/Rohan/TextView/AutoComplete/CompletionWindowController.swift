// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class CompletionWindowController: NSWindowController {

  private var completionViewController: CompletionViewController {
    window!.contentViewController as! CompletionViewController
  }

  var isVisible: Bool { window?.isVisible ?? false }
  
  init(_ viewController: CompletionViewController) {
    let window = CompletionWindow(contentViewController: viewController)
    window.applyDefaultSetting()
    super.init(window: window)
    
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

  public func showWindow(at origin: CGPoint, items: [String], parent: NSWindow) {
    guard let window = window else { return }

    if !isVisible { parent.addChildWindow(window, ordered: .above) }

    // TODO: set up completion items

    window.setFrameTopLeftPoint(origin)

    // when window is closed, clean up
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification, object: window, queue: .main
    ) { [weak self] notification in
      self?.cleanupOnClose()
    }

    // when parent window loses focus, close current window
    NotificationCenter.default.addObserver(
      forName: NSWindow.didResignKeyNotification, object: parent, queue: .main
    ) { [weak self] notification in
      self?.close()
    }
  }

  private func cleanupOnClose() {
    // TODO: clean up completion items
  }

  public override func close() {
    guard isVisible else { return }
    super.close()
  }
}
