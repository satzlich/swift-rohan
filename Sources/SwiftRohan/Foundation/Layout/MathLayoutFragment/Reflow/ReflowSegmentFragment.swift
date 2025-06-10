// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

/// A segment of math list layout that is used for reflowing the content.
final class ReflowSegmentFragment: MathLayoutFragment {
  /// The source fragment that this segment is derived from.
  private let source: MathListLayoutFragment
  /// index range in the source fragment.
  private let range: Range<Int>
  /// Added upstream space before the segment.
  private let upstream: CGFloat
  /// Added downstream space after the segment.
  private let downstream: CGFloat

  /// Total width of the segment, including upstream and downstream spaces.
  private let totalWidth: CGFloat

  private(set) var glyphOrigin: CGPoint

  var width: Double { totalWidth }
  internal let ascent: Double
  internal let descent: Double
  internal var height: Double { ascent + descent }

  init(
    _ source: MathListLayoutFragment, _ range: Range<Int>,
    upstream: CGFloat, downstream: CGFloat
  ) {
    precondition(range.isEmpty == false)
    self.source = source
    self.range = range
    self.upstream = upstream
    self.downstream = downstream

    do {
      let minX = source.get(range.lowerBound).minX
      let maxX = source.get(range.upperBound - 1).maxX
      self.totalWidth = maxX - minX + upstream + downstream
    }

    do {
      var ascent: CGFloat = 0
      var descent: CGFloat = 0
      for index in range {
        let fragment = source.get(index)
        ascent = max(ascent, fragment.ascent)
        descent = max(descent, fragment.descent)
      }
      self.ascent = ascent
      self.descent = descent
    }

    self.glyphOrigin = .zero
  }

  var accentAttachment: Double { totalWidth / 2 }
  var italicsCorrection: Double { 0 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }
  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  var layoutLength: Int { 1 }

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  func draw(at point: CGPoint, in context: CGContext) {
    var point = point
    point.x += upstream - source.get(range.lowerBound).glyphOrigin.x

    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    for index in range {
      let fragment = source.get(index)
      fragment.draw(at: fragment.glyphOrigin, in: context)
    }
    context.restoreGState()
  }

  func fixLayout(_ mathContext: MathContext) { /* no-op */  }

  func debugPrint(_ name: String) -> Array<String> {
    [
      "\(name): ReflowSegmentFragment"
    ]
  }
}
