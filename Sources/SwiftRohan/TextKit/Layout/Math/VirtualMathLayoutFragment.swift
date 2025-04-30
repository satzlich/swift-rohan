// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

/// A virtual math layout fragment that wraps another math layout fragment
/// __as component__.
final class VirtualMathLayoutFragment<T: MathLayoutFragment>: MathLayoutFragment {
  let nucleus: T
  private(set) var glyphOrigin: CGPoint

  init(_ fragment: T) {
    self.nucleus = fragment
    self.glyphOrigin = .zero
  }

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  func fixLayout(_ mathContext: MathContext) {
    nucleus.fixLayout(mathContext)
  }

  var layoutLength: Int { nucleus.layoutLength }

  func draw(at point: CGPoint, in context: CGContext) {
    nucleus.draw(at: point, in: context)
  }

  var width: Double { nucleus.width }

  var height: Double { nucleus.height }

  var ascent: Double { nucleus.ascent }

  var descent: Double { nucleus.descent }

  var italicsCorrection: Double { nucleus.italicsCorrection }

  var accentAttachment: Double { nucleus.accentAttachment }

  var clazz: MathClass { nucleus.clazz }

  var limits: Limits { nucleus.limits }

  var isSpaced: Bool { nucleus.isSpaced }

  var isTextLike: Bool { nucleus.isTextLike }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = "virtual"
    let children = nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [children])
  }
}
