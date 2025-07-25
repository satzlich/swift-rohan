import CoreGraphics
import Foundation
import Testing

@testable import SwiftRohan

struct StringTests {
  @Test
  func coverage() {
    let str = "Hello, World!"
    _ = str.indexRange(for: 3..<5)
  }
}
