// Copyright 2024-2025 Lie Yan

struct InsertionPoint {
  private(set) var path: Array<RohanIndex>
  private(set) var isRectified: Bool

  init(_ path: Array<RohanIndex>, isRectified: Bool = false) {
    self.path = path
    self.isRectified = isRectified
  }

  mutating func rectify(_ i: Int, with index: Int...) {
    precondition(i < path.count)
    path.removeLast(path.count - i)
    index.forEach { path.append(.index($0)) }
    isRectified = true
  }

  mutating func rectify(_ i: Int, with result: (index: Int, offset: Int)) {
    self.rectify(i, with: result.index, result.offset)
  }
}
