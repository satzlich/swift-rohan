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
      let accent = MathAccentLayoutFragment(accent: Chars.dotAbove, nucleus: nucleus)
      accent.fixLayout(context)
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
      attach.fixLayout(context)
      fragments.append(attach)
    }

    // fraction
    do {
      guard
        let fraction1 = createFractionFragment("x", "y", .fraction, font, table, context),
        let fraction2 = createFractionFragment("x", "y", .binomial, font, table, context),
        // pass intentionally empty denominator
        let fraction3 = createFractionFragment("x", "", .atop, font, table, context)
      else {
        Issue.record("Failed to create fraction fragment")
        return
      }
      fragments.append(fraction1)
      fragments.append(fraction2)
      fragments.append(fraction3)

      // more methods
      for fraction in [fraction1, fraction2, fraction3] {
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
      leftRight.fixLayout(context)
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
        rowCount: 2, columnCount: 2, subtype: .cases, DelimiterPair.PAREN, context)
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
      mathOp.fixLayout(context)
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
      radical1.fixLayout(context)
      fragments.append(radical1)

      let radical2 = MathRadicalLayoutFragment(radicand, nil)
      radical2.fixLayout(context)
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
      overline.fixLayout(context)
      fragments.append(overline)
    }

    // under/over-spreader
    do {
      guard let nucleus = createMathListFragment("x", font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return
      }
      let overspreader =
        MathUnderOverspreaderLayoutFragment(.over, Chars.overBrace, nucleus)
      overspreader.fixLayout(context)
      fragments.append(overspreader)
    }

    // text mode
    do {
      let attrString = NSMutableAttributedString(string: "x")
      let ctLine = CTLineCreateWithAttributedString(attrString)
      let textLine = TextLineLayoutFragment(attrString, ctLine)
      textLine.fixLayout(context)
      fragments.append(textLine)
      //
      let textMode = TextModeLayoutFragment(textLine)
      textMode.fixLayout(context)
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

  @Test
  func coverage_Attach() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let table = font.copyMathTable(),
      let context = MathContext(font, .display, false, .blue)
    else {
      Issue.record("Failed to create math table or MathContext")
      return
    }

    func create(
      _ nucleus: String, _ attachments: [MathIndex]
    ) -> MathAttachLayoutFragment? {
      guard let nucleus = createMathListFragment(nucleus, font, table, context)
      else {
        Issue.record("Failed to create nucleus fragment")
        return nil
      }

      var lsub: MathListLayoutFragment?
      var lsup: MathListLayoutFragment?
      var sub: MathListLayoutFragment?
      var sup: MathListLayoutFragment?

      for index in attachments {
        switch index {
        case .lsub:
          lsub = createMathListFragment("4", font, table, context)
        case .lsup:
          lsup = createMathListFragment("5", font, table, context)
        case .sub:
          sub = createMathListFragment("3", font, table, context)
        case .sup:
          sup = createMathListFragment("2", font, table, context)
        default:
          Issue.record("Invalid attachment index")
          return nil
        }
      }

      let attach = MathAttachLayoutFragment(
        nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
      attach.fixLayout(context)
      return attach
    }

    let attachments: [MathIndex] = [.lsub, .lsup, .sub, .sup]
    let attachNodes = attachments.combinations(ofCount: 1...4).flatMap { combination in
      let attach1 = create("x", combination)
      let attach2 = create("\u{220F}", combination)
      return [attach1, attach2]
    }
    .compactMap { $0 }

    for attach in attachNodes {
      let components = [attach.nucleus, attach.lsub, attach.lsup, attach.sub, attach.sup]
        .compactMap { $0 }
      let xs = components.flatMap { [$0.minX - 0.5, $0.midX, $0.maxX + 0.5] }
      let ys = components.flatMap { [$0.minY - 0.5, $0.midY, $0.maxY + 0.5] }

      for (x, y) in product(xs, ys) {
        let point = CGPoint(x: x, y: y)
        _ = attach.getMathIndex(interactingAt: point)
        for index in [MathIndex.nuc, .sub, .sup, .lsub, .lsup] {
          _ = attach.rayshoot(from: point, index, in: .up)
          _ = attach.rayshoot(from: point, index, in: .down)
        }
      }
    }
  }

  @Test
  func coverage_Matrix() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let table = font.copyMathTable(),
      let context = MathContext(font, .display, false, .blue)
    else {
      Issue.record("Failed to create math table or MathContext")
      return
    }

    guard let x = createMathListFragment("x", font, table, context),
      let y = createMathListFragment("y", font, table, context),
      let z = createMathListFragment("z", font, table, context),
      let w = createMathListFragment("w", font, table, context)
    else {
      Issue.record("Failed to create matrix elements")
      return
    }

    let matrix = MathMatrixLayoutFragment(
      rowCount: 2, columnCount: 2, subtype: .cases, DelimiterPair.PAREN, context)
    matrix.setElement(0, 0, x)
    matrix.setElement(0, 1, y)
    matrix.setElement(1, 0, z)
    matrix.setElement(1, 1, w)
    matrix.fixLayout(context)

    do {
      matrix.insertRow(at: 1)
      matrix.insertColumn(at: 1)
      matrix.removeRow(at: 1)
      matrix.removeColumn(at: 1)
    }

    var xs: [CGFloat] = []
    var ys: [CGFloat] = []

    xs.append(contentsOf: [matrix.minX - 0.5, matrix.midX, matrix.maxX + 0.5])
    ys.append(contentsOf: [matrix.minY - 0.5, matrix.midY, matrix.maxY + 0.5])
    for i in 0..<matrix.rowCount {
      for j in 0..<matrix.columnCount {
        let element = matrix.getElement(i, j)
        xs.append(contentsOf: [element.minX - 0.5, element.midX, element.maxX + 0.5])
        ys.append(contentsOf: [element.minY - 0.5, element.midY, element.maxY + 0.5])
      }
    }

    for (x, y) in product(xs, ys) {
      let point = CGPoint(x: x, y: y)
      _ = matrix.getGridIndex(interactingAt: point)
      for i in 0..<matrix.rowCount {
        for j in 0..<matrix.columnCount {
          _ = matrix.rayshoot(from: point, GridIndex(i, j), in: .up)
          _ = matrix.rayshoot(from: point, GridIndex(i, j), in: .down)
        }
      }
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
    list.fixLayout(context)
    return list
  }

  private func createFractionFragment(
    _ num: String, _ denom: String, _ subtype: MathFractionLayoutFragment.Subtype,
    _ font: Font, _ table: MathTable, _ context: MathContext
  ) -> MathFractionLayoutFragment? {
    guard let num = createMathListFragment(num, font, table, context),
      let denom = createMathListFragment(denom, font, table, context)
    else {
      Issue.record("Failed to create MathFractionLayoutFragment")
      return nil
    }
    let fraction = MathFractionLayoutFragment(num, denom, subtype)
    fraction.fixLayout(context)
    return fraction
  }
}
