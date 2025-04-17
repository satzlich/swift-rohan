// Copyright 2024-2025 Lie Yan

import Foundation

final class ConcurrentCache<K, V> where K: Hashable {
  private var cache: [K: V] = [:]
  private let queue =
    DispatchQueue(label: "net.satzlich.ConcurrentCache", attributes: .concurrent)

  func getOrCreate(_ key: K, _ create: () -> V) -> V {
    // First try to read concurrently
    var value: V?
    queue.sync {
      value = cache[key]
    }

    if let existingValue = value {
      return existingValue
    }

    // If not found, synchronize the write operation
    return queue.sync(flags: .barrier) {
      // Check again in case another thread created it while we were waiting
      if let existingValue = cache[key] {
        return existingValue
      }
      let newValue = create()
      cache[key] = newValue
      return newValue
    }
  }
}
