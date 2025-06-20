// Copyright 2024-2025 Lie Yan

final class CountAnchor {
  internal let name: CounterName
  private(set) var value: Int
  private(set) var isActive: Bool

  /// The previous anchor in the linked list.
  private(set) weak var previous: CountAnchor?
  /// The next anchor in the linked list.
  private(set) var next: CountAnchor?

  /// The previous active anchor.
  private(set) weak var previousActive: CountAnchor?
  /// The next active anchor.
  private(set) var nextActive: CountAnchor?

  init() {
    preconditionFailure()
  }

  // MARK: - Query

  internal func value(forName name: CounterName) -> Int {
    preconditionFailure()
  }

  static func insert(_ anchor: CountAnchor, after previous: CountAnchor) {
    precondition(anchor.previous == nil && anchor.next == nil)
  }

  static func insert(_ anchor: CountAnchor, before next: CountAnchor) {
    precondition(anchor.previous == nil && anchor.next == nil)
  }

  static func remove(_ anchor: CountAnchor) {
    precondition(anchor.previous != nil || anchor.next != nil)
  }
}
