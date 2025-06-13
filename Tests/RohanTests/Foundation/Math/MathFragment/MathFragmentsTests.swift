// Copyright 2024-2025 Lie Yan

import AppKit
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct MathFragmentsTests {

  private var folderName: String { "\(Swift.type(of: self))" }

  init() throws {
    try TestUtils.touchDirectory(folderName)
  }

  @Test
  func coverage() {
    var fragments: [MathFragment] = []

    do {
      let font = Font.createWithName("STIX Two Math", 12, isFlipped: true)
      let mathTable = font.copyMathTable()!

      // glyph
      let glyph = GlyphFragment("(", font, mathTable)!
      fragments.append(glyph)

      // translated
      let translated = TranslatedFragment(source: glyph, shiftDown: 7.0)
      fragments.append(translated)

      // variant
      let mathContext = MathContext(font, .display, false, .blue)!
      let variant = glyph.stretch(
        orientation: .vertical, target: 60, shortfall: 2, mathContext)
      fragments.append(variant)

      // fragment
      let composition = MathComposition.createHorizontal([glyph, variant])
      let frame = FrameFragment(composition)
      fragments.append(frame)

      // rule
      let rule = RuleFragment(width: 10, height: 1)
      fragments.append(rule)

      // colored
      let colored = ColoredFragment(color: .red, wrapped: rule)
      fragments.append(colored)

      // composite
      let composite = FragmentCompositeFragment(fragments)
      fragments.append(composite)
    }

    for fragment in fragments {
      //
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
      //
      _ = fragment.bounds
      _ = fragment.boxMetrics
      _ = fragment.isNearlyEqual(to: BoxMetrics(width: 0, ascent: 0, descent: 0))
    }

    let pageSize = CGSize(width: 160, height: 200)

    TestUtils.outputPDF(folderName: folderName, #function, pageSize) { rect in
      guard let context = NSGraphicsContext.current?.cgContext else { return }
      for (i, fragment) in fragments.enumerated() {
        let point = CGPoint(x: Double(i + 1) * 10, y: pageSize.height / 2)
        fragment.draw(at: point, in: context)
      }
    }
  }

  @Test
  func memoryLayoutSize() {
    #expect(MemoryLayout<GlyphFragment>.size == 67)
    #expect(MemoryLayout<VariantFragment>.size == 84)
  }

  @Test
  func glyphFragment() {
    let font = Font.createWithName("Latin Modern Math", 12, isFlipped: true)
    let mathTable = font.copyMathTable()!

    let chars: [UnicodeScalar] = ["+", "<", "f", "p", "∫", "∑"]
    let expected = [
      "(12, 9.34×(7.00+1.00), ic: 0.00, ac: 4.67, Vary, never)",
      "(29, 9.34×(6.67+0.67), ic: 0.00, ac: 4.67, Relation, never)",
      "(71, 4.62×(8.46+0.00), ic: 0.95, ac: 3.14, Alphabetic, never)",
      "(81, 6.67×(5.30+2.33), ic: 0.00, ac: 2.42, Alphabetic, never)",
      "(3049, 7.98×(9.66+3.67), ic: 3.98, ac: 5.98, Large, never)",
      "(3060, 12.67×(9.00+3.00), ic: 0.00, ac: 6.34, Large, display)",
    ]
    for (i, char) in chars.enumerated() {
      let fragment = GlyphFragment(char, font, mathTable)!
      #expect(fragment.description == expected[i])
    }

    // nil
    #expect(nil == GlyphFragment(char: "नि", font, mathTable))
  }
}
