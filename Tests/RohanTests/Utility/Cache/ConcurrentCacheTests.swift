import Foundation
import Testing

@testable import SwiftRohan

struct ConcurrentCacheTests {
  @Test
  func coverage() {
    let cache = ConcurrentCache<Int, String>()

    func create() -> String {
      return "Hello"
    }

    func tryCreate() -> String? {
      return nil
    }

    #expect(cache.getOrCreate(10, create) == "Hello")
    #expect(cache.tryGetOrCreate(11, create) == "Hello")
    #expect(cache.tryGetOrCreate(12, tryCreate) == nil)
    #expect(cache.tryGetOrCreate(11, create) == "Hello")
  }
}
