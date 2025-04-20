// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct CommandsTests {

  @Test
  static func testDefaultCommands() {
    #expect(MathSymbols.allCases.count == 723)
    #expect(DefaultCommands.allCases.count == 745)
  }
}
