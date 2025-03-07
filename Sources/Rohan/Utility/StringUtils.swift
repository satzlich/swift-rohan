// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

enum StringUtils {
  static func concate<S>(_ lhs: BigString, _ rhs: S) -> BigString
  where S: Collection, S.Element == Character {
    lhs + rhs
  }

  /** Inserts `placement` into `source` at `offset`. */
  static func splice<S>(_ source: BigString, _ offset: Int, _ placement: S) -> BigString
  where S: Collection, S.Element == Character {
    precondition(0...source.utf16.count ~= offset, "offset out of bounds")

    guard !placement.isEmpty else { return source }
    var result = source
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    result.insert(contentsOf: placement, at: index)
    return result
  }

  /** Remove range from `source` and insert `placement` at `range.lowerBound`. */
  static func splice<S>(_ source: BigString, _ range: Range<Int>, _ placement: S?) -> BigString
  where S: Collection, S.Element == Character {
    precondition(0...source.utf16.count ~= range.lowerBound, "range out of bounds")
    precondition(0...source.utf16.count ~= range.upperBound, "range out of bounds")

    let rangeNotEmpty = !range.isEmpty
    let placementNotEmpty = (placement?.isEmpty == false)

    guard rangeNotEmpty || placementNotEmpty else { return source }

    var result = source
    let first = source.utf16.index(source.startIndex, offsetBy: range.lowerBound)
    // remove range if not empty
    if rangeNotEmpty {
      let last = source.utf16.index(source.startIndex, offsetBy: range.upperBound)
      result.removeSubrange(first..<last)
    }
    // insert placement if not empty
    if placementNotEmpty {
      result.insert(contentsOf: placement!, at: first)
    }
    return result
  }

  /** Convenicen function to call `splice(source, range, nil)`. */
  static func splice(_ source: BigString, _ range: Range<Int>, _ placement: Void?) -> BigString {
    splice(source, range, nil as String?)
  }

  static func subString(_ source: BigString, _ range: Range<Int>) -> String {
    precondition(0...source.utf16.count ~= range.lowerBound, "range out of bounds")
    precondition(0...source.utf16.count ~= range.upperBound, "range out of bounds")
    let first = source.utf16.index(source.startIndex, offsetBy: range.lowerBound)
    let last = source.utf16.index(source.startIndex, offsetBy: range.upperBound)
    return String(source[first..<last])
  }

  static func split(_ source: BigString, at offset: Int) -> (BigString, BigString) {
    precondition(0...source.utf16.count ~= offset, "offset out of bounds")
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    return (BigString(source[..<index]), BigString(source[index...]))
  }
}
