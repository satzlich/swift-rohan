import AppKit
import Foundation

/// Base class for all interal views
class RohanView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setUp()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }

  private final func setUp() {
    wantsLayer = true
    clipsToBounds = false
  }

  override final var isFlipped: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
  }
}
