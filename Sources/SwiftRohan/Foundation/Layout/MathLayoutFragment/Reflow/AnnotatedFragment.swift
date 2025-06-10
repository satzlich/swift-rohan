// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

struct AnnotatedFragment {
  let fragment: any MathLayoutFragment
  /// spacing (in points) between this fragment and the **next**.
  var spacing: CGFloat = .zero
  /// cursor position between this fragment and the **next**
  var cursorPosition: CursorPosition = .upstream
  /// whether a penalty is inserted between this fragment and the next
  var penalty: Bool = false

  // exporse properties for convenience

  var width: Double { fragment.width }
  var ascent: Double { fragment.ascent }
  var descent: Double { fragment.descent }
  var height: Double { fragment.height }
  var italicsCorrection: Double { fragment.italicsCorrection }
  var accentAttachment: Double { fragment.accentAttachment }

  var clazz: MathClass { fragment.clazz }
  var limits: Limits { fragment.limits }
  var isSpaced: Bool { fragment.isSpaced }
  var isTextLike: Bool { fragment.isTextLike }

  var layoutLength: Int { fragment.layoutLength }
  var glyphOrigin: CGPoint { fragment.glyphOrigin }

  func setGlyphOrigin(_ origin: CGPoint) {
    fragment.setGlyphOrigin(origin)
  }

  func draw(at point: CGPoint, in context: CGContext) {
    fragment.draw(at: point, in: context)
  }

  init(_ fragment: any MathLayoutFragment) {
    self.fragment = fragment
  }
}
