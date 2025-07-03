// Copyright 2024-2025 Lie Yan

internal struct CounterArray {
  private var _boolArray: BoolArray

  init(_ counterSegments: some Collection<CounterSegment?>) {
    self._boolArray = BoolArray(counterSegments.lazy.map { $0 != nil })
  }

  init() {
    self._boolArray = BoolArray()
  }

  @inline(__always) var isEmpty: Bool { _boolArray.isEmpty }
  @inline(__always) var count: Int { _boolArray.count }
  @inline(__always) var trueCount: Int { _boolArray.trueCount }

  subscript(index: Int) -> Bool { @inline(__always) get { _boolArray[index] } }

  @inline(__always)
  func trueIndex(before position: Int) -> Int? {
    _boolArray.trueIndex(before: position)
  }

  @inline(__always)
  func trueIndex(after position: Int) -> Int? {
    _boolArray.trueIndex(after: position)
  }

  @inline(__always)
  mutating func insert(_ segment: CounterSegment?, at index: Int) {
    _boolArray.insert(segment != nil, at: index)
  }

  @inline(__always)
  mutating func insert(
    contentsOf segments: some Collection<CounterSegment?>, at index: Int
  ) {
    _boolArray.insert(contentsOf: segments.lazy.map { $0 != nil }, at: index)
  }

  @inline(__always)
  mutating func remove(at index: Int) -> Bool {
    _boolArray.remove(at: index)
  }

  @inline(__always)
  mutating func removeSubrange(_ range: Range<Int>) {
    _boolArray.removeSubrange(range)
  }

  @inline(__always)
  mutating func removeAll() {
    _boolArray.removeAll()
  }

  @inline(__always)
  mutating func replaceSubrange(
    _ subrange: Range<Int>, with newElements: some Collection<CounterSegment?>
  ) {
    _boolArray.replaceSubrange(subrange, with: newElements.lazy.map { $0 != nil })
  }
}
