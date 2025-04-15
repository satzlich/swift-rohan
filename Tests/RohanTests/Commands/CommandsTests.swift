// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct CommandsTests {

  @Test
  static func testDefaultCommands() {
    #expect(MathSymbols.allCases.count == 621)
    #expect(DefaultCommands.allCases.count == 638)
  }
}
