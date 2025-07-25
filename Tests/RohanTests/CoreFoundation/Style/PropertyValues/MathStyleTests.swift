import Foundation
import Testing

@testable import SwiftRohan

struct MathStyleTests {
  @Test
  func coverage() {
    for style in MathStyle.allCases {
      _ = style.scaleUp()
      _ = style.inlineParallel()
    }
  }
}
