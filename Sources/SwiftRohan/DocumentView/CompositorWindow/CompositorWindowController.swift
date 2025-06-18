// Copyright 2024-2025 Lie Yan

import AppKit

class CompositorWindowController: NSWindowController {
  public weak var delegate: CompositorWindowDelegate? = nil

  /// Associated view controller.
  var compositorViewController: CompositorViewController {
    window!.contentViewController as! CompositorViewController
  }

  private weak var parentWindow: NSWindow?
  private var windowPosition: CGPoint?
  private var compositorMode: CompositorMode?

  init(_ viewController: CompositorViewController, _ parent: NSWindow) {
    self.parentWindow = parent

    let window = CompositorWindow()
    super.init(window: window)

    window.contentViewController = viewController
    viewController.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Show the window in a modal manner.
  func showModal(at position: CGPoint, mode: CompositorMode) {
    self.windowPosition = position
    self.compositorMode = mode

    guard let window = self.window,
      let parentWindow = parentWindow
    else { return }

    self.updateWindowPosition()

    parentWindow.addChildWindow(window, ordered: .above)
    NSApp.runModal(for: window)
  }

  /// Dismiss the window.
  func dismiss() {
    self.windowPosition = nil
    self.compositorMode = nil

    NSApp.stopModal()
    guard let window = self.window else { return }
    window.orderOut(nil)
    window.parent?.removeChildWindow(window)
  }

  /// Update the window position based on compositor mode.
  private func updateWindowPosition() {
    guard let window = self.window,
      let windowPosition = self.windowPosition,
      let compositorMode = self.compositorMode
    else { return }

    switch compositorMode {
    case .normal:
      window.setFrameTopLeftPoint(windowPosition)

    case .inverted:
      window.setFrameOrigin(windowPosition)
    }
  }
}

extension CompositorWindowController: @preconcurrency CompositorViewDelegate {
  func commandDidChange(_ text: String, _ controller: CompositorViewController) {
    delegate?.commandDidChange(text, self)
  }

  func commitSelection(_ item: CompletionItem, _ controller: CompositorViewController) {
    delegate?.commitSelection(item, self)
  }

  func viewDidLayout(_ controller: CompositorViewController) {
    updateWindowPosition()
  }
}
