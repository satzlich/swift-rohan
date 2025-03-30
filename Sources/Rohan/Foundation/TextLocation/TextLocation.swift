// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public struct TextLocation: Equatable, Hashable, CustomStringConvertible, Sendable {
  /// indices except the last
  let indices: [RohanIndex]

  /// last index (either character offset in text node, or node index in
  ///  element/argument node)
  let offset: Int

  internal init(_ indices: [RohanIndex], _ offset: Int) {
    precondition(offset >= 0)
    self.indices = indices
    self.offset = offset
  }

  internal var asPath: [RohanIndex] { indices + [.index(offset)] }

  /// Compare two text locations.
  /// - Returns: nil if the two locations are incomparable, otherwise the
  ///     comparison result
  public func compare(_ location: TextLocation) -> ComparisonResult? {
    let lhs = chain(self.indices, CollectionOfOne(.index(self.offset)))
    let rhs = chain(location.indices, CollectionOfOne(.index(location.offset)))

    guard let (lhs, rhs) = zip(lhs, rhs).first(where: !=) else {
      return ComparableComparator().compare(self.indices.count, location.indices.count)
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

  public var description: String {
    return "[" + indices.map(\.description).joined(separator: ",") + "]:\(offset)"
  }
}

extension TextLocation {
  /// Normalize the text location for a given tree.
  func normalized(for tree: RootNode) -> TextLocation? {
    Trace.from(self, tree)?.toTextLocation()
  }
}
