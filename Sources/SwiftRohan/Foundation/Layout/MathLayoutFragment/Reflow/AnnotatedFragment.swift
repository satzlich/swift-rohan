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

  /// The layout offset of this fragment in the layout context.
  private(set) var layoutOffset: Int = 0

  /// - Precondition: `offset` must be non-negative.
  mutating func setLayoutOffset(_ offset: Int) {
    precondition(offset >= 0)
    layoutOffset = offset
  }

  // MARK: - Convenience Properties and Methods

  @inlinable @inline(__always) var width: Double { fragment.width }
  @inlinable @inline(__always) var ascent: Double { fragment.ascent }
  @inlinable @inline(__always) var descent: Double { fragment.descent }
  @inlinable @inline(__always) var height: Double { fragment.height }

  @inlinable @inline(__always)
  var italicsCorrection: Double { fragment.italicsCorrection }

  @inlinable @inline(__always) var accentAttachment: Double { fragment.accentAttachment }

  @inlinable @inline(__always) var clazz: MathClass { fragment.clazz }
  @inlinable @inline(__always) var limits: Limits { fragment.limits }
  @inlinable @inline(__always) var isSpaced: Bool { fragment.isSpaced }
  @inlinable @inline(__always) var isTextLike: Bool { fragment.isTextLike }

  @inlinable @inline(__always) var layoutLength: Int { fragment.layoutLength }
  @inlinable @inline(__always) var glyphOrigin: CGPoint { fragment.glyphOrigin }

  @inlinable @inline(__always)
  func setGlyphOrigin(_ origin: CGPoint) {
    fragment.setGlyphOrigin(origin)
  }

  @inlinable @inline(__always)
  func draw(at point: CGPoint, in context: CGContext) {
    fragment.draw(at: point, in: context)
  }

  @inlinable @inline(__always)
  init(_ fragment: any MathLayoutFragment) {
    self.fragment = fragment
  }
}
