// Copyright 2024-2025 Lie Yan

import Algorithms
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
    precondition(0...source.utf16.count ~= range.lowerBound)
    precondition(0...source.utf16.count ~= range.upperBound)
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
      if last.isEmpty == false {
        nodes.append(TextNode(last))
      }
      return nodes
    }
  }

  /// Returns the range delimited by word boundary starting from offset in the
  /// given direction.
  static func wordBoundaryRange(
    _ string: BigString, offset: Int, direction: LinearDirection
  ) -> Range<Int> {
    precondition(0...string.utf16.count ~= offset)

    var index = string.utf16.index(string.startIndex, offsetBy: offset)
    switch direction {
    case .forward:
      index = string.index(roundingDown: index)  // upstream boundary
    case .backward:
      index = string.index(roundingUp: index)  // downstream boundary
    }

    let range = string.wordBoundaryRange(index, direction)

    let lowerBound = string.utf16.distance(from: string.startIndex, to: range.lowerBound)
    let upperBound = string.utf16.distance(from: string.startIndex, to: range.upperBound)
    return lowerBound..<upperBound
  }

  /// Returns the range delimited by word boundary enclosing offset.
  static func wordBoundaryRange(_ string: BigString, enclosing offset: Int) -> Range<Int>
  {
    precondition(0...string.utf16.count ~= offset)

    var index = string.utf16.index(string.startIndex, offsetBy: offset)
    index = string.index(roundingDown: index)  // upstream boundary

    let range = string.wordBoundaryRange(enclosing: index)
    let lowerBound = string.utf16.distance(from: string.startIndex, to: range.lowerBound)
    let upperBound = string.utf16.distance(from: string.startIndex, to: range.upperBound)
    return lowerBound..<upperBound
  }
}

private extension BigString {
  /// Returns the range delimited by word boundary starting from index in the
  /// given direction.
  func wordBoundaryRange(_ index: Index, _ direction: LinearDirection) -> Range<Index> {
    precondition(startIndex...endIndex ~= index)

    switch direction {
    case .forward:
      return forwardWordRange(from: index)
    case .backward:
      return backwardWordRange(from: index)
    }
  }

  /// Returns the range delimited by word boundary enclosing index.
  func wordBoundaryRange(enclosing index: Index) -> Range<Index> {
    precondition(startIndex...endIndex ~= index)

    if index == startIndex {
      return forwardWordRange(from: index)
    }
    else if index == endIndex {
      return backwardWordRange(from: index)
    }
    else {
      let nextIndex = self.index(after: index)
      let start = backwardWordRange(from: nextIndex).lowerBound
      let end = forwardWordRange(from: index).upperBound
      return start..<end
    }
  }

  private func isWordCharacter(_ char: Character) -> Bool {
    return char.isLetter || char.isNumber
  }

  private func isWhitespace(_ char: Character) -> Bool {
    // ignore other whitespace characters
    return char == Characters.space || char == Characters.tab
  }

  private func forwardWordRange(from index: Index) -> Range<Index> {
    precondition(startIndex...endIndex ~= index)

    if index == endIndex {
      return index..<index
    }
    else {
      if isWordCharacter(self[index]) {
        let end = self[index...].firstIndex(where: { !isWordCharacter($0) })
          .flatMap { j in
            isWhitespace(self[j])
              ? self[j...].firstIndex(where: { !isWhitespace($0) })
              : j
          }

        return index..<(end ?? endIndex)
      }
      else {
        let end = self[index...].firstIndex(where: { isWordCharacter($0) })
          .flatMap { j in
            isWhitespace(self[j])
              ? self[j...].firstIndex(where: { !isWhitespace($0) })
              : j
          }
        return index..<(end ?? endIndex)
      }
    }
  }

  private func backwardWordRange(from index: Index) -> Range<Index> {
    precondition(startIndex...endIndex ~= index)

    if index == startIndex {
      return index..<index
    }
    else {
      guard let i = self[..<index].lastIndex(where: { !isWhitespace($0) })
      else { return startIndex..<index }

      // i is the last non-whitespace character before index

      // if in the range of word, select to start of current word
      if isWordCharacter(self[i]) {
        if let preStart = self[..<i].lastIndex(where: { !isWordCharacter($0) }) {
          return self.index(after: preStart)..<index
        }
        else {
          return startIndex..<index
        }
      }
      // otherwise select through non-word chars (stopping after previous word)
      else {
        if let preStart = self[..<i].lastIndex(where: { isWordCharacter($0) }) {
          return self.index(after: preStart)..<index
        }
        else {
          return startIndex..<index
        }
      }
    }
  }
}
