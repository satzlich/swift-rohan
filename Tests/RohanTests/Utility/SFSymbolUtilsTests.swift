// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation
import Testing

@testable import SwiftRohan

struct SFSymbolUtilsTests {
  @Test
  func coverage() {
    _ = SFSymbolUtils.textField(for: "note.text", 12)
  }
}
