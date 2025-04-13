// Copyright 2024-2025 Lie Yan

import AppKit

class CompositorWindowController: NSWindowController {
  private weak var parentWindow: NSWindow?
  private var isModal = false

  init(parent: NSWindow, contentViewController: NSViewController) {
    self.parentWindow = parent

    let window = CompositorWindow()
    super.init(window: window)

    window.contentViewController = contentViewController
    window.parent = parent
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Show the window as a modal dialog.
  /// - Parameters:
  ///   - position: the top-left corner of the window.
  func showModal(at position: NSPoint) {
    guard let window = self.window,
      let parentWindow = parentWindow
    else { return }
    window.setFrameTopLeftPoint(position)
    parentWindow.addChildWindow(window, ordered: .above)
    isModal = true
    NSApp.runModal(for: window)
  }

  /// Dismiss the modal dialog.
  func endModal() {
    isModal = false
    NSApp.stopModal()
    guard let window = self.window else { return }
    window.orderOut(nil)
    window.parent?.removeChildWindow(window)
  }
}
