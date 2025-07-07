// Copyright 2024-2025 Lie Yan

import AppKit

final class ListItemTextLayoutFragment: NSTextLayoutFragment {

  private let itemMarker: NSAttributedString
  private let _precomputedPosition: CGPoint
  private let indent: CGFloat

  final override var renderingSurfaceBounds: CGRect {
    var bounds = super.renderingSurfaceBounds
    bounds.origin.x = -indent
    bounds.size.width += indent
    return bounds
  }

  final override func draw(at point: CGPoint, in context: CGContext) {
    super.draw(at: point, in: context)

    context.saveGState()
    var position = _precomputedPosition
    position.x += point.x
    position.y += point.y
    itemMarker.draw(at: position)
    context.restoreGState()
  }

  init(
    textElement: NSTextElement, range: NSTextRange? = nil,
    itemMarker: NSAttributedString, indent: CGFloat
  ) {
    self.itemMarker = itemMarker
    self.indent = indent
    _precomputedPosition = CGPoint(x: -itemMarker.size().width, y: 0)
    super.init(textElement: textElement, range: range)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
