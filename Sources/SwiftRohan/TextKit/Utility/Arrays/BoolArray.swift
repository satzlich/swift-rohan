// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

struct BoolArray: Equatable, Hashable, ExpressibleByArrayLiteral {
  private var _size: Int
  private var _truePositions: Array<Int> = []

  typealias ArrayLiteralElement = Bool

  init(arrayLiteral elements: ArrayLiteralElement...) {
    self.init(elements)
  }

  init() {
    self._size = 0
    self._truePositions = []
  }

  init(_ values: some Collection<Bool>) {
    self._size = values.count
    self._truePositions = values.enumerated()
      .compactMap { (index, value) -> Int? in value ? index : nil }
  }

  // MARK: - Query

  subscript(position: Int) -> Bool {
    get {
      precondition(0..<_size ~= position)
      return _getValue(at: position)
    }
    set {
      precondition(0..<_size ~= position)
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

  @inlinable
  mutating func insert(contentsOf values: some Collection<Bool>, at index: Int) {
    precondition(0..._size ~= index)

    let delta = values.count
    _size += delta

    let lowerBound = Satz.lowerBound(_truePositions, index)
    for i in lowerBound..<_truePositions.count {
      _truePositions[i] += delta
    }

    let positions = values.enumerated()
      .compactMap { (offset, value) -> Int? in value ? index + offset : nil }
    _truePositions.insert(contentsOf: positions, at: lowerBound)
  }

  mutating func remove(at index: Int) -> Bool {
    precondition(0..<_size ~= index)

    _size -= 1

    let lowerBound = Satz.lowerBound(_truePositions, index)
    if lowerBound < _truePositions.count && _truePositions[lowerBound] == index {
      for i in lowerBound + 1..<_truePositions.count {
        _truePositions[i] -= 1
      }
      _truePositions.remove(at: lowerBound)
      return true
    }
    else {
      for i in lowerBound..<_truePositions.count {
        _truePositions[i] -= 1
      }
      return false
    }
  }

  mutating func removeSubrange(_ bounds: Range<Int>) {
    precondition(bounds.lowerBound >= 0 && bounds.upperBound <= _size)

    let size = bounds.count
    _size -= size

    let upperBound = Satz.lowerBound(_truePositions, bounds.upperBound)
    for i in upperBound..<_truePositions.count {
      _truePositions[i] -= size
    }
    let lowerBound = Satz.lowerBound(_truePositions, bounds.lowerBound)
    _truePositions.removeSubrange(lowerBound..<upperBound)
  }

  mutating func removeAll() {
    _size = 0
    _truePositions.removeAll()
  }

  mutating func replaceSubrange(
    _ bounds: Range<Int>, with newElements: some Collection<Bool>
  ) {
    precondition(bounds.lowerBound >= 0 && bounds.upperBound <= _size)

    let delta = newElements.count - bounds.count
    _size += delta

    // make shift
    let upperBound = Satz.lowerBound(_truePositions, bounds.upperBound)
    for i in upperBound..<_truePositions.count {
      _truePositions[i] += delta
    }

    // make replacement
    let lowerBound = Satz.lowerBound(_truePositions, bounds.lowerBound)
    let positions = newElements.enumerated()
      .compactMap { (offset, value) -> Int? in value ? bounds.lowerBound + offset : nil }
    _truePositions.replaceSubrange(lowerBound..<upperBound, with: positions)
  }

  // MARK: - Efficient Queries

  /// Returns the last index less than or equal to the given position and contains true.
  func trueIndex(before position: Int) -> Int? {
    guard position >= 0 else { return nil }

    let index = Satz.lowerBound(_truePositions, position)
    if index > 0 {
      return _truePositions[index - 1]
    }

    return nil
  }

  /// Returns the first index greater than the given position and contains true.
  func trueIndex(after position: Int) -> Int? {
    guard position < _size else { return nil }
    let index = Satz.upperBound(_truePositions, position)
    if index < _truePositions.count {
      return _truePositions[index]
    }
    return nil
  }

  // MARK: - Private Helpers

  @inline(__always)
  private func _getValue(at position: Int) -> Bool {
    let index = Satz.lowerBound(_truePositions, position)
    return index < _truePositions.count && _truePositions[index] == position
  }

  /// Set a true value at the specified position.
  @inline(__always)
  private mutating func _setTrue(at position: Int) {
    let index = Satz.lowerBound(_truePositions, position)
    if index >= _truePositions.count || _truePositions[index] != position {
      _truePositions.insert(position, at: index)
    }
  }

  /// Set a false value at the specified position.
  @inline(__always)
  private mutating func _setFalse(at position: Int) {
    let index = Satz.lowerBound(_truePositions, position)
    if index < _truePositions.count && _truePositions[index] == position {
      _truePositions.remove(at: index)
    }
  }
}
