// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathSymbol.predefinedCases.count == 569)
    #expect(CommandRecords.allCases.count == 675)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 72)
  }
}
