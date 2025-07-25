import CoreGraphics
import Testing

@testable import SwiftRohan

struct CGPointTests {
  @Test
  func coverage() {
    let point = CGPoint(x: 1, y: 2)
    _ = point.with(x: 10)
  }
}
