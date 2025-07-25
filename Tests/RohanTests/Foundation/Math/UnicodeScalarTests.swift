import Testing

@testable import SwiftRohan

struct UnicodeScalarTests {
  @Test
  static func testMathClass() {
    let div = UnicodeScalar("/")
    #expect(div.mathClass == .Binary)
  }
}
