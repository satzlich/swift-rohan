// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

enum StringUtils {
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

  static func split(_ source: BigString, at offset: Int) -> (BigString, BigString) {
    precondition(0...source.utf16.count ~= offset, "offset out of bounds")
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    return (BigString(source[..<index]), BigString(source[index...]))
  }

  static func subString(_ source: BigString, _ range: Range<Int>) -> String {
    precondition(0...source.utf16.count ~= range.lowerBound, "range out of bounds")
    precondition(0...source.utf16.count ~= range.upperBound, "range out of bounds")
    let first = source.utf16.index(source.startIndex, offsetBy: range.lowerBound)
    let last = source.utf16.index(source.startIndex, offsetBy: range.upperBound)
    return String(source[first..<last])
  }

}
