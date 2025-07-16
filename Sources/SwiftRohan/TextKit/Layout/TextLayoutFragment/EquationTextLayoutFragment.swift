// Copyright 2024-2025 Lie Yan

import AppKit

typealias HorizontalBounds = (x: CGFloat, width: CGFloat)

final class EquationTextLayoutFragment: NSTextLayoutFragment {
  private let _equationNumber: NSAttributedString
  private let _precomputedPosition: CGPoint

  final override func draw(at point: CGPoint, in context: CGContext) {
    super.draw(at: point, in: context)

    context.saveGState()
    defer { context.restoreGState() }

    var position = _precomputedPosition
    let glyphOrigin = self.textLineFragments.first?.glyphOrigin ?? .zero
    position.x += point.x - layoutFragmentFrame.origin.x
    position.y += point.y + glyphOrigin.y
    _equationNumber.draw(at: position)
    // reset text matrix to identity after NSAttributedString drawing.
    context.textMatrix = .identity
  }

  /// - Parameters:
  ///   - equationNumber: The equation number to be displayed.
  ///   - horizontalBounds: The horizontal bounds from paragraph indent to the
  ///       end of the equation number.
  init(
    textElement: NSTextElement, range: NSTextRange? = nil,
    equationNumber: NSAttributedString, horizontalBounds: HorizontalBounds,
  ) {
    self._equationNumber = equationNumber
    do {
      let number = _equationNumber.boundingRect(with: .zero, context: nil)
      let x = horizontalBounds.x + horizontalBounds.width - number.width
      let y = -number.origin.y - number.height
      _precomputedPosition = CGPoint(x: x, y: y)
    }
    super.init(textElement: textElement, range: range)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
