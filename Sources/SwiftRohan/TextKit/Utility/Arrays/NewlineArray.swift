// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections

/// Array of boolean values that indicate whether a newline should be inserted
/// at a given index.
struct NewlineArray: Equatable, Hashable {
  /// boolean values that indicate whether the corresponding element is a block.
  @usableFromInline
  internal var _isBlock: BitArray
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
    value(before: index, leadingMask: false)
  }

  /// Returns the value before the given index.
  /// - Parameters:
  ///   - index: The index for which to return the value before.
  ///   - leadingMask: the mask for the first element. Default is `false`.
  @inlinable @inline(__always)
  internal func value(before index: Int, leadingMask: Bool) -> Bool {
    precondition(0 <= index && index < _isNewline.count)
    return index == 0
      ? _isBlock[0] && leadingMask
      : _isNewline[index - 1]
  }

  init() {
    self._isBlock = BitArray()
    self._isNewline = BitArray()
    self.trailingCount = 0
  }

  init(_ isBlock: some Sequence<Bool>) {
    self._isBlock = BitArray(isBlock)
    self._isNewline =
      !_isBlock.isEmpty
      ? Self._computeNewlines(for: _isBlock)
      : []
    self.trailingCount = _isNewline.lazy.map(\.intValue).reduce(0, +)
  }

  mutating func insert(contentsOf isBlock: some Collection<Bool>, at index: Int) {
    precondition(index >= 0 && index <= _isNewline.count)

    guard !isBlock.isEmpty else { return }

    let prev: Bool? = index > 0 ? _isBlock[index - 1] : nil
    let next: Bool? = index < _isBlock.count ? _isBlock[index] : nil
    let (previous, segment) =
      Self._computeNewlines(previous: prev, segment: isBlock, next: next)

    var delta = 0
    if let previous {
      delta += previous.intValue - _isNewline[index - 1].intValue
      _isNewline[index - 1] = previous
    }
    delta += segment.lazy.map(\.intValue).reduce(0, +)

    _isBlock.insert(contentsOf: isBlock, at: index)
    _isNewline.insert(contentsOf: segment, at: index)
    trailingCount += delta
  }

  mutating func insert(isBlock: Bool, at index: Int) {
    insert(contentsOf: CollectionOfOne(isBlock), at: index)
  }

  mutating func removeSubrange(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _isNewline.count)

    guard !range.isEmpty else { return }

    // remove
    let delta = -_isNewline[range].lazy.map(\.intValue).reduce(0, +)
    _isBlock.removeSubrange(range)
    _isNewline.removeSubrange(range)
    trailingCount += delta

    // update the previous
    guard range.lowerBound > 0 else { return }
    let i = range.lowerBound - 1
    let newValue: Bool =
      (i < _isNewline.count - 1)
      ? (_isBlock[i] || _isBlock[i + 1])
      : false
    trailingCount += newValue.intValue - _isNewline[i].intValue
    _isNewline[i] = newValue
  }

  mutating func remove(at index: Int) {
    removeSubrange(index..<index + 1)
  }

  mutating func removeAll() {
    self._isBlock.removeAll()
    self._isNewline.removeAll()
    self.trailingCount = 0
  }

  mutating func replaceSubrange(_ range: Range<Int>, with isBlock: some Collection<Bool>)
  {
    precondition(range.lowerBound >= 0 && range.upperBound <= _isNewline.count)

    guard !isBlock.isEmpty else {
      self.removeSubrange(range)
      return
    }
    guard !range.isEmpty else {
      self.insert(contentsOf: isBlock, at: range.lowerBound)
      return
    }

    let prev: Bool? = range.lowerBound > 0 ? _isBlock[range.lowerBound - 1] : nil
    let next: Bool? = range.upperBound < _isBlock.count ? _isBlock[range.upperBound] : nil
    let (previous, segment) =
      Self._computeNewlines(previous: prev, segment: isBlock, next: next)

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

    _isBlock.replaceSubrange(range, with: isBlock)
    _isNewline.replaceSubrange(range, with: segment)
    trailingCount += delta
  }

  mutating func setValue(isBlock: Bool, at index: Int) {
    precondition(0..<_isBlock.count ~= index)
    guard _isBlock[index] != isBlock else { return }

    // compute new values at previous and target position
    let prev: Bool? = (index == 0) ? nil : _isBlock[index - 1]
    let next: Bool? = (index + 1 < _isBlock.count) ? _isBlock[index + 1] : nil
    let (previous, current) =
      Self.computeNewlines(previous: prev, current: isBlock, next: next)
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
    _isBlock[index] = isBlock
    _isNewline[index] = current
    // update true count
    trailingCount += delta
  }

  private static func computeNewlines(
    previous: Bool?, current isBlock: Bool, next: Bool?
  ) -> (previous: Bool?, current: Bool) {
    let previous = previous.map { $0 || isBlock }
    let current = next.map { isBlock || $0 } ?? false
    return (previous, current)
  }

  /// Compute the newlines for a segment of `isBlock` values.
  /// - Parameters:
  ///   - previous: The `isBlock` value of the element before the segment. Can be `nil`.
  ///   - isBlock: The segment of `isBlock` values.
  ///   - next: The `isBlock` value of the element after the segment. Can be `nil`.
  /// - Returns:
  ///   __previous__: The `newline` value of the element before the segment.
  ///   __segment__: The newlines for the segment.
  /// - Precondition: `isBlock` is not empty.
  private static func _computeNewlines(
    previous: Bool?, segment isBlock: some Collection<Bool>, next: Bool?
  ) -> (previous: Bool?, segment: BitArray) {
    precondition(!isBlock.isEmpty)

    // insertNewline of previous neighbour
    let previous: Bool? = previous.map({ $0 || isBlock.first! })

    if let next {
      // compute newlines
      let isBlock = chain(isBlock, CollectionOfOne(next))
      var newlines = Self._computeNewlines(for: isBlock)
      newlines.removeLast()
      return (previous, newlines)
    }
    else {
      // compute newlines
      let newlines = Self._computeNewlines(for: isBlock)
      return (previous, newlines)
    }
  }

  /// Determine whether a newline should be inserted after each element.
  /// - Precondition: The input collection is not empty.
  /// - Postcondition: The last element is always false.
  private static func _computeNewlines(for isBlock: some Collection<Bool>) -> BitArray {
    precondition(!isBlock.isEmpty)
    var bitArray = BitArray()
    bitArray.reserveCapacity(isBlock.count)
    bitArray.append(contentsOf: isBlock.lazy.adjacentPairs().map { $0.0 || $0.1 })
    bitArray.append(false)
    return bitArray
  }
}
