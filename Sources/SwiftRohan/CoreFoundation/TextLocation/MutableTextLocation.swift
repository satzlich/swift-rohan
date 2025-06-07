// Copyright 2024-2025 Lie Yan

/// Text location that is mutable from the end.
struct MutableTextLocation {
  private(set) var path: Array<RohanIndex>
  private(set) var isRectified: Bool

  init(_ location: TextLocation, isRectified: Bool = false) {
    self.path = location.asArray
    self.isRectified = isRectified
  }

  /// Replaces `path[i...]` with `indices`.
  /// - Precondition: `i<=path.count`
  mutating func rectify(_ i: Int, with indices: Int...) {
    precondition(i <= path.count)
    path.removeLast(path.count - i)
    path.append(contentsOf: indices.map { .index($0) })
    isRectified = true
  }

  internal func toTextLocation() -> TextLocation {
    // Note: the interface design guarantees that operation is always valid
    let offset = path.last!.index()!
    return TextLocation(path.dropLast(), offset)
  }
}
