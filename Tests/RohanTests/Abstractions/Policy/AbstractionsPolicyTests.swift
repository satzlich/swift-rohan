// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.predefinedCases.count == 25)
    #expect(MathArray.predefinedCases.count == 8)
    #expect(MathExpression.predefinedCases.count == 9)
    #expect(MathGenFrac.predefinedCases.count == 8)
    #expect(MathKind.predefinedCases.count == 8)
    #expect(MathOperator.predefinedCases.count == 44)
    #expect(MathSpreader.predefinedCases.count == 6)
    #expect(NamedSymbol.predefinedCases.count == 458)
    #expect(MathTextStyle.predefinedCases.count == 8)
    #expect(CommandRecords.allCases.count == 592)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 340)
  }
}
