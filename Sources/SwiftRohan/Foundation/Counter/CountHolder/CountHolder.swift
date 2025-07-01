// Copyright 2024-2025 Lie Yan

import Foundation

internal class CountHolder {
  /// The previous holder in the linked list.
  private(set) weak var previous: CountHolder?
  /// The next holder in the linked list.
  private(set) var next: CountHolder?

  /// True if the state of this holder is out-of-date and needs to be updated.
  internal var isDirty: Bool { preconditionFailure("overriding required") }

  /// Mark this holder as dirty if applicable, and propagate the message to the
  /// next holder in the linked list.
  /// - Postcondition: All count holders after this one for which "mark dirty"
  ///     action is applicable become dirty.
  internal func propagateDirty() { preconditionFailure("overriding required") }

  /// Initialize the linked list with an initial and final count holder.
  static func initList() -> (initial: InitialCountHolder, final: FinalCountHolder) {
    let initial = InitialCountHolder()
    let final = FinalCountHolder()
    initial.next = final
    final.previous = initial
    return (initial, final)
  }

  static func insert(_ holder: CountHolder, before next: CountHolder) {
    precondition(next.previous != nil)
    let p = next.previous!

    holder.previous = p
    p.next = holder
    next.previous = holder
    holder.next = next
  }

  static func insert(
    contentsOf holders: some Collection<CountHolder>, before next: CountHolder
  ) {
    precondition(next.previous != nil)
    guard holders.isEmpty == false else { return }

    var p = next.previous!

    for holder in holders {
      holder.previous = p
      p.next = holder
      p = holder
    }

    next.previous = p
    p.next = next
  }

  static func remove(_ holder: CountHolder) {
    precondition(holder.previous != nil)

    let p = holder.previous!

    p.next = holder.next
    holder.next?.previous = p
    holder.previous = nil
    holder.next = nil
  }

  /// Remove the count holders in the half-open range `[begin, end)`.
  static func removeSubrange(_ begin: CountHolder, _ end: CountHolder) {
    precondition(begin.previous != nil)

    guard begin !== end else { return }

    begin.previous?.next = end
    end.previous?.next = nil
    end.previous = begin.previous
    begin.previous = nil
  }

  /// Remove the count holders in the closed range `[begin, end]`.
  static func removeSubrange(_ begin: CountHolder, inclusive end: CountHolder) {
    precondition(begin.previous != nil)
    precondition(end.next != nil)

    guard let end = end.next else { return }
    removeSubrange(begin, end)
  }

  /// Returns the value for the given counter name.
  /// - Postcondition: Call to this method clears the dirty state of the holder.
  internal func value(forName name: CounterName) -> Int {
    preconditionFailure("overriding required")
  }
}
