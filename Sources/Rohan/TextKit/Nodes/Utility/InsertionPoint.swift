// Copyright 2024-2025 Lie Yan

struct InsertionPoint {
  private(set) var path: Array<RohanIndex>
  private(set) var isRectified: Bool

  init(_ path: Array<RohanIndex>, isRectified: Bool = false) {
    self.path = path
    self.isRectified = isRectified
  }

  mutating func rectify(_ i: Int, with index: Int...) {
    precondition(i <= path.count)
    path.removeLast(path.count - i)
    index.forEach { path.append(.index($0)) }
    isRectified = true
  }

  mutating func rectify(_ i: Int, with index: RohanIndex) {
    precondition(i <= path.count)
    path.removeLast(path.count - i)
    path.append(index)
    isRectified = true
  }

  var asTextLocation: TextLocation? {
    guard let offset = path.last?.index() else { return nil }
    return TextLocation(path.dropLast(), offset)
  }
}
