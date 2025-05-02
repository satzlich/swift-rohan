// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func testCommands() {
    #expect(MathSymbols.allCases.count == 569)
    #expect(CommandRecords.allCases.count == 671)
  }

  @Test
  static func testReplacementRules() {
    #expect(ReplacementRules.allCases.count == 35)
  }
}
