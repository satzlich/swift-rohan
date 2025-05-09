// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TimedCacheTests {
  @Test
  func coverage() {
    let cache = TimedCache<Int, String>(expirationInterval: 0.5, cleanupInterval: 2)

    cache.setValue("six", forKey: 6)
    cache.setValue("ten", forKey: 10)

    //
    #expect(cache.value(forKey: 6) == "six")
    #expect(cache.value(forKey: 10) == "ten")
    #expect(cache.value(forKey: 11) == nil)

    //
    cache.removeValue(forKey: 6)
    #expect(cache.value(forKey: 6) == nil)
    #expect(cache.value(forKey: 10) == "ten")

    //
    Thread.sleep(forTimeInterval: 0.6)
    #expect(cache.value(forKey: 10) == nil)

    //
    _ = cache.count
    _ = cache.validCount
    cache.cleanupExpiredItems()
    cache.removeAll()
  }
}
