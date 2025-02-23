// Copyright 2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct RohanTests {
  @Test
  static func test_NSRange_clamped() {
    let lhs = NSRange(location: 0, length: 5)
    let rhs = NSRange(location: 6, length: 10)
    
    let clamped = lhs.clamped(to: rhs)
    #expect(clamped.location == 6)
    #expect(clamped.length == 0)
  }
}
