import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ContentModeTests {
  @Test
  func coverage() {
    for nodeType in NodeType.allCases {
      _ = nodeType.contentMode
    }
  }
}
