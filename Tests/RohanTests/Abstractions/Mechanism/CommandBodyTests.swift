// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct CommandBodyTests {
  @Test
  func coverage() {
    let records = CommandRecords.allCases.map(\.body)
    let rules = ReplacementRules.allCases.map(\.command)
    let categories = ContainerCategory.allCases

    for (body, category) in product(records + rules, categories) {
      _ = body.isCompatible(with: category)
      _ = body.isMathOnly
      _ = body.isUniversal
      _ = body.preview
    }
  }
}
