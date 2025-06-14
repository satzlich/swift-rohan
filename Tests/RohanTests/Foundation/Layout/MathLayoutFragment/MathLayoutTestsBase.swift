// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

class MathLayoutTestsBase {
  internal var folderName: String { "\(Swift.type(of: self))" }

  internal let font: Font
  internal let table: MathTable
  internal let context: MathContext

  init() throws {
    self.font = Font.createWithName("STIX Two Math", 10, isFlipped: true)
    self.table = font.copyMathTable()!
    self.context = MathContext(font, .text, false, .black)!
    try TestUtils.touchDirectory(folderName)
  }

  func createGlyphFragment(
    _ char: Character, styled: Bool = true
  ) -> MathGlyphLayoutFragment? {
    let newChar =
      styled
      ? MathUtils.styledChar(
        for: char, variant: .serif, bold: false, italic: nil, autoItalic: true)
      : char
    guard let glyph = MathGlyphLayoutFragment(char: newChar, font, table, char.length)
    else {
      Issue.record("Failed to create MathGlyphLayoutFragment")
      return nil
    }
    return glyph
  }

  func createMathListFragment(
    _ string: String, _ context: MathContext? = nil
  ) -> MathListLayoutFragment? {
    let context = context ?? self.context
    let fragments = string.compactMap { createGlyphFragment($0) }
    guard fragments.count == string.count else {
      Issue.record("Failed to create MathListLayoutFragment")
      return nil
    }
    let list = MathListLayoutFragment(context)
    list.beginEditing()
    list.insert(contentsOf: fragments, at: 0)
    list.endEditing()
    list.fixLayout(context)
    return list
  }

  func createFractionFragment(
    _ num: String, _ denom: String, _ subtype: MathGenFrac
  ) -> MathFractionLayoutFragment? {
    guard let num = createMathListFragment(num),
      let denom = createMathListFragment(denom)
    else {
      Issue.record("Failed to create MathFractionLayoutFragment")
      return nil
    }
    let fraction = MathFractionLayoutFragment(num, denom, subtype)
    fraction.fixLayout(context)
    return fraction
  }

  func createAccentFragment(
    _ nucleus: String, _ accent: MathAccent
  ) -> MathAccentLayoutFragment? {
    guard let nucleus = createMathListFragment(nucleus) else {
      Issue.record("Failed to create nucleus fragment")
      return nil
    }
    let accent = MathAccentLayoutFragment(accent, nucleus: nucleus)
    accent.fixLayout(context)
    return accent
  }
}
