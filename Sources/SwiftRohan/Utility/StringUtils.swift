// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

enum StringUtils {
  /**
   Inserts `placement` into `source` at `offset`.

   - Parameters:
      - source: The source string.
      - offset: The __UTF16__ offset at which to insert `placement`.
      - placement: The string to insert.

   ## Example
    ```swift
    let source = BigString("Hello, world!")
    let placement = "beautiful "
    let result = StringUtils.splice(source, 7, placement)
    print(result) // "Hello, beautiful world!"
    ```
   */
  static func splice<S>(_ source: BigString, _ offset: Int, _ placement: S) -> BigString
  where S: Collection, S.Element == Character {
    precondition(0...source.utf16.count ~= offset, "offset out of bounds")
    guard !placement.isEmpty else { return source }
    var result = source
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    result.insert(contentsOf: placement, at: index)
    return result
  }

  /**
   Splits `source` at `offset`, producing two non-empty substrings.
   - Parameters:
      - source: The source string.
      - offset: The __UTF16__ offset at which to split `source`.
   - Returns: A tuple of two strings: `(source[..<offset], source[offset...])`.
   */
  static func strictSplit(
    _ source: BigString, at offset: Int
  ) -> (BigSubstring, BigSubstring) {
    precondition(source.isEmpty == false)
    precondition(offset > 0 && offset < source.utf16.count)
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    return (source[..<index], source[index...])
  }

  /**
   Returns the substring of `source` for the given `range`.
   - Parameters:
      - source: The source string.
      - range: The __UTF16__ range of the substring.
   - Returns: The substring of `source` for the given `range`.
   */
  static func substring(of source: BigString, for range: Range<Int>) -> BigSubstring {
    precondition(0...source.utf16.count ~= range.lowerBound, "range out of bounds")
    precondition(0...source.utf16.count ~= range.upperBound, "range out of bounds")
    let first = source.utf16.index(source.startIndex, offsetBy: range.lowerBound)
    let last = source.utf16.index(source.startIndex, offsetBy: range.upperBound)
    return source[first..<last]
  }

  /// Returns equivalent nodes from raw string.
  /// If only one text node, return nil.
  static func getNodes(fromRaw string: String) -> Optional<[Node]> {
    precondition(!string.isEmpty)
    // split by newline except for "line separator"
    let parts = string.split(omittingEmptySubsequences: false) { char in
      char.isNewline && char != Characters.lineSeparator
    }
    // if only one piece, return nil
    if parts.count == 1 {
      return nil
    }
    // otherwise, intersperse with linebreaks
    else {
      var nodes: [Node] = parts.dropLast().flatMap { s in
        if !s.isEmpty { return [TextNode(s), LinebreakNode()] }
        return [LinebreakNode()]
      }
      let last = parts.last!
      if !last.isEmpty {
        nodes.append(TextNode(last))
      }
      return nodes
    }
  }
}
