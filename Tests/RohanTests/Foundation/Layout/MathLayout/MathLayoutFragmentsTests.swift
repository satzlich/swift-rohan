// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct MathLayoutFragmentsTests {

  private var folderName: String { "\(Swift.type(of: self))" }

  private let font: Font
  private let table: MathTable
  private let context: MathContext

  init() throws {
    self.font = Font.createWithName("Latin Modern Math", 12, isFlipped: true)
    self.table = font.copyMathTable()!
    self.context = MathContext(font, .display, false, .black)!
    try TestUtils.touchDirectory(folderName)
  }

  @Test
  func accent() {
    var fragments: Array<MathLayoutFragment> = []

    guard let accent = createAccentFragment("x", MathAccent.acute, font, table, context),
      let accent2 =
        createAccentFragment("x", MathAccent.underleftarrow, font, table, context),
      let unresolved =
        createAccentFragment("x", MathAccent("_unresolved", "碐"), font, table, context)
    else {
      Issue.record("Failed to create nucleus fragment")
      return
    }

    fragments.append(accent)
    fragments.append(accent2)
    fragments.append(unresolved)

    // more methods
    do {
      let point = CGPoint(x: 1, y: 2)
      _ = accent.getMathIndex(interactingAt: point)
      _ = accent.rayshoot(from: point, .nuc, in: .up)
      _ = accent.rayshoot(from: point, .nuc, in: .down)
    }

    for fragment in fragments {
      callStandardMethods(fragment, fileName: #function)
    }
  }

  @Test
  func attachments() {
    let scriptContext = context.with(mathStyle: .script)
    guard let nucleus = createMathListFragment("x", context),
      let sub = createMathListFragment("3", scriptContext),
      let sup = createMathListFragment("2", scriptContext),
      let lsub = createMathListFragment("4", scriptContext),
      let lsup = createMathListFragment("5", scriptContext)
    else {
      Issue.record("Failed to create nucleus/sub/sup fragment")
      return
    }
    let attach = MathAttachLayoutFragment(
      nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
    attach.fixLayout(context)

    //
    callStandardMethods(attach, fileName: #function)
  }

  @Test
  func mathAttributes() {
    guard let nucleus = createMathListFragment("x", context)
    else {
      Issue.record("Failed to create nucleus fragment")
      return
    }
    let attributes = MathAttributesLayoutFragment(nucleus, attributes: .mathop)
    attributes.fixLayout(context)

    //
    callStandardMethods(attributes, fileName: #function)
  }

  @Test
  func fractions() {
    var fragments: Array<MathLayoutFragment> = []

    guard
      let fraction1 = createFractionFragment("x", "y", .frac, font, table, context),
      let fraction2 = createFractionFragment("x", "y", .binom, font, table, context),
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

    for fragment in fragments {
      callStandardMethods(fragment, fileName: #function)
    }
  }

  @Test
  func glyphsAndVariants() {
    var fragments: Array<MathLayoutFragment> = []

    guard let glyph = createGlyphFragment("(", font, table)
    else {
      Issue.record("Failed to create glyph fragment")
      return
    }
    fragments.append(glyph)

    //
    let stretched = glyph.glyph.stretch(
      orientation: .vertical, target: 60, shortfall: 2, context)
    let variant = MathGlyphVariantLayoutFragment(stretched, glyph.layoutLength)
    fragments.append(variant)

    //
    for fragment in fragments {
      callStandardMethods(fragment, fileName: #function)
    }
  }

  @Test
  func leftRight() {
    guard let nucleus = createMathListFragment("x", context)
    else {
      Issue.record("Failed to create nucleus fragment")
      return
    }
    let leftRight = MathLeftRightLayoutFragment(DelimiterPair.BRACE, nucleus)
    leftRight.fixLayout(context)

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

    // standard methods
    callStandardMethods(leftRight, fileName: #function)
  }

  @Test
  func mathList() {
    guard let list = createMathListFragment("x", context)
    else {
      Issue.record("Failed to create math list fragment")
      return
    }

    // standard methods
    callStandardMethods(list, fileName: #function)
  }

  @Test
  func matrix() {
    guard let a = createMathListFragment("x", context),
      let b = createMathListFragment("y", context),
      let c = createMathListFragment("z", context),
      let d = createMathListFragment("w", context)
    else {
      Issue.record("Failed to create matrix elements")
      return
    }
    let matrix = MathArrayLayoutFragment(
      rowCount: 2, columnCount: 2, subtype: MathArray.cases, context)
    matrix.setElement(0, 0, a)
    matrix.setElement(0, 1, b)
    matrix.setElement(1, 0, c)
    matrix.setElement(1, 1, d)
    matrix.fixLayout(context)

    //
    callStandardMethods(matrix, fileName: #function)
  }

  @Test
  func mathOperator() {
    let node = MathOperatorNode(MathOperator.min)
    let styleSheet = StyleSheetTests.sampleStyleSheet()
    let mathContext = MathUtils.resolveMathContext(for: node, styleSheet)
    let mathOp = MathOperatorLayoutFragment(node, styleSheet, mathContext)
    mathOp.fixLayout(context)

    //
    callStandardMethods(mathOp, fileName: #function)
  }

  @Test
  func radicals() {
    var fragments: Array<MathLayoutFragment> = []

    guard let radicand = createMathListFragment("x", context),
      let index = createMathListFragment("2", context)
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
    //
    for fragment in fragments {
      callStandardMethods(fragment, fileName: #function)
    }
  }

  @Test
  func underOver() {
    var fragments: Array<MathLayoutFragment> = []

    for spreader in [MathSpreader.underline, .overline, .underbrace, .overbrace] {
      let nucleus = createMathListFragment("x", context)!
      let overspreader = MathUnderOverLayoutFragment(spreader, nucleus)
      overspreader.fixLayout(context)
      fragments.append(overspreader)
    }

    //
    for fragment in fragments {
      callStandardMethods(fragment, fileName: #function)
    }
  }

  @Test
  func textMode() {
    let attrString = NSMutableAttributedString(string: "x")
    let ctLine = CTLineCreateWithAttributedString(attrString)
    let textLine = CTLineLayoutFragment(
      attrString, ctLine, .textMode, .typographicBounds)
    let textMode = TextModeNode._NodeFragment(textLine)
    textMode.fixLayout(context)

    //
    callStandardMethods(textMode, fileName: #function)
  }

  @Test
  func mathFragmentWrapper() {
    let glyphFragment: GlyphFragment = GlyphFragment(char: "x", font, table)!
    let wrapper = MathFragmentWrapper(glyphFragment, 1)

    // the use of wrapper here is for test only. GlyphFragment should be used together
    // with MathGlyphLayoutFragment.

    //
    callStandardMethods(wrapper, fileName: #function)
  }

  // MARK: - More Tests

  @Test
  func moreAttachments() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let table = font.copyMathTable(),
      let context = MathContext(font, .display, false, .blue)
    else {
      Issue.record("Failed to create math table or MathContext")
      return
    }

    func create(
      _ nucleus: String, _ attachments: Array<MathIndex>
    ) -> MathAttachLayoutFragment? {
      guard let nucleus = createMathListFragment(nucleus, context)
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
          lsub = createMathListFragment("4", context)
        case .lsup:
          lsup = createMathListFragment("5", context)
        case .sub:
          sub = createMathListFragment("3", context)
        case .sup:
          sup = createMathListFragment("2", context)
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

    let attachments: Array<MathIndex> = [.lsub, .lsup, .sub, .sup]
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
  func moreMatrix() {
    let font = Font.createWithName("STIX Two Math", 12)
    guard let table = font.copyMathTable(),
      let context = MathContext(font, .display, false, .blue)
    else {
      Issue.record("Failed to create math table or MathContext")
      return
    }

    guard let x = createMathListFragment("x", context),
      let y = createMathListFragment("y", context),
      let z = createMathListFragment("z", context),
      let w = createMathListFragment("w", context)
    else {
      Issue.record("Failed to create matrix elements")
      return
    }

    let matrix = MathArrayLayoutFragment(
      rowCount: 2, columnCount: 2, subtype: MathArray.cases, context)
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

    var xs: Array<CGFloat> = []
    var ys: Array<CGFloat> = []

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

  // MARK: - Helper

  private func callStandardMethods(_ fragment: MathLayoutFragment, fileName: String) {
    Self.callStandardMethods(fragment, context)

    let size = CGSize(width: 180, height: 240)
    TestUtils.outputPDF(folderName: folderName, fileName, size) { rect in
      guard let context = NSGraphicsContext.current?.cgContext else { return }
      let point = CGPoint(x: rect.width / 2, y: rect.height / 2)
      fragment.draw(at: point, in: context)
    }
  }

  /// Call standard methods on the fragment.
  internal static func callStandardMethods(
    _ fragment: MathLayoutFragment, _ context: MathContext
  ) {
    // protocol methods
    _ = fragment.layoutLength
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
    _ = fragment.debugPrint("test")

    // extension
    _ = fragment.minX
    _ = fragment.midX
    _ = fragment.maxX
    _ = fragment.minY
    _ = fragment.midY
    _ = fragment.maxY
    _ = fragment.boxDescription

    for corner in Corner.allCases {
      _ = fragment.kernAtHeight(context, corner, 10)
    }
  }

  private func createGlyphFragment(
    _ char: Character, _ font: Font, _ table: MathTable
  ) -> MathGlyphLayoutFragment? {
    let styled =
      MathUtils.styledChar(
        for: char, variant: .serif, bold: false, italic: nil, autoItalic: true)
    guard let glyph = MathGlyphLayoutFragment(char: styled, font, table, char.length)
    else {
      Issue.record("Failed to create MathGlyphLayoutFragment")
      return nil
    }
    return glyph
  }

  private func createMathListFragment(
    _ string: String, _ context: MathContext
  ) -> MathListLayoutFragment? {
    let font = context.getFont()
    let table = context.table
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
    _ num: String, _ denom: String, _ subtype: MathGenFrac,
    _ font: Font, _ table: MathTable, _ context: MathContext
  ) -> MathFractionLayoutFragment? {
    guard let num = createMathListFragment(num, context),
      let denom = createMathListFragment(denom, context)
    else {
      Issue.record("Failed to create MathFractionLayoutFragment")
      return nil
    }
    let fraction = MathFractionLayoutFragment(num, denom, subtype)
    fraction.fixLayout(context)
    return fraction
  }

  private func createAccentFragment(
    _ nucleus: String, _ accent: MathAccent, _ font: Font, _ table: MathTable,
    _ context: MathContext
  ) -> MathAccentLayoutFragment? {
    guard let nucleus = createMathListFragment("x", context)
    else {
      Issue.record("Failed to create nucleus fragment")
      return nil
    }
    let accent = MathAccentLayoutFragment(accent, nucleus: nucleus)
    accent.fixLayout(context)
    return accent
  }
}
