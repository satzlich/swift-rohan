// Copyright 2024-2025 Lie Yan

import AppKit

final class ListItemTextLayoutFragment: NSTextLayoutFragment {

  let itemMarker: NSAttributedString
  let indent: CGFloat

  final override var renderingSurfaceBounds: CGRect {
    var bounds = super.renderingSurfaceBounds
    bounds.origin.x -= indent
    bounds.size.width += indent
    return bounds
  }

  override func draw(at point: CGPoint, in context: CGContext) {
    let itemRect: CGRect
    do {
      let size = itemMarker.size()
      let renderingOrigin = renderingSurfaceBounds.origin
      let x = renderingOrigin.x + (indent - size.width)
      let y = renderingOrigin.y
      itemRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
    }

    context.saveGState()
    itemMarker.draw(in: itemRect)
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
