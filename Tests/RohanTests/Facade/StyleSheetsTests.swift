// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct StyleSheetsTests {
  @Test
  func coverage() {
    let allCases = StyleSheets.allCases
    _ = allCases.map { record in record.provider(12) }

    _ = StyleSheets.Record.defaultValue
  }
}
