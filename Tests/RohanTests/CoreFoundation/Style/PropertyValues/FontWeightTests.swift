import Foundation
import Testing

@testable import SwiftRohan

struct FontWeightTests {
  @Test
  func coverage() {
    for weight in FontWeight.allCases {
      _ = weight.symbolicTraits()
    }
  }
}
