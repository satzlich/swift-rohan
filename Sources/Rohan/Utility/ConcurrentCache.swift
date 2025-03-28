// Copyright 2024-2025 Lie Yan

import Foundation

final class ConcurrentCache<K, V> where K: Hashable {
  private var cache: [K: V] = [:]
  private let lock = NSLock()

  func get(_ key: K, _ create: () -> V) -> V {
    if let value = lock.withLock({ cache[key] }) {
      return value
    }
    let value = create()
    lock.withLock { cache[key] = value }
    return value
  }
}
