// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class RhClipView: NSClipView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    _setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    _setUp()
  }

  private func _setUp() {
    // (0.93, 0.93, 0.93) is used by MS Word
    self.backgroundColor = NSColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.shadowColor.withAlphaComponent(0.4)
    shadow.shadowOffset = NSMakeSize(0, -2)
    shadow.shadowBlurRadius = 4
    self.shadow = shadow

    self.wantsLayer = true
    self.layer?.masksToBounds = false
  }

  override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
    var constrainedBounds = super.constrainBoundsRect(proposedBounds)

    guard let documentView = documentView
    else { return constrainedBounds }

    let documentFrame = documentView.frame

    // center only if document is smaller than clip view
    if documentFrame.width < constrainedBounds.width {
      let inset = (constrainedBounds.width - documentFrame.width) / 2.0
      constrainedBounds.origin.x = -inset
    }

    // center only if document is smaller than clip view
    if documentFrame.height < constrainedBounds.height {
      let inset = (constrainedBounds.height - documentFrame.height) / 2.0
      constrainedBounds.origin.y = -inset
    }

    return constrainedBounds
  }
}
