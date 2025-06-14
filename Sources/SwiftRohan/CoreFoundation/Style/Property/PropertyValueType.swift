// Copyright 2024-2025 Lie Yan

import Foundation

internal enum PropertyValueType: Equatable, Hashable, Codable, Sendable {
  case none

  // basic types
  case bool
  case integer
  case float
  case string

  // general
  case absLength
  case color

  // font
  case fontSize
  case fontStretch
  case fontStyle
  case fontWeight

  // math
  case mathStyle
  case mathVariant

  // paragraph
  case textAlignment

  // sum
  case sum(Sum)

  public static func sum(_ elements: Set<PropertyValueType>) -> PropertyValueType {
    .sum(Sum(elements))
  }

  /// A set that enforces invariants.
  public struct Sum: Equatable, Hashable, Codable, Sendable {
    typealias Element = PropertyValueType

    let elements: Set<Element>

    init(_ elements: Set<Element>) {
      precondition(Self.validate(elements: elements))
      self.elements = elements
    }

    func isSubset(of other: Sum) -> Bool {
      elements.isSubset(of: other.elements)
    }

    func contains(_ element: Element) -> Bool {
      elements.contains(element)
    }

    /// Returns true if invariants are satisfied.
    static func validate(elements: Set<Element>) -> Bool {
      elements.count > 1 && elements.allSatisfy { $0.isSimple }
    }
  }

  /// Returns true if `self` is simple.
  /// - Complexity: O(1)
  public var isSimple: Bool {
    switch self {
    case .sum: return false
    default: return true
    }
  }

  /// Returns true if `self` is a subset of `other`.
  /// - Complexity: O(m) where m is the size of `self`
  public func isSubset(of other: Self) -> Bool {
    switch self {
    case let .sum(s):
      switch other {
      case let .sum(t):
        return s.isSubset(of: t)
      default:
        return false
      }
    default:
      switch other {
      case let .sum(t):
        return t.contains(self)
      default:
        return self == other
      }
    }
  }
}
