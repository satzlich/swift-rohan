import Foundation
import Testing

@testable import SwiftRohan

struct FontStretchTests {
  @Test
  func coverage() {
    for stretch in FontStretch.allCases {
      _ = stretch.symbolicTraits()
    }
  }
}
