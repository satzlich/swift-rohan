// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

struct UnicodeScalarTests {
  @Test
  static func testMathClass() {
    let div = UnicodeScalar("/")
    #expect(div.mathClass == .Binary)
  }
}
