// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import UnicodeMathClass

final class MathListLayoutFragment: MathLayoutFragment {
  init(_ textColor: Color) {
    self._textColor = textColor
  }

  private var _fragments: Deque<any MathLayoutFragment> = []
  private var _textColor: Color

  /** index where the left-most modification is made */
  private var _dirtyIndex: Int? = nil

  @inline(__always)
  private func update(dirtyIndex: Int) {
    _dirtyIndex = _dirtyIndex.map { min($0, dirtyIndex) } ?? dirtyIndex
  }

  // MARK: - State

  private var _isEditing: Bool = false
  var isEditing: Bool { @inline(__always) get { _isEditing } }

  func beginEditing() {
    precondition(!isEditing && _dirtyIndex == nil)
    _isEditing = true
  }

  func endEditing() {
    precondition(isEditing)
    _isEditing = false
  }

  // MARK: - Subfragments

  var isEmpty: Bool { @inline(__always) get { _fragments.isEmpty } }
  var count: Int { @inline(__always) get { _fragments.count } }

  func getFragment(at index: Int) -> MathLayoutFragment { _fragments[index] }

  func insert(_ fragment: MathLayoutFragment, at index: Int) {
    precondition(isEditing)
    _fragments.insert(fragment, at: index)
    _contentLayoutLength += fragment.layoutLength
    update(dirtyIndex: index)
  }

  func insert(contentsOf fragments: [MathLayoutFragment], at index: Int) {
    precondition(isEditing)
    _fragments.insert(contentsOf: fragments, at: index)
    _contentLayoutLength += fragments.lazy.map(\.layoutLength).reduce(0, +)
    update(dirtyIndex: index)
  }

  func remove(at index: Int) -> MathLayoutFragment {
    precondition(isEditing)
    let removed = _fragments.remove(at: index)
    _contentLayoutLength -= removed.layoutLength
    update(dirtyIndex: index)
    return removed
  }

  func removeSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    _contentLayoutLength -= _fragments[range].lazy.map(\.layoutLength).reduce(0, +)
    _fragments.removeSubrange(range)
    update(dirtyIndex: range.lowerBound)
  }

  func invalidateSubrange(_ range: Range<Int>) {
    precondition(isEditing)
    update(dirtyIndex: range.lowerBound)
  }

  /**
     Returns the index of the first fragment that is __exactly__ n units
     of `layoutLength` away from i, or nil if no such fragment exists.
     */
  func index(_ i: Int, llOffsetBy n: Int) -> Int? {
    precondition(i >= 0 && i <= count)
    if n >= 0 {
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
    else {
      let m = -n
      var j = i
      var s = 0
      // let s(j) = sum { fragments[k].layoutLength | k in [j, i) }
      // result = argmax { s(j) >= |n| } st. s(j) == |n|
      while s < m && j > 0 {
        s += _fragments[j - 1].layoutLength
        j -= 1
      }
      return m == s ? j : nil
    }
  }

  // MARK: Frame

  /** origin with respect to enclosing frame */
  private var _frameOrigin: CGPoint = .zero

  var glyphFrame: CGRect {
    let size = CGSize(width: width, height: height)
    return CGRect(origin: _frameOrigin, size: size)
  }

  func setGlyphOrigin(_ origin: CGPoint) {
    _frameOrigin = origin
  }

  // MARK: Metrics

  private var _width: Double = 0
  private var _ascent: Double = 0
  private var _descent: Double = 0

  var width: Double { _width }
  var ascent: Double { _ascent }
  var descent: Double { _descent }
  var height: Double { ascent + descent }

  var italicsCorrection: Double {
    _fragments.count == 1 ? _fragments[0].italicsCorrection : 0
  }

  var accentAttachment: Double {
    _fragments.count == 1 ? _fragments[0].accentAttachment : _width / 2
  }

  // MARK: - Categories

  var clazz: MathClass { _fragments.count == 1 ? _fragments[0].clazz : .Normal }
  var limits: Limits { _fragments.count == 1 ? _fragments[0].limits : .never }

  // MARK: - Flags

  var isSpaced: Bool { _fragments.count == 1 ? _fragments[0].isSpaced : false }
  var isTextLike: Bool { _fragments.count == 1 ? _fragments[0].isTextLike : false }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.setFillColor(_textColor.nsColor.cgColor)
    context.translateBy(x: point.x, y: point.y)
    for fragment in _fragments {
      fragment.draw(at: fragment.glyphFrame.origin, in: context)
    }
    context.restoreGState()
  }

  // MARK: Length

  var layoutLength: Int { 1 }
  private var _contentLayoutLength: Int = 0
  var contentLayoutLength: Int { @inline(__always) get { _contentLayoutLength } }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    precondition(!isEditing)

    guard let dirtyIndex = _dirtyIndex else { return }
    defer { _dirtyIndex = nil }

    // find the start index
    assert(dirtyIndex <= _fragments.count)
    let startIndex: Int =
      _fragments[..<dirtyIndex]
      .lastIndex(where: { $0.clazz != .Vary }) ?? 0

    func updateMetrics(_ width: CGFloat) {
      // update metrics
      _width = width
      _ascent = _fragments.lazy.map(\.ascent).max() ?? 0
      _descent = _fragments.lazy.map(\.descent).max() ?? 0
    }

    // ensure we are processing non-empty fragments
    guard startIndex < _fragments.count else {
      assert(startIndex == _fragments.count)
      let width =
        (_fragments.last?.glyphFrame)
        .map { $0.origin.x + $0.width } ?? 0
      updateMetrics(width)
      return
    }

    // compute inter-fragment spacing
    let spacings = chain(
      // part 0
      MathUtils.resolveMathClass(_fragments[startIndex...].lazy.map(\.clazz))
        .adjacentPairs()
        .lazy.map { MathUtils.resolveSpacing($0, $1, mathContext.mathStyle) },
      // part 1
      CollectionOfOne(nil)
    )

    let font = mathContext.getFont()

    // update positions of fragments
    var position: CGPoint =
      startIndex == 0 ? .zero : _fragments[startIndex].glyphFrame.origin
    for (fragment, spacing) in zip(_fragments[startIndex...], spacings) {
      fragment.setGlyphOrigin(position)
      let space = spacing.map { font.convertToPoints($0) } ?? 0
      position.x += fragment.width + space
    }

    updateMetrics(position.x)
  }
}
