// Copyright 2024-2025 Lie Yan

public struct GridIndex: Equatable, Hashable, Codable, Comparable,
  CustomStringConvertible, Sendable
{
  public let row: Int
  public let column: Int

  internal init(_ row: Int, _ column: Int) {
    precondition(GridIndex.validate(row: row))
    precondition(GridIndex.validate(column: column))
    self.row = row
    self.column = column
  }

  public var description: String {
    "(\(row),\(column))"
  }

  public static func < (lhs: GridIndex, rhs: GridIndex) -> Bool {
    (lhs.row, lhs.column) < (rhs.row, rhs.column)
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
