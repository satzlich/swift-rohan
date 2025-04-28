// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func testCommands() {
    #expect(MathSymbols.allCases.count == 723)
    #expect(CommandRecords.allCases.count == 768)
  }

  @Test
  static func testReplacementRules() {
    #expect(ReplacementRules.allCases.count == 31)
  }
}
