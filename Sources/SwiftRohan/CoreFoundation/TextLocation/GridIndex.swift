public struct GridIndex: Equatable, Hashable, Codable, Sendable {
  public let row: Int
  public let column: Int

  internal init(_ row: Int, _ column: Int) {
    precondition(GridIndex.validate(row: row))
    precondition(GridIndex.validate(column: column))
    self.row = row
    self.column = column
  }

  /*
   We follow the practice of Microsoft Word.
   Row count must be between 1 and 32767. Column count must be between 1 and 63.
   */

  internal static func validate(row: Int) -> Bool {
    0..<32767 ~= row
  }

  internal static func validate(column: Int) -> Bool {
    0..<63 ~= column
  }
}

extension GridIndex: Comparable {
  public static func < (lhs: GridIndex, rhs: GridIndex) -> Bool {
    (lhs.row, lhs.column) < (rhs.row, rhs.column)
  }
}

extension GridIndex: CustomStringConvertible {
  public var description: String {
    "(\(row),\(column))"
  }

  /// Parse a string of the form "(row,column)".
  static func parse<S: StringProtocol>(_ string: S) -> GridIndex? {
    guard string.first == "(",
      string.last == ")"
    else { return nil }
    let components =
      string
      .dropFirst()
      .dropLast()
      .split(separator: ",")
      .map { Int($0) }
    guard components.count == 2,
      let row = components[0],
      let column = components[1],
      validate(row: row),
      validate(column: column)
    else { return nil }
    return GridIndex(row, column)
  }
}
