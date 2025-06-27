// Copyright 2024-2025 Lie Yan

import BitCollections

/// Array of booleans that maintains true-value count.
internal struct BooleanArray: Equatable, Hashable {
  private var _bitArray: BitArray
  private(set) var trueCount: Int

  internal var asBitArray: BitArray { _bitArray }

  internal var isEmpty: Bool { _bitArray.isEmpty }
  internal var count: Int { _bitArray.count }

  internal subscript(index: Int) -> Bool {
    @inline(__always) get { _bitArray[index] }
    @inlinable set { _setValue(newValue, at: index) }
  }

  init() {
    self._bitArray = BitArray()
    self.trueCount = 0
  }

  init(_ values: some Collection<Bool>) {
    self._bitArray = BitArray(values)
    self.trueCount = values.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
  }

  @inline(__always)
  mutating func insert(contentsOf values: some Collection<Bool>, at index: Int) {
    precondition(index >= 0 && index <= _bitArray.count)

    guard !values.isEmpty else { return }

    _bitArray.insert(contentsOf: values, at: index)
    trueCount += values.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
  }

  @inline(__always)
  mutating func insert(_ value: Bool, at index: Int) {
    precondition(index >= 0 && index <= _bitArray.count)
    _bitArray.insert(value, at: index)
    trueCount += value ? 1 : 0
  }

  @inline(__always)
  mutating func removeSubrange(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _bitArray.count)
    let delta = _bitArray[range].lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    _bitArray.removeSubrange(range)
    trueCount -= delta
  }

  @inline(__always)
  mutating func remove(at index: Int) {
    precondition(index >= 0 && index < _bitArray.count)
    let value = _bitArray[index]
    _bitArray.remove(at: index)
    trueCount -= value ? 1 : 0
  }

  @inline(__always)
  mutating func removeAll() {
    _bitArray.removeAll()
    trueCount = 0
  }

  @inline(__always)
  mutating func replaceSubrange(
    _ range: Range<Int>, with newElements: some Collection<Bool>
  ) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _bitArray.count)

    let deleted = _bitArray[range].lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    let added = newElements.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    _bitArray.replaceSubrange(range, with: newElements)
    trueCount += added - deleted
  }

  @inline(__always)
  private mutating func _setValue(_ value: Bool, at index: Int) {
    precondition(index >= 0 && index < _bitArray.count)

    if _bitArray[index] != value {
      _bitArray[index] = value
      trueCount += value ? 1 : -1
    }
  }
}
