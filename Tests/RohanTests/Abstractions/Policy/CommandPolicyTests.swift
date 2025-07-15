// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

/// Check the total number of commands and replacement rules.
struct CommandPolicyTests {

  @Test
  static func commandSet() {
    #expect(MathAccent.allCommands.count == 25)
    #expect(MathArray.allCommands.count == 16)
    #expect(MathAttributes.allCommands.count == 10)
    #expect(MathExpression.allCommands.count == 11)
    #expect(MathGenFrac.allCommands.count == 8)
    #expect(MathOperator.allCommands.count == 34)
    #expect(MathSpreader.allCommands.count == 23)
    #expect(MathStyles.allCommands.count == 12)
    #expect(MathTemplate.allCommands.count == 7)
    #expect(NamedSymbol.allCommands.count == 458)
    #expect(TextStyles.allCommands.count == 4)

    let sum =
      MathAccent.allCommands.count + MathArray.allCommands.count
      + MathAttributes.allCommands.count + MathExpression.allCommands.count
      + MathGenFrac.allCommands.count + MathOperator.allCommands.count
      + MathSpreader.allCommands.count + MathStyles.allCommands.count
      + MathTemplate.allCommands.count + NamedSymbol.allCommands.count
      + TextStyles.allCommands.count

    #expect(sum == 608)  // + 2 ("\sqrt", "\text").
    #expect(CommandDeclaration.allCommands.count == sum)
    #expect(CommandRecords.allCases.count == 630)
  }

  @Test
  static func replacementRuleSet() {
    #expect(ReplacementRules.allCases.count == 591)
  }
}
