// Copyright 2024-2025 Lie Yan

import AppKit
import Testing

@testable import SwiftRohan

struct PlaygroundTests {
  var attributes: Dictionary<NSAttributedString.Key, Any> = [
    .font: NSFont.systemFont(ofSize: 10)
  ]

  @Test
  func nsAttributedString_size() {
    do {
      let attrString = NSAttributedString(string: "Hello", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 24.6875))
    }
    do {
      let attrString = NSAttributedString(string: "Jenny", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 28.583984375))
    }
    do {
      let attrString = NSAttributedString(string: "\u{00A0}", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 2.9296875))
    }
    do {
      let attrString = NSAttributedString(string: "\u{3000}", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 9.941634241245136))
    }
  }
}
