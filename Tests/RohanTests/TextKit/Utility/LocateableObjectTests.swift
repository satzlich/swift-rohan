// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct LocateableObjectTests {
  @Test
  func coverage() {
    do {
      let object = LocateableObject.text("Hello")
      #expect(object.nonText() == nil)
    }
    do {
      let object = LocateableObject.nonText(LinebreakNode())
      #expect(object.nonText()?.type == .linebreak)
    }
  }
}
