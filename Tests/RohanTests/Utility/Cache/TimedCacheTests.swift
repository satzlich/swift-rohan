import Foundation
import Testing

@testable import SwiftRohan

struct TimedCacheTests {
  @Test
  func coverage() {
    let duration: TimeInterval = 0.2

    let cache = TimedCache<Int, String>(duration, duration * 2)

    cache.setValue("nine", forKey: 9)
    cache.setValue("ten", forKey: 10)
    cache.setValue("eleven", forKey: 11)

    //
    #expect(cache.value(forKey: 9) == "nine")
    #expect(cache.value(forKey: 10) == "ten")
    #expect(cache.value(forKey: 11) == "eleven")
    #expect(cache.value(forKey: 12) == nil)

    //
    cache.removeValue(forKey: 9)
    #expect(cache.value(forKey: 9) == nil)
    #expect(cache.value(forKey: 10) == "ten")

    //
    Thread.sleep(forTimeInterval: duration * 1.5)
    #expect(cache.value(forKey: 10) == nil)

    //
    Thread.sleep(forTimeInterval: duration * 1.5)
    _ = cache.count
    _ = cache.validCount
    cache.cleanupExpiredItems()
    cache.removeAll()
  }
}
