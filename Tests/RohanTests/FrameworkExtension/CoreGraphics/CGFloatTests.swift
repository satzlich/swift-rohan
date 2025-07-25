import CoreGraphics
import Testing

@testable import SwiftRohan

struct CGFloatTests {
  @Test
  func coverage() {
    let value = CGFloat(10)
    _ = value.clamped(6, 10, inset: 4)
  }
}
