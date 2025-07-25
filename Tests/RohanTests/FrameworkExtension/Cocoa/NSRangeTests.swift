import Foundation
import Testing

@testable import SwiftRohan

struct NSRangeTests {
  @Test
  static func clamped_to() {
    do {
      let lhs = NSRange(location: 0, length: 5)
      let rhs = NSRange(location: 6, length: 10)
      let clamped = lhs.clamped(to: rhs)
      #expect(clamped.location == 6)
      #expect(clamped.length == 0)
    }
    do {
      let lhs = NSRange(location: NSNotFound, length: 5)
      let rhs = NSRange(location: 3, length: 10)
      let clamped = lhs.clamped(to: rhs)
      #expect(clamped.location == NSNotFound)
    }
  }
}
