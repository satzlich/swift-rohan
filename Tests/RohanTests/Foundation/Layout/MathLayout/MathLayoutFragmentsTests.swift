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

      // more methods
      do {
        let point = CGPoint(x: 1, y: 2)
        _ = accent.getMathIndex(interactingAt: point)
        _ = accent.rayshoot(from: point, .nuc, in: .up)
        _ = accent.rayshoot(from: point, .nuc, in: .down)
      }
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
        let denom = createMathListFragment("y", font, table, context),
        let denom2 = createMathListFragment("", font, table, context)
      else {
        Issue.record("Failed to create num/denom fragment")
        return
      }
      let fraction1 = MathFractionLayoutFragment(num, denom)
      fragments.append(fraction1)

      let fraction2 = MathFractionLayoutFragment(num, denom2)
      fragments.append(fraction2)

      // more methods
      for fraction in [fraction1, fraction2] {
        let point = CGPoint(x: 1, y: 2)
        _ = fraction.getMathIndex(interactingAt: point)
        _ = fraction.rayshoot(from: point, .num, in: .up)
        _ = fraction.rayshoot(from: point, .num, in: .down)
        _ = fraction.rayshoot(from: point, .denom, in: .up)
        _ = fraction.rayshoot(from: point, .denom, in: .down)
      }
    }

    // glyph, glyph variant
    do {
      guard let glyph = createGlyphFragment("(", font, table)
      else {
        Issue.record("Failed to create glyph fragment")
        return
      }
      fragments.append(glyph)

      //
      let stretched = glyph.glyph.stretchVertical(60, shortfall: 2, context)
      let variant = MathGlyphVariantLayoutFragment(stretched, glyph.layoutLength)
      fragments.append(variant)
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

      // more methods
      do {
        let point1 = CGPoint(x: leftRight.nucleus.minX - 0.5, y: 0)
        let point2 = CGPoint(x: leftRight.nucleus.maxX + 0.5, y: 0)
        let point3 = CGPoint(x: leftRight.nucleus.midX, y: 0)
        for point in [point1, point2, point3] {
          _ = leftRight.getMathIndex(interactingAt: point)
        }
        _ = leftRight.rayshoot(from: point1, .nuc, in: .up)
        _ = leftRight.rayshoot(from: point1, .nuc, in: .down)
      }
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
      let radical1 = MathRadicalLayoutFragment(radicand, index)
      fragments.append(radical1)

      let radical2 = MathRadicalLayoutFragment(radicand, nil)
      fragments.append(radical2)

      // more methods
      for radical in [radical1, radical2] {
        let point1 = CGPoint(x: radical.radicand.minX - 0.5, y: 0)
        let point2 = CGPoint(x: radical.radicand.midX, y: 0)

        _ = radical.getMathIndex(interactingAt: point1)
        _ = radical.getMathIndex(interactingAt: point2)
        _ = radical.rayshoot(from: point1, .radicand, in: .up)
        _ = radical.rayshoot(from: point1, .radicand, in: .down)
      }
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
      fragments.append(textLine)
      //
      let textMode = TextModeLayoutFragment(textLine)
      fragments.append(textMode)
    }

    for fragment in fragments {
      fragment.setGlyphOrigin(CGPoint(x: 10, y: 0))
      fragment.fixLayout(context)
      _ = fragment.width
      _ = fragment.height
      _ = fragment.ascent
      _ = fragment.descent
      _ = fragment.italicsCorrection
      _ = fragment.accentAttachment
      _ = fragment.clazz
      _ = fragment.limits
      _ = fragment.isSpaced
      _ = fragment.isTextLike
      _ = fragment.debugPrint()
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
