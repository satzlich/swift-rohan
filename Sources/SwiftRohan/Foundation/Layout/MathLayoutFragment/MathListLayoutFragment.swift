// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreGraphics
import DequeModule
import SatzAlgorithms
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
  private var _textColor: Color
  private var _fontSize: CGFloat

  private var _fragments: Deque<AnnotatedFragment> = []

  private var _reflowSegments: Array<ReflowSegmentFragment> = []

  init(_ mathContext: MathContext) {
    self._textColor = mathContext.textColor
    self._fontSize = mathContext.getFontSize()
  }

  // MARK: - State

  internal private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(!isEditing && _dirtyIndex == nil)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing)
    isEditing = false
  }

  // MARK: - Subfragments

  /// least index of modified fragments since last fixLayout.
  private var _dirtyIndex: Int? = nil

  private func update(dirtyIndex: Int) {
    _dirtyIndex = _dirtyIndex.map { Swift.min($0, dirtyIndex) } ?? dirtyIndex
  }

  var isEmpty: Bool { _fragments.isEmpty }
  var count: Int { _fragments.count }
  var first: MathLayoutFragment? { _fragments.first?.fragment }
  var last: MathLayoutFragment? { _fragments.last?.fragment }

  func get(_ i: Int) -> any MathLayoutFragment {
    precondition(i >= 0 && i < count)
    return _fragments[i].fragment
  }

  func getAnnotated(_ i: Int) -> AnnotatedFragment {
    precondition(i >= 0 && i < count)
    return _fragments[i]
  }

  func insert(_ fragment: MathLayoutFragment, at index: Int) {
    insert(contentsOf: [fragment], at: index)
  }

  func insert(contentsOf fragments: Array<MathLayoutFragment>, at index: Int) {
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
  var height: Double { _ascent + _descent }

  var italicsCorrection: Double { _fragments.getOnlyElement()?.italicsCorrection ?? 0 }

  var accentAttachment: Double {
    _fragments.getOnlyElement()?.accentAttachment ?? _width / 2
  }

  var clazz: MathClass { _fragments.getOnlyElement()?.clazz ?? .Normal }
  var limits: Limits { _fragments.getOnlyElement()?.limits ?? .never }

  var isSpaced: Bool { _fragments.getOnlyElement()?.isSpaced ?? false }
  var isTextLike: Bool { _fragments.getOnlyElement()?.isTextLike ?? false }

  func draw(at point: CGPoint, in context: CGContext) {
    drawSubrange(0..<_fragments.count, at: point, in: context)
  }

  func drawSubrange(_ range: Range<Int>, at point: CGPoint, in context: CGContext) {
    precondition(0 <= range.lowerBound && range.upperBound <= _fragments.count)
    context.saveGState()
    context.setFillColor(_textColor.cgColor)
    context.translateBy(x: point.x, y: point.y)
    for fragment in _fragments[range] {
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
    let startIndex =
      _fragments[..<dirtyIndex].lastIndex { $0.clazz.isVariable == false } ?? 0

    func updateMetrics(_ width: CGFloat) {
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

    // resolve running math classes
    let resolvedClasses =
      MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))

    let font = mathContext.getFont()

    // update position and annotation from startIndex
    var position: CGPoint = (startIndex == 0 ? .zero : _fragments[startIndex].glyphOrigin)
    for i in startIndex..<_fragments.endIndex {
      let ii = i - startIndex
      let fragment = _fragments[i]

      // position and spacing
      do {
        fragment.setGlyphOrigin(position)

        if i + 1 < _fragments.endIndex {
          let clazz = resolvedClasses[ii]
          let nextClazz = resolvedClasses[ii + 1]
          let spacing =
            MathUtils.resolveSpacing(clazz, nextClazz, mathContext.mathStyle) ?? .zero
          _fragments[i].spacing = font.convertToPoints(spacing)
        }
        else {
          _fragments[i].spacing = .zero
        }

        position.x += fragment.width + _fragments[i].spacing
      }

      // cursor position
      if i + 1 < _fragments.count {
        let current = fragment.clazz
        let next = _fragments[i + 1].clazz
        _fragments[i].cursorPosition = Self.resolveCursorPosition(current, next)
      }
      else {
        _fragments[i].cursorPosition = .upstream
      }

      // penalty
      if i + 1 < _fragments.endIndex {
        let current = resolvedClasses[ii]
        let next = resolvedClasses[ii + 1]
        let penalty = (current == .Binary) || (current == .Relation && next != .Relation)
        _fragments[i].penalty = penalty
      }
      else {  // no penalty for the last fragment
        _fragments[i].penalty = false
      }
    }

    updateMetrics(position.x)
  }

  /// Returns the cursor position between two fragments.
  private static func resolveCursorPosition(
    _ lhs: MathClass, _ rhs: MathClass
  ) -> CursorPosition {
    func isTextLike(_ clazz: MathClass) -> Bool {
      clazz == .Alphabetic || clazz == .Normal
    }

    switch (isTextLike(lhs), isTextLike(rhs)) {
    case (true, true):
      return .downstream  // middle works, but downstream is simpler
    case (true, false):
      return .upstream
    case (false, true):
      return .downstream
    case (false, false):
      return .middle
    }
  }

  /// Returns __exact__ segment frame whose origin is relative to __the top-left corner__
  /// of the container.
  func getSegmentFrame(_ layoutOffset: Int) -> SegmentFrame? {
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
    let cursorX = cursorDistanceThroughUpstream(index)
    // origin moved to top-left corner
    let frame = CGRect(
      x: cursorX, y: -ascent + self.ascent,
      width: 0, height: ascent + descent)
    return SegmentFrame(frame, ascent)
  }

  /// Returns cursor distance for the given position from the upstream of math list.
  func cursorDistanceThroughUpstream(_ index: Int) -> Double {
    precondition(0 <= index && index <= _fragments.count)
    if _fragments.isEmpty {
      return 0
    }
    else if index == 0 {
      return 0  // it's an invariant of math list
    }
    else if index < _fragments.count {
      let fragment = _fragments[index - 1]
      var distance = fragment.fragment.maxX
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
      return _width  // it's an invariant of math list.
    }
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
    else if index < _fragments.count {  // middle
      let previous = _fragments[index - 1]
      switch previous.cursorPosition {
      case .upstream:
        let lhs = previous.fragment
        return lhs.glyphOrigin.with(xDelta: lhs.width)
      case .middle:
        let lhs = previous.fragment
        let rhs = _fragments[index].fragment
        return CGPoint(x: (lhs.maxX + rhs.minX) / 2, y: rhs.glyphOrigin.y)
      case .downstream:
        return _fragments[index].glyphOrigin
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
      let ascent = Swift.max(_fragments[range].lazy.map(\.ascent).max()!, minAscent)
      let descent = Swift.max(_fragments[range].lazy.map(\.descent).max()!, minDescent)

      let x0 = cursorDistanceThroughUpstream(range.lowerBound)
      let x1 = cursorDistanceThroughUpstream(range.upperBound)
      let frame =
        CGRect(x: x0, y: -ascent + self.ascent, width: x1 - x0, height: ascent + descent)
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

    guard let i = getFragment(interactingAt: point) else { return (0..<0, 0) }
    let first = _fragments[0..<i].lazy.map(\.layoutLength).reduce(0, +)
    let fraction = fractionOfDistanceThroughGlyph(for: point, i)
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
  /// - Parameters:
  ///   - point: the point to compute for.
  ///   - i: the index of the fragment picked by given point.
  /// - Note: point is relative to __the glyph origin__.
  private func fractionOfDistanceThroughGlyph(for point: CGPoint, _ i: Int) -> Double {
    precondition(i >= 0 && i < _fragments.count)
    let fragment = _fragments[i]
    return ((point.x - fragment.glyphOrigin.x) / fragment.width).clamped(0, 1)
  }

  // MARK: - Debug

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): \(type(of: self))"

    let children =
      _fragments.map(\.fragment).enumerated()
      .map { (i, fragment) in fragment.debugPrint("\(i)") }

    return PrintUtils.compose([description], children)
  }
}

// MARK: - Reflow

extension MathListLayoutFragment {

  var reflowSegmentCount: Int { _reflowSegments.count }

  var reflowSegments: Array<ReflowSegmentFragment> {
    precondition(!isEditing)
    return _reflowSegments
  }

  /// Returns the index of the segment containing the layout offset.
  /// If the offset is not in any segment, returns the end index.
  func reflowSegmentIndex(_ layoutOffset: Int) -> Int {
    precondition(!isEditing)
    return _reflowSegments.firstIndex { $0.offsetRange.contains(layoutOffset) }
      ?? _reflowSegments.endIndex
  }

  func performReflow() {
    precondition(!isEditing)

    _reflowSegments.removeAll(keepingCapacity: true)

    guard !_fragments.isEmpty else { return }

    var first = 0
    var firstOffset = 0
    var i = 0
    var offset = 0

    var unusedPrevious: CGFloat = 0
    while i < _fragments.count {
      let fragment = _fragments[i]
      i += 1
      offset += fragment.layoutLength

      // segment boundary
      if fragment.penalty {
        let upstream = unusedPrevious
        let downstream: Double
        let spacing = fragment.spacing
        switch fragment.cursorPosition {
        case .upstream:
          downstream = 0
        case .middle:
          downstream = spacing / 2
        case .downstream:
          downstream = spacing
        }
        unusedPrevious = spacing - downstream

        let range = first..<i
        let offsetRange = firstOffset..<offset
        let segment =
          ReflowSegmentFragment(
            self, range, offsetRange, upstream: upstream, downstream: downstream)
        _reflowSegments.append(segment)

        first = i
        firstOffset = offset
      }
    }
    do {
      assert(i == _fragments.count)
      assert(offset == contentLayoutLength)
      let range = first..<i
      let offsetRange = firstOffset..<offset
      let segment =
        ReflowSegmentFragment(
          self, range, offsetRange, upstream: unusedPrevious, downstream: 0)
      _reflowSegments.append(segment)
    }
  }
}
