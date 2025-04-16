// Copyright 2024-2025 Lie Yan

import AppKit

class CompositorWindow: NSWindow {
  private var eventMonitors: [Any?] = []

  override init(
    contentRect: NSRect, styleMask style: NSWindow.StyleMask,
    backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
  ) {
    super.init(
      contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    setupWindow()
  }

  private func setupWindow() {
    autorecalculatesKeyViewLoop = true
    backgroundColor = .clear
    isExcludedFromWindowsMenu = true
    isMovable = false
    level = .popUpMenu
    styleMask = [.resizable, .fullSizeContentView]
    tabbingMode = .disallowed
    titlebarAppearsTransparent = true
    titleVisibility = .hidden

    standardWindowButton(.closeButton)?.isHidden = true
    standardWindowButton(.miniaturizeButton)?.isHidden = true
    standardWindowButton(.zoomButton)?.isHidden = true
  }

  private func setupEventMonitoring() {
    // Monitor ESC key to close the window
    let keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
      [weak self] event in
      if event.keyCode == 53 {  // Escape key
        self?.close()
        return nil
      }
      return event
    }
    eventMonitors.append(keyMonitor)

    // Monitor mouse events to close the window when clicked outside
    let mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) {
      [weak self] event in
      guard let window = self else { return }
      let screenPoint = window.convertPoint(toScreen: event.locationInWindow)
      if !window.frame.contains(screenPoint) {
        window.close()
      }
    }
    eventMonitors.append(mouseMonitor)
  }

  private func removeEventMonitors() {
    for monitor in eventMonitors {
      guard let monitor = monitor else { continue }
      NSEvent.removeMonitor(monitor)
    }
    eventMonitors.removeAll()
  }

  override func close() {
    parent?.isMovable = true
    removeEventMonitors()
    (windowController as? CompositorWindowController)?.dismiss()
    super.close()
  }

  override func becomeKey() {
    super.becomeKey()
    parent?.isMovable = false
    setupEventMonitoring()
  }

  override func resignKey() {
    removeEventMonitors()
    parent?.isMovable = true
    super.resignKey()
  }

  override var canBecomeKey: Bool { return true }
  override var canBecomeMain: Bool { return true }

  deinit {
    removeEventMonitors()
  }
}
