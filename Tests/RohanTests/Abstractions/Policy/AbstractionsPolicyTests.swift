// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.predefinedCases.count == 26)
    #expect(MathArray.predefinedCases.count == 8)
    #expect(MathExpression.predefinedCases.count == 1)
    #expect(MathGenFrac.predefinedCases.count == 5)
    #expect(MathKind.predefinedCases.count == 8)
    #expect(MathOperator.predefinedCases.count == 42)
    #expect(MathSpreader.predefinedCases.count == 6)
    #expect(MathSymbol.predefinedCases.count == 578)
    #expect(MathTextStyle.predefinedCases.count == 8)
    #expect(CommandRecords.allCases.count == 701)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 185)
  }
}
