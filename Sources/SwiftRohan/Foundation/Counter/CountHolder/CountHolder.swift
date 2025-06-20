// Copyright 2024-2025 Lie Yan

import Foundation

internal class CountHolder {
  /// The previous holder in the linked list.
  private(set) weak var previous: CountHolder?
  /// The next holder in the linked list.
  private(set) var next: CountHolder?

  /// The previous active holder.
  private(set) weak var previousActive: CountHolder?
  /// The next active holder.
  private(set) var nextActive: CountHolder?

  /// Returns true if this count holder may produce or change count values.
  internal var isActive: Bool { preconditionFailure("overriding required") }

  // MARK: - Query

  internal func value(forName name: CounterName) -> Int {
    preconditionFailure("overriding required")
  }

  // MARK: - Manipulation

  static func insert(_ anchor: CountHolder, after previous: CountHolder) {
    precondition(anchor.previous == nil && anchor.next == nil)
  }

  static func insert(_ anchor: CountHolder, before next: CountHolder) {
    precondition(anchor.previous == nil && anchor.next == nil)
  }

  static func insert<C: Collection<CountHolder>>(
    contentsOf anchors: C, after previous: CountHolder
  ) {
    precondition(anchors.allSatisfy { $0.previous == nil && $0.next == nil })
  }

  static func insert<C: Collection<CountHolder>>(
    contentsOf anchors: C, before next: CountHolder
  ) {
    precondition(anchors.allSatisfy { $0.previous == nil && $0.next == nil })
  }

  static func remove(_ anchor: CountHolder) {
    precondition(anchor.previous != nil || anchor.next != nil)
  }

  /// - Precondition: `begin` must precede `end` in the linked list.
  static func removeSubrange(_ begin: CountHolder, _ end: CountHolder) {
    precondition(begin.previous != nil)
    precondition(begin.next != nil && end.previous != nil)
  }
}
