// Copyright 2024-2025 Lie Yan

/// Simple wrapper over BoolArray for managing counter segments.
internal struct CounterArray {
  @usableFromInline
  internal var _boolArray: BoolArray

  @inlinable @inline(__always)
  init(_ counterSegments: some Collection<CounterSegment?>) {
    self._boolArray = BoolArray(counterSegments.lazy.map { $0 != nil })
  }

  @inlinable @inline(__always)
  init() {
    self._boolArray = BoolArray()
  }

  @inlinable @inline(__always) var isEmpty: Bool { _boolArray.isEmpty }
  @inlinable @inline(__always) var count: Int { _boolArray.count }
  @inlinable @inline(__always) var trueCount: Int { _boolArray.trueCount }

  @inlinable @inline(__always)
  subscript(index: Int) -> Bool { _boolArray[index] }

  @inlinable @inline(__always)
  func trueIndex(before position: Int) -> Int? {
    _boolArray.trueIndex(before: position)
  }

  @inlinable @inline(__always)
  func trueIndex(after position: Int) -> Int? {
    _boolArray.trueIndex(after: position)
  }

  @inlinable @inline(__always)
  mutating func insert(_ segment: CounterSegment?, at index: Int) {
    _boolArray.insert(segment != nil, at: index)
  }

  @inlinable @inline(__always)
  mutating func insert(
    contentsOf segments: some Collection<CounterSegment?>, at index: Int
  ) {
    _boolArray.insert(contentsOf: segments.lazy.map { $0 != nil }, at: index)
  }

  @inlinable @inline(__always)
  mutating func remove(at index: Int) -> Bool {
    _boolArray.remove(at: index)
  }

  @inlinable @inline(__always)
  mutating func removeSubrange(_ range: Range<Int>) {
    _boolArray.removeSubrange(range)
  }

  @inlinable @inline(__always)
  mutating func removeAll() {
    _boolArray.removeAll()
  }

  @inlinable @inline(__always)
  mutating func replaceSubrange(
    _ subrange: Range<Int>, with newElements: some Collection<CounterSegment?>
  ) {
    _boolArray.replaceSubrange(subrange, with: newElements.lazy.map { $0 != nil })
  }
}
