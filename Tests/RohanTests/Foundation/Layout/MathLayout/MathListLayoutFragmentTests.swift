// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct MathListLayoutFragmentTests {
  private let mathContext = Self.testingMathContext()
  private var font: Font { mathContext.getFont() }
  private var table: MathTable { mathContext.table }

  private static func testingMathContext() -> MathContext {
    let font = Font.createWithName("STIX Two Math", 10)
    let context = MathContext(font, .text, false, .black)!
    return context
  }

  private func getGlyph(for character: Character) -> MathGlyphLayoutFragment {
    MathGlyphLayoutFragment(char: character, font, table, character.length)!
  }

  // MARK: - Test

  @Test
  func reflow() {
    let mathList = MathListLayoutFragment(mathContext)
    let glyphs = "x+y=z/w".map { getGlyph(for: $0) }

    mathList.beginEditing()
    mathList.insert(contentsOf: glyphs, at: 0)
    mathList.endEditing()
    mathList.fixLayout(mathContext)

    #expect(mathList.reflowSegmentCount == 0)

    mathList.performReflow()
    #expect(mathList.reflowSegmentCount == 3)

    let width = mathList.reflowSegments().lazy.map(\.width).reduce(0, +)
    #expect(width.isApproximatelyEqual(to: mathList.width))
  }
}
