import Foundation

struct BoolArray {
  private var _size: Int
  private var _truePositions: Array<Int> = []

  init() {
    self._size = 0
    self._truePositions = []
  }

  // MARK: - Query

  subscript(position: Int) -> Bool {
    get {
      guard position >= 0 && position < _size else {
        fatalError("Index out of bounds: \(position) (0..<\(_size))")
      }
      return _contains(position)
    }
    set {
      guard position >= 0 && position < _size else {
        fatalError("Index out of bounds: \(position) (0..<\(_size))")
      }
      if newValue {
        _setTrue(at: position)
      }
      else {
        _setFalse(at: position)
      }
    }
  }

  var isEmpty: Bool { _size == 0 }
  var count: Int { _size }
  var trueCount: Int { _truePositions.count }

  // MARK: - Edit

  mutating func insert(_ value: Bool, at index: Int) {
    insert(contentsOf: CollectionOfOne(value), at: index)
  }

  mutating func insert(contentsOf values: some Collection<Bool>, at index: Int) {
    guard index >= 0 && index <= _size else {
      fatalError("Index out of bounds: \(index) (0..<\(_size))")
    }

    // First increase the size
    _size += values.count

    // Shift existing true positions after the insertion point
    let startIndex = _lowerBound(index)
    let shiftAmount = values.count
    for i in startIndex..<_truePositions.count {
      _truePositions[i] += shiftAmount
    }

    // Insert new true values
    let positions = values.enumerated()
      .compactMap { (offset, value) -> Int? in value ? index + offset : nil }
    _truePositions.insert(contentsOf: positions, at: startIndex)
  }

  mutating func remove(at index: Int) {
    removeSubrange(index..<index + 1)
  }

  mutating func removeSubrange(_ bounds: Range<Int>) {
    guard bounds.lowerBound >= 0 && bounds.upperBound <= _size else {
      fatalError("Range \(bounds) out of bounds (0..<\(_size))")
    }

    // Shift remaining true positions after the range
    let shiftAmount = bounds.count
    for i in _lowerBound(bounds.upperBound)..<_truePositions.count {
      _truePositions[i] -= shiftAmount
    }

    // Decrease the size
    _size -= bounds.count

    // Find range of true positions to remove
    let lower = _lowerBound(bounds.lowerBound)
    let upper = _lowerBound(bounds.upperBound)
    _truePositions.removeSubrange(lower..<upper)
  }

  // MARK: - Efficient Queries

  /// Returns the last index less than or equal to the given position and contains true.
  func previousTrueIndex(_ position: Int) -> Int? {
    guard position >= 0 else { return nil }

    let index = _lowerBound(position)
    if index > 0 {
      return _truePositions[index - 1]
    }

    return nil
  }

  /// Returns the first index greater than the given position and contains true.
  func nextTrueIndex(_ position: Int) -> Int? {
    guard position < _size else { return nil }

    let index = _upperBound(position)

    // Return the found position or next one
    if index < _truePositions.count {
      return _truePositions[index]
    }

    return nil
  }

  // MARK: - Private Helpers

  /// Returns the first index where the element is not less than the given value
  /// (like std::lower_bound)
  @inline(__always)
  private func _lowerBound(_ position: Int) -> Int {
    var left = 0
    var right = _truePositions.count

    while left < right {
      let mid = left + (right - left) / 2
      if _truePositions[mid] < position {
        left = mid + 1
      }
      else {
        right = mid
      }
    }

    return left
  }

  /// Returns the first index where the element is greater than the given value
  /// (like std::upper_bound)
  @inline(__always)
  private func _upperBound(_ position: Int) -> Int {
    var left = 0
    var right = _truePositions.count

    while left < right {
      let mid = left + (right - left) / 2
      if _truePositions[mid] <= position {
        left = mid + 1
      }
      else {
        right = mid
      }
    }

    return left
  }

  private func _contains(_ position: Int) -> Bool {
    let index = _lowerBound(position)
    return index < _truePositions.count && _truePositions[index] == position
  }

  /// Set a true value at the specified position.
  private mutating func _setTrue(at position: Int) {
    let index = _lowerBound(position)
    if index >= _truePositions.count || _truePositions[index] != position {
      _truePositions.insert(position, at: index)
    }
  }

  /// Set a false value at the specified position.
  private mutating func _setFalse(at position: Int) {
    let index = _lowerBound(position)
    if index < _truePositions.count && _truePositions[index] == position {
      _truePositions.remove(at: index)
    }
  }
}
