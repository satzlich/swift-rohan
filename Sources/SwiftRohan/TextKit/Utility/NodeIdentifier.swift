// Copyright 2024-2025 Lie Yan

actor NodeIdAllocator {
  private static var _counter: Int = 1

  static func allocate() -> NodeIdentifier {
    defer { Self._counter += 1 }
    return NodeIdentifier(Self._counter)
  }

  static func resetCounter() {
    Self._counter = 1
  }
}

struct NodeIdentifier: Equatable, Hashable, CustomStringConvertible, Sendable {
  private let id: Int

  fileprivate init(_ id: Int) {
    self.id = id
  }

  var description: String { "\(id)" }
}
