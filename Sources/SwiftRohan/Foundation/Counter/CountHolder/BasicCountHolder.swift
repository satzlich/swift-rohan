// Copyright 2024-2025 Lie Yan

import Foundation

final class BasicCountHolder: CountHolder, CountPublisher {
  final override var isDirty: Bool { _isDirty }

  final override func propagateDirty() {
    guard _isDirty == false else { return }
    _isDirty = true
    next?.propagateDirty()
    notifyObservers(markAsDirty: ())
  }

  final override func value(forName name: CounterName) -> Int {
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
