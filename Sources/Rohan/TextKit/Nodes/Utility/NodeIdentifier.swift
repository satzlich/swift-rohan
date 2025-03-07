// Copyright 2024-2025 Lie Yan

@DebugDescription
struct NodeIdentifier: Equatable, Hashable, CustomStringConvertible {
  static var _counter: Int = 1
  let _id: Int

  init() {
    self._id = NodeIdentifier._counter
    NodeIdentifier._counter += 1
  }

  var description: String { "\(_id)" }

  static func resetCounter() {
    NodeIdentifier._counter = 1
  }
}
