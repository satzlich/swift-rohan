// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct MathLayoutFragmentsTests {
  @Test
  func coverage() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let table = font.copyMathTable(),
      let context = MathContext(font, .display, false, .blue)
    else {
      Issue.record("Failed to create math table or MathContext")
      return
    }

    var fragments: [MathLayoutFragment] = []

    // accent
    do {
      guard let nucleus = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }
      let accent = MathAccentLayoutFragment(accent: Characters.dotAbove, nucleus: nucleus)
      fragments.append(accent)
    }

    // attach
    do {
      guard let nucleus = createMathListFragment("x", font, table, context),
        let sub = createMathListFragment("3", font, table, context),
        let sup = createMathListFragment("2", font, table, context),
        let lsub = createMathListFragment("4", font, table, context),
        let lsup = createMathListFragment("5", font, table, context)
      else {
        Issue.record("Failed to create nucleus/sub/sup fragment")
        return
      }
      let attach = MathAttachLayoutFragment(
        nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
      fragments.append(attach)
    }

    // fraction
    do {
      guard let num = createMathListFragment("x", font, table, context),
        let denom = createMathListFragment("y", font, table, context)
      else {
        Issue.record("Failed to create num/denom fragment")
        return
      }
      let fraction = MathFractionLayoutFragment(num, denom)
      fragments.append(fraction)
    }

    // glyph
    do {
      guard let glyph = createGlyphFragment("a", font, table)
      else {
        Issue.record("Failed to create glyph fragment")
        return
      }
      fragments.append(glyph)
    }

    // left-right
    do {
      guard let nucleus = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }
      let leftRight = MathLeftRightLayoutFragment(DelimiterPair.BRACE, nucleus)
      fragments.append(leftRight)
    }

    // math list
    do {
      guard let list = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create math list fragment")
        return
      }
      fragments.append(list)
    }

    // matrix
    do {
      guard let a = createMathListFragment("x", font, table, context),
        let b = createMathListFragment("y", font, table, context),
        let c = createMathListFragment("z", font, table, context),
        let d = createMathListFragment("w", font, table, context)
      else {
        Issue.record("Failed to create matrix elements")
        return
      }
      let matrix = MathMatrixLayoutFragment(
        rowCount: 2, columnCount: 2, DelimiterPair.PAREN,
        FixedColumnAlignmentProvider(.start), DefaultColumnGapProvider.self, context)
      matrix.setElement(0, 0, a)
      matrix.setElement(0, 1, b)
      matrix.setElement(1, 0, c)
      matrix.setElement(1, 1, d)
      matrix.fixLayout(context)

      fragments.append(matrix)
    }

    // operator
    do {
      guard let content = createMathListFragment("min", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }

      let mathOp = MathOperatorLayoutFragment(content, false)
      fragments.append(mathOp)
    }

    // radical
    do {
      guard let radicand = createMathListFragment("x", font, table, context),
        let index = createMathListFragment("2", font, table, context)
      else {
        Issue.record("Failed to create radicand/index fragment")
        return
      }
      let radical = MathRadicalLayoutFragment(radicand, index)
      fragments.append(radical)
    }

    // under/over-line
    do {
      guard let nucleus = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }
      let overline = MathUnderOverlineLayoutFragment(.over, nucleus)
      fragments.append(overline)
    }

    // under/over-spreader
    do {
      guard let nucleus = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }
      let overspreader = MathUnderOverspreaderLayoutFragment(
        .over, Characters.overBrace, nucleus)
      fragments.append(overspreader)
    }

    // text mode
    do {
      let attrString = NSMutableAttributedString(string: "x")
      let ctLine = CTLineCreateWithAttributedString(attrString)
      let textLine = TextLineLayoutFragment(attrString, ctLine)
      let textMode = TextModeLayoutFragment(textLine)
      fragments.append(textMode)
    }

    for fragment in fragments {

    }
  }

  private func createGlyphFragment(
    _ char: Character, _ font: Font, _ table: MathTable
  ) -> MathGlyphLayoutFragment? {
    guard let glyph = MathGlyphLayoutFragment(char, font, table, char.length)
    else {
      Issue.record("Failed to create MathGlyphLayoutFragment")
      return nil
    }
    return glyph
  }

  private func createMathListFragment(
    _ string: String, _ font: Font, _ table: MathTable, _ context: MathContext
  ) -> MathListLayoutFragment? {
    let fragments = string.map { char in createGlyphFragment(char, font, table) }
      .compactMap { $0 }
    guard fragments.count == string.count
    else {
      Issue.record("Failed to create MathListLayoutFragment")
      return nil
    }
    let list = MathListLayoutFragment(context)
    list.beginEditing()
    list.insert(contentsOf: fragments, at: 0)
    list.endEditing()
    return list
  }
}
