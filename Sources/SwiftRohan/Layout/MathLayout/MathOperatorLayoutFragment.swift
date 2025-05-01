// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathOperatorLayoutFragment: MathLayoutFragment {

  let content: MathListLayoutFragment
  let _limits: Limits

  init(_ content: MathListLayoutFragment, _ limits: Bool) {
    self.content = content
    self._limits = limits ? .always : .never
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

  var italicsCorrection: Double { content.italicsCorrection }

  var accentAttachment: Double { content.accentAttachment }

  // IMPORTANT: The operator is always Large
  var clazz: MathClass { .Large }

  var limits: Limits { _limits }

  var isSpaced: Bool { content.isSpaced }

  var isTextLike: Bool { content.isTextLike }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "\(NodeType.mathOperator)"
    let description = "\(name) \(boxDescription)"

    let content = content.debugPrint("content")
    return PrintUtils.compose([description], [content])
  }

  func fixLayout(_ mathContext: MathContext) {
    // do nothing
  }
}
