import Foundation
import Testing

@testable import SwiftRohan

class MathLayoutTestsBase {
  internal var folderName: String { "\(Swift.type(of: self))" }

  internal let font: Font
  internal let table: MathTable
  internal let context: MathContext

  init(mathFont: String = "STIX Two Math", createFolder: Bool = false) throws {
    self.font = Font.createWithName(mathFont, 10, isFlipped: true)
    self.table = font.copyMathTable()!
    self.context = MathContext(font, .text, false, .black)!
    if createFolder {
      try TestUtils.touchDirectory(folderName)
    }
  }

  func createGlyphFragment(
    _ char: Character, styled: Bool = true, context: MathContext? = nil
  ) -> MathGlyphLayoutFragment? {
    let newChar =
      styled
      ? MathUtils.styledChar(
        for: char, variant: .serif, bold: false, italic: nil, autoItalic: true)
      : char

    let context = context ?? self.context
    let font = context.getFont()
    let table = context.table

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
    let fragments = string.compactMap { createGlyphFragment($0, context: context) }
    guard fragments.count == string.count else {
      Issue.record("Failed to create MathListLayoutFragment")
      return nil
    }
    let mathList = MathListLayoutFragment(context)
    mathList.beginEditing()
    mathList.insert(contentsOf: fragments, at: 0)
    mathList.endEditing()
    mathList.fixLayout(context)
    return mathList
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
