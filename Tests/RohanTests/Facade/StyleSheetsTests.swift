// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct StyleSheetsTests {
  @Test
  func coverage() {
    _ = StyleSheets.allCases.map { (_, f) in f(12) }
  }
}
