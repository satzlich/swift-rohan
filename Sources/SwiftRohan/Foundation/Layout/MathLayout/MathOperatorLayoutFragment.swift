// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathOperatorLayoutFragment: MathLayoutFragment {
  private let _textLine: TextLineLayoutFragment
  private let _limits: Limits

  init(_ node: MathOperatorNode, _ styleSheet: StyleSheet, _ mathContext: MathContext) {
    let mathOp = node.mathOperator
    self._textLine = TextLineLayoutFragment.createTextMode(
      mathOp.string, node, styleSheet, .imageBounds)
    self._limits = mathOp.limits
    self.glyphOrigin = .zero
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _textLine.draw(at: point, in: context)
  }

  var width: Double { _textLine.width }
  var height: Double { _textLine.height }
  var ascent: Double { _textLine.ascent }
  var descent: Double { _textLine.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Large }
  var limits: Limits { _limits }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func debugPrint(_ name: String?) -> Array<String> {
    let text = _textLine.attrString.string
    let description =
      (name.map { "\($0): " } ?? "") + "mathoperator(\(text)) \(boxDescription)"
    return PrintUtils.compose([description], [])
  }

  func fixLayout(_ mathContext: MathContext) {
    // do nothing
  }
}
