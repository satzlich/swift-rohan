// Copyright 2024-2025 Lie Yan

/// Text location that is mutable from the end.
struct MutableTextLocation {
  private(set) var path: Array<RohanIndex>
  private(set) var isRectified: Bool

  init(_ location: TextLocation, isRectified: Bool = false) {
    self.path = location.asPath
    self.isRectified = isRectified
  }

  mutating func rectify(_ i: Int, with index: Int...) {
    precondition(i <= path.count)
    path.removeLast(path.count - i)
    index.forEach { path.append(.index($0)) }
    isRectified = true
  }

  var asTextLocation: TextLocation? {
    guard let offset = path.last?.index() else { return nil }
    return TextLocation(path.dropLast(), offset)
  }
}
