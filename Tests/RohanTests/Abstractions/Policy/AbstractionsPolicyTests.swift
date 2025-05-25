// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.allCommands.count == 25)
    #expect(MathArray.allCommands.count == 8)
    #expect(MathExpression.allCommands.count == 10)
    #expect(MathGenFrac.allCommands.count == 8)
    #expect(MathKind.allCommands.count == 8)
    #expect(MathOperator.allCommands.count == 43)
    #expect(MathSpreader.allCommands.count == 6)
    #expect(NamedSymbol.allCommands.count == 458)
    #expect(MathTextStyle.allCommands.count == 8)

    let sum =
      MathAccent.allCommands.count + MathArray.allCommands.count
      + MathExpression.allCommands.count + MathGenFrac.allCommands.count
      + MathKind.allCommands.count + MathOperator.allCommands.count
      + MathSpreader.allCommands.count + NamedSymbol.allCommands.count
      + MathTextStyle.allCommands.count

    #expect(sum == 574)
    #expect(CommandRecords.allCases.count == 593)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 340)
  }
}
