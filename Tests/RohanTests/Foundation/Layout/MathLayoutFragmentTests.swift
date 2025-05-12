// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct MathLayoutFragmentTests {
  @Test
  func coverage() {
    let font = Font.createWithName("STIX Two Math", 12)
    let table = font.copyMathTable()!
    let context = MathContext(font, .text, false, .blue)!

    let char: Character = "a"
    let fragment = MathGlyphLayoutFragment(char: char, font, table, char.length)!

    do {
      fragment.setGlyphOrigin(.zero)
      _ = fragment.minX
      _ = fragment.midX
      _ = fragment.maxX
      _ = fragment.minY
      _ = fragment.midY
      _ = fragment.maxY
      _ = fragment.boxDescription
      _ = fragment.debugPrint()

      for corner in Corner.allCases {
        _ = fragment.kernAtHeight(context, corner, 10)
      }
    }
  }
}
