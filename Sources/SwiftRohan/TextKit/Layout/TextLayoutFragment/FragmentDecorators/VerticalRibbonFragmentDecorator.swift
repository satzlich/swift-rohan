// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class VerticalRibbonFragmentDecorator: FragmentDecorator {

  func draw(at point: CGPoint, in context: CGContext, for fragment: NSTextLayoutFragment)
  {
    context.saveGState()
    defer { context.restoreGState() }

    let frame = fragment.layoutFragmentFrame

    let width = 2.0
    let position = CGPoint(
      x: point.x - frame.origin.x - width,
      y: point.y)
    let size = CGSize(width: width, height: frame.size.height)

    // draw the vertical ribbon
    context.setFillColor(_color.cgColor)
    context.fill(CGRect(origin: position, size: size))
  }

  // MARK: - State

  private let _color: NSColor

  init(color: NSColor) {
    self._color = color
  }
}
