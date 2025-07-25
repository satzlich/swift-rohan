import Foundation
import Testing

@testable import SwiftRohan

struct FontStyleTests {
  @Test
  func coverage() {
    for style in FontStyle.allCases {
      _ = style.symbolicTraits()
    }
  }
}
