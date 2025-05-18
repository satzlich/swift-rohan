// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

// Wrapper for LayoutFragment to conform to MathLayoutFragment.
final class MathLayoutFragmentWrapper<T: LayoutFragment>: MathLayoutFragment {
  var nucleus: T

  private(set) var glyphOrigin: CGPoint

  init(_ fragment: T) {
    self.nucleus = fragment
    self.glyphOrigin = .zero
  }

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  var layoutLength: Int { nucleus.layoutLength }

  func draw(at point: CGPoint, in context: CGContext) {
    nucleus.draw(at: point, in: context)
  }

  var width: Double { nucleus.width }
  var height: Double { nucleus.height }
  var ascent: Double { nucleus.ascent }
  var descent: Double { nucleus.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "mathwrapper \(boxDescription)"
    return PrintUtils.compose([description], [])
  }
}
