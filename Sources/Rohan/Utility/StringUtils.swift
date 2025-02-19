// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

enum StringUtils {
  @inline(__always)
  static func concate<S>(_ lhs: BigString, _ rhs: S) -> BigString
  where S: Collection, S.Element == Character {
    lhs + rhs
  }

  /** Inserts `placement` into `source` at `offset`. */
  @inline(__always)
  static func splice<S>(
    _ source: BigString,
    _ offset: Int,
    _ placement: S
  ) -> BigString
  where S: Collection, S.Element == Character {
    guard !placement.isEmpty else { return source }
    var result = source
    let index = source.index(source.startIndex, offsetBy: offset)
    result.insert(contentsOf: placement, at: index)
    return result
  }

  /** Remove range from `source` and insert `placement` at `range.lowerBound`. */
  @inline(__always)
  static func splice<S>(
    _ source: BigString,
    _ range: Range<Int>,
    _ placement: S?
  ) -> BigString
  where S: Collection, S.Element == Character {
    let rangeNotEmpty = !range.isEmpty
    let placementNotEmpty = (placement?.isEmpty == false)

    guard rangeNotEmpty || placementNotEmpty else { return source }

    var result = source
    let first = source.index(source.startIndex, offsetBy: range.lowerBound)
    // remove range if not empty
    if rangeNotEmpty {
      let last = source.index(source.startIndex, offsetBy: range.upperBound)
      result.removeSubrange(first..<last)
    }
    // insert placement if not empty
    if placementNotEmpty {
      result.insert(contentsOf: placement!, at: first)
    }
    return result
  }

  /** Convenicen function to call `splice(source, range, nil)`. */
  @inline(__always)
  static func splice(
    _ source: BigString,
    _ range: Range<Int>,
    _ placement: Void?
  ) -> BigString {
    splice(source, range, nil as String?)
  }

  @inline(__always)
  static func subString(_ source: BigString, _ range: Range<Int>) -> String {
    let first = source.index(source.startIndex, offsetBy: range.lowerBound)
    let last = source.index(source.startIndex, offsetBy: range.upperBound)
    return String(source[first..<last])
  }
}
