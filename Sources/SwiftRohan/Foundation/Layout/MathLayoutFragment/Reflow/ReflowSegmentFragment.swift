// Copyright 2024-2025 Lie Yan

import CoreGraphics
import UnicodeMathClass

/// A segment of math list layout that is used for reflowing the content.
final class ReflowSegmentFragment: MathLayoutFragment {
  // MARK: - MathLayoutFragment

  var width: Double { totalWidth }
  internal let ascent: Double
  internal let descent: Double
  internal var height: Double { ascent + descent }

  var accentAttachment: Double { totalWidth / 2 }
  var italicsCorrection: Double { 0 }

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }
  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  var layoutLength: Int { 1 }

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  func draw(at point: CGPoint, in context: CGContext) {
    var point = point
    point.x += upstream - source.get(range.lowerBound).glyphOrigin.x
    source.drawSubrange(range, at: point, in: context)
  }

  func fixLayout(_ mathContext: MathContext) { /* no-op */  }

  func debugPrint(_ name: String) -> Array<String> {
    [
      "\(name): ReflowSegmentFragment"
    ]
  }

  // MARK: - Implementation

  /// The source fragment that this segment is derived from.
  private let source: MathListLayoutFragment
  /// index range in the source fragment.
  internal let range: Range<Int>
  /// Layout offset range in the source fragment.
  internal let offsetRange: Range<Int>
  /// Added upstream space before the segment.
  internal let upstream: CGFloat
  /// Added downstream space after the segment.
  private let downstream: CGFloat

  /// Total width of the segment, including upstream and downstream spaces.
  private let totalWidth: CGFloat

  init(
    _ source: MathListLayoutFragment,
    _ range: Range<Int>,
    _ offsetRange: Range<Int>,
    upstream: CGFloat, downstream: CGFloat
  ) {
    precondition(range.isEmpty == false)
    self.source = source
    self.range = range
    self.offsetRange = offsetRange
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

  // MARK: - ReflowSegmentFragment

  /// **Exact distance** from the fragment identified by index to the
  /// upstream boundary of the segment. When the index is at the upper
  /// bound, the distance is from the downstream edge of the last fragment.
  func distanceThroughSegment(_ index: Int) -> Double {
    precondition(index >= range.lowerBound)
    precondition(index <= range.upperBound)
    if index == range.lowerBound {
      return upstream
    }
    else if index < range.upperBound {
      return upstream + source.get(index).glyphOrigin.x
        - source.get(range.lowerBound).glyphOrigin.x
    }
    else {
      return totalWidth - downstream
    }
  }

  /// Convert the distance from the upstream edge of the segment to the
  /// **equivalent** distance from the upstream edge of the math list layout
  /// fragment.
  func equivalentPosition(_ x: Double) -> Double {
    x - upstream + source.get(range.lowerBound).glyphOrigin.x
  }

  /// **Cursor distance** from the position given by the index to the
  /// upstream boundary of the segment.
  func cursorDistanceThroughSegment(_ index: Int) -> Double {
    precondition(index >= range.lowerBound)
    precondition(index <= range.upperBound)

    if index == range.lowerBound {
      return 0
    }
    else if index < range.upperBound {
      let first = source.get(range.lowerBound)
      let fragment = source.getAnnotated(index - 1)
      var distance = upstream + fragment.fragment.maxX - first.minX
      switch fragment.cursorPosition {
      case .upstream:
        break
      case .middle:
        distance += fragment.spacing / 2
      case .downstream:
        distance += fragment.spacing
      }
      return distance
    }
    else {
      return totalWidth
    }
  }

  /// Returns the index of the fragment whose layout offset range contains
  /// the given layout offset. If not found, **clamps to** the nearest index
  /// within the segment range (upper bound included).
  func fragmentIndex(_ layoutOffset: Int) -> Int {
    guard layoutOffset >= offsetRange.lowerBound else { return range.lowerBound }
    guard layoutOffset < offsetRange.upperBound else { return range.upperBound }

    let i = source.index(containing: layoutOffset)
    assert(range ~= i)
    return i
  }
}
