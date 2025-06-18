// Copyright 2024-2025 Lie Yan

import AppKit
import Testing

@testable import SwiftRohan

struct NSAttributedStringTests {
  @Test
  func coverage() {
    let attributes: Dictionary<NSAttributedString.Key, Any> = [
      .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
    ]
    do {
      let attrString = NSAttributedString(string: "Hello", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 30.908203125))
    }
    do {
      let attrString = NSAttributedString(string: "Jenny", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 30.908203125))
    }
  }
}
