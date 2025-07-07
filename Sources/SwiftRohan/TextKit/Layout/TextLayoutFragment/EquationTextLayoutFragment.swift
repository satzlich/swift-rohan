// Copyright 2024-2025 Lie Yan

import AppKit

typealias HorizontalBounds = (x: CGFloat, width: CGFloat)

final class EquationTextLayoutFragment: NSTextLayoutFragment {
  private let _equationNumber: NSAttributedString
  /// The horizontal bounds from paragraph indent to the end of the equation number.
  private let _horizontalBounds: HorizontalBounds

  final override func draw(at point: CGPoint, in context: CGContext) {
    super.draw(at: point, in: context)

    let glyphOrigin = self.textLineFragments.first?.glyphOrigin ?? .zero
    let fragment = layoutFragmentFrame
    let number = _equationNumber.boundingRect(with: .zero, options: [], context: nil)

    let x =
      point.x - fragment.origin.x + _horizontalBounds.x + _horizontalBounds.width
      - number.width
    let y = point.y + glyphOrigin.y - number.origin.y - number.height
    _equationNumber.draw(at: CGPoint(x: x, y: y))
  }

  init(
    textElement: NSTextElement, range: NSTextRange? = nil,
    equationNumber: NSAttributedString, horizontalBounds: HorizontalBounds,
  ) {
    self._equationNumber = equationNumber
    self._horizontalBounds = horizontalBounds
    super.init(textElement: textElement, range: range)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
