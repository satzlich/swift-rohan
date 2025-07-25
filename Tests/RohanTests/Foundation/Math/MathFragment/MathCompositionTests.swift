import AppKit
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct MathCompositionTests {
  @Test
  func coverage() {
    _ = MathComposition.createHorizontal([])
  }
}
