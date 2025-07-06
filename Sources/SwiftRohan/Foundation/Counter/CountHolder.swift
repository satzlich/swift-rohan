// Copyright 2024-2025 Lie Yan

import Foundation

final class CountHolder: CountPublisher {
  /// The previous holder in the linked list.
  private(set) weak var previous: CountHolder?
  /// The next holder in the linked list.
  private(set) var next: CountHolder?

  /// True if the state of this holder is out-of-date and needs to be updated.
  final var isDirty: Bool { _isDirty }

  /// Mark this holder as dirty if applicable, and propagate the message to the
  /// next holder in the linked list.
  /// - Postcondition: All count holders after this one for which "mark dirty"
  ///     action is applicable become dirty.
  final func propagateDirty() {
    // stop early if this holder is already dirty.
    guard _isDirty == false else { return }

    _isDirty = true
    next?.propagateDirty()
    notifyObservers(markAsDirty: ())
  }

  // MARK: - Manipulation

  @inlinable @inline(__always)
  static func connect(_ first: CountHolder, _ second: CountHolder) {
    first.next = second
    second.previous = first
  }

  /// Insert a new holder before the next holder in the linked list.
  static func insert(_ holder: CountHolder, before next: CountHolder) {
    insert(contentsOf: CollectionOfOne(holder), before: next)
  }

  /// Insert the given count holders before the next holder in the linked list.
  @inlinable
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

  /// Remove the given count holder from the linked list.
  /// - Returns: `true` if the linked list **is empty** after the removal.
  static func remove(_ holder: CountHolder) -> Bool {
    if let p = holder.previous {
      p.next = holder.next
      holder.next?.previous = p
      holder.previous = nil
      holder.next = nil
      return false
    }
    else {
      // `holder` is the first holder in the linked list.
      if let next = holder.next {
        next.previous = nil
        holder.next = nil
        return false
      }
      else {
        // no-op, `holder` is the only holder in the linked list.
        return true
      }
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
  /// - Returns: `true` if the linked list **is empty** after the removal.
  static func removeSubrange(_ begin: CountHolder, inclusive end: CountHolder) -> Bool {
    if let end = end.next {
      removeSubrange(begin, end)
      return false
    }
    else {
      // `end` is the last holder in the linked list.
      if let p = begin.previous {
        p.next = nil
        return false
      }
      else {
        // `[begin,end]` is the whole of the linked list.

        // no-op
        return true
      }
    }
  }

  // MARK: - Query

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
  @inlinable @inline(__always)
  static func countSubrange(_ begin: CountHolder, inclusive end: CountHolder) -> Int {
    countSubrange(begin, end) + 1
  }

  // MARK: - Counter Values

  /// Returns the value for the given counter name.
  /// - Postcondition: Call to this method clears the dirty state of the holder.
  final func value(forName name: CounterName) -> Int {
    if _isDirty {
      _cache.removeAll()
      _isDirty = false
      // FALL THROUGH
    }
    else if let cachedValue = _cache[name] {
      return cachedValue
    }

    let value = _computeValue(forName: name)
    _cache[name] = value
    return value
  }

  private final func _computeValue(forName name: CounterName) -> Int {
    switch name {
    case .section:
      let previousValue = previous?.value(forName: .section) ?? 0
      switch self.counterName {
      case .section: return previousValue + 1
      case _: return previousValue
      }

    case .subsection:
      switch self.counterName {
      case .section:
        return 0
      case .subsection:
        let previousValue = previous?.value(forName: .subsection) ?? 0
        return previousValue + 1
      case _:
        let previousValue = previous?.value(forName: .subsection) ?? 0
        return previousValue
      }

    case .subsubsection:
      switch self.counterName {
      case .section, .subsection:
        return 0
      case .subsubsection:
        let previousValue = previous?.value(forName: .subsubsection) ?? 0
        return previousValue + 1
      case _:
        let previousValue = previous?.value(forName: .subsubsection) ?? 0
        return previousValue
      }

    case .equation:
      let previousValue = previous?.value(forName: .equation) ?? 0
      switch self.counterName {
      case .equation:
        return previousValue + 1
      case _:
        return previousValue
      }
    }
  }

  // MARK: - State

  /// The name of the counter this holder is responsible for.
  let counterName: CounterName

  /// - Important: To support early stop of propagation, default value must be
  ///     false. Meanwhile, only use `propagateDirty()` to set this value to true.
  private var _isDirty: Bool = false

  private var _cache: Dictionary<CounterName, Int> = [:]

  private var _observers = NSHashTable<AnyObject>(options: .weakMemory)

  init(_ name: CounterName) {
    self.counterName = name
  }

  // MARK: - Observer

  final func registerObserver(_ observer: any CountObserver) {
    _observers.add(observer)
  }

  final func unregisterObserver(_ observer: any CountObserver) {
    _observers.remove(observer)
  }

  final func notifyObservers(markAsDirty: Void) {
    for case let observer as CountObserver in _observers.objectEnumerator() {
      observer.countObserver(markAsDirty: markAsDirty)
    }
  }
}
