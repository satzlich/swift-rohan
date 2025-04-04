// Copyright 2024-2025 Lie Yan

import Rohan
import Testing

struct UnicodeScalarTests {
  @Test
  static func testMathClass() {
    let div = UnicodeScalar("/")
    #expect(div.mathClass == .Binary)
  }
}
