// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.predefinedCases.count == 26)
    #expect(MathArray.predefinedCases.count == 8)
    #expect(MathExpression.predefinedCases.count == 4)
    #expect(MathGenFrac.predefinedCases.count == 8)
    #expect(MathKind.predefinedCases.count == 8)
    #expect(MathOperator.predefinedCases.count == 42)
    #expect(MathSpreader.predefinedCases.count == 6)
    #expect(NamedSymbol.predefinedCases.count == 614)
    #expect(MathTextStyle.predefinedCases.count == 8)
    #expect(CommandRecords.allCases.count == 739)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 185)
  }
}
