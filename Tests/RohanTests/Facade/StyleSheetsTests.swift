// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct StyleSheetsTests {
  @Test
  func coverage() {
    _ = StyleSheets.allRecords.map { record in record.provider(12) }
    _ = StyleSheets.textSizes

    _ = StyleSheets.defaultRecord
    _ = StyleSheets.defaultTextSize
  }
}
