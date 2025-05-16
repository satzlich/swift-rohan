// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathOperatorLayoutFragment: MathLayoutFragment {
  let content: TextLineLayoutFragment
  let _limits: Limits

  init(_ content: TextLineLayoutFragment, _ mathOp: MathOperator) {
    self.content = content
    self._limits = mathOp.limits
    self.glyphOrigin = .zero
  }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    content.draw(at: point, in: context)
  }

  var width: Double { content.width }
  var height: Double { content.height }
  var ascent: Double { content.ascent }
  var descent: Double { content.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  // IMPORTANT: The operator is always Large
  var clazz: MathClass { .Large }
  var limits: Limits { _limits }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "\(NodeType.mathOperator)"
    let description = "\(name) \(boxDescription)"
    let content = ["content: \(content.attrString.string)"]
    return PrintUtils.compose([description], [content])
  }

  func fixLayout(_ mathContext: MathContext) {
    // do nothing
  }
}
