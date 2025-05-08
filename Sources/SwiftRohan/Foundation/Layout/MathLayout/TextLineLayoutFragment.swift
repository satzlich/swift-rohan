// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

final class TextLineLayoutFragment: MathLayoutFragment {
  private(set) var attrString: NSMutableAttributedString
  private(set) var ctLine: CTLine
  private var _width: CGFloat = 0
  private var _ascent: CGFloat = 0
  private var _descent: CGFloat = 0

  init(_ attrString: NSMutableAttributedString, _ ctLine: CTLine) {
    self.attrString = attrString
    self.ctLine = ctLine
    self.glyphOrigin = .zero

    // Get the line width
    let lineWidth = CTLineGetTypographicBounds(ctLine, &_ascent, &_descent, nil)
    self._width = Double(lineWidth)
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
    ctLine.draw(context)
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

  var italicsCorrection: Double { 0 }

  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }

  var limits: Limits { .never }

  var isSpaced: Bool { false }

  var isTextLike: Bool { true }

  // MARK: - Debug

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "textmode"
    let description: String = "\(name) \(boxDescription)"
    return [description]
  }
}
