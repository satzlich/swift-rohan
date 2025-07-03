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
    if let p = next.previous {
      holder.previous = p
      p.next = holder
      next.previous = holder
      holder.next = next
    }
    else {
      // `next` is the first holder in the linked list.
      holder.next = next
      next.previous = holder
    }
  }

  static func insert(
    contentsOf holders: some BidirectionalCollection<CountHolder>,
    before next: CountHolder
  ) {
    guard holders.isEmpty == false else { return }

    if var p = next.previous {

      for holder in holders {
        holder.previous = p
        p.next = holder
        p = holder
      }

      next.previous = p
      p.next = next
    }
    else {
      // `next` is the first holder in the linked list.

      for (p, q) in holders.adjacentPairs() {
        p.next = q
        q.previous = p
      }
      let last = holders.last!
      last.next = next
      next.previous = last
    }
  }

  static func remove(_ holder: CountHolder) {
    if let p = holder.previous {
      p.next = holder.next
      holder.next?.previous = p
      holder.previous = nil
      holder.next = nil
    }
    else {
      // `holder` is the first holder in the linked list.
      guard let next = holder.next else { return }
      next.previous = nil
      holder.next = nil
    }
  }

  /// Remove the count holders in the half-open range `[begin, end)`.
  static func removeSubrange(_ begin: CountHolder, _ end: CountHolder) {
    guard begin !== end else { return }

    if begin.previous != nil {
      begin.previous?.next = end
      end.previous?.next = nil
      end.previous = begin.previous
      begin.previous = nil
    }
    else {
      // `[begin,end)` is the initial segment in the linked list.
      end.previous?.next = nil
      end.previous = nil
    }
  }

  /// Remove the count holders in the closed range `[begin, end]`.
  static func removeSubrange(_ begin: CountHolder, inclusive end: CountHolder) {
    guard let end = end.next else { return }
    removeSubrange(begin, end)
  }

  /// Returns the value for the given counter name.
  /// - Postcondition: Call to this method clears the dirty state of the holder.
  internal func value(forName name: CounterName) -> Int {
    preconditionFailure("overriding required")
  }

  /// Count the number of count holders in the half-open range `[begin, end)`.
  static func countSubrange(_ begin: CountHolder, _ end: CountHolder) -> Int {
    var count = 0
    var holder: CountHolder? = begin

    while holder != nil && holder !== end {
      count += 1
      holder = holder?.next
    }
    return count
  }

  /// Count the number of count holders in the closed range `[begin, end]`.
  static func countSubrange(_ begin: CountHolder, inclusive end: CountHolder) -> Int {
    countSubrange(begin, end) + 1
  }
}
