// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation

struct TraceElement {
  let node: Node
  let index: RohanIndex

  init(_ node: Node, _ index: RohanIndex) {
    self.node = node
    self.index = index
  }

  func with(index: RohanIndex) -> TraceElement {
    TraceElement(node, index)
  }
}

public struct TextLocation: Equatable, Hashable, CustomStringConvertible {
  /** indices except the last; there is no index for the root node */
  let indices: [RohanIndex]
  /** last index; character offset in text node, or node index in element node */
  let offset: Int

  internal init(_ indices: [RohanIndex], _ offset: Int) {
    precondition(offset >= 0)
    self.indices = indices
    self.offset = offset
  }

  public func compare(_ location: TextLocation) -> ComparisonResult? {
    let lhs = chain(self.indices, CollectionOfOne(.index(self.offset)))
    let rhs = chain(location.indices, CollectionOfOne(.index(location.offset)))

    guard let (lhs, rhs) = zip(lhs, rhs).first(where: !=)
    else { return ComparableComparator().compare(self.indices.count, location.indices.count) }

    switch (lhs, rhs) {
    case let (.index(lhs), .index(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    case let (.mathIndex(lhs), .mathIndex(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    case let (.gridIndex(lhs), .gridIndex(rhs)):
      return ComparableComparator().compare(lhs, rhs)
    default:
      return nil
    }
  }

  public var description: String {
    return "[" + indices.map(\.description).joined(separator: ",") + "]:\(offset)"
  }
}
