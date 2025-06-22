// Copyright 2024-2025 Lie Yan

import AppKit

final class ListItemTextLayoutFragment: NSTextLayoutFragment {

  let itemMarker: NSAttributedString
  let indent: CGFloat

  final override var renderingSurfaceBounds: CGRect {
    var bounds = super.renderingSurfaceBounds
    bounds.origin.x = -indent
    bounds.size.width += indent
    return bounds
  }

  final override func draw(at point: CGPoint, in context: CGContext) {
    // compute the position of item marker
    let x = point.x - itemMarker.size().width
    let y = point.y
    let markerPosition = CGPoint(x: x, y: y)

    // draw the item marker
    context.saveGState()
    itemMarker.draw(at: markerPosition)
    context.restoreGState()

    super.draw(at: point, in: context)
  }

  init(
    textElement: NSTextElement, range: NSTextRange? = nil,
    itemMarker: NSAttributedString, indent: CGFloat
  ) {
    self.itemMarker = itemMarker
    self.indent = indent
    super.init(textElement: textElement, range: range)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
