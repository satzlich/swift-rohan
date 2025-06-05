// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreGraphics
import DequeModule
import SatzAlgorithms
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
  private enum CursorPosition {
    /// cursor is placed after the upstream fragment
    case upstream
    /// cursor is placed in the middle between two fragments
    case middle
    /// cursor is placed before the downstream fragment
    case downstream
  }

  private struct AnnotatedFragment {
    let fragment: any MathLayoutFragment
    /// spacing between this fragment and the next
    var spacing: Em = .zero
    /// cursor position between this fragment and the previous
    var cursorPosition: CursorPosition = .middle
    /// whether a penalty is inserted between this fragment and the next
    var penalty: Bool = false

    // exporse properties for convenience

    @inline(__always) var width: Double { fragment.width }
    @inline(__always) var ascent: Double { fragment.ascent }
    @inline(__always) var descent: Double { fragment.descent }
    @inline(__always) var height: Double { fragment.height }
    @inline(__always) var italicsCorrection: Double { fragment.italicsCorrection }
    @inline(__always) var accentAttachment: Double { fragment.accentAttachment }

    @inline(__always) var clazz: MathClass { fragment.clazz }
    @inline(__always) var limits: Limits { fragment.limits }
    @inline(__always) var isSpaced: Bool { fragment.isSpaced }
    @inline(__always) var isTextLike: Bool { fragment.isTextLike }

    @inline(__always) var layoutLength: Int { fragment.layoutLength }
    @inline(__always) var glyphOrigin: CGPoint { fragment.glyphOrigin }
    @inline(__always) func setGlyphOrigin(_ origin: CGPoint) {
      fragment.setGlyphOrigin(origin)
    }

    @inline(__always) func draw(at point: CGPoint, in context: CGContext) {
      fragment.draw(at: point, in: context)
    }

    init(_ fragment: any MathLayoutFragment) {
      self.fragment = fragment
    }
  }

  private var _fragments: Deque<AnnotatedFragment> = []
  private var _textColor: Color
  /// least index of modified fragments since last fixLayout.
  private var _dirtyIndex: Int? = nil
  private(set) var isEditing: Bool = false

  init(_ mathContext: MathContext) {
    self._textColor = mathContext.textColor
  }

  private func update(dirtyIndex: Int) {
    _dirtyIndex = _dirtyIndex.map { Swift.min($0, dirtyIndex) } ?? dirtyIndex
  }

  // MARK: - State

  func beginEditing() {
    precondition(!isEditing && _dirtyIndex == nil)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing)
    isEditing = false
  }

  // MARK: - Subfragments

  var isEmpty: Bool { _fragments.isEmpty }
  var count: Int { _fragments.count }
  var first: MathLayoutFragment? { _fragments.first?.fragment }
  var last: MathLayoutFragment? { _fragments.last?.fragment }

  func get(_ i: Int) -> any MathLayoutFragment {
    precondition(i >= 0 && i < count)
    return _fragments[i].fragment
  }

  func insert(_ fragment: MathLayoutFragment, at index: Int) {
    precondition(isEditing)
    _fragments.insert(AnnotatedFragment(fragment), at: index)
    contentLayoutLength += fragment.layoutLength
    update(dirtyIndex: index)
  }

  func insert(contentsOf fragments: [MathLayoutFragment], at index: Int) {
    precondition(isEditing)
    _fragments.insert(contentsOf: fragments.map(AnnotatedFragment.init), at: index)
    contentLayoutLength += fragments.lazy.map(\.layoutLength).reduce(0, +)
    update(dirtyIndex: index)
  }

  func removeSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    contentLayoutLength -= _fragments[range].lazy.map(\.layoutLength).reduce(0, +)
    _fragments.removeSubrange(range)
    update(dirtyIndex: range.lowerBound)
  }

  func invalidateSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    update(dirtyIndex: range.lowerBound)
  }

  /// Returns the index of the first fragment that is __exactly__ n units
  /// of `layoutLength` away from i, or nil if no such fragment
  func index(_ i: Int, llOffsetBy n: Int) -> Int? {
    precondition(i >= 0 && i <= count)
    if n >= 0 {
      return searchIndexForward(i, distance: n)
    }
    else {
      return searchIndexBackward(i, distance: -n)
    }
  }

  /// Search for the index after i by n units of layout length
  private func searchIndexForward(_ i: Int, distance n: Int) -> Int? {
    precondition(n >= 0)
    var j = i
    var s = 0
    // let s(j) = sum { fragments[k].layoutLength | k in [i, j) }
    // result = argmin { s(j) >= n } st. s(j) == n
    while s < n && j < _fragments.count {
      s += _fragments[j].layoutLength
      j += 1
    }
    return n == s ? j : nil
  }

  /// Search for the index before i by n units of layout length
  private func searchIndexBackward(_ i: Int, distance n: Int) -> Int? {
    precondition(n >= 0)
    var j = i
    var s = 0
    // let s(j) = sum { fragments[k].layoutLength | k in [j, i) }
    // result = argmax { s(j) >= |n| } st. s(j) == |n|
    while s < n && j > 0 {
      s += _fragments[j - 1].layoutLength
      j -= 1
    }
    return n == s ? j : nil
  }

  /// Returns the range of fragments whose layout offset match `layoutRange`, or nil
  /// if no such fragments exist.
  func indexRange(_ layoutRange: Range<Int>) -> Range<Int>? {
    guard let i = searchIndexForward(0, distance: layoutRange.lowerBound),
      let j = searchIndexForward(i, distance: layoutRange.count)
    else { return nil }
    return i..<j
  }

  // MARK: Frame

  /// origin with respect to enclosing frame
  private(set) var glyphOrigin: CGPoint = .zero

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  private var _width: Double = 0
  private var _ascent: Double = 0
  private var _descent: Double = 0

  var width: Double { _width }
  var ascent: Double { _ascent }
  var descent: Double { _descent }
  var height: Double { ascent + descent }

  var italicsCorrection: Double { _fragments.getOnlyElement()?.italicsCorrection ?? 0 }

  var accentAttachment: Double {
    _fragments.getOnlyElement()?.accentAttachment ?? _width / 2
  }

  var clazz: MathClass { _fragments.getOnlyElement()?.clazz ?? .Normal }
  var limits: Limits { _fragments.getOnlyElement()?.limits ?? .never }

  var isSpaced: Bool { _fragments.getOnlyElement()?.isSpaced ?? false }
  var isTextLike: Bool { _fragments.getOnlyElement()?.isTextLike ?? false }

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.setFillColor(_textColor.nsColor.cgColor)
    context.translateBy(x: point.x, y: point.y)
    for fragment in _fragments {
      fragment.draw(at: fragment.glyphOrigin, in: context)
    }
    context.restoreGState()
  }

  var layoutLength: Int { 1 }
  private(set) var contentLayoutLength: Int = 0

  func fixLayout(_ mathContext: MathContext) {
    precondition(!isEditing)

    guard let dirtyIndex = _dirtyIndex else { return }
    defer { _dirtyIndex = nil }

    // find the start index
    assert(dirtyIndex <= _fragments.count)
    let startIndex = _fragments[..<dirtyIndex].lastIndex { !$0.clazz.isVariable } ?? 0

    func updateMetrics(_ width: CGFloat) {
      // update metrics
      _width = width
      _ascent = _fragments.lazy.map(\.ascent).max() ?? 0
      _descent = _fragments.lazy.map(\.descent).max() ?? 0
    }

    // ensure we are processing non-empty fragments
    guard startIndex < _fragments.count else {
      assert(startIndex == _fragments.count)
      let width = (_fragments.last).map { $0.glyphOrigin.x + $0.width } ?? 0
      updateMetrics(width)
      return
    }

    // compute inter-fragment spacing
    let resolvedClasses =
      MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))
    var spacings: Array<Em?> = resolvedClasses.adjacentPairs()
      .map { MathUtils.resolveSpacing($0, $1, mathContext.mathStyle) }
    spacings.append(nil)  // append nil for the last fragment
    assert(spacings.count == _fragments.endIndex - startIndex)

    let font = mathContext.getFont()

    // update positions of fragments
    var position: CGPoint = startIndex == 0 ? .zero : _fragments[startIndex].glyphOrigin

    for i in startIndex..<_fragments.endIndex {
      let (fragment, spacing) = (_fragments[i], spacings[i - startIndex])

      fragment.setGlyphOrigin(position)
      let space: CGFloat
      if let spacing = spacing {
        _fragments[i].spacing = spacing
        space = font.convertToPoints(spacing)
      }
      else {
        _fragments[i].spacing = .zero
        space = 0
      }
      position.x += fragment.width + space
    }

    updateMetrics(position.x)
  }

  private static func resolveCursorPosition(
    _ fragment: any MathLayoutFragment, previous: (any MathLayoutFragment)
  ) -> CursorPosition {
    if !(fragment.clazz == .Alphabetic || fragment.clazz == .Normal) {
      if previous.clazz == .Alphabetic || previous.clazz == .Normal {
        return .upstream
      }
      else {
        return .middle
      }
    }
    else {
      return .downstream
    }
  }

  /// Returns __exact__ segment frame whose origin is relative to __the top-left corner__
  /// of the container.
  func getSegmentFrame(for layoutOffset: Int) -> SegmentFrame? {
    guard let i = self.index(0, llOffsetBy: layoutOffset) else { return nil }
    if self.isEmpty {
      return SegmentFrame(.zero, 0)
    }
    else if i < self.count {
      let fragment = _fragments[i]
      // origin moved to top-left corner
      let origin = fragment.glyphOrigin.with(yDelta: -fragment.ascent + self.ascent)
      let size = CGSize(width: 0, height: fragment.height)
      return SegmentFrame(CGRect(origin: origin, size: size), fragment.ascent)
    }
    else if i == self.count {
      let fragment = _fragments[i - 1]
      // origin moved to top-left corner
      let origin = fragment.glyphOrigin
        .with(xDelta: fragment.width)
        .with(yDelta: -fragment.ascent + self.ascent)
      let size = CGSize(width: 0, height: fragment.height)
      return SegmentFrame(CGRect(origin: origin, size: size), fragment.ascent)
    }
    else {
      return nil
    }
  }

  /// Get a visually pleasing (inexact) segment frame for the fragment at index.
  /// - Parameters:
  ///   - index: The index of the fragment.
  ///   - minAscentDescent: The minimum ascent and descent of the segment frame.
  /// - Returns: The segment frame for the fragment at index whose origin is relative
  ///       to __the top-left corner__ of the container.
  private func getNiceFrame(
    for index: Int,
    _ minAscentDescent: (CGFloat, CGFloat)
  ) -> SegmentFrame? {
    guard index <= self.count else { return nil }

    let (ascent, descent) = minAscentDescent
    let origin: CGPoint = getNiceOrigin(index)
    // origin moved to top-left corner
    let frame = CGRect(
      x: origin.x, y: origin.y - ascent + self.ascent,
      width: 0, height: ascent + descent)
    return SegmentFrame(frame, ascent)
  }

  /// Get a visually pleasing (inexact) origin for the fragment at index.
  /// - Parameter index: The index of the fragment.
  /// - Returns: The origin for the fragment at index whose origin is relative to
  ///     __the glyph origin__ of the container.
  private func getNiceOrigin(_ index: Int) -> CGPoint {
    precondition(0...count ~= index)
    if self.isEmpty {  // empty
      return .zero
    }
    else if index == 0 {  // first
      return _fragments[index].glyphOrigin
    }
    else if index < self.count {  // middle
      let lhs = _fragments[index - 1].fragment
      let rhs = _fragments[index].fragment
      let cursorPosition = Self.resolveCursorPosition(rhs, previous: lhs)
      switch cursorPosition {
      case .upstream:
        return lhs.glyphOrigin.with(xDelta: lhs.width)
      case .middle:
        return CGPoint(x: (lhs.maxX + rhs.minX) / 2, y: rhs.glyphOrigin.y)
      case .downstream:
        return rhs.glyphOrigin
      }
    }
    else {  // last
      let fragment = _fragments[count - 1]
      return fragment.glyphOrigin.with(xDelta: fragment.width)
    }
  }

  /// - Note: Origins of the segment frame is relative to __the top-left corner__
  /// of the container.
  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    _ minAscentDescent: (CGFloat, CGFloat),
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard let range = indexRange(layoutRange) else { return false }

    if self.isEmpty || range.isEmpty {
      guard let segmentFrame = self.getNiceFrame(for: range.lowerBound, minAscentDescent)
      else { return false }
      return block(layoutRange, segmentFrame.frame, segmentFrame.baselinePosition)
    }
    // ASSERT: fragments not empty
    // ASSERT: range not empty
    else {
      let (minAscent, minDescent) = minAscentDescent
      let ascent = {
        let ascent = _fragments[range].lazy.map(\.ascent).max()!
        return Swift.max(ascent, minAscent)
      }()
      let descent = {
        let descent = _fragments[range].lazy.map(\.descent).max()!
        return Swift.max(descent, minDescent)
      }()

      let origin = getNiceOrigin(range.lowerBound)
      let endOrigin = getNiceOrigin(range.upperBound)
      let frame = CGRect(
        origin: CGPoint(x: origin.x, y: origin.y - ascent + self.ascent),
        size: CGSize(width: endOrigin.x - origin.x, height: ascent + descent))
      return block(layoutRange, frame, ascent)
    }
  }

  /// Returns the layout range for the glyph selected by point. If no fragment is
  /// hit, return an empty range.
  /// - Note: `point` is relative to __the glyph origin__ of the container.
  func getLayoutRange(interactingAt point: CGPoint) -> (Range<Int>, Double) {
    if point.x < 0 {
      return (0..<0, 0)
    }
    else if point.x > self.width {
      let n = _fragments.lazy.map(\.layoutLength).reduce(0, +)
      return (n..<n, 0)
    }

    guard let i = getFragment(interactingAt: point)
    else { return (0..<0, 0) }

    let first = _fragments[0..<i].lazy.map(\.layoutLength).reduce(0, +)
    // check point selection
    let fraction = fractionOfDistanceThroughGlyph(for: point)
    // do range selection
    let last = first + _fragments[i].layoutLength
    return (first..<last, fraction)
  }

  /// Returns the index of the fragment hit by point (inexactly). If the fragment
  /// list is empty, return nil.
  /// - Note: point is relative to __the glyph origin__ of the container.
  private func getFragment(interactingAt point: CGPoint) -> Int? {
    guard !self.isEmpty else { return nil }
    // j ← arg max { f[i].minX < point.x | i ∈ [0, count) }
    // jj = j+1 ← arg min { ¬(f[i].minX < point.x) | i ∈ [0, count) }
    let jj = Satz.lowerBound(_fragments, point.x) { $0.glyphOrigin.x < $1 }
    return jj > 0 ? jj - 1 : 0
  }

  /// The fraction of distance from the upstream edge.
  /// - Note: point is relative to __the glyph origin__.
  private func fractionOfDistanceThroughGlyph(for point: CGPoint) -> Double {
    guard let i = getFragment(interactingAt: point) else { return 0 }
    let fragment = _fragments[i]
    return ((point.x - fragment.glyphOrigin.x) / fragment.width).clamped(0, 1)
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "mlist \(boxDescription)"

    let children: [Array<String>] = _fragments
      .lazy.map(\.fragment).enumerated()
      .map { (i, fragment) in fragment.debugPrint("\(i)") }

    return PrintUtils.compose([description], children)
  }
}
