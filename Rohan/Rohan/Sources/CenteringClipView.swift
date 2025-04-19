// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class CenteringClipView: NSClipView {
  // MARK: - Init

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    _setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    _setUp()
  }

  private func _setUp() {
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

    let documentWidth = documentView.frame.width
    let clipViewWidth = constrainedBounds.width

    // Only center if document is smaller than clip view
    if documentWidth < clipViewWidth {
      // Calculate horizontal inset to center
      let inset = (clipViewWidth - documentWidth) / 2.0
      constrainedBounds.origin.x = -inset
    }

    let documentHeight = documentView.frame.height
    let clipViewHeight = constrainedBounds.height
    // Only center if document is smaller than clip view
    if documentHeight < clipViewHeight {
      // Calculate vertical inset to center
      let inset = (clipViewHeight - documentHeight) / 2.0
      constrainedBounds.origin.y = -inset
    }

    return constrainedBounds
  }
}
