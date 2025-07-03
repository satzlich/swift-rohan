// Copyright 2024-2025 Lie Yan

internal struct CounterArray {
  private var _boolArray: BoolArray

  init(_ counterSegments: some Collection<CounterSegment?>) {
    self._boolArray = BoolArray(counterSegments.lazy.map { $0 != nil })
  }

  init() {
    self._boolArray = BoolArray()
  }

  var isEmpty: Bool { _boolArray.isEmpty }
  var count: Int { _boolArray.count }

  subscript(index: Int) -> Bool {
    get { _boolArray[index] }
  }

  mutating func insert(_ segment: CounterSegment?, at index: Int) {
    _boolArray.insert(segment != nil, at: index)
  }

  mutating func insert(
    contentsOf segments: some Collection<CounterSegment?>, at index: Int
  ) {
    _boolArray.insert(contentsOf: segments.lazy.map { $0 != nil }, at: index)
  }

  mutating func remove(at index: Int) -> Bool {
    _boolArray.remove(at: index)
  }

  mutating func removeSubrange(_ range: Range<Int>) {
    _boolArray.removeSubrange(range)
  }

  mutating func removeAll() {
    _boolArray.removeAll()
  }

  mutating func replaceSubrange(
    _ subrange: Range<Int>, with newElements: some Collection<CounterSegment?>
  ) {
    _boolArray.replaceSubrange(subrange, with: newElements.lazy.map { $0 != nil })
  }
}
