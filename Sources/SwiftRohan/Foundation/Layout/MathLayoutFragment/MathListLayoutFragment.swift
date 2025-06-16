// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreGraphics
import DequeModule
import SatzAlgorithms
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
  private struct _Flags: OptionSet {
    let rawValue: Int8

    static let isEditing = _Flags(rawValue: 1 << 0)
    static let isReflowDirty = _Flags(rawValue: 1 << 1)
  }

  private var _textColor: Color
  private var _fragments: Deque<AnnotatedFragment> = []
  private var _reflowSegments: Array<ReflowSegmentFragment> = []

  private(set) var contentLayoutLength: Int = 0

  /// minimum index of modified fragments since last fixLayout.
  private var _dirtyIndex: Optional<Int> = nil
  private var _flags: _Flags = []

  internal func markDirty(_ dirtyIndex: Int) {
    _dirtyIndex = _dirtyIndex.map { Swift.min($0, dirtyIndex) } ?? dirtyIndex
    _flags.insert(.isReflowDirty)
  }

  init(_ mathContext: MathContext) {
    self._textColor = mathContext.textColor
  }

  // MARK: - State

  @inlinable @inline(__always)
  internal var isEditing: Bool { _flags.contains(.isEditing) }

  @inlinable @inline(__always)
  internal var isLayoutDirty: Bool { _dirtyIndex != nil }

  @inlinable @inline(__always)
  internal var isReflowDirty: Bool { _flags.contains(.isReflowDirty) }

  func beginEditing() {
    precondition(!isEditing && !isLayoutDirty)
    _flags.insert(.isEditing)
  }

  func endEditing() {
    precondition(isEditing)
    _flags.remove(.isEditing)
  }

  // MARK: - Content

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
    markDirty(index)
  }

  func removeSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    contentLayoutLength -= _fragments[range].lazy.map(\.layoutLength).reduce(0, +)
    _fragments.removeSubrange(range)
    markDirty(range.lowerBound)
  }

  func invalidateSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    markDirty(range.lowerBound)
  }

  // MARK: - MathLayoutFragment

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

  func fixLayout(_ mathContext: MathContext) {
    self.fixLayout(mathContext, previousClass: nil)
  }

  /// Fixes layout of the math list.
  /// - Parameters:
  ///   - mathContext: the math context to use for layout.
  ///   - previousClass: the math class to precede the first fragment of this list
  ///       for the purpose of spacing.
  /// - Complexity: O(n-k) where k is the number of fragments before the dirty index.
  func fixLayout(_ mathContext: MathContext, previousClass: MathClass?) {
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
      let width = _fragments.last.map { $0.glyphOrigin.x + $0.width } ?? 0
      updateMetrics(width)
      return
    }

    // resolve running math classes
    let resolvedClasses =
      startIndex == 0
      ? MathUtils.resolveMathClass(_fragments.lazy.map(\.clazz), previous: previousClass)
      : MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))

    // initialize position and layout offset
    var position: CGPoint
    var layoutOffset: Int
    if startIndex == 0 {
      position = .zero
      layoutOffset = 0
    }
    else {
      position = _fragments[startIndex].glyphOrigin
      layoutOffset = _fragments[startIndex].layoutOffset
    }
    // update position and annotation from startIndex
    let font = mathContext.getFont()
    for i in startIndex..<_fragments.endIndex {
      let ii = i - startIndex
      let fragment = _fragments[i]

      // layout offset
      do {
        _fragments[i].setLayoutOffset(layoutOffset)
        layoutOffset += fragment.layoutLength
      }

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

  /// Returns __exact__ segment frame whose origin is relative to __the top-left corner__
  /// of the container.
  /// - Complexity: O(log n) where n is the number of fragments.
  func getSegmentFrame(_ layoutOffset: Int) -> SegmentFrame? {
    guard let i = self.index(matching: layoutOffset) else { return nil }
    if self.isEmpty {
      return SegmentFrame(.zero, 0)
    }
    else if i < self.count {
      let fragment = _fragments[i]
      let segmentFrame = composeSegmentFrame(
        fragment.glyphOrigin, width: 0,
        ascent: fragment.ascent, descent: fragment.descent)
      return segmentFrame
    }
    else {
      assert(i == self.count)
      let fragment = _fragments[self.count - 1]
      var segmentFrame = composeSegmentFrame(
        fragment.glyphOrigin, width: 0,
        ascent: fragment.ascent, descent: fragment.descent)
      segmentFrame.frame.origin.x += fragment.width
      return segmentFrame
    }
  }

  /// Enumerates text segments in the layout range.
  /// - Complexity: O(log n) where n is the number of fragments.
  /// - Note: Origins of the segment frame is relative to __the top-left corner__
  /// of the container.
  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    _ minAscentDescent: (Double, Double),
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    guard let range = indexRange(matching: layoutRange) else { return false }
    let (cursorAscent, cursorDescent) = cursorHeight(range, minAscentDescent)

    let segmentFrame: SegmentFrame
    if self.isEmpty {
      guard range.isEmpty && range.lowerBound == 0 else { return false }
      segmentFrame = composeSegmentFrame(
        .zero, width: 0, ascent: cursorAscent, descent: cursorDescent)
    }
    else if range.isEmpty {
      guard range.lowerBound <= _fragments.count else { return false }
      let x = cursorDistanceThroughUpstream(range.lowerBound)
      segmentFrame = composeSegmentFrame(
        CGPoint(x: x, y: 0), width: 0, ascent: cursorAscent, descent: cursorDescent)
    }
    // ASSERT: fragments not empty
    // ASSERT: range not empty
    else {
      let x0 = cursorDistanceThroughUpstream(range.lowerBound)
      let x1 = cursorDistanceThroughUpstream(range.upperBound)
      segmentFrame = composeSegmentFrame(
        CGPoint(x: x0, y: 0), width: x1 - x0,
        ascent: cursorAscent, descent: cursorDescent)
    }

    return block(layoutRange, segmentFrame.frame, segmentFrame.baselinePosition)
  }

  /// Returns the layout range for the glyph selected by point. If no fragment is
  /// hit, return an empty range.
  /// - Complexity: O(log n).
  /// - Note: `point` is relative to __the glyph origin__ of the container.
  func getLayoutRange(interactingAt point: CGPoint) -> (Range<Int>, Double) {
    precondition(!isEditing && !isLayoutDirty)

    if point.x <= 0 {
      return (0..<0, 0)
    }
    else if point.x >= self.width {
      let n = self.contentLayoutLength
      return (n..<n, 0)
    }

    guard let i = getFragment(interactingAt: point) else { return (0..<0, 0) }
    assert(0..<_fragments.count ~= i)

    let fragment = _fragments[i]
    let offset = _fragments[i].layoutOffset
    let end = offset + fragment.layoutLength
    let fraction = (point.x - fragment.glyphOrigin.x) / fragment.width
    return (offset..<end, fraction.clamped(0, 1))
  }

  // MARK: - Debug

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): \(type(of: self))"

    let children =
      _fragments.map(\.fragment).enumerated()
      .map { (i, fragment) in fragment.debugPrint("\(i)") }

    return PrintUtils.compose([description], children)
  }

  // MARK: - Query for Index

  /// Returns the index of the fragment hit by point (inexactly). If the fragment
  /// list is empty, return nil.
  /// - Complexity: O(log n).
  /// - Postcondition: if the return value is not nil, the index is in [0, count).
  /// - Note: point is relative to __the glyph origin__ of the container.
  private func getFragment(interactingAt point: CGPoint) -> Int? {
    precondition(!isEditing && !isLayoutDirty)
    guard !self.isEmpty else { return nil }
    // j ← arg max { f[i].minX < point.x | i ∈ [0, count) }
    // jj = j+1 ← arg min { ¬(f[i].minX < point.x) | i ∈ [0, count) }
    let jj = Satz.lowerBound(_fragments, point.x) { $0.glyphOrigin.x < $1 }
    return jj > 0 ? jj - 1 : 0
  }

  /// Returns the index of fragment that **matches** the layout offset.
  /// - Complexity: O(log n).
  /// - Precondition: the math list is not in editing mode and there is no dirty index.
  func index(matching layoutOffset: Int) -> Int? {
    precondition(!isEditing && !isLayoutDirty)
    precondition(layoutOffset >= 0)
    let i = self.index(containing: layoutOffset)
    if i < _fragments.count {
      if _fragments[i].layoutOffset == layoutOffset {
        return i
      }
    }
    else {
      assert(i == _fragments.count)
      if layoutOffset == contentLayoutLength { return i }
    }
    return nil
  }

  /// Returns the range of fragments whose layout offset match `layoutRange`, or nil
  /// if no such fragments exist.
  /// - Complexity: O(log n).
  /// - Precondition: the math list is not in editing mode and there is no dirty index.
  func indexRange(matching layoutRange: Range<Int>) -> Range<Int>? {
    precondition(!isEditing && !isLayoutDirty)
    guard let i = index(matching: layoutRange.lowerBound),
      let j = index(matching: layoutRange.upperBound)
    else { return nil }
    return i..<j
  }

  /// Returns the index of the fragment whose layout offset range contains the given
  /// layout offset. If no such fragment exists, returns fragment count.
  /// - Complexity: O(log n).
  /// - Precondition: the math list is not in editing mode and there is no dirty index.
  func index(containing layoutOffset: Int) -> Int {
    precondition(!isEditing && !isLayoutDirty)
    precondition(layoutOffset >= 0)
    return Satz.lowerBound(_fragments, layoutOffset) { $0.layoutOffset < $1 }
  }

  /// Returns the index of the first fragment that is __exactly__ n units
  /// of `layoutLength` away from i, or nil if no such fragment
  /// - Complexity: O(n).
  /// - Precondition: Use this during editing or when fixLayout.
  func index(_ i: Int, llOffsetBy n: Int) -> Int? {
    precondition(isEditing || isLayoutDirty)
    precondition(i >= 0 && i <= count)
    return n >= 0
      ? searchIndexForward(i, distance: n)
      : searchIndexBackward(i, distance: -n)

    /// Search for the index after i by n units of layout length
    func searchIndexForward(_ i: Int, distance n: Int) -> Int? {
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
    /// - Complexity: O(n).
    func searchIndexBackward(_ i: Int, distance n: Int) -> Int? {
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
  }

  // MARK: - Cursor Facility

  /// Returns cursor distance for the given position from the upstream of math list.
  /// - Complexity: O(1).
  internal func cursorDistanceThroughUpstream(_ index: Int) -> Double {
    precondition(!isEditing && !isLayoutDirty)
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

  /// Compute cursor height (ascent, descent) for the index range.
  /// - Complexity: O(n), where n is the size of the range.
  internal func cursorHeight(
    _ range: Range<Int>, _ minAsccentDescent: (ascent: Double, descent: Double)
  ) -> (ascent: Double, descent: Double) {
    precondition(!isEditing && !isLayoutDirty)
    precondition(0 <= range.lowerBound && range.upperBound <= _fragments.count)

    if range.isEmpty {
      return minAsccentDescent
    }
    else {
      let (minAscent, minDescent) = minAsccentDescent
      let range = range.clamped(to: 0..<_fragments.count)
      let ascent = _fragments[range].lazy.map(\.ascent).max()!
      let descent = _fragments[range].lazy.map(\.descent).max()!
      return (max(ascent, minAscent), max(descent, minDescent))
    }
  }

  /// Returns the cursor position between two fragments.
  internal static func resolveCursorPosition(
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

  /// Compose a segment frame whose origin is at the **top-left** corner and is relative
  /// to the **top-left** corner of this math list.
  /// - Parameters:
  ///   - glyphOrigin: glyph origin relative to the **glyph origin** of the math list.
  ///
  /// - Invariant: the method satisfies: `f(p1+p2) = f(p1) + p2` where "+" is translation.
  internal func composeSegmentFrame(
    _ glyphOrigin: CGPoint, width: CGFloat, ascent: CGFloat, descent: CGFloat
  ) -> SegmentFrame {
    let frame = CGRect(
      x: glyphOrigin.x, y: glyphOrigin.y - ascent + self.ascent,
      width: width, height: ascent + descent)
    return SegmentFrame(frame, ascent)
  }
}

// MARK: - Reflow

extension MathListLayoutFragment {

  var reflowSegmentCount: Int { _reflowSegments.count }

  var reflowSegments: Array<ReflowSegmentFragment> {
    precondition(!isEditing && !isReflowDirty)
    return _reflowSegments
  }

  /// Returns the index of the segment containing the layout offset.
  /// If the offset is not in any segment, returns the end index.
  func reflowSegmentIndex(containing layoutOffset: Int) -> Int {
    precondition(!isEditing && !isReflowDirty)
    return Satz.lowerBound(_reflowSegments, layoutOffset) {
      $0.offsetRange.upperBound <= $1
    }
  }

  func performReflow() {
    precondition(!isEditing && !isLayoutDirty)

    _reflowSegments.removeAll(keepingCapacity: true)
    defer { _flags.remove(.isReflowDirty) }

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
