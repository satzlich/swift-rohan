// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/** Base class for all interal views */
@MainActor
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
    clipsToBounds = true
  }

  override final var isFlipped: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
  }
}
