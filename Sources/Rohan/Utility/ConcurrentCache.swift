// Copyright 2024-2025 Lie Yan

import Foundation

final class ConcurrentCache<K, V> where K: Hashable {
  private var cache: [K: V] = [:]
  private let lock = NSLock()

  func getOrCreate(_ key: K, _ create: () -> V) -> V {
    lock.withLock {
      if let value = cache[key] {
        return value
      }
      let value = create()
      cache[key] = value
      return value
    }
  }
}
