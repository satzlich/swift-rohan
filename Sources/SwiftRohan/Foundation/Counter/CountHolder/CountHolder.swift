// Copyright 2024-2025 Lie Yan

import Foundation

internal class CountHolder: CountPublisher {
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
    guard _isDirty == false else { return }
    _isDirty = true
    next?.propagateDirty()
    notifyObservers(markAsDirty: ())
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

//  /// Initialize the linked list with an initial and final count holder.
//  static func initList() -> (initial: InitialCountHolder, final: FinalCountHolder) {
//    let initial = InitialCountHolder()
//    let final = FinalCountHolder()
//    initial.next = final
//    final.previous = initial
//    return (initial, final)
//  }

  // MARK: - Manipulation

  /// Concatenate the given count holders into a linked list.
  /// - Returns: The first holder in the linked list, or `nil` if the collection is empty.
  static func concate(
    contentsOf holders: some BidirectionalCollection<CountHolder>
  ) {
    guard let first = holders.first else { return }
    var p = first
    for holder in holders.dropFirst() {
      p.next = holder
      holder.previous = p
      p = holder
    }
    p.next = nil
  }

  @inlinable @inline(__always)
  static func connect(_ first: CountHolder, _ second: CountHolder) {
    first.next = second
    second.previous = first
  }

  /// Insert a new holder before the next holder in the linked list.
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

  /// Insert a new holder after the previous holder in the linked list.
  static func insert(_ holder: CountHolder, after previous: CountHolder) {
    if let n = previous.next {
      holder.next = n
      n.previous = holder
      previous.next = holder
      holder.previous = previous
    }
    else {
      // `previous` is the last holder in the linked list.
      previous.next = holder
      holder.previous = previous
    }
  }

  /// Insert the given count holders before the next holder in the linked list.
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

  /// Insert the given count holders after the previous holder in the linked list.
  static func insert(
    contentsOf holders: some BidirectionalCollection<CountHolder>,
    after previous: CountHolder
  ) {
    guard holders.isEmpty == false else { return }

    if var n = previous.next {

      for holder in holders.reversed() {
        holder.next = n
        n.previous = holder
        n = holder
      }
      previous.next = n
      n.previous = previous
    }
    else {
      // `previous` is the last holder in the linked list.

      for (p, q) in holders.adjacentPairs() {
        q.previous = p
        p.next = q
      }
      let first = holders.first!
      first.previous = previous
      previous.next = first
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
  static func countSubrange(_ begin: CountHolder, inclusive end: CountHolder) -> Int {
    countSubrange(begin, end) + 1
  }

  /// Map the count holders in the half-open range `[begin, end)` to an array.
  static func mapSubrange<T>(
    _ begin: CountHolder, _ end: CountHolder,
    _ transform: (CountHolder) throws -> T
  ) rethrows -> Array<T> {
    var result: Array<T> = []
    var holder: CountHolder = begin

    while holder !== end {
      result.append(try transform(holder))
      if let next = holder.next {
        holder = next
      }
      else {
        break
      }
    }
    return result
  }

  /// Map the count holders in the closed range `[begin, end]` to an array.
  static func mapSubrange<T>(
    _ begin: CountHolder, inclusive end: CountHolder,
    _ transform: (CountHolder) throws -> T
  ) rethrows -> Array<T> {
    var result: Array<T> = []
    var holder: CountHolder = begin

    while holder !== end {
      result.append(try transform(holder))
      if let next = holder.next {
        holder = next
      }
      else {
        break
      }
    }
    result.append(try transform(end))
    return result
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

    let value = computeValue(forName: name)
    _cache[name] = value
    return value
  }

  final func computeValue(forName name: CounterName) -> Int {
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

  private var _observers = Set<WeakObserver>()

  init(_ name: CounterName) {
    self.counterName = name
  }

  // MARK: - Observer

  final func registerObserver(_ observer: any CountObserver) {
    /// We use a weak reference to avoid strong reference cycles.
    _observers.insert(WeakObserver(observer))
  }

  final func unregisterObserver(_ observer: any CountObserver) {
    _observers.remove(WeakObserver(observer))
  }

  final func notifyObservers(markAsDirty: Void) {
    for observer in _observers {
      observer.countObserver(markAsDirty: markAsDirty)
    }
  }

  private struct WeakObserver: Equatable, Hashable {
    private weak var observer: (any CountObserver)?

    init(_ observer: any CountObserver) {
      self.observer = observer
    }

    static func == (lhs: WeakObserver, rhs: WeakObserver) -> Bool {
      lhs.observer === rhs.observer
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(observer!))
    }

    func countObserver(markAsDirty: Void) {
      observer?.countObserver(markAsDirty: markAsDirty)
    }
  }
}
