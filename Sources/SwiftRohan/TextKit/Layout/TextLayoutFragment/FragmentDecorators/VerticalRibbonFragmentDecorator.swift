import AppKit
import Foundation

final class VerticalRibbonFragmentDecorator: FragmentDecorator {

  func draw(at point: CGPoint, in context: CGContext, for fragment: NSTextLayoutFragment)
  {
    context.saveGState()
    defer { context.restoreGState() }

    let frame = fragment.layoutFragmentFrame
    let width = 2.0
    let size = CGSize(width: width, height: frame.size.height)

    let position: CGPoint
    switch _isRightEdge {
    case false:
      position = CGPoint(
        x: point.x - frame.origin.x - width,
        y: point.y)
    case true:
      let containerWidth =
        fragment.textLayoutManager?.textContainer?.size.width ?? 65536.0
      position = CGPoint(
        x: point.x - frame.origin.x + containerWidth,
        y: point.y)
    }

    // draw the vertical ribbon
    context.setFillColor(_color.cgColor)
    context.fill(CGRect(origin: position, size: size))
  }

  // MARK: - State

  private let _color: NSColor
  private let _isRightEdge: Bool

  init(color: NSColor, isRightEdge: Bool = true) {
    self._color = color
    self._isRightEdge = isRightEdge
  }
}
