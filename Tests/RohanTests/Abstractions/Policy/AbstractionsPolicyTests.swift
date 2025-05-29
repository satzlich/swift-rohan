// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct AbstractionPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.allCommands.count == 25)
    #expect(MathArray.allCommands.count == 9)
    #expect(MathAttributes.allCommands.count == 10)
    #expect(MathExpression.allCommands.count == 11)
    #expect(MathGenFrac.allCommands.count == 8)
    #expect(MathOperator.allCommands.count == 43)
    #expect(MathSpreader.allCommands.count == 6)
    #expect(MathStyles.allCommands.count == 12)
    #expect(MathTemplate.allCommands.count == 7)
    #expect(NamedSymbol.allCommands.count == 458)

    let sum =
      MathAccent.allCommands.count + MathArray.allCommands.count
      + MathAttributes.allCommands.count + MathExpression.allCommands.count
      + MathGenFrac.allCommands.count + MathOperator.allCommands.count
      + MathSpreader.allCommands.count + MathStyles.allCommands.count
      + MathTemplate.allCommands.count + NamedSymbol.allCommands.count

    #expect(sum == 589)
    #expect(CommandDeclaration.allCommands.count == sum)
    #expect(CommandRecords.allCases.count == 605)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 353)
  }
}
