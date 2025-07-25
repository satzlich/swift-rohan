import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct CommandBodyTests {
  @Test
  func coverage() {
    let records = CommandRecords.allCases.map(\.body)
    let rules = ReplacementRules.allCases.map(\.command)
    let containerProperties = ContainerProperty.allCasesForTesting

    for body in records {
      _ = body.isMathOnly
      _ = body.isUniversal
      _ = body.preview
      _ = body.insertString()
    }

    for (body, container) in product(records + rules, containerProperties) {
      _ = body.isCompatible(with: container)
    }
  }

  @Test
  func extraCoverage() {
    // cover preview for long string.
    do {
      let body =
        CommandBody.insertString(CommandBody.InsertString("LongString", .text))
      _ = body.preview
    }

    // nil case for namedSymbolExpr
    #expect(nil == CommandBody.namedSymbolExpr("nonexistent"))
  }
}
