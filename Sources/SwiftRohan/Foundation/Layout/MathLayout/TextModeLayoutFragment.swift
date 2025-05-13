// Copyright 2024-2025 Lie Yan

import CoreGraphics
import CoreText
import Foundation
import TTFParser
import UnicodeMathClass

/// A simple math layout fragment that wraps another math layout fragment
/// __as component__.
final class TextModeLayoutFragment: MathLayoutFragment {
  var nucleus: TextLineLayoutFragment
  private(set) var glyphOrigin: CGPoint

  init(_ fragment: TextLineLayoutFragment) {
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
    let description = name ?? "simple"
    let nucleus = ["content: \(nucleus.attrString.string)"]
    return PrintUtils.compose([description], [nucleus])
  }
}
