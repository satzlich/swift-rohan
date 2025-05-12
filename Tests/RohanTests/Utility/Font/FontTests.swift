// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct FontTests {
  @Test
  func coverage() {
    let font = Font.createWithName("Arial", 12)

    let chars: [UniChar] = "Hello, World!".utf16.map { $0 }
    var glyphs = [CGGlyph](repeating: 0, count: chars.count)

    let okay = font.getGlyphs(for: chars, &glyphs)
    #expect(okay == true)

    do {
      var advances = [CGSize](repeating: .zero, count: chars.count)
      _ = font.getAdvances(for: glyphs, .default, &advances)
    }

    do {
      var bounds = [CGRect](repeating: .zero, count: chars.count)
      _ = font.getBoundingRects(for: glyphs, &bounds)
    }
  }

  @Test
  func isFlipped() {
    let font = Font.createWithName("Arial", 12, isFlipped: true)

    #expect(font.xHeight < 0)
    #expect(font.ascent > 0)
    #expect(font.descent > 0)
  }
}
