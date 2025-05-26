// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.allCommands.count == 25)
    #expect(MathArray.allCommands.count == 9)
    #expect(MathExpression.allCommands.count == 11)
    #expect(MathGenFrac.allCommands.count == 8)
    #expect(MathKind.allCommands.count == 8)
    #expect(MathLimits.allCommands.count == 2)
    #expect(MathOperator.allCommands.count == 43)
    #expect(MathSpreader.allCommands.count == 6)
    #expect(NamedSymbol.allCommands.count == 458)
    #expect(MathTextStyle.allCommands.count == 8)

    let sum =
      MathAccent.allCommands.count + MathArray.allCommands.count
      + MathExpression.allCommands.count + MathGenFrac.allCommands.count
      + MathKind.allCommands.count + MathLimits.allCommands.count
      + MathOperator.allCommands.count + MathSpreader.allCommands.count
      + NamedSymbol.allCommands.count + MathTextStyle.allCommands.count

    #expect(sum == 578)
    #expect(CommandRecords.allCases.count == 605)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 352)
  }
}
