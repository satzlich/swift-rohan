import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ContentTagTests {
  @Test
  func coverage() {
    for nodeType in NodeType.allCases {
      _ = nodeType.contentTag
    }
  }
}
