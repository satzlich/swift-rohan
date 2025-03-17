// Copyright 2024-2025 Lie Yan

import AppKit
import CoreText
import Foundation
import Testing

@testable import Rohan

struct MathFragmentTests {
  @Test
  static func testMemoryLayoutSize() {
    #expect(MemoryLayout<GlyphFragment>.size == 67)
    #expect(MemoryLayout<VariantFragment>.size == 84)
  }

  @Test
  static func testGlyphFragment() {
    let font = Font.createWithName("Latin Modern Math", 12, isFlipped: true)
    let mathTable = font.copyMathTable()!

    let chars: [UnicodeScalar] = ["+", "<", "f", "p", "∫", "∑"]
    let expected = [
      "(12, 9.34×(7.00+1.00), ic: 0.00, ac: 4.67, Vary, never)",
      "(29, 9.34×(6.67+0.67), ic: 0.00, ac: 4.67, Relation, always)",
      "(71, 3.67×(8.46+0.00), ic: 0.95, ac: 3.14, Alphabetic, never)",
      "(81, 6.67×(5.30+2.33), ic: 0.00, ac: 2.42, Alphabetic, never)",
      "(3049, 7.98×(9.66+3.67), ic: 3.98, ac: 3.99, Large, never)",
      "(3060, 12.67×(9.00+3.00), ic: 0.00, ac: 6.34, Large, display)",
    ]
    for (i, char) in chars.enumerated() {
      let fragment = GlyphFragment(char, font, mathTable)!
      #expect(fragment.description == expected[i])
    }
  }

  static let mathFonts: [String] = [
    "Asana Math",
    "Concrete Math",
    "Euler Math",
    "Fira Math",
    "Latin Modern Math",
    "Libertinus Math",
    "NewComputerModernMath",
    "NewComputerModernSansMath",
    "STIX Two Math",
  ]

  @Test
  static func testVariantFragment() {
    let filePath = TestUtils.filePath(#function.dropLast(2) + ".pdf")!

    let width = 300
    let height = 200
    let pageSize = CGSize(width: width, height: height * mathFonts.count)

    func box(_ i: Int) -> CGRect {
      CGRect(x: 0, y: i * height, width: width, height: height)
    }

    DrawUtils.drawPDF(filePath: filePath, pageSize: pageSize, isFlipped: true) { bounds in
      guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
      for (i, font) in mathFonts.enumerated() {
        cgContext.saveGState()
        Self.drawSample(font, box(i), cgContext)
        cgContext.restoreGState()
      }
    }
  }

  static func drawSample(_ fontName: String, _ bounds: CGRect, _ cgContext: CGContext) {
    // Create math context
    let fontSize = 12.0
    let font = Font.createWithName(fontName, fontSize, isFlipped: true)
    let mathContext = MathContext(font, .display, Color.black)!

    // Reset text matrix
    cgContext.textMatrix = .identity

    // Define characters
    let smallX: UnicodeScalar = MathUtils.styledChar(
      for: "x", variant: .serif,
      bold: false, italic: nil,
      autoItalic: true)
    let leftBrace: UnicodeScalar = "{"
    let leftCeil: UnicodeScalar = "⌈"
    let circumflex: UnicodeScalar = "\u{0302}"
    let topBrace: UnicodeScalar = "\u{23de}"

    let originX = bounds.origin.x
    let originY = bounds.origin.y

    // draw font name
    do {
      let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: fontName, size: fontSize, isFlipped: true)!
      ]
      let fontName = NSAttributedString(string: fontName, attributes: attributes)
      fontName.draw(at: CGPoint(x: originX + 5, y: originY + 15))
    }

    // draw rect for bounds
    cgContext.saveGState()
    cgContext.setStrokeColor(NSColor.black.withAlphaComponent(0.05).cgColor)
    cgContext.stroke(bounds)
    cgContext.restoreGState()

    cgContext.textMatrix = .identity
    Self.createAndDrawVariants(
      mathContext, leftBrace, smallX, .vertical,
      CGPoint(x: originX + 5, y: originY + 77),
      [10, 30, 50, 70, 90],
      cgContext)
    Self.createAndDrawVariants(
      mathContext, leftCeil, smallX, .vertical,
      CGPoint(x: originX + 85, y: originY + 77),
      [10, 30, 50, 70, 90],
      cgContext)

    Self.createAndDrawVariants(
      mathContext, circumflex, smallX, .horizontal,
      CGPoint(x: originX + 215, y: originY + 77),
      [10, 14, 18, 22, 26],
      cgContext)
    Self.createAndDrawVariants(
      mathContext, topBrace, smallX, .horizontal,
      CGPoint(x: originX + 215, y: originY + 177),
      [10, 30, 50, 70, 90],
      cgContext)
  }

  static func createAndDrawVariants(
    _ mathContext: MathContext,
    _ char: UnicodeScalar,
    _ refChar: UnicodeScalar,
    _ orientation: TextOrientation,
    _ point: CGPoint,
    _ lengths: [CGFloat],
    _ cgContext: CGContext
  ) {
    let font = mathContext.getFont()
    let table = mathContext.table

    let styledChar = MathUtils.styledChar(
      for: refChar, variant: .serif, bold: false, italic: nil, autoItalic: true)
    let refChar_ = GlyphFragment(styledChar, font, table)!

    let char_ = GlyphFragment(char, font, table)!
    let variants = lengths.map { length in
      MathUtils.stretchGlyph(
        char_, orientation: orientation, target: length, shortfall: 2,
        context: mathContext)
    }

    if orientation == .vertical {
      refChar_.draw(at: point, in: cgContext)

      for (i, variant) in ([char_] + variants).enumerated() {
        let position = CGPoint(x: point.x + CGFloat(i + 1) * 10.0, y: point.y)
        variant.draw(at: position, in: cgContext)
      }
    }
    else {
      assert(orientation == .horizontal)
      let accent = char_
      let nucleus = refChar_

      nucleus.draw(at: point, in: cgContext)

      func xPos(_ accent: MathFragment) -> CGFloat {
        -accent.accentAttachment + nucleus.accentAttachment
      }

      for (i, variant) in ([accent] + variants).enumerated() {
        let position = CGPoint(x: point.x + xPos(variant), y: point.y - CGFloat(i) * 10.0)
        variant.draw(at: position, in: cgContext)
      }
    }
  }
}
