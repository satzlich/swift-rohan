// Copyright 2024-2025 Lie Yan

public enum RohanIndex: Equatable, Hashable, Codable, Sendable {
  case index(Int)
  case mathIndex(MathIndex)
  case gridIndex(GridIndex)
  case argumentIndex(Int)

  public static func gridIndex(_ row: Int, _ column: Int) -> RohanIndex {
    precondition(row >= 0 && column >= 0)
    return .gridIndex(GridIndex(row, column))
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
}

extension RohanIndex: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .index(index): return "↓\(index)"
    case let .mathIndex(index): return "\(index)"
    case let .gridIndex(index): return "\(index)"
    case let .argumentIndex(index): return "⇒\(index)"
    }
  }
}

extension RohanIndex {
  static func parse<S: StringProtocol>(_ string: S) -> RohanIndex? {
    guard string.count > 1 else { return nil }
    switch string[string.startIndex] {
    case "↓":
      guard let index = Int(string.dropFirst()) else { return nil }
      return .index(index)

    case "⇒":
      guard let index = Int(string.dropFirst()) else { return nil }
      return .argumentIndex(index)

    case "(":
      guard let gridIndex = GridIndex.parse(string) else { return nil }
      return .gridIndex(gridIndex)

    default:
      guard let mathIndex = MathIndex.parse(string) else { return nil }
      return .mathIndex(mathIndex)
    }
  }
}
