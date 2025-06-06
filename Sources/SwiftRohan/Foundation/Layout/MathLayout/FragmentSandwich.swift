// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import UnicodeMathClass

final class FragmentSandwich: MathLayoutFragment {
  /// Added space before the wrapped fragment.
  let upstream: CGFloat
  /// Added space after the wrapped fragment.
  let downstream: CGFloat
  /// The wrapped fragment.
  let wrapped: MathLayoutFragment

  init(
    upstream: CGFloat,
    downstream: CGFloat,
    wrapped: MathLayoutFragment
  ) {
    self.upstream = upstream
    self.downstream = downstream
    self.wrapped = wrapped

    self.glyphOrigin = .zero
  }

  var width: Double { wrapped.width + Double(upstream) + Double(downstream) }
  var height: Double { wrapped.height }
  var ascent: Double { wrapped.ascent }
  var descent: Double { wrapped.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }
  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { wrapped.layoutLength }

  func fixLayout(_ mathContext: MathContext) {
    // no-op
  }

  func draw(at point: CGPoint, in context: CGContext) {
    wrapped.draw(at: point.with(xDelta: upstream), in: context)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    [
      "FragmentSandwich \(name ?? "")"
    ]
  }
}
