// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing
import UnicodeMathClass

@testable import SwiftRohan

struct MathUtilsTests {
  @Test
  func fractionStyle() {
    for style in MathStyle.allCases {
      _ = MathUtils.fractionStyle(for: style)
    }
  }

  @Test
  func scriptStyle() {
    for style in MathStyle.allCases {
      _ = MathUtils.scriptStyle(for: style)
    }
  }

  @Test
  func matrixStyle() {
    for style in MathStyle.allCases {
      _ = MathUtils.matrixStyle(for: style)
    }
  }

  @Test
  func resolveSpacing() {
    let classPairs = product(MathClass.allCases, MathClass.allCases)

    for ((lhs, rhs), style) in product(classPairs, MathStyle.allCases) {
      _ = MathUtils.resolveSpacing(lhs, rhs, style)
    }
  }

  @Test
  func stretchAxis() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let mathTable = font.copyMathTable()
    else {
      Issue.record("Failed to copy math table")
      return
    }

    do {
      guard let glyph = font.getGlyph(for: "(" as Character)
      else {
        Issue.record("Failed to get glyph for '('")
        return
      }
      let stretchAxis = MathUtils.stretchAxis(for: glyph, mathTable)
      #expect(stretchAxis == .vertical)
    }

    do {
      let char = Characters.overBrace
      guard let glyph = font.getGlyph(for: char)
      else {
        Issue.record("Failed to get glyph for '\(char)'")
        return
      }
      let stretchAxis = MathUtils.stretchAxis(for: glyph, mathTable)
      #expect(stretchAxis == .horizontal)
    }
  }

  @Test
  func styledChar() {
    let latin = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let latinComplement = "ħıȷ"
    let greek = "αβγδεζηθικλμνξοπρστυφχψωΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ"
    let greekComplement = "Ϝϝϴ∇∂ϵϑϰϕϱϖ"
    let hebrew = "\u{05D0}"
    let digits = "0123456789"
    let other = "〈〉《》"
    let chars =
      latin + latinComplement + greek + greekComplement + hebrew + digits + other

    for char in chars {  // 100+
      for variant in MathVariant.allCases {  // 10-
        for bold in [false, true] {  // 2
          for italic in [false, true] {  // 2
            _ = MathUtils.styledChar(
              for: char, variant: variant, bold: bold, italic: italic, autoItalic: false)
          }
        }
      }
    }
  }
}
