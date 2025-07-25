import Algorithms
import BitCollections

/// Array of boolean values that indicate whether a newline should be inserted
/// at a given index.
struct NewlineArray: Equatable, Hashable {
  /// List of layout types.
  @usableFromInline
  internal var _layoutTypes: ContiguousArray<LayoutType>
  /// boolean values that indicate whether a newline should be inserted **after**
  /// each element.
  @usableFromInline
  internal var _isNewline: BitArray

  /// the sum of all `true` values of trailing newlines.
  private(set) var trailingCount: Int

  @inlinable @inline(__always)
  internal var asBitArray: BitArray { _isNewline }

  @inlinable @inline(__always)
  internal var isEmpty: Bool { _isNewline.isEmpty }

  @inlinable @inline(__always)
  internal var count: Int { _isNewline.count }

  @inlinable @inline(__always)
  internal subscript(index: Int) -> Bool { _isNewline[index] }

  @inlinable @inline(__always)
  var first: Bool? { _isNewline.first }

  @inlinable @inline(__always)
  var last: Bool? { _isNewline.last }

  @inlinable @inline(__always)
  internal func value(before index: Int) -> Bool {
    value(before: index, atBlockEdge: true)
  }

  /// Returns the value before the given index.
  /// - Parameters:
  ///   - index: The index for which to return the value before.
  ///   - atBlockEdge: If `true`, the first element is located at the start of a block.
  @inlinable @inline(__always)
  internal func value(before index: Int, atBlockEdge: Bool) -> Bool {
    precondition(0 <= index && index < _isNewline.count)
    return index == 0
      ? _layoutTypes[0] == .hardBlock && !atBlockEdge  // for softBlock and inline, no newline.
      : _isNewline[index - 1]
  }

  init() {
    self._layoutTypes = ContiguousArray()
    self._isNewline = BitArray()
    self.trailingCount = 0
  }

  init(_ layoutTypes: some Sequence<LayoutType>) {
    self._layoutTypes = ContiguousArray(layoutTypes)
    self._isNewline =
      !_layoutTypes.isEmpty
      ? Self._computeNewlines(for: _layoutTypes)
      : []
    self.trailingCount = _isNewline.lazy.map(\.intValue).reduce(0, +)
  }

  mutating func insert(contentsOf layoutTypes: some Collection<LayoutType>, at index: Int)
  {
    precondition(index >= 0 && index <= _isNewline.count)

    guard !layoutTypes.isEmpty else { return }

    let prev: LayoutType? = index > 0 ? _layoutTypes[index - 1] : nil
    let next: LayoutType? = index < _layoutTypes.count ? _layoutTypes[index] : nil
    let (previous, segment) =
      Self._computeNewlines(previous: prev, segment: layoutTypes, next: next)

    var delta = 0
    if let previous {
      delta += previous.intValue - _isNewline[index - 1].intValue
      _isNewline[index - 1] = previous
    }
    delta += segment.lazy.map(\.intValue).reduce(0, +)

    _layoutTypes.insert(contentsOf: layoutTypes, at: index)
    _isNewline.insert(contentsOf: segment, at: index)
    trailingCount += delta
  }

  mutating func insert(layoutType: LayoutType, at index: Int) {
    insert(contentsOf: CollectionOfOne(layoutType), at: index)
  }

  mutating func removeSubrange(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _isNewline.count)

    guard !range.isEmpty else { return }

    // remove
    let delta = -_isNewline[range].lazy.map(\.intValue).reduce(0, +)
    _layoutTypes.removeSubrange(range)
    _isNewline.removeSubrange(range)
    trailingCount += delta

    // update the previous
    guard range.lowerBound > 0 else { return }
    let i = range.lowerBound - 1
    let newValue: Bool =
      (i < _isNewline.count - 1)
      ? LayoutType.isNewline(_layoutTypes[i], _layoutTypes[i + 1])
      : false
    trailingCount += newValue.intValue - _isNewline[i].intValue
    _isNewline[i] = newValue
  }

  mutating func remove(at index: Int) {
    removeSubrange(index..<index + 1)
  }

  mutating func removeAll() {
    self._layoutTypes.removeAll()
    self._isNewline.removeAll()
    self.trailingCount = 0
  }

  mutating func replaceSubrange(
    _ range: Range<Int>, with layoutTypes: some Collection<LayoutType>
  ) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _isNewline.count)

    guard !layoutTypes.isEmpty else {
      self.removeSubrange(range)
      return
    }
    guard !range.isEmpty else {
      self.insert(contentsOf: layoutTypes, at: range.lowerBound)
      return
    }

    let prev: LayoutType? =
      range.lowerBound > 0 ? _layoutTypes[range.lowerBound - 1] : nil
    let next: LayoutType? =
      range.upperBound < _layoutTypes.count ? _layoutTypes[range.upperBound] : nil
    let (previous, segment) =
      Self._computeNewlines(previous: prev, segment: layoutTypes, next: next)

    var delta = 0
    // deduct the old values
    delta -= _isNewline[range].lazy.map(\.intValue).reduce(0, +)
    // add change of previous neighbour
    if let previous {
      delta += previous.intValue - _isNewline[range.lowerBound - 1].intValue
      // update previous neighbour
      _isNewline[range.lowerBound - 1] = previous
    }
    // add the new values
    delta += segment.lazy.map(\.intValue).reduce(0, +)

    _layoutTypes.replaceSubrange(range, with: layoutTypes)
    _isNewline.replaceSubrange(range, with: segment)
    trailingCount += delta
  }

  mutating func setValue(layoutType: LayoutType, at index: Int) {
    precondition(0..<_layoutTypes.count ~= index)
    guard _layoutTypes[index] != layoutType else { return }

    // compute new values at previous and target position
    let prev: LayoutType? = (index == 0) ? nil : _layoutTypes[index - 1]
    let next: LayoutType? =
      (index + 1 < _layoutTypes.count) ? _layoutTypes[index + 1] : nil
    let (previous, current) =
      Self.computeNewlines(previous: prev, current: layoutType, next: next)
    var delta = 0
    if let previous {
      // compute delta
      delta += previous.intValue - _isNewline[index - 1].intValue
      // update previous
      _isNewline[index - 1] = previous
    }
    // compute delta
    delta += current.intValue - _isNewline[index].intValue
    // update target
    _layoutTypes[index] = layoutType
    _isNewline[index] = current
    // update true count
    trailingCount += delta
  }

  private static func computeNewlines(
    previous: LayoutType?, current layoutType: LayoutType, next: LayoutType?
  ) -> (previous: Bool?, current: Bool) {
    let previous = previous.map { LayoutType.isNewline($0, layoutType) }
    let current = next.map { LayoutType.isNewline(layoutType, $0) } ?? false
    return (previous, current)
  }

  /// Compute the newlines for a segment of layout types.
  /// - Parameters:
  ///   - previous: The layout type of the element before the segment. May be `nil`.
  ///   - layoutTypes: The segment of layout types.
  ///   - next: The layout type of the element after the segment. May be `nil`.
  /// - Returns:
  ///   __previous__: The newline value of the element before the segment.
  ///   __segment__: The newlines for the segment.
  /// - Precondition: `layoutTypes` is not empty.
  private static func _computeNewlines(
    previous: LayoutType?,
    segment layoutTypes: some Collection<LayoutType>,
    next: LayoutType?
  ) -> (previous: Bool?, segment: BitArray) {
    precondition(!layoutTypes.isEmpty)

    // insertNewline of previous neighbour
    let previous: Bool? = previous.map {
      LayoutType.isNewline($0, layoutTypes.first!)
    }

    if let next {
      // compute newlines
      let layoutTypes = chain(layoutTypes, CollectionOfOne(next))
      var newlines = Self._computeNewlines(for: layoutTypes)
      newlines.removeLast()
      return (previous, newlines)
    }
    else {
      // compute newlines
      let newlines = Self._computeNewlines(for: layoutTypes)
      return (previous, newlines)
    }
  }

  /// Determine whether a newline should be inserted after each element.
  /// - Precondition: The input collection is not empty.
  /// - Postcondition: The last element is always false.
  private static func _computeNewlines(
    for layoutTypes: some Collection<LayoutType>
  ) -> BitArray {
    precondition(!layoutTypes.isEmpty)
    var bitArray = BitArray()
    bitArray.reserveCapacity(layoutTypes.count)
    bitArray.append(
      contentsOf: layoutTypes.lazy.adjacentPairs()
        .map { (lhs, rhs) in LayoutType.isNewline(lhs, rhs) })
    bitArray.append(false)
    return bitArray
  }
}
