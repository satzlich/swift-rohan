// Copyright 2024-2025 Lie Yan
import AppKit

struct HorizontalBounds {
  var x: CGFloat
  var width: CGFloat
}

final class EquationNumberFragmentDecorator: FragmentDecorator {

  func draw(at point: CGPoint, in context: CGContext, for fragment: NSTextLayoutFragment)
  {
    context.saveGState()
    defer { context.restoreGState() }

    var position = _precomputedPosition
    let glyphOrigin = fragment.textLineFragments.first?.glyphOrigin ?? .zero
    position.x += point.x - fragment.layoutFragmentFrame.origin.x
    position.y += point.y + glyphOrigin.y
    _equationNumber.draw(at: position)
    // reset text matrix to identity after NSAttributedString drawing.
    context.textMatrix = .identity
  }

  // MARK: - State

  private let _equationNumber: NSAttributedString
  private let _precomputedPosition: CGPoint

  /// - Parameters:
  ///   - equationNumber: The equation number to be displayed.
  ///   - horizontalBounds: The horizontal bounds from paragraph indent to the
  ///       end of the equation number.
  init(equationNumber: NSAttributedString, horizontalBounds: HorizontalBounds) {
    self._equationNumber = equationNumber
    do {
      let number = _equationNumber.boundingRect(with: .zero, context: nil)
      let x = horizontalBounds.x + horizontalBounds.width - number.width
      let y = -number.origin.y - number.height
      _precomputedPosition = CGPoint(x: x, y: y)
    }
  }
}
