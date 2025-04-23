// Copyright 2024-2025 Lie Yan

public enum RohanIndex: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
  case index(Int)
  case mathIndex(MathIndex)
  case gridIndex(GridIndex)
  case argumentIndex(Int)

  // MARK: - Init

  public static func gridIndex(_ row: Int, _ column: Int) -> RohanIndex {
    .gridIndex(GridIndex(row, column))
  }

  // MARK: - Getters

  func index() -> Int? {
    switch self {
    case let .index(index): return index
    default: return nil
    }
  }

  func mathIndex() -> MathIndex? {
    switch self {
    case let .mathIndex(index): return index
    default: return nil
    }
  }

  func gridIndex() -> GridIndex? {
    switch self {
    case let .gridIndex(index): return index
    default: return nil
    }
  }

  func argumentIndex() -> Int? {
    switch self {
    case let .argumentIndex(index): return index
    default: return nil
    }
  }

  func isSameType(as other: RohanIndex) -> Bool {
    switch (self, other) {
    case (.index, .index),
      (.mathIndex, .mathIndex),
      (.gridIndex, .gridIndex),
      (.argumentIndex, .argumentIndex):
      return true
    default:
      return false
    }
  }

  public var description: String {
    switch self {
    case let .index(index): return "\(index)↓"
    case let .mathIndex(index): return "\(index)"
    case let .gridIndex(index): return "\(index)"
    case let .argumentIndex(index): return "\(index)⇒"
    }
  }
}

public enum MathIndex: Int, Comparable, Codable, CustomStringConvertible, Sendable {
  case leftSubScript = 0
  case leftSuperScript = 1
  case nucleus = 2
  // scripts
  case subScript = 3
  case superScript = 4
  // fraction
  case numerator = 5
  case denominator = 6
  // radical
  case index = 7
  case radicand = 8

  public static func < (lhs: MathIndex, rhs: MathIndex) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

  public var description: String {
    switch self {
    case .leftSubScript: return "leftSubscript"
    case .leftSuperScript: return "leftSuperscript"
    case .nucleus: return "nucleus"
    case .subScript: return "subscript"
    case .superScript: return "superscript"
    case .numerator: return "numerator"
    case .denominator: return "denominator"
    case .index: return "index"
    case .radicand: return "radicand"
    }
  }
}

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
