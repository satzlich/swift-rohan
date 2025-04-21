// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct StringUtilsTests {
  @Test
  func test_isPrefixFree() {
    do {
      let strings = ["abc", "ab", "a"]
      #expect(StringUtils.isPrefixFree(strings) == false)
    }

    do {
      let strings = ["abc", "bc", "c", "ac"]
      #expect(StringUtils.isPrefixFree(strings) == true)
    }
  }
}
