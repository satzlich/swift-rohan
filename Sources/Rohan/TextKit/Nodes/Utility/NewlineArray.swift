// Copyright 2024-2025 Lie Yan

import Algorithms
import BitCollections

/**
 Maintains an array of booleans that indicates whether a newline should
 be inserted at a given index.
 */
@usableFromInline
struct NewlineArray {
  private var _isBlock: BitArray
  private var _insertNewline: BitArray
  private(set) var trueValueCount: Int

  public var isEmpty: Bool { @inline(__always) get { _insertNewline.isEmpty } }
  public var count: Int { @inline(__always) get { _insertNewline.count } }
  public var asBitArray: BitArray { @inline(__always) get { _insertNewline } }

  public subscript(index: Int) -> Bool {
    @inline(__always) get { _insertNewline[index] }
  }

  init<S>(_ isBlock: S) where S: Sequence, S.Element == Bool {
    self._isBlock = BitArray(isBlock)
    self._insertNewline = BitArray(Self.computeNewlines(for: _isBlock))
    self.trueValueCount = _insertNewline.lazy.map(\.intValue).reduce(0, +)
  }

  mutating func insert<C>(contentsOf isBlock: C, at index: Int)
  where C: Collection, C.Element == Bool {
    precondition(index >= 0 && index <= _insertNewline.count)

    let prev: Bool? = index == 0 ? nil : _isBlock[index - 1]
    let next: Bool? = index == _isBlock.count ? nil : _isBlock[index]
    let (previous, segment) = Self.computeNewlines(
      previous: prev,
      segment: isBlock,
      next: next)

    var delta = 0
    if previous != nil {
      delta += previous!.intValue - _insertNewline[index - 1].intValue
      _insertNewline[index - 1] = previous!
    }
    delta += segment.lazy.map(\.intValue).reduce(0, +)

    _isBlock.insert(contentsOf: isBlock, at: index)
    _insertNewline.insert(contentsOf: segment, at: index)
    trueValueCount += delta
  }

  mutating func insert(_ isBlock: Bool, at index: Int) {
    insert(contentsOf: CollectionOfOne(isBlock), at: index)
  }

  mutating func removeSubrange(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _insertNewline.count)

    guard !range.isEmpty else { return }

    // remove
    let delta = -_insertNewline[range].lazy.map(\.intValue).reduce(0, +)
    _isBlock.removeSubrange(range)
    _insertNewline.removeSubrange(range)
    trueValueCount += delta

    // update the previous
    guard range.lowerBound > 0 else { return }
    let i = range.lowerBound - 1
    let newValue: Bool =
      (i < _insertNewline.count - 1)
      ? (_isBlock[i] || _isBlock[i + 1])
      : false
    trueValueCount += newValue.intValue - _insertNewline[i].intValue
    _insertNewline[i] = newValue
  }

  mutating func remove(at index: Int) {
    removeSubrange(index..<index + 1)
  }

  mutating func removeAll() {
    self._isBlock.removeAll()
    self._insertNewline.removeAll()
    self.trueValueCount = 0
  }

  mutating func setValue(isBlock: Bool, at index: Int) {
    precondition(0..<_isBlock.count ~= index)
    guard _isBlock[index] != isBlock else { return }

    // compute new values at previous and target position
    let prev: Bool? = (index == 0) ? nil : _isBlock[index - 1]
    let next: Bool? = (index + 1 < _isBlock.count) ? _isBlock[index + 1] : nil
    let (previous, current) = Self.computeNewlines(
      previous: prev,
      current: isBlock,
      next: next)
    var delta = 0
    if previous != nil {
      // compute delta
      delta += previous!.intValue - _insertNewline[index - 1].intValue
      // update previous
      _insertNewline[index - 1] = previous!
    }
    // compute delta
    delta += current.intValue - _insertNewline[index].intValue
    // update target
    _isBlock[index] = isBlock
    _insertNewline[index] = current
    // update true count
    trueValueCount += delta
  }

  static func computeNewlines(
    previous: Bool?,
    current isBlock: Bool,
    next: Bool?
  ) -> (previous: Bool?, current: Bool) {
    let previous = previous.map { $0 || isBlock }
    let current = next.map { isBlock || $0 } ?? false
    return (previous, current)
  }

  static func computeNewlines<S>(
    previous: Bool?,
    segment isBlock: S,
    next: Bool?
  ) -> (previous: Bool?, segment: [Bool])
  where S: Sequence, S.Element == Bool {
    let isBlock = previous.asArray + isBlock + next.asArray
    var newlines = Self.computeNewlines(for: isBlock)

    let previous = previous.map { _ in newlines[0] }

    if previous != nil {
      newlines.removeFirst()
    }
    if next != nil {
      newlines.removeLast()
    }

    return (previous, newlines)
  }

  /** Determine whether newlines are needed between adjacent children. */
  static func computeNewlines<C>(for isBlock: C) -> [Bool]
  where C: Collection, C.Element == Bool {
    if isBlock.isEmpty { return [] }
    return isBlock.adjacentPairs().map { $0.0 || $0.1 } + CollectionOfOne(false)
  }
}
