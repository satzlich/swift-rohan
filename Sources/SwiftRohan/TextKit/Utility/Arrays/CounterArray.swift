// Copyright 2024-2025 Lie Yan

import BitCollections

internal struct CounterArray: Equatable, Hashable {
  private var _counters: BitArray
  private(set) var trueCount: Int

  internal var asBitArray: BitArray { _counters }

  internal var isEmpty: Bool { _counters.isEmpty }
  internal var count: Int { _counters.count }
  internal subscript(index: Int) -> Bool {
    get { _counters[index] }
    set { _setValue(newValue, at: index) }
  }

  init() {
    self._counters = BitArray()
    self.trueCount = 0
  }

  init(_ counters: some Collection<Bool>) {
    self._counters = BitArray(counters)
    self.trueCount = counters.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
  }

  @inline(__always)
  mutating func insert(contentsOf counters: some Collection<Bool>, at index: Int) {
    precondition(index >= 0 && index <= _counters.count)

    guard !counters.isEmpty else { return }

    _counters.insert(contentsOf: counters, at: index)
    trueCount += counters.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
  }

  @inline(__always)
  mutating func insert(_ value: Bool, at index: Int) {
    precondition(index >= 0 && index <= _counters.count)
    _counters.insert(value, at: index)
    trueCount += value ? 1 : 0
  }

  @inline(__always)
  mutating func removeSubrange(_ range: Range<Int>) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _counters.count)
    let delta = _counters[range].lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    _counters.removeSubrange(range)
    trueCount -= delta
  }

  @inline(__always)
  mutating func remove(at index: Int) {
    precondition(index >= 0 && index < _counters.count)
    let value = _counters[index]
    _counters.remove(at: index)
    trueCount -= value ? 1 : 0
  }

  @inline(__always)
  mutating func removeAll() {
    _counters.removeAll()
    trueCount = 0
  }

  @inline(__always)
  mutating func replaceSubrange(
    _ range: Range<Int>, with newElements: some Collection<Bool>
  ) {
    precondition(range.lowerBound >= 0 && range.upperBound <= _counters.count)

    let deleted = _counters[range].lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    let added = newElements.lazy.map { $0 ? 1 : 0 }.reduce(0, +)
    _counters.replaceSubrange(range, with: newElements)
    trueCount += added - deleted
  }

  @inline(__always)
  private mutating func _setValue(_ value: Bool, at index: Int) {
    precondition(index >= 0 && index < _counters.count)

    if _counters[index] != value {
      _counters[index] = value
      trueCount += value ? 1 : -1
    }
  }
}
