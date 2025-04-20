// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

enum StringUtils {
  /// Inserts `placement` into `source` at `offset`.
  /// - Parameters:
  ///   - source: The source string.
  ///   - offset: The __UTF16__ offset at which to insert `placement`.
  ///   - placement: The string to insert.
  /// ## Example
  /// ```swift
  /// let source = BigString("Hello, world!")
  /// let placement = "beautiful "
  /// let result = StringUtils.splice(source, 7, placement)
  /// print(result) // "Hello, beautiful world!"
  /// ```
  static func splice<S: Collection<Character>>(
    _ source: BigString, _ offset: Int, _ placement: S
  ) -> BigString {
    precondition(0...source.utf16.count ~= offset)
    guard !placement.isEmpty else { return source }
    var result = source
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    result.insert(contentsOf: placement, at: index)
    return result
  }

  /// Splits `source` at `offset`, producing two non-empty substrings.
  /// - Parameters:
  ///   - source: The source string.
  ///   - offset: The __UTF16__ offset at which to split `source`.
  /// - Returns: A tuple of two strings: `(source[..<offset], source[offset...])`.
  static func strictSplit(
    _ source: BigString, at offset: Int
  ) -> (BigSubstring, BigSubstring) {
    precondition(source.isEmpty == false)
    precondition(offset > 0 && offset < source.utf16.count)
    let index = source.utf16.index(source.startIndex, offsetBy: offset)
    return (source[..<index], source[index...])
  }

  /// Returns the substring of `source` for the given `range`.
  /// - Parameters:
  ///   - source: The source string.
  ///   - range: The __UTF16__ range of the substring.
  /// - Returns: The substring of `source` for the given `range`.
  static func substring(of source: BigString, for range: Range<Int>) -> BigSubstring {
    precondition(0...source.utf16.count ~= range.lowerBound, "range out of bounds")
    precondition(0...source.utf16.count ~= range.upperBound, "range out of bounds")
    let first = source.utf16.index(source.startIndex, offsetBy: range.lowerBound)
    let last = source.utf16.index(source.startIndex, offsetBy: range.upperBound)
    return source[first..<last]
  }

  /// Convert raw string to an array of nodes with each newline (except line separator)
  /// replaced by a `LinebreakNode`. If there is only one piece, return nil.
  static func getNodes(fromRaw string: String) -> Optional<[Node]> {
    precondition(!string.isEmpty)

    let parts = string.split(omittingEmptySubsequences: false) { char in
      char.isNewline && char != Characters.lineSeparator
    }
    if parts.count == 1 {
      return nil
    }
    else {
      var nodes: [Node] = parts.dropLast()
        .flatMap { part in
          part.isEmpty ? [LinebreakNode()] : [TextNode(part), LinebreakNode()]
        }
      let last = parts.last!
      if !last.isEmpty {
        nodes.append(TextNode(last))
      }
      return nodes
    }
  }

  /// Returns the range of the word boundary for a given offset and direction.
  static func wordBoundary(
    _ string: BigString,
    offset: Int,
    direction: LinearDirection
  ) -> Range<Int> {
    precondition(0...string.utf16.count ~= offset)

    let index = string.utf16.index(string.startIndex, offsetBy: offset)
    let range = string.wordBoundaryRange(from: index, direction)
    let lowerBound = string.utf16.distance(from: string.startIndex, to: range.lowerBound)
    let upperBound = string.utf16.distance(from: string.startIndex, to: range.upperBound)
    return lowerBound..<upperBound
  }
}

private extension BigString {
  func wordBoundaryRange(
    from index: Index,
    _ direction: LinearDirection
  ) -> Range<Index> {
    switch direction {
    case .forward:
      return forwardWordRange(from: index)
    case .backward:
      return backwardWordRange(from: index)
    }
  }

  private func isWordCharacter(_ char: Character) -> Bool {
    return char.isLetter || char.isNumber || char == "_"
  }

  private func forwardWordRange(from index: Index) -> Range<Index> {
    guard index < endIndex else { return index..<index }

    let start = index
    var end = index

    // If starting in middle of word, scan to end of word
    if end < endIndex && isWordCharacter(self[end]) {
      end = self[end...].prefix(while: isWordCharacter).endIndex
    }

    // Skip non-word characters
    end = self[end...].prefix(while: { !isWordCharacter($0) }).endIndex

    // Find next word end
    end = self[end...].prefix(while: isWordCharacter).endIndex

    return start..<end
  }

  private func backwardWordRange(from index: Index) -> Range<Index> {
    guard index > startIndex else { return startIndex..<index }

    var start = index
    let end = index

    // Move backward through non-word characters
    while start > startIndex && !isWordCharacter(self[self.index(before: start)]) {
      start = self.index(before: start)
    }

    // Move backward through word characters
    while start > startIndex && isWordCharacter(self[self.index(before: start)]) {
      start = self.index(before: start)
    }

    return start..<end
  }
}
