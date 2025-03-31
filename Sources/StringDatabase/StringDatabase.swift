// Copyright 2024-2025 Lie Yan

import Foundation

public final class StringDatabase<V> {
  public typealias Key = String
  public typealias Value = V
  public typealias Element = (key: String, value: Value)

  private var elements: Dictionary<String, Value> = [:]

  public init(_ elements: Array<Element>) {

  }

  public subscript(key: Key) -> Value? {
    get {
      return elements[key]
    }
    set {
      elements[key] = newValue
    }
  }

  /// Count the number of entries that match the pattern.
  /// - Parameters:
  ///   - pattern: The pattern to match.
  ///   - options: The options for searching.
  ///   - offset: The offset of the first entry to return.
  ///   - limit: The maximum number of entries to return.
  /// - Returns: The number of entries that match the pattern.
  public func count(
    _ pattern: StringPattern,
    options: MatchOptions = [],
    offset: Int? = nil, limit: Int? = nil
  ) -> Int {
    0
  }

  /// Select entries that match the pattern.
  /// - Parameters:
  ///   - pattern: The pattern to match.
  ///   - options: The options for searching.
  ///   - offset: The offset of the first entry to return.
  ///   - limit: The maximum number of entries to return.
  /// - Returns: The entries that match the pattern.
  public func select(
    _ pattern: StringPattern,
    options: MatchOptions = [],
    offset: Int? = nil, limit: Int? = nil
  ) -> Array<Element> {
    []
  }

  /// Feedback the choice for the pattern.
  /// - Parameters:
  ///   - choice: The choice made by the user.
  ///   - pattern: The pattern to match.
  ///   - options: The options for searching.
  ///   - offset: The offset of the first entry to return.
  ///   - limit: The maximum number of entries to return.
  public func feedback(
    _ choice: Key,
    for pattern: StringPattern,
    options: MatchOptions = [],
    offset: Int? = nil, limit: Int? = nil
  ) {
  }
}
