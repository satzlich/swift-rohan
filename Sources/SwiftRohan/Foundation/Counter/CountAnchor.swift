// Copyright 2024-2025 Lie Yan

final class CountAnchor {
  internal let name: CounterName
  private(set) var value: Int
  private(set) var isActive: Bool

  /// The previous anchor in the linked list.
  private(set) weak var previous: CountAnchor?
  /// The next anchor in the linked list.
  private(set) var next: CountAnchor?

  /// The previous proxy.
  private(set) weak var previousProxy: CountAnchor?
  /// The next proxy.
  private(set) var nextProxy: CountAnchor?

  init() {
    preconditionFailure()
  }

  // MARK: - Query

  internal func value(forName name: CounterName) -> Int {
    preconditionFailure()
  }
}
