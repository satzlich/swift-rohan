// Copyright 2024-2025 Lie Yan

import AppKit

final class CompletionWindow: NSWindow {
  override var canBecomeKey: Bool {
    // Keyboard events are disabled for this window, but events can be forwarded
    // to NSTableView within it from CompletionViewController by special handling
    // therein.
    false
  }

  /// Apply default setting to the window
  func applyDefaultSetting() {
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
}
