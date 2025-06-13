// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

public struct TextLocation: Equatable, Hashable, Sendable {
  /// indices except the last
  let indices: Array<RohanIndex>

  /// last index (either character offset in text node, or node index in
  /// element/argument node)
  let offset: Int

  internal init(_ indices: Array<RohanIndex>, _ offset: Int) {
    precondition(offset >= 0)
    self.indices = indices
    self.offset = offset
  }

  internal var asArray: Array<RohanIndex> { indices + [.index(offset)] }

  internal var asArraySlice: ArraySlice<RohanIndex> { indices + [.index(offset)] }

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

  /// Parse a string into a text location.
  static func parse<S: StringProtocol>(_ string: S) -> TextLocation? {
    let components = string.split(separator: ":")
    guard components.count == 2,
      let indices = parseIndices(components[0]),
      let offset = Int(components[1])
    else { return nil }
    return TextLocation(indices, offset)
  }

  /// Parse a string into a list of indices.
  static func parseIndices<S: StringProtocol>(_ string: S) -> Array<RohanIndex>? {
    guard string.first == "[",
      string.last == "]"
    else { return nil }
    let pattern = #/,(?!\d)/#  // comma not followed by a digit
    let indices = String(string.dropFirst().dropLast()).split(separator: pattern)
    var result: Array<RohanIndex> = []
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
  /// - Postcondition: The returned location is guaranteed to be equivalent to the
  ///     original location in the context of the given tree.
  func normalised(for tree: RootNode) -> TextLocation? {
    Trace.from(self, tree)?.toNormalLocation()
  }

  /// Convert to user-space text location for a given tree.
  /// - Note: The returned location is **not guaranteed** to be equivalent to the
  ///     original location in the context of the given tree. If the result is to
  ///     be used for further internal processing, it is recommended to
  ///     call `normalised(for:)`.
  func toUseSpace(for tree: RootNode) -> TextLocation? {
    guard var trace = Trace.from(self, tree) else { return nil }
    return trace.toUserSpaceLocation()
  }

  /// Returns the text location with the given offset.
  func with(offsetDelta: Int) -> TextLocation {
    precondition(offset + offsetDelta >= 0)
    return TextLocation(indices, offset + offsetDelta)
  }
}
