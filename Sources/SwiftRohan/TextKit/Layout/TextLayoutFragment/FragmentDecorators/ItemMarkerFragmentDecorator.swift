// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class ItemMarkerFragmentDecorator: FragmentDecorator {

  func draw(at point: CGPoint, in context: CGContext, for fragment: NSTextLayoutFragment)
  {
    context.saveGState()
    defer { context.restoreGState() }

    var position = _precomputedPosition
    position.x += point.x
    position.y += point.y
    itemMarker.draw(at: position)
    context.textMatrix = .identity
  }

  // MARK: - State

  private let itemMarker: NSAttributedString
  private let _precomputedPosition: CGPoint
  private let indent: CGFloat

  init(itemMarker: NSAttributedString, indent: CGFloat) {
    self.itemMarker = itemMarker
    self.indent = indent
    _precomputedPosition = CGPoint(x: -itemMarker.size().width, y: 0)
  }
}
