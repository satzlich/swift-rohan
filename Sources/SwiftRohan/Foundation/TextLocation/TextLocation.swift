// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public struct TextLocation: Equatable, Hashable, Sendable {
  /// indices except the last
  let indices: [RohanIndex]

  /// last index (either character offset in text node, or node index in
  /// element/argument node)
  let offset: Int

  internal init(_ indices: [RohanIndex], _ offset: Int) {
    precondition(offset >= 0)
    self.indices = indices
    self.offset = offset
  }

  internal var asArray: [RohanIndex] { indices + [.index(offset)] }

  /// Compare two text locations.
  /// - Returns: nil if the two locations are incomparable, otherwise the
  ///     comparison result
  public func compare(_ other: TextLocation) -> ComparisonResult? {
    let lhs = chain(self.indices, CollectionOfOne(.index(self.offset)))
    let rhs = chain(other.indices, CollectionOfOne(.index(other.offset)))

    guard let (lhs, rhs) = zip(lhs, rhs).first(where: !=)
    else {
      return ComparableComparator().compare(indices.count, other.indices.count)
    }

    switch (lhs, rhs) {
    case let (.index(lhs), .index(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    case let (.mathIndex(lhs), .mathIndex(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    case let (.gridIndex(lhs), .gridIndex(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    case let (.argumentIndex(lhs), .argumentIndex(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    default:
      return nil
    }
  }

}

extension TextLocation: CustomStringConvertible {
  public var description: String {
    return "[" + indices.map(\.description).joined(separator: ",") + "]:\(offset)"
  }
}

extension TextLocation {
  static func parse<S: StringProtocol>(_ string: S) -> TextLocation? {
    let components = string.split(separator: ":")
    guard components.count == 2,
      let indices = parseIndices(components[0]),
      let offset = Int(components[1])
    else { return nil }
    return TextLocation(indices, offset)
  }

  static func parseIndices<S: StringProtocol>(_ string: S) -> [RohanIndex]? {
    guard string.first == "[",
      string.last == "]"
    else { return nil }
    let indices = string.dropFirst().dropLast().split(separator: ",")
    var result: [RohanIndex] = []
    result.reserveCapacity(indices.count)
    for index in indices {
      if let rohanIndex = RohanIndex.parse(index) {
        result.append(rohanIndex)
      }
      else {
        return nil
      }
    }
    return result
  }
}

extension TextLocation {
  /// Normalize the text location for a given tree.
  func normalized(for tree: RootNode) -> TextLocation? {
    Trace.from(self, tree)?.toTextLocation()
  }

  /// Returns the text location with the given offset.
  func with(offsetDelta: Int) -> TextLocation {
    precondition(offset + offsetDelta >= 0)
    return TextLocation(indices, offset + offsetDelta)
  }
}
