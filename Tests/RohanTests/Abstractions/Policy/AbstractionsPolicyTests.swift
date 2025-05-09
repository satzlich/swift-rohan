// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathSymbols.allCases.count == 723)
    #expect(CommandRecords.allCases.count == 828)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 40)
  }
}
