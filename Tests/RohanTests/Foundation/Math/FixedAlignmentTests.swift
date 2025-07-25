import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct FixedAlignmentTests {
  @Test
  func coverage() {
    for alignment in FixedAlignment.allCases {
      _ = alignment.position(20)
    }
  }
}
