import Foundation

final class ConcurrentCache<K: Hashable, V> {
  private var cache: Dictionary<K, V> = [:]
  private let queue =
    DispatchQueue(label: "net.satzlich.ConcurrentCache", attributes: .concurrent)

  /// Gets the value for the given key from the cache. If the value does not exist,
  /// creates it using the provided closure and stores it in the cache.
  func getOrCreate(_ key: K, _ create: () -> V) -> V {
    // first try to read concurrently
    var value: V?
    queue.sync {
      value = cache[key]
    }

    if let existingValue = value {
      return existingValue
    }

    // if not found, synchronize the write operation
    return queue.sync(flags: .barrier) {
      // check again in case another thread created it while we were waiting
      if let existingValue = cache[key] {
        return existingValue
      }
      // create the value and store it in the cache
      let newValue = create()
      cache[key] = newValue
      return newValue
    }
  }

  /// Gets the value for the given key from the cache. If the value does not exist,
  /// try to create it using the provided closure. If the closure returns nil,
  /// the cache remains unchanged.
  func tryGetOrCreate(_ key: K, _ tryCreate: () -> V?) -> V? {
    // first try to read concurrently
    var value: V?
    queue.sync {
      value = cache[key]
    }

    if let existingValue = value {
      return existingValue
    }

    // if not found, synchronize the write operation
    return queue.sync(flags: .barrier) {
      // check again in case another thread created it while we were waiting
      if let existingValue = cache[key] {
        return existingValue
      }
      // create the value and store it in the cache
      let newValue = tryCreate()
      if let newValue {
        cache[key] = newValue
        return newValue
      }
      else {
        return nil
      }
    }
  }
}
