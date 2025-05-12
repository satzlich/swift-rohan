// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

final class TextLineLayoutFragment: LayoutFragment {
  private(set) var attrString: NSMutableAttributedString
  private(set) var ctLine: CTLine
  private var _width: CGFloat = 0
  private var _ascent: CGFloat = 0
  private var _descent: CGFloat = 0

  enum BoundsOption {
    case imageBounds
    case typographicBounds
  }

  init(_ attrString: NSMutableAttributedString, _ ctLine: CTLine, options: BoundsOption) {
    self.attrString = attrString
    self.ctLine = ctLine
    self.glyphOrigin = .zero

    switch options {
    case .imageBounds:
      let rect = CTLineGetImageBounds(ctLine, nil)
      let ascent = -rect.origin.y
      let descent = rect.height - ascent

      self._width = CTLineGetTypographicBounds(ctLine, nil, nil, nil)
      self._ascent = ascent
      self._descent = descent

    case .typographicBounds:
      self._width = CTLineGetTypographicBounds(ctLine, &_ascent, &_descent, nil)
    }
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Layout

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    CTLineDraw(ctLine, context)
    context.restoreGState()
  }

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  // MARK: - Metrics

  var width: Double { _width }
  var height: Double { _ascent + _descent }
  var ascent: Double { _ascent }
  var descent: Double { _descent }
}
